package com.animaltracking.backend.controller;

import com.animaltracking.backend.dto.JwtResponse;
import com.animaltracking.backend.dto.LoginRequest;
import com.animaltracking.backend.entity.User;
import com.animaltracking.backend.repository.UserRepository;
import com.animaltracking.backend.security.JwtUtils;
import com.animaltracking.backend.service.EmailService; // 🟢 L'IMPORT QUI MANQUAIT !
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AuthController {

    @Autowired
    AuthenticationManager authenticationManager;

    @Autowired
    UserRepository userRepository;

    @Autowired
    JwtUtils jwtUtils;

    @Autowired
    PasswordEncoder passwordEncoder;

    @Autowired
    EmailService emailService; // 🟢 L'injection qui causait l'erreur "No beans found"

    // ==========================================
    // 1. CONNEXION CLASSIQUE
    // ==========================================
    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@RequestBody LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getUsername(), loginRequest.getPassword()));

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtils.generateJwtToken(authentication);

        Optional<User> userOptional = userRepository.findByUsername(loginRequest.getUsername());

        if (userOptional.isPresent()) {
            User user = userOptional.get();
            return ResponseEntity.ok(new JwtResponse(
                    jwt,
                    Long.valueOf(user.getId()),
                    user.getUsername(),
                    user.getEmailAddress(),
                    user.getFirstName(),
                    user.getLastName(),
                    user.getUserRole().name()
            ));
        }

        return ResponseEntity.badRequest().body("Erreur : Utilisateur introuvable.");
    }

    // ==========================================
    // 2. DEMANDER LE CODE (MOT DE PASSE OUBLIÉ)
    // ==========================================
    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        Optional<User> userOpt = userRepository.findByEmailAddress(email);

        if (userOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("message", "Email introuvable."));
        }

        User user = userOpt.get();
        // Générer un code à 6 chiffres
        String code = String.valueOf((int)(Math.random() * 900000) + 100000);

        user.setResetCode(code);
        user.setResetCodeExpiration(LocalDateTime.now().plusMinutes(15));
        userRepository.save(user);

        // Envoyer le VRAI email
        emailService.sendResetCode(user.getEmailAddress(), code);

        return ResponseEntity.ok(Map.of("message", "Code envoyé avec succès."));
    }

    // ==========================================
    // 3. VÉRIFIER LE CODE
    // ==========================================
    @PostMapping("/verify-code")
    public ResponseEntity<?> verifyCode(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String code = request.get("code");
        Optional<User> userOpt = userRepository.findByEmailAddress(email);

        if (userOpt.isPresent()) {
            User user = userOpt.get();
            // Vérifier que le code correspond ET qu'il n'est pas expiré
            if (code.equals(user.getResetCode()) && user.getResetCodeExpiration() != null && user.getResetCodeExpiration().isAfter(LocalDateTime.now())) {
                return ResponseEntity.ok(Map.of("message", "Code valide."));
            }
        }
        return ResponseEntity.status(400).body(Map.of("message", "Code invalide ou expiré."));
    }

    // ==========================================
    // 4. SAUVEGARDER LE NOUVEAU MOT DE PASSE
    // ==========================================
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String code = request.get("code");
        String newPassword = request.get("newPassword");

        Optional<User> userOpt = userRepository.findByEmailAddress(email);

        if (userOpt.isPresent()) {
            User user = userOpt.get();
            // Ultime vérification de sécurité
            if (code.equals(user.getResetCode())) {
                user.setEncryptedPassword(passwordEncoder.encode(newPassword));
                user.setResetCode(null); // On efface le code après usage pour sécuriser le compte
                user.setResetCodeExpiration(null);
                userRepository.save(user);
                return ResponseEntity.ok(Map.of("message", "Mot de passe mis à jour avec succès."));
            }
        }
        return ResponseEntity.status(400).body(Map.of("message", "Erreur de sécurité lors de la mise à jour."));
    }
}
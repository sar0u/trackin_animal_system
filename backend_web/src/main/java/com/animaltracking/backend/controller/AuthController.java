package com.animaltracking.backend.controller;

import com.animaltracking.backend.dto.JwtResponse;
import com.animaltracking.backend.dto.LoginRequest;
import com.animaltracking.backend.entity.PasswordResetToken;
import com.animaltracking.backend.entity.User;
import com.animaltracking.backend.repository.PasswordResetTokenRepository;
import com.animaltracking.backend.repository.UserRepository;
import com.animaltracking.backend.security.JwtUtils;
import com.animaltracking.backend.service.EmailService;
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

    @Autowired AuthenticationManager authenticationManager;
    @Autowired UserRepository userRepository;
    @Autowired PasswordResetTokenRepository tokenRepository;
    @Autowired JwtUtils jwtUtils;
    @Autowired PasswordEncoder passwordEncoder;
    @Autowired EmailService emailService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getUsername(), loginRequest.getPassword()));
        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = jwtUtils.generateJwtToken(authentication, loginRequest.isRememberMe());

        return userRepository.findByUsername(loginRequest.getUsername())
                .or(() -> userRepository.findByEmail(loginRequest.getUsername()))
                .map(user -> ResponseEntity.ok((Object) new JwtResponse(
                        jwt, user.getId(), user.getUsername(), user.getEmail(),
                        user.getFirstName(), user.getLastName(), user.getRole().name())))
                .orElse(ResponseEntity.badRequest().body("Utilisateur introuvable."));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        Optional<User> userOpt = userRepository.findByEmail(email);

        if (userOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("message", "Email introuvable."));
        }

        User user = userOpt.get();
        String code = String.valueOf((int)(Math.random() * 900000) + 100000);

        PasswordResetToken token = new PasswordResetToken();
        token.setUser(user);
        token.setContact(email);
        token.setCodeHash(passwordEncoder.encode(code));
        token.setUsed(false);
        token.setExpiresAt(LocalDateTime.now().plusMinutes(15));
        tokenRepository.save(token);

        emailService.sendResetCode(email, code);

        return ResponseEntity.ok(Map.of("message", "Code envoyé avec succès."));
    }

    @PostMapping("/verify-code")
    public ResponseEntity<?> verifyCode(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String code = request.get("code");

        return tokenRepository.findTopByContactAndUsedFalseOrderByCreatedAtDesc(email)
                .filter(t -> t.getExpiresAt().isAfter(LocalDateTime.now()))
                .filter(t -> passwordEncoder.matches(code, t.getCodeHash()))
                .map(t -> ResponseEntity.ok((Object) Map.of("message", "Code valide.")))
                .orElse(ResponseEntity.status(400).body(Map.of("message", "Code invalide ou expiré.")));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String code = request.get("code");
        String newPassword = request.get("newPassword");

        Optional<PasswordResetToken> tokenOpt = tokenRepository
                .findTopByContactAndUsedFalseOrderByCreatedAtDesc(email)
                .filter(t -> t.getExpiresAt().isAfter(LocalDateTime.now()))
                .filter(t -> passwordEncoder.matches(code, t.getCodeHash()));

        if (tokenOpt.isEmpty()) {
            return ResponseEntity.status(400).body(Map.of("message", "Erreur de sécurité lors de la mise à jour."));
        }

        PasswordResetToken token = tokenOpt.get();
        token.setUsed(true);
        tokenRepository.save(token);

        User user = token.getUser();
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        return ResponseEntity.ok(Map.of("message", "Mot de passe mis à jour avec succès."));
    }
}

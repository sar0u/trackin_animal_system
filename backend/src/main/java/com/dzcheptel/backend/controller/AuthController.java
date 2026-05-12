package com.dzcheptel.backend.controller;

import com.dzcheptel.backend.dto.JwtResponse;
import com.dzcheptel.backend.dto.LoginRequest;
import com.dzcheptel.backend.entity.PasswordResetToken;
import com.dzcheptel.backend.entity.User;
import com.dzcheptel.backend.entity.UserRole;
import com.dzcheptel.backend.repository.FarmRepository;
import com.dzcheptel.backend.repository.PasswordResetTokenRepository;
import com.dzcheptel.backend.repository.UserRepository;
import com.dzcheptel.backend.security.JwtUtils;
import com.dzcheptel.backend.service.EmailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AuthController {

    @Autowired AuthenticationManager authenticationManager;
    @Autowired UserRepository userRepository;
    @Autowired FarmRepository farmRepository;
    @Autowired PasswordResetTokenRepository tokenRepository;
    @Autowired JwtUtils jwtUtils;
    @Autowired PasswordEncoder passwordEncoder;
    @Autowired EmailService emailService;

    @GetMapping("/health")
    public ResponseEntity<?> health() {
        return ResponseEntity.ok(Map.of("status", "UP"));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getUsername(), loginRequest.getPassword()));
        SecurityContextHolder.getContext().setAuthentication(authentication);

        Optional<User> userOpt = userRepository.findByUsername(loginRequest.getUsername())
                .or(() -> userRepository.findByEmail(loginRequest.getUsername()));

        if (userOpt.isEmpty()) {
            return ResponseEntity.badRequest().body("Utilisateur introuvable.");
        }

        User user = userOpt.get();
        Long farmId = resolveFarmId(user);
        String role = user.getRole() != null ? user.getRole().name() : null;

        String jwt = jwtUtils.generateJwtToken(authentication, loginRequest.isRememberMe(), role, farmId);

        return ResponseEntity.ok(new JwtResponse(
                jwt, user.getId(), user.getUsername(), user.getEmail(),
                user.getFirstName(), user.getLastName(), role));
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody Map<String, Object> req) {
        String role = (String) req.getOrDefault("role", "Farmer");
        if ("Administrator".equalsIgnoreCase(role)) {
            return ResponseEntity.status(403).body(Map.of("message", "Création d'admin interdite via /register."));
        }
        return createUser(req, UserRole.valueOf(role));
    }

    @PostMapping("/register-admin")
    public ResponseEntity<?> registerAdmin(@RequestBody Map<String, Object> req) {
        return createUser(req, UserRole.Administrator);
    }

    private ResponseEntity<?> createUser(Map<String, Object> req, UserRole role) {
        String username = (String) req.get("username");
        String email = (String) req.get("email");
        String password = (String) req.get("password");
        if (username == null || email == null || password == null) {
            return ResponseEntity.badRequest().body(Map.of("message", "username, email, password requis."));
        }
        if (userRepository.findByUsername(username).isPresent() || userRepository.findByEmail(email).isPresent()) {
            return ResponseEntity.status(409).body(Map.of("message", "Utilisateur déjà existant."));
        }

        User u = new User();
        u.setUsername(username);
        u.setEmail(email);
        u.setPassword(passwordEncoder.encode(password));
        u.setFirstName((String) req.getOrDefault("firstName", username));
        u.setLastName((String) req.getOrDefault("lastName", ""));
        u.setPhone((String) req.get("phoneNumber"));
        u.setRole(role);
        u.setIsActive(true);
        userRepository.save(u);

        return ResponseEntity.ok(Map.of("id", u.getId(), "username", u.getUsername(), "role", role.name()));
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

    @PostMapping({"/verify-code", "/verify-reset-code"})
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

    private Long resolveFarmId(User user) {
        if (user.getRole() != UserRole.Farmer) return null;
        List<com.dzcheptel.backend.entity.Farm> farms = farmRepository.findByOwnerId(user.getId());
        return farms.isEmpty() ? null : farms.get(0).getId();
    }
}

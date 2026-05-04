package com.hbtech.cheptel.controller;

import com.hbtech.cheptel.dto.request.LoginRequest;
import com.hbtech.cheptel.dto.request.RegisterRequest;
import com.hbtech.cheptel.dto.response.LoginResponse;
import com.hbtech.cheptel.entity.Role;
import com.hbtech.cheptel.entity.User;
import com.hbtech.cheptel.repository.UserRepository;
import com.hbtech.cheptel.security.JwtTokenProvider;
import com.hbtech.cheptel.service.PasswordResetService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final PasswordResetService passwordResetService;

    public AuthController(
            AuthenticationManager authenticationManager,
            JwtTokenProvider jwtTokenProvider,
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            PasswordResetService passwordResetService
    ) {
        this.authenticationManager = authenticationManager;
        this.jwtTokenProvider = jwtTokenProvider;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.passwordResetService = passwordResetService;
    }

    // ============================================================
    // LOGIN
    // ============================================================

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {

        if (loginRequest == null) {
            return ResponseEntity.badRequest()
                    .body(LoginResponse.error("Requête invalide"));
        }

        if (loginRequest.getIdentifier() == null || loginRequest.getPassword() == null) {
            return ResponseEntity.badRequest()
                    .body(LoginResponse.error("Identifiant et mot de passe requis"));
        }

        String identifier = loginRequest.getIdentifier().trim();
        String password = loginRequest.getPassword();

        try {
            Optional<User> userOpt = userRepository.findByUsername(identifier);

            if (userOpt.isEmpty()) {
                userOpt = userRepository.findByEmail(identifier);
            }

            if (userOpt.isEmpty()) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(LoginResponse.error("Identifiants invalides"));
            }

            User user = userOpt.get();

            if (!user.isEnabled()) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(LoginResponse.error("Compte désactivé"));
            }

            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            user.getUsername(),
                            password
                    )
            );

            Long farmId = user.getFarm() != null ? user.getFarm().getId() : null;
            String farmName = user.getFarm() != null ? user.getFarm().getName() : null;

            String token = jwtTokenProvider.generateToken(
                    user.getUsername(),
                    user.getRole().name(),
                    farmId
            );

            return ResponseEntity.ok(
                    LoginResponse.success(
                            token,
                            user.getRole().name(),
                            user.getUsername(),
                            farmId,
                            farmName
                    )
            );

        } catch (AuthenticationException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(LoginResponse.error("Identifiants invalides"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(LoginResponse.error("Erreur serveur : " + e.getMessage()));
        }
    }

    // ============================================================
    // REGISTER
    // ============================================================

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {

        if (request == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Requête invalide"));
        }

        if (request.getUsername() == null || request.getUsername().isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Nom d'utilisateur obligatoire"));
        }

        if (request.getEmail() == null || request.getEmail().isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Email obligatoire"));
        }

        if (request.getPassword() == null || request.getPassword().length() < 6) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Mot de passe minimum 6 caractères"));
        }

        if (request.getRole() == null || request.getRole().isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Rôle obligatoire"));
        }

        if ("ADMIN".equalsIgnoreCase(request.getRole())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("message", "La création d'un administrateur est réservée à l'interface web."));
        }

        if (userRepository.findByUsername(request.getUsername()).isPresent()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Nom d'utilisateur déjà utilisé"));
        }

        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Email déjà utilisé"));
        }

        try {
            Role role = Role.valueOf(request.getRole().toUpperCase());

            User user = User.builder()
                    .username(request.getUsername())
                    .email(request.getEmail())
                    .phoneNumber(request.getPhoneNumber())
                    .password(passwordEncoder.encode(request.getPassword()))
                    .role(role)
                    .enabled(true)
                    .build();

            userRepository.save(user);

            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(Map.of("message", "Compte créé avec succès"));

        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Rôle invalide"));
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body(Map.of("message", "Erreur création compte : " + e.getMessage()));
        }
    }

    @PostMapping("/register-admin")
    public ResponseEntity<?> registerAdmin(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String email = request.get("email");
        String phone = request.get("phoneNumber");
        String password = request.get("password");

        if (username == null || username.isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Nom d'utilisateur obligatoire"));
        }

        if (email == null || email.isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Email obligatoire"));
        }

        if (password == null || password.length() < 6) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Mot de passe minimum 6 caractères"));
        }

        if (userRepository.findByUsername(username).isPresent()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Nom d'utilisateur déjà pris"));
        }

        if (userRepository.findByEmail(email).isPresent()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Email déjà utilisé"));
        }

        User admin = User.builder()
                .username(username)
                .email(email)
                .phoneNumber(phone)
                .password(passwordEncoder.encode(password))
                .role(Role.ADMIN)
                .enabled(true)
                .build();

        userRepository.save(admin);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(Map.of("message", "Compte administrateur créé avec succès"));
    }

    // ============================================================
    // FORGOT PASSWORD - ENVOI CODE
    // ============================================================

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> payload) {
        String contact = payload.get("contact");

        if (contact == null || contact.isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Email ou téléphone obligatoire"));
        }

        passwordResetService.sendCode(contact.trim().toLowerCase());

        return ResponseEntity.ok(Map.of(
                "message", "Si un compte est associé à ce contact, un code a été envoyé."
        ));
    }

    @PostMapping("/verify-reset-code")
    public ResponseEntity<?> verifyResetCode(@RequestBody Map<String, String> payload) {
        String contact = payload.get("contact");
        String code = payload.get("code");

        if (contact == null || code == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Contact et code obligatoires"));
        }

        boolean valid = passwordResetService.verifyCode(
                contact.trim().toLowerCase(),
                code.trim()
        );

        if (!valid) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", "Code invalide ou expiré"));
        }

        return ResponseEntity.ok(Map.of("message", "Code vérifié avec succès"));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> payload) {
        String contact = payload.get("contact");
        String code = payload.get("code");
        String newPassword = payload.get("newPassword");

        if (contact == null || code == null || newPassword == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Données manquantes"));
        }

        if (newPassword.length() < 6) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Mot de passe minimum 6 caractères"));
        }

        boolean reset = passwordResetService.resetPassword(
                contact.trim().toLowerCase(),
                code.trim(),
                newPassword
        );

        if (!reset) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("message", "Code invalide ou expiré. Recommencez."));
        }

        return ResponseEntity.ok(Map.of("message", "Mot de passe réinitialisé avec succès"));
    }

    // ============================================================
    // VERIFY RESET CODE
    // ============================================================


    // ============================================================
    // HEALTH CHECK
    // ============================================================

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("OK");
    }

}
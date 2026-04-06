package com.animaltracking.backend.controller;

import com.animaltracking.backend.dto.JwtResponse;
import com.animaltracking.backend.dto.LoginRequest;
import com.animaltracking.backend.entity.User;
import com.animaltracking.backend.repository.UserRepository;
import com.animaltracking.backend.security.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

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

    @PostMapping("/login")
    public ResponseEntity<?> authenticateUser(@RequestBody LoginRequest loginRequest) {

        // 1. On vérifie les identifiants
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginRequest.getEmail(), loginRequest.getPassword()));

        // 2. On met l'utilisateur dans le contexte de sécurité
        SecurityContextHolder.getContext().setAuthentication(authentication);

        // 3. On génère le token JWT
        String jwt = jwtUtils.generateJwtToken(authentication);

        // 4. On récupère l'utilisateur en base de données pour construire la réponse Flutter
        // Attention au nom de la méthode, elle doit correspondre à ton repository (ex: findByEmailAddress)
        Optional<User> userOptional = userRepository.findByEmailAddress(loginRequest.getEmail());

        if (userOptional.isPresent()) {
            User user = userOptional.get();
            // On utilise notre DTO pour renvoyer une belle réponse propre
            return ResponseEntity.ok(new JwtResponse(
                    jwt,
                    Long.valueOf(user.getId()), // Assure-toi que l'ID est bien convertible en Long
                    user.getEmailAddress(),
                    user.getFirstName(),
                    user.getLastName(),
                    user.getUserRole().name() // On récupère l'Enum (ex: Administrator)
            ));
        }

        return ResponseEntity.badRequest().body("Erreur : Utilisateur introuvable après authentification.");
    }
}
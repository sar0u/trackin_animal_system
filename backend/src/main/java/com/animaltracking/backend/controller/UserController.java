package com.animaltracking.backend.controller;

import com.animaltracking.backend.entity.User;
import com.animaltracking.backend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    // C'est cette ligne qui avait disparu et qui causait l'erreur "Cannot resolve symbol"
    private final UserService userService;
    private final PasswordEncoder passwordEncoder;

    // 1. LECTURE (Sécurisée contre les boucles infinies)
    @GetMapping
    public List<Map<String, Object>> getAllUsersSafe() {
        List<User> usersFromDb = userService.getAllUsers();
        List<Map<String, Object>> safeUsersList = new ArrayList<>();

        for (User u : usersFromDb) {
            Map<String, Object> safeUser = new HashMap<>();
            safeUser.put("id", u.getId());
            safeUser.put("username", u.getUsername());
            safeUser.put("emailAddress", u.getEmailAddress());
            safeUser.put("firstName", u.getFirstName());
            safeUser.put("lastName", u.getLastName());
            safeUser.put("userRole", u.getUserRole() != null ? u.getUserRole().name() : "Inconnu");
            safeUser.put("creationTimestamp", u.getCreationTimestamp());

            safeUsersList.add(safeUser);
        }
        return safeUsersList;
    }

    // 2. LECTURE PAR ID
    @GetMapping("/{id}")
    public User getUserById(@PathVariable Integer id) {
        return userService.getUserById(id);
    }

    // 3. CRÉATION (Sécurisée)
    @PostMapping
    @PreAuthorize("hasRole('Administrator')")
    public User createUser(@RequestBody User user) {

        // 🟢 LE SECRET EST ICI : On crypte le mot de passe reçu du frontend
        String plainPassword = user.getEncryptedPassword();
        user.setEncryptedPassword(passwordEncoder.encode(plainPassword));

        return userService.save(user);
    }

    // 4. MISE À JOUR (Sécurisée)
    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Integer id, @RequestBody User updatedUser) {
        try {
            User user = userService.getUserById(id);
            user.setFirstName(updatedUser.getFirstName());
            user.setLastName(updatedUser.getLastName());
            user.setEmailAddress(updatedUser.getEmailAddress());
            user.setUserRole(updatedUser.getUserRole());
            user.setUsername(updatedUser.getUsername());

            userService.save(user);
            return ResponseEntity.ok().body(Map.of("message", "Utilisateur modifié avec succès"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Erreur : " + e.getMessage());
        }
    }

    // 5. SUPPRESSION (Sécurisée)
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Integer id) {
        try {
            userService.deleteUser(id);
            return ResponseEntity.ok().body(Map.of("message", "Utilisateur supprimé avec succès"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Erreur : " + e.getMessage());
        }
    }
}
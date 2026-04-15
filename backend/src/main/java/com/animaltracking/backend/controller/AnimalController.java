package com.animaltracking.backend.controller;

import com.animaltracking.backend.entity.Animal;
import com.animaltracking.backend.service.AnimalService;
import com.animaltracking.backend.service.UserService;
import com.animaltracking.backend.service.FarmService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/animals")
@Tag(name = "Animal Management", description = "Endpoints pour la gestion des animaux")
public class AnimalController {

    @Autowired
    private AnimalService animalService;

    @Autowired
    private com.animaltracking.backend.service.UserService userService;

    @Autowired
    private com.animaltracking.backend.service.FarmService farmService;

    @GetMapping("/stats/summary")
    @Operation(summary = "Statistiques globales pour le dashboard")
    public ResponseEntity<java.util.Map<String, Object>> getDashboardStats() {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();

        // 1. Chiffres clés (KPI)
        stats.put("totalAnimals", animalService.countAllAnimals());
        stats.put("totalUsers", userService.getAllUsers().size());
        stats.put("totalFarms", farmService.getAllFarms().size());
        stats.put("activeAlerts", 14); // Valeur statique en attendant un AlertService

        // 2. Répartition des Espèces (Bovins/Ovins)
        stats.put("speciesStats", animalService.getSpeciesDistribution());

        // 3. Répartition des Profils (Pour les barres de progression)
        java.util.Map<String, Long> userProfiles = new java.util.HashMap<>();
        userProfiles.put("Éleveurs", 124102L); // À dynamiser plus tard via userService
        userProfiles.put("Vétérinaires", 12402L);
        userProfiles.put("Agents", 6000L);
        stats.put("userProfiles", userProfiles);

        // 4. État Sanitaire
        java.util.Map<String, Double> health = new java.util.HashMap<>();
        health.put("sain", 98.4);
        health.put("observation", 1.2);
        health.put("quarantaine", 0.3);
        health.put("attente", 0.1);
        stats.put("healthStats", health);

        // 5. Gestion des Fraudes (Section demandée)
        stats.put("fraudRate", 82);
        stats.put("recentFrauds", java.util.List.of(
                createFraudMap("14m", "Anomalie RFID", "FR-88219", "Double enregistrement détecté pour l'animal ID: 992-3321", "HIGH"),
                createFraudMap("2h", "Résolution en cours", "TR-0042", "Trajectoire hors zone. Agent dépêché sur site.", "INFO")
        ));

        return ResponseEntity.ok(stats);
    }

    // Petite méthode utilitaire pour structurer les fraudes
    private java.util.Map<String, String> createFraudMap(String time, String type, String farm, String desc, String severity) {
        java.util.Map<String, String> f = new java.util.HashMap<>();
        f.put("timeAgo", time);
        f.put("type", type);
        f.put("farmId", farm);
        f.put("description", desc);
        f.put("severity", severity);
        return f;
    }

    @GetMapping
    @Operation(summary = "Liste tous les animaux")
    public List<Animal> getAll() {
        return animalService.getAllAnimals();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détails d'un animal")
    public ResponseEntity<Animal> getById(@PathVariable Integer id) {
        return ResponseEntity.ok(animalService.getAnimalById(id));
    }
}
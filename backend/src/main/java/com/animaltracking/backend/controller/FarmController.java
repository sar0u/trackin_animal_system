package com.animaltracking.backend.controller;

import com.animaltracking.backend.entity.Farm;
import com.animaltracking.backend.service.FarmService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/farms")
@Tag(name = "Farm Management", description = "Gestion des exploitations agricoles")
public class FarmController {

    @Autowired
    private FarmService farmService;

    // 1. LECTURE (Version sécurisée pour envoyer le Status et l'Owner)
    @GetMapping
    @Operation(summary = "Lister toutes les fermes avec détails")
    public List<Map<String, Object>> getAllFarmsSafe() {
        List<Farm> farms = farmService.getAllFarms();
        List<Map<String, Object>> response = new ArrayList<>();

        for (Farm f : farms) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", f.getId());
            map.put("name", f.getFarmName());
            map.put("location", f.getGeographicAddress());
            map.put("status", f.getStatus()); // 🟢 Ajout du nouveau statut

            // On envoie les infos de l'owner (User) sans données sensibles
            if (f.getOwner() != null) {
                Map<String, Object> ownerMap = new HashMap<>();
                ownerMap.put("id", f.getOwner().getId());
                map.put("owner", ownerMap);
            }

            response.add(map);
        }
        return response;
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détails d'une ferme")
    public ResponseEntity<Farm> getById(@PathVariable Integer id) {
        return ResponseEntity.ok(farmService.getFarmById(id));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('Administrator', 'FieldAgent')")
    @Operation(summary = "Ajouter une nouvelle ferme")
    public ResponseEntity<Farm> create(@RequestBody Farm farm) {
        // Le statut sera 'Active' par défaut via l'annotation @Column ou l'initialisation dans l'entité
        return ResponseEntity.ok(farmService.createFarm(farm));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Administrator', 'FieldAgent')")
    @Operation(summary = "Mettre à jour les informations d'une ferme")
    public ResponseEntity<Farm> update(@PathVariable Integer id, @RequestBody Farm farm) {
        // Assurez-vous que le service met bien à jour le champ 'status' et 'owner'
        return ResponseEntity.ok(farmService.updateFarm(id, farm));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    @Operation(summary = "Supprimer une ferme")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        farmService.deleteFarm(id);
        return ResponseEntity.noContent().build();
    }
}
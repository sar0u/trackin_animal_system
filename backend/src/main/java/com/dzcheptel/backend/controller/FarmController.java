package com.dzcheptel.backend.controller;

import com.dzcheptel.backend.entity.Farm;
import com.dzcheptel.backend.service.FarmService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/farms")
@Tag(name = "Farm Management", description = "Gestion des exploitations agricoles")
public class FarmController {

    @Autowired
    private FarmService farmService;

    @GetMapping
    @Operation(summary = "Lister toutes les fermes")
    public List<Farm> getAll() {
        return farmService.getAllFarms();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détails d'une ferme")
    public ResponseEntity<Farm> getById(@PathVariable Long id) {
        return ResponseEntity.ok(farmService.getFarmById(id));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('Administrator', 'Farmer')")
    @Operation(summary = "Ajouter une nouvelle ferme")
    public ResponseEntity<Farm> create(@RequestBody Farm farm) {
        return ResponseEntity.ok(farmService.createFarm(farm));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Administrator', 'Farmer')")
    @Operation(summary = "Mettre à jour les informations d'une ferme")
    public ResponseEntity<Farm> update(@PathVariable Long id, @RequestBody Farm farm) {
        return ResponseEntity.ok(farmService.updateFarm(id, farm));
    }

    @PutMapping("/{id}/status")
    @PreAuthorize("hasAnyRole('Administrator', 'Inspector')")
    @Operation(summary = "Mettre à jour le statut et la vérification d'une ferme")
    public ResponseEntity<Farm> updateStatusAndVerification(
            @PathVariable Long id,
            @RequestBody Map<String, Object> updates) {

        String status = (String) updates.get("status");
        Boolean isVerified = (Boolean) updates.get("isVerified");

        Farm updatedFarm = farmService.updateStatusAndVerification(id, status, isVerified);
        return ResponseEntity.ok(updatedFarm);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    @Operation(summary = "Supprimer une ferme")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        farmService.deleteFarm(id);
        return ResponseEntity.noContent().build();
    }
}
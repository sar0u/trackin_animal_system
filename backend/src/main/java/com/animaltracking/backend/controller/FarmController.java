package com.animaltracking.backend.controller;

import com.animaltracking.backend.entity.Farm;
import com.animaltracking.backend.service.FarmService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/farms")
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
    public ResponseEntity<Farm> getById(@PathVariable Integer id) {
        return ResponseEntity.ok(farmService.getFarmById(id));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('Administrator', 'FieldAgent')")
    @Operation(summary = "Ajouter une nouvelle ferme")
    public ResponseEntity<Farm> create(@RequestBody Farm farm) {
        return ResponseEntity.ok(farmService.createFarm(farm));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Administrator', 'FieldAgent')")
    @Operation(summary = "Mettre à jour les informations d'une ferme")
    public ResponseEntity<Farm> update(@PathVariable Integer id, @RequestBody Farm farm) {
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
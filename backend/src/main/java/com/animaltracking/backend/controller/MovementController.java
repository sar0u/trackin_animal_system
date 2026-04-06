package com.animaltracking.backend.controller;

import com.animaltracking.backend.entity.Movement;
import com.animaltracking.backend.service.MovementService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/movements")
@Tag(name = "Movement Tracking", description = "Historique des déplacements d'animaux")
public class MovementController {

    @Autowired
    private MovementService movementService;

    @GetMapping
    @Operation(summary = "Lister tous les mouvements enregistrés")
    public List<Movement> getAll() {
        return movementService.getAllMovements();
    }

    @GetMapping("/animal/{animalId}")
    @Operation(summary = "Historique des déplacements pour un animal spécifique")
    public List<Movement> getByAnimal(@PathVariable Integer animalId) {
        return movementService.getMovementsByAnimal(animalId);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détails d'un mouvement")
    public ResponseEntity<Movement> getById(@PathVariable Integer id) {
        return ResponseEntity.ok(movementService.getMovementById(id));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('Administrator', 'FieldAgent')")
    @Operation(summary = "Enregistrer manuellement un déplacement")
    public ResponseEntity<Movement> create(@RequestBody Movement movement) {
        return ResponseEntity.ok(movementService.createMovement(movement));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    @Operation(summary = "Supprimer une trace de mouvement")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        movementService.deleteMovement(id);
        return ResponseEntity.noContent().build();
    }
}
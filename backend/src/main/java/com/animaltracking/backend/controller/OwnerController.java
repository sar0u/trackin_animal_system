package com.animaltracking.backend.controller;

import com.animaltracking.backend.entity.Owner;
import com.animaltracking.backend.service.OwnerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/owners")
@Tag(name = "Owner Management", description = "Gestion des propriétaires d'élevages")
public class OwnerController {

    @Autowired
    private OwnerService ownerService;

    @GetMapping
    @Operation(summary = "Lister tous les propriétaires")
    public List<Owner> getAll() {
        return ownerService.getAllOwners();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détails d'un propriétaire")
    public ResponseEntity<Owner> getById(@PathVariable Integer id) {
        return ResponseEntity.ok(ownerService.getOwnerById(id));
    }

    @PostMapping
    @PreAuthorize("hasRole('Administrator')")
    @Operation(summary = "Créer un nouveau profil propriétaire")
    public ResponseEntity<Owner> create(@RequestBody Owner owner) {
        return ResponseEntity.ok(ownerService.createOwner(owner));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Administrator', 'FieldAgent')")
    @Operation(summary = "Modifier les infos d'un propriétaire")
    public ResponseEntity<Owner> update(@PathVariable Integer id, @RequestBody Owner owner) {
        return ResponseEntity.ok(ownerService.updateOwner(id, owner));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    @Operation(summary = "Supprimer un propriétaire")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        ownerService.deleteOwner(id);
        return ResponseEntity.noContent().build();
    }
}
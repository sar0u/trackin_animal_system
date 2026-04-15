package com.animaltracking.backend.controller;

import com.animaltracking.backend.entity.RfidTag;
import com.animaltracking.backend.service.RfidTagService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/rfid-tags")
@Tag(name = "RFID Tag Management", description = "Gestion du matériel de traçage")
public class RfidTagController {

    @Autowired
    private RfidTagService rfidTagService;

    @GetMapping
    @Operation(summary = "Lister tous les tags")
    public List<RfidTag> getAll() {
        return rfidTagService.getAllTags();
    }

    @PostMapping
    @PreAuthorize("hasRole('Administrator')")
    @Operation(summary = "Enregistrer un nouveau tag en stock")
    public ResponseEntity<RfidTag> create(@RequestBody RfidTag tag) {
        return ResponseEntity.ok(rfidTagService.createTag(tag));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détails d'un tag spécifique")
    public ResponseEntity<RfidTag> getById(@PathVariable Integer id) {
        return ResponseEntity.ok(rfidTagService.getTagById(id));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Administrator', 'FieldAgent')")
    @Operation(summary = "Mettre à jour l'état d'un tag")
    public ResponseEntity<RfidTag> update(@PathVariable Integer id, @RequestBody RfidTag tag) {
        return ResponseEntity.ok(rfidTagService.updateTag(id, tag));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    @Operation(summary = "Supprimer un tag du système")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        rfidTagService.deleteTag(id);
        return ResponseEntity.noContent().build();
    }
}
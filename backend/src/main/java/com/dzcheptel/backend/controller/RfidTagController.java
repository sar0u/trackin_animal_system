package com.dzcheptel.backend.controller;

import com.dzcheptel.backend.entity.RfidTag;
import com.dzcheptel.backend.service.RfidTagService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/rfid-tags")
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
    public ResponseEntity<RfidTag> getById(@PathVariable Long id) {
        return ResponseEntity.ok(rfidTagService.getTagById(id));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Administrator', 'Inspector')")
    @Operation(summary = "Mettre à jour l'état d'un tag")
    public ResponseEntity<RfidTag> update(@PathVariable Long id, @RequestBody RfidTag tag) {
        return ResponseEntity.ok(rfidTagService.updateTag(id, tag));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    @Operation(summary = "Supprimer un tag du système")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        rfidTagService.deleteTag(id);
        return ResponseEntity.noContent().build();
    }
}
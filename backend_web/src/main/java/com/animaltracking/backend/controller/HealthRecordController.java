package com.animaltracking.backend.controller;

import com.animaltracking.backend.entity.HealthRecord;
import com.animaltracking.backend.service.HealthRecordService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/health-records")
@Tag(name = "Health Records", description = "Gestion du suivi médical des animaux")
public class HealthRecordController {

    @Autowired
    private HealthRecordService healthRecordService;

    @GetMapping
    @Operation(summary = "Lister tous les dossiers médicaux")
    public List<HealthRecord> getAll() {
        return healthRecordService.getAllRecords();
    }

    @GetMapping("/animal/{animalId}")
    @Operation(summary = "Suivi médical complet pour un animal")
    public List<HealthRecord> getByAnimal(@PathVariable Long animalId) {
        return healthRecordService.getRecordsByAnimal(animalId);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('Administrator', 'Veterinarian')")
    @Operation(summary = "Enregistrer une nouvelle visite ou intervention")
    public ResponseEntity<HealthRecord> create(@RequestBody HealthRecord record) {
        return ResponseEntity.ok(healthRecordService.createRecord(record));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Administrator', 'Veterinarian')")
    @Operation(summary = "Modifier un dossier médical")
    public ResponseEntity<HealthRecord> update(@PathVariable Long id, @RequestBody HealthRecord record) {
        return ResponseEntity.ok(healthRecordService.updateRecord(id, record));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    @Operation(summary = "Supprimer un enregistrement médical")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        healthRecordService.deleteRecord(id);
        return ResponseEntity.noContent().build();
    }
}
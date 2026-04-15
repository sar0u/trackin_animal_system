package com.animaltracking.backend.controller;

import com.animaltracking.backend.entity.Vaccination;
import com.animaltracking.backend.service.VaccinationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/vaccinations")
@Tag(name = "Vaccination Records", description = "Gestion du calendrier vaccinal")
public class VaccinationController {

    @Autowired
    private VaccinationService vaccinationService;

    @GetMapping
    @Operation(summary = "Lister toutes les vaccinations effectuées")
    public List<Vaccination> getAll() {
        return vaccinationService.getAllVaccinations();
    }

    @GetMapping("/record/{recordId}")
    @Operation(summary = "Détails vaccins pour un dossier médical précis")
    public List<Vaccination> getByHealthRecord(@PathVariable Integer recordId) {
        return vaccinationService.getVaccinationsByHealthRecord(recordId);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('Administrator', 'Veterinarian')")
    @Operation(summary = "Enregistrer l'administration d'un vaccin")
    public ResponseEntity<Vaccination> create(@RequestBody Vaccination vaccination) {
        return ResponseEntity.ok(vaccinationService.createVaccination(vaccination));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Administrator', 'Veterinarian')")
    @Operation(summary = "Modifier les données d'une vaccination")
    public ResponseEntity<Vaccination> update(@PathVariable Integer id, @RequestBody Vaccination vaccination) {
        return ResponseEntity.ok(vaccinationService.updateVaccination(id, vaccination));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    @Operation(summary = "Supprimer une fiche de vaccination")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        vaccinationService.deleteVaccination(id);
        return ResponseEntity.noContent().build();
    }
}
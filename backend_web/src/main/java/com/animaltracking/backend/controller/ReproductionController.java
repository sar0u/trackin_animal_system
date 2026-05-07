package com.animaltracking.backend.controller;

import com.animaltracking.backend.entity.Reproduction;
import com.animaltracking.backend.service.ReproductionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reproductions")
@RequiredArgsConstructor
public class ReproductionController {

    private final ReproductionService service;

    @GetMapping
    public List<Reproduction> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Reproduction> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @GetMapping("/animal/{femaleId}")
    public List<Reproduction> getByFemale(@PathVariable Long femaleId) {
        return service.getByFemale(femaleId);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('Administrator','Veterinarian')")
    public ResponseEntity<Reproduction> create(@RequestBody Reproduction reproduction) {
        return ResponseEntity.ok(service.create(reproduction));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Administrator','Veterinarian')")
    public ResponseEntity<Reproduction> update(@PathVariable Long id, @RequestBody Reproduction payload) {
        return ResponseEntity.ok(service.update(id, payload));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}

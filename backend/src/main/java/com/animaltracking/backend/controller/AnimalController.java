package com.animaltracking.backend.controller;

import com.animaltracking.backend.entity.Animal;
import com.animaltracking.backend.service.AnimalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/animals")
@Tag(name = "Animal Management", description = "Endpoints pour la gestion des animaux")
public class AnimalController {

    @Autowired
    private AnimalService animalService;

    @GetMapping
    @Operation(summary = "Liste tous les animaux")
    public List<Animal> getAll() {
        return animalService.getAllAnimals();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détails d'un animal")
    public ResponseEntity<Animal> getById(@PathVariable Integer id) {
        return ResponseEntity.ok(animalService.getAnimalById(id));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('Administrator', 'FieldAgent')")
    @Operation(summary = "Créer un nouvel animal")
    public ResponseEntity<Animal> create(@RequestBody Animal animal) {
        return ResponseEntity.ok(animalService.createAnimal(animal));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Administrator', 'Veterinarian')")
    @Operation(summary = "Mettre à jour un animal")
    public ResponseEntity<Animal> update(@PathVariable Integer id, @RequestBody Animal animal) {
        return ResponseEntity.ok(animalService.updateAnimal(id, animal));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    @Operation(summary = "Supprimer un animal")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        animalService.deleteAnimal(id);
        return ResponseEntity.noContent().build();
    }
}
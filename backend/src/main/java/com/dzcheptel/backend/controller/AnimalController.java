package com.dzcheptel.backend.controller;

import com.dzcheptel.backend.entity.Animal;
import com.dzcheptel.backend.repository.AnimalRepository;
import com.dzcheptel.backend.service.AnimalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/animals")
@Tag(name = "Animal Management", description = "Endpoints pour la gestion des animaux")
@RequiredArgsConstructor
public class AnimalController {

    private final AnimalService animalService;
    private final AnimalRepository animalRepository;

    @GetMapping
    @Operation(summary = "Liste tous les animaux")
    public List<Map<String, Object>> getAll() {
        return animalService.listAnimalsForApi();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Détails d'un animal")
    public ResponseEntity<Map<String, Object>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(animalService.getAnimalForApi(id));
    }

    @GetMapping("/rfid/{rfidCode}")
    @Operation(summary = "Détails d'un animal par RFID (mobile scan)")
    @PreAuthorize("hasAnyRole('Farmer','Veterinarian','Inspector','Administrator')")
    public ResponseEntity<?> getByRfid(@PathVariable String rfidCode) {
        return animalRepository.findByRfidCode(rfidCode)
                .map(a -> ResponseEntity.ok(animalService.getAnimalForApi(a.getId())))
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('Administrator', 'Farmer')")
    @Operation(summary = "Créer un nouvel animal")
    public ResponseEntity<Animal> create(@RequestBody Animal animal) {
        return ResponseEntity.ok(animalService.createAnimal(animal));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Administrator', 'Veterinarian')")
    @Operation(summary = "Mettre à jour un animal")
    public ResponseEntity<Animal> update(@PathVariable Long id, @RequestBody Animal animal) {
        return ResponseEntity.ok(animalService.updateAnimal(id, animal));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    @Operation(summary = "Supprimer un animal")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        animalService.deleteAnimal(id);
        return ResponseEntity.noContent().build();
    }
}
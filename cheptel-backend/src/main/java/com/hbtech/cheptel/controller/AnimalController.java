package com.hbtech.cheptel.controller;
import com.hbtech.cheptel.dto.request.CreateAnimalRequest;
import com.hbtech.cheptel.dto.request.CreateEventRequest;
import com.hbtech.cheptel.dto.response.AnimalResponse;
import com.hbtech.cheptel.dto.response.EventResponse;
import com.hbtech.cheptel.entity.*;
import com.hbtech.cheptel.repository.AnimalEventRepository;
import com.hbtech.cheptel.repository.AnimalRepository;
import com.hbtech.cheptel.service.AnimalService;
import com.hbtech.cheptel.service.CurrentUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import com.hbtech.cheptel.dto.UpdateAnimalRequest;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/animals")
public class AnimalController {

    private final AnimalService animalService;
    private final CurrentUserService currentUserService;
    @Autowired
    private AnimalRepository animalRepository;

    public AnimalController(AnimalService animalService, CurrentUserService currentUserService) {
        this.animalService = animalService;
        this.currentUserService = currentUserService;
    }

    @Autowired
    private AnimalEventRepository animalEventRepository;

    @GetMapping("/rfid/{rfidTag}")
    @PreAuthorize("hasAnyRole('FERMIER','VETERINAIRE','CONTROLEUR','ADMIN')")
    public ResponseEntity<?> getByRfid(@PathVariable String rfidTag) {

        User current = currentUserService.getCurrentUserOrThrow();

        Animal animal;
        try {
            animal = animalService.getByRfidOrThrow(rfidTag);
        } catch (Exception e) {
            return ResponseEntity.status(404)
                    .body(Map.of("message", "Animal introuvable pour ce tag RFID: " + rfidTag));
        }

        // Règle : le fermier ne voit QUE les animaux de SA ferme
        if (current.getRole() == Role.FERMIER) {
            Long userFarmId = current.getFarm() != null ? current.getFarm().getId() : null;
            Long animalFarmId = animal.getFarm().getId();

            System.out.println("DEBUG - userFarmId: " + userFarmId + " | animalFarmId: " + animalFarmId);

            if (userFarmId == null || !userFarmId.equals(animalFarmId)) {
                return ResponseEntity.status(403)
                        .body(Map.of("message", "Cet animal n'appartient pas à votre exploitation"));
            }
        }

        AnimalResponse response = AnimalResponse.builder()
                .id(animal.getId())
                .rfidTag(animal.getRfidTag())
                .species(animal.getSpecies())
                .breed(animal.getBreed())
                .gender(animal.getGender())
                .weight(animal.getWeight())
                .status(animal.getStatus())
                .color(animal.getColor())
                .birthDate(animal.getBirthDate())
                .farmId(animal.getFarm().getId())
                .farmName(animal.getFarm().getName())
                .build();

        return ResponseEntity.ok(response);
    }
    @GetMapping("/rfid/{rfidTag}/events")
    @PreAuthorize("hasAnyRole('FERMIER','VETERINAIRE','CONTROLEUR','ADMIN')")
    public ResponseEntity<List<EventResponse>> getEvents(@PathVariable String rfidTag) {

        Animal animal = animalService.getByRfidOrThrow(rfidTag);

        List<EventResponse> events = animalEventRepository
                .findByAnimalIdOrderByEventDateDesc(animal.getId())
                .stream().map(e -> EventResponse.builder()
                        .id(e.getId())
                        .eventType(e.getEventType().name())
                        .eventDate(e.getEventDate())
                        .latitude(e.getLatitude())
                        .longitude(e.getLongitude())
                        .location(e.getLocation())
                        .notes(e.getNotes())
                        .performedBy(e.getPerformedBy() != null ? e.getPerformedBy().getUsername() : null)
                        .createdAt(e.getCreatedAt())
                        .build())
                .collect(Collectors.toList());

        return ResponseEntity.ok(events);
    }


// Ajoute cette méthode dans la classe AnimalController

    @PostMapping("/create")
    @PreAuthorize("hasAnyRole('FERMIER','ADMIN')")
    public ResponseEntity<?> createAnimal(@RequestBody CreateAnimalRequest request) {

        User current = currentUserService.getCurrentUserOrThrow();

        if (current.getFarm() == null) {
            return ResponseEntity.status(403).body(java.util.Map.of("message", "Vous n'êtes associé à aucune ferme"));
        }

        // Vérifier si le tag RFID existe déjà
        if (animalService.existsByRfidTag(request.getRfidTag())) {
            return ResponseEntity.status(400).body(java.util.Map.of("message", "Ce tag RFID est déjà utilisé"));
        }

        try {
            Animal animal = Animal.builder()
                    .rfidTag(request.getRfidTag())
                    .species(Species.valueOf(request.getSpecies().toUpperCase()))
                    .breed(request.getBreed())
                    .gender(Gender.valueOf(request.getGender().toUpperCase()))
                    .weight(request.getWeight())
                    .color(request.getColor())
                    .birthDate(request.getBirthDate() != null ? LocalDate.parse(request.getBirthDate()) : null)
                    .status(AnimalStatus.ACTIVE)
                    .farm(current.getFarm())
                    .build();

            Animal saved = animalRepository.save(animal);

            AnimalResponse response = AnimalResponse.builder()
                    .id(saved.getId())
                    .rfidTag(saved.getRfidTag())
                    .species(saved.getSpecies())
                    .breed(saved.getBreed())
                    .gender(saved.getGender())
                    .weight(saved.getWeight())
                    .status(saved.getStatus())
                    .color(saved.getColor())
                    .birthDate(saved.getBirthDate())
                    .farmId(saved.getFarm().getId())
                    .farmName(saved.getFarm().getName())
                    .build();

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(400).body(java.util.Map.of("message", "Erreur: " + e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('FERMIER','ADMIN')")
    public ResponseEntity<?> updateAnimal(
            @PathVariable Long id,
            @RequestBody UpdateAnimalRequest request) {

        User current = currentUserService.getCurrentUserOrThrow();

        Animal animal = animalRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Animal introuvable"));

        // Vérifier que l'animal appartient au fermier
        if (current.getRole() == Role.FERMIER) {
            Long userFarmId = current.getFarm() != null ? current.getFarm().getId() : null;
            if (userFarmId == null || !userFarmId.equals(animal.getFarm().getId())) {
                return ResponseEntity.status(403)
                        .body(java.util.Map.of("message", "Cet animal n'appartient pas à votre exploitation"));
            }
        }

        try {
            if (request.getBreed() != null) animal.setBreed(request.getBreed());
            if (request.getGender() != null) animal.setGender(Gender.valueOf(request.getGender().toUpperCase()));
            if (request.getWeight() != null) animal.setWeight(request.getWeight());
            if (request.getColor() != null) animal.setColor(request.getColor());
            if (request.getStatus() != null) animal.setStatus(AnimalStatus.valueOf(request.getStatus().toUpperCase()));
            if (request.getBirthDate() != null && !request.getBirthDate().isEmpty()) {
                animal.setBirthDate(java.time.LocalDate.parse(request.getBirthDate()));
            }

            Animal saved = animalRepository.save(animal);

            AnimalResponse response = AnimalResponse.builder()
                    .id(saved.getId())
                    .rfidTag(saved.getRfidTag())
                    .species(saved.getSpecies())
                    .breed(saved.getBreed())
                    .gender(saved.getGender())
                    .weight(saved.getWeight())
                    .status(saved.getStatus())
                    .color(saved.getColor())
                    .birthDate(saved.getBirthDate())
                    .farmId(saved.getFarm().getId())
                    .farmName(saved.getFarm().getName())
                    .build();

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(400).body(java.util.Map.of("message", "Erreur: " + e.getMessage()));
        }
    }
}
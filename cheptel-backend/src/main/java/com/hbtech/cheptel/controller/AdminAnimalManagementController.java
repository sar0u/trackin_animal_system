package com.hbtech.cheptel.controller;

import com.hbtech.cheptel.entity.*;
import com.hbtech.cheptel.repository.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin/animal-management")
@PreAuthorize("hasRole('ADMIN')")
public class AdminAnimalManagementController {

    private final AnimalRepository animalRepository;
    private final MovementRepository movementRepository;
    private final VaccinationRepository vaccinationRepository;
    private final HealthRecordRepository healthRecordRepository;
    private final AnimalEventRepository animalEventRepository;

    public AdminAnimalManagementController(
            AnimalRepository animalRepository,
            MovementRepository movementRepository,
            VaccinationRepository vaccinationRepository,
            HealthRecordRepository healthRecordRepository,
            AnimalEventRepository animalEventRepository
    ) {
        this.animalRepository = animalRepository;
        this.movementRepository = movementRepository;
        this.vaccinationRepository = vaccinationRepository;
        this.healthRecordRepository = healthRecordRepository;
        this.animalEventRepository = animalEventRepository;
    }

    @GetMapping("/animals")
    public ResponseEntity<List<Map<String, Object>>> getAllAnimals(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String species,
            @RequestParam(required = false) Long farmId
    ) {
        List<Animal> animals = animalRepository.findAll();

        if (status != null && !status.isBlank()) {
            animals = animals.stream()
                    .filter(a -> a.getStatus() != null && a.getStatus().name().equalsIgnoreCase(status))
                    .toList();
        }

        if (species != null && !species.isBlank()) {
            animals = animals.stream()
                    .filter(a -> a.getSpecies() != null && a.getSpecies().name().equalsIgnoreCase(species))
                    .toList();
        }

        if (farmId != null) {
            animals = animals.stream()
                    .filter(a -> a.getFarm() != null && a.getFarm().getId().equals(farmId))
                    .toList();
        }

        List<Map<String, Object>> result = animals.stream()
                .map(this::animalListMap)
                .toList();

        return ResponseEntity.ok(result);
    }

    @GetMapping("/history/{identifier}")
    public ResponseEntity<?> getAnimalHistory(@PathVariable String identifier) {
        String decoded = URLDecoder.decode(identifier, StandardCharsets.UTF_8);

        Animal animal;

        try {
            Long id = Long.valueOf(decoded);
            animal = animalRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Animal introuvable avec ID : " + id));
        } catch (NumberFormatException e) {
            animal = animalRepository.findByRfidTag(decoded)
                    .orElseThrow(() -> new RuntimeException("Animal introuvable avec RFID : " + decoded));
        }

        return ResponseEntity.ok(buildAnimalHistory(animal));
    }

    private Map<String, Object> animalListMap(Animal a) {
        Map<String, Object> map = new HashMap<>();

        map.put("id", a.getId());
        map.put("rfidTag", a.getRfidTag());
        map.put("species", a.getSpecies() != null ? a.getSpecies().name() : null);
        map.put("breed", a.getBreed());
        map.put("gender", a.getGender() != null ? a.getGender().name() : null);
        map.put("weight", a.getWeight());
        map.put("status", a.getStatus() != null ? a.getStatus().name() : null);
        map.put("color", a.getColor());
        map.put("birthDate", a.getBirthDate());

        map.put("farmId", a.getFarm() != null ? a.getFarm().getId() : null);
        map.put("farmName", a.getFarm() != null ? a.getFarm().getName() : null);
        map.put("farmWilaya", a.getFarm() != null ? a.getFarm().getWilaya() : null);

        map.put("motherId", a.getMother() != null ? a.getMother().getId() : null);
        map.put("motherRfid", a.getMother() != null ? a.getMother().getRfidTag() : null);

        map.put("fatherId", a.getFather() != null ? a.getFather().getId() : null);
        map.put("fatherRfid", a.getFather() != null ? a.getFather().getRfidTag() : null);

        return map;
    }

    private Map<String, Object> buildAnimalHistory(Animal animal) {
        Map<String, Object> result = new HashMap<>();

        result.put("id", animal.getId());
        result.put("rfidTag", animal.getRfidTag());
        result.put("species", animal.getSpecies() != null ? animal.getSpecies().name() : null);
        result.put("breed", animal.getBreed());
        result.put("gender", animal.getGender() != null ? animal.getGender().name() : null);
        result.put("weight", animal.getWeight());
        result.put("status", animal.getStatus() != null ? animal.getStatus().name() : null);
        result.put("color", animal.getColor());
        result.put("birthDate", animal.getBirthDate());

        result.put("currentFarm", animal.getFarm() != null ? animal.getFarm().getName() : null);
        result.put("currentFarmId", animal.getFarm() != null ? animal.getFarm().getId() : null);
        result.put("currentFarmWilaya", animal.getFarm() != null ? animal.getFarm().getWilaya() : null);

        result.put("mother", animal.getMother() != null ? simpleAnimalMap(animal.getMother()) : null);
        result.put("father", animal.getFather() != null ? simpleAnimalMap(animal.getFather()) : null);

        result.put("movements",
                movementRepository.findByAnimalIdOrderByMovementDateDesc(animal.getId())
                        .stream()
                        .map(m -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("id", m.getId());
                            map.put("type", m.getMovementType() != null ? m.getMovementType().name() : null);
                            map.put("fromFarm", m.getFromFarm() != null ? m.getFromFarm().getName() : null);
                            map.put("toFarm", m.getToFarm() != null ? m.getToFarm().getName() : null);
                            map.put("date", m.getMovementDate());
                            map.put("price", m.getPrice());
                            map.put("counterpartyName", m.getCounterpartyName());
                            map.put("performedBy", m.getPerformedBy() != null ? m.getPerformedBy().getUsername() : null);
                            map.put("notes", m.getNotes());
                            return map;
                        })
                        .toList()
        );

        result.put("vaccinations",
                vaccinationRepository.findByAnimalIdOrderByVaccinationDateDesc(animal.getId())
                        .stream()
                        .map(v -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("id", v.getId());
                            map.put("vaccineName", v.getVaccineName());
                            map.put("vaccineType", v.getVaccineType());
                            map.put("manufacturer", v.getManufacturer());
                            map.put("batchNumber", v.getBatchNumber());
                            map.put("vaccinationDate", v.getVaccinationDate());
                            map.put("expirationDate", v.getExpirationDate());
                            map.put("veterinarian", v.getVeterinarian() != null ? v.getVeterinarian().getUsername() : null);
                            return map;
                        })
                        .toList()
        );

        result.put("healthRecords",
                healthRecordRepository.findByAnimalIdOrderByVisitDateDesc(animal.getId())
                        .stream()
                        .map(r -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("id", r.getId());
                            map.put("recordType", r.getRecordType() != null ? r.getRecordType().name() : null);
                            map.put("diagnosis", r.getDiagnosis());
                            map.put("symptoms", r.getSymptoms());
                            map.put("treatment", r.getTreatment());
                            map.put("visitDate", r.getVisitDate());
                            map.put("nextVisitDate", r.getNextVisitDate());
                            map.put("isResolved", r.getIsResolved());
                            map.put("severity", r.getSeverity() != null ? r.getSeverity().name() : null);
                            map.put("veterinarian", r.getVeterinarian() != null ? r.getVeterinarian().getUsername() : null);
                            return map;
                        })
                        .toList()
        );

        result.put("events",
                animalEventRepository.findByAnimalIdOrderByEventDateDesc(animal.getId())
                        .stream()
                        .map(e -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("id", e.getId());
                            map.put("eventType", e.getEventType() != null ? e.getEventType().name() : null);
                            map.put("eventDate", e.getEventDate());
                            map.put("location", e.getLocation());
                            map.put("latitude", e.getLatitude());
                            map.put("longitude", e.getLongitude());
                            map.put("performedBy", e.getPerformedBy() != null ? e.getPerformedBy().getUsername() : null);
                            map.put("notes", e.getNotes());
                            return map;
                        })
                        .toList()
        );

        List<Map<String, Object>> offspring = animalRepository.findAll()
                .stream()
                .filter(a ->
                        (a.getMother() != null && a.getMother().getId().equals(animal.getId()))
                                ||
                                (a.getFather() != null && a.getFather().getId().equals(animal.getId()))
                )
                .map(a -> {
                    Map<String, Object> map = simpleAnimalMap(a);
                    map.put("birthDate", a.getBirthDate());
                    map.put("status", a.getStatus() != null ? a.getStatus().name() : null);
                    map.put("relation",
                            a.getMother() != null && a.getMother().getId().equals(animal.getId())
                                    ? "Fils/Fille côté mère"
                                    : "Fils/Fille côté père"
                    );
                    return map;
                })
                .toList();

        result.put("offspring", offspring);

        return result;
    }

    private Map<String, Object> simpleAnimalMap(Animal a) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", a.getId());
        map.put("rfidTag", a.getRfidTag());
        map.put("species", a.getSpecies() != null ? a.getSpecies().name() : null);
        map.put("breed", a.getBreed());
        map.put("gender", a.getGender() != null ? a.getGender().name() : null);
        return map;
    }
}
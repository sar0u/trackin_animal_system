package com.hbtech.cheptel.controller;

import com.hbtech.cheptel.dto.response.AnimalHistoryResponse;
import com.hbtech.cheptel.dto.response.AnimalResponse;
import com.hbtech.cheptel.dto.response.HealthSheetResponse;
import com.hbtech.cheptel.entity.Animal;
import com.hbtech.cheptel.entity.AnimalStatus;
import com.hbtech.cheptel.entity.User;
import com.hbtech.cheptel.repository.AnimalRepository;
import com.hbtech.cheptel.repository.HealthAlertRepository;
import com.hbtech.cheptel.repository.HealthRecordRepository;
import com.hbtech.cheptel.repository.VaccinationRepository;
import com.hbtech.cheptel.service.AlertGeneratorService;
import com.hbtech.cheptel.service.AnimalService;
import com.hbtech.cheptel.service.CurrentUserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/fermier")
public class FermierController {

    private final AnimalService animalService;
    private final CurrentUserService currentUserService;
    private final AnimalRepository animalRepository;
    private final VaccinationRepository vaccinationRepository;
    private final HealthRecordRepository healthRecordRepository;
    private final HealthAlertRepository healthAlertRepository;
    private final AlertGeneratorService alertGeneratorService;

    public FermierController(
            AnimalService animalService,
            CurrentUserService currentUserService,
            AnimalRepository animalRepository,
            VaccinationRepository vaccinationRepository,
            HealthRecordRepository healthRecordRepository,
            HealthAlertRepository healthAlertRepository,
            AlertGeneratorService alertGeneratorService
    ) {
        this.animalService = animalService;
        this.currentUserService = currentUserService;
        this.animalRepository = animalRepository;
        this.vaccinationRepository = vaccinationRepository;
        this.healthRecordRepository = healthRecordRepository;
        this.healthAlertRepository = healthAlertRepository;
        this.alertGeneratorService = alertGeneratorService;
    }

    @GetMapping("/stats")
    @PreAuthorize("hasRole('FERMIER')")
    public ResponseEntity<?> getFermierStats() {

        User current = currentUserService.getCurrentUserOrThrow();

        if (current.getFarm() == null) {
            return ResponseEntity.status(403)
                    .body(Map.of("message", "Aucune ferme associée"));
        }

        Long farmId = current.getFarm().getId();

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalAnimaux", animalRepository.countByFarmId(farmId));
        stats.put("animauxActifs", animalRepository.countByFarmIdAndStatus(farmId, AnimalStatus.ACTIVE));
        stats.put("animauxVendus", animalRepository.countByFarmIdAndStatus(farmId, AnimalStatus.SOLD));
        stats.put("animauxMorts", animalRepository.countByFarmIdAndStatus(farmId, AnimalStatus.DEAD));
        stats.put("farmName", current.getFarm().getName());
        stats.put("farmId", farmId);

        return ResponseEntity.ok(stats);
    }

    @GetMapping("/animals")
    @PreAuthorize("hasRole('FERMIER')")
    public ResponseEntity<?> getMyAnimals() {

        User current = currentUserService.getCurrentUserOrThrow();

        if (current.getFarm() == null) {
            return ResponseEntity.status(403)
                    .body(Map.of("message", "Aucune ferme associée"));
        }

        List<Animal> animals = animalRepository.findByFarmId(current.getFarm().getId());

        List<AnimalResponse> response = animals.stream()
                .map(a -> AnimalResponse.builder()
                        .id(a.getId())
                        .rfidTag(a.getRfidTag())
                        .species(a.getSpecies())
                        .breed(a.getBreed())
                        .gender(a.getGender())
                        .weight(a.getWeight())
                        .status(a.getStatus())
                        .color(a.getColor())
                        .birthDate(a.getBirthDate())
                        .farmId(a.getFarm().getId())
                        .farmName(a.getFarm().getName())
                        .build())
                .toList();

        return ResponseEntity.ok(response);
    }

    @GetMapping("/alerts")
    @PreAuthorize("hasRole('FERMIER')")
    public ResponseEntity<?> getMyAlerts() {

        alertGeneratorService.generateAll();

        User current = currentUserService.getCurrentUserOrThrow();

        if (current.getFarm() == null) {
            return ResponseEntity.ok(List.of());
        }

        List<Animal> animals = animalRepository.findByFarmId(current.getFarm().getId());

        List<Map<String, Object>> alerts = animals.stream()
                .flatMap(animal ->
                        healthAlertRepository
                                .findByAnimalIdAndIsResolvedFalseOrderByDueDateAsc(animal.getId())
                                .stream()
                                .map(alert -> {
                                    Map<String, Object> map = new HashMap<>();
                                    map.put("id", alert.getId());
                                    map.put("animalId", animal.getId());
                                    map.put("animalRfidTag", animal.getRfidTag());
                                    map.put("alertType", alert.getAlertType() != null ? alert.getAlertType().name() : null);
                                    map.put("message", alert.getMessage());
                                    map.put("dueDate", alert.getDueDate() != null ? alert.getDueDate().toString() : null);
                                    map.put("severity", alert.getSeverity() != null ? alert.getSeverity().name() : "INFO");
                                    return map;
                                })
                )
                .toList();

        return ResponseEntity.ok(alerts);
    }

    @GetMapping("/animals/rfid/{rfidTag}/history")
    @PreAuthorize("hasRole('FERMIER')")
    public ResponseEntity<?> getAnimalHistory(@PathVariable String rfidTag) {

        User current = currentUserService.getCurrentUserOrThrow();
        Animal animal = animalService.getByRfidOrThrow(rfidTag);

        Long userFarmId = current.getFarm() != null ? current.getFarm().getId() : null;

        if (userFarmId == null || !userFarmId.equals(animal.getFarm().getId())) {
            return ResponseEntity.status(403)
                    .body(Map.of("message", "Cet animal n'appartient pas à votre exploitation"));
        }

        List<HealthSheetResponse.VaccinationDto> vaccinations =
                vaccinationRepository.findByAnimalIdOrderByVaccinationDateDesc(animal.getId())
                        .stream()
                        .map(v -> HealthSheetResponse.VaccinationDto.builder()
                                .id(v.getId())
                                .vaccineName(v.getVaccineName())
                                .vaccineType(v.getVaccineType())
                                .vaccinationDate(v.getVaccinationDate())
                                .expirationDate(v.getExpirationDate())
                                .batchNumber(v.getBatchNumber())
                                .manufacturer(v.getManufacturer())
                                .build())
                        .toList();

        List<HealthSheetResponse.HealthRecordDto> records =
                healthRecordRepository.findByAnimalIdOrderByVisitDateDesc(animal.getId())
                        .stream()
                        .map(r -> HealthSheetResponse.HealthRecordDto.builder()
                                .id(r.getId())
                                .recordType(r.getRecordType() != null ? r.getRecordType().name() : null)
                                .diagnosis(r.getDiagnosis())
                                .symptoms(r.getSymptoms())
                                .treatment(r.getTreatment())
                                .visitDate(r.getVisitDate())
                                .nextVisitDate(r.getNextVisitDate())
                                .veterinarianName(
                                        r.getVeterinarian() != null
                                                ? r.getVeterinarian().getUsername()
                                                : null
                                )
                                .build())
                        .toList();

        AnimalHistoryResponse response = AnimalHistoryResponse.builder()
                .animalId(animal.getId())
                .rfidTag(animal.getRfidTag())
                .species(animal.getSpecies().name())
                .breed(animal.getBreed())
                .status(animal.getStatus().name())
                .farmName(animal.getFarm().getName())
                .vaccinations(vaccinations)
                .healthRecords(records)
                .build();

        return ResponseEntity.ok(response);
    }
}
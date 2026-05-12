package com.dzcheptel.backend.controller;

import com.dzcheptel.backend.entity.Animal;
import com.dzcheptel.backend.entity.HealthRecord;
import com.dzcheptel.backend.entity.RecordType;
import com.dzcheptel.backend.entity.Vaccination;
import com.dzcheptel.backend.repository.AnimalRepository;
import com.dzcheptel.backend.repository.HealthRecordRepository;
import com.dzcheptel.backend.repository.VaccinationRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import com.dzcheptel.backend.entity.User;
import com.dzcheptel.backend.repository.UserRepository;
import com.dzcheptel.backend.service.impl.UserDetailsImpl;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/veterinaire")
@Tag(name = "Veterinarian", description = "Endpoints pour le rôle vétérinaire")
@RequiredArgsConstructor
public class VeterinaireController {

    private final AnimalRepository animalRepository;
    private final HealthRecordRepository healthRecordRepository;
    private final VaccinationRepository vaccinationRepository;
    private final UserRepository userRepository;

    @GetMapping("/animals/rfid/{rfidCode}/health")
    @Operation(summary = "Fiche santé complète d'un animal par RFID")
    public ResponseEntity<?> getHealthSheet(@PathVariable String rfidCode) {
        Animal animal = animalRepository.findByRfidCode(rfidCode).orElse(null);
        if (animal == null) {
            return ResponseEntity.notFound().build();
        }

        List<HealthRecord> records = healthRecordRepository.findByAnimalId(animal.getId());

        List<Map<String, Object>> vaccinations = records.stream()
            .flatMap(hr -> vaccinationRepository.findByHealthRecordId(hr.getId()).stream()
                .map(this::buildVaccination))
            .collect(Collectors.toList());

        List<Map<String, Object>> healthRecords = records.stream()
            .map(this::buildHealthRecord)
            .collect(Collectors.toList());

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("animalId", animal.getId());
        response.put("rfidTag", animal.getRfidTag());
        response.put("species", animal.getSpecies() != null ? animal.getSpecies().name() : null);
        response.put("breed", animal.getBreed());
        response.put("weight", animal.getWeight());
        response.put("status", animal.getStatus() != null ? animal.getStatus().name() : null);
        response.put("farmName", animal.getFarm() != null ? animal.getFarm().getName() : null);
        response.put("vaccinations", vaccinations);
        response.put("healthRecords", healthRecords);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/animals/rfid/{rfidCode}/health-records")
    @Operation(summary = "Créer un nouveau dossier santé pour un animal")
    public ResponseEntity<?> createHealthRecord(
            @PathVariable String rfidCode,
            @RequestBody Map<String, Object> payload) {
        Animal animal = animalRepository.findByRfidCode(rfidCode).orElse(null);
        if (animal == null) {
            return ResponseEntity.notFound().build();
        }

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User veterinarian = null;
        if (auth != null && auth.getPrincipal() instanceof UserDetailsImpl) {
            UserDetailsImpl userDetails = (UserDetailsImpl) auth.getPrincipal();
            veterinarian = userRepository.findById(userDetails.getId()).orElse(null);
        }

        HealthRecord record = new HealthRecord();
        record.setAnimal(animal);
        record.setVeterinarian(veterinarian);

        String recordTypeStr = (String) payload.get("recordType");
        if (recordTypeStr != null) {
            try {
                record.setRecordType(RecordType.valueOf(recordTypeStr));
            } catch (IllegalArgumentException e) {
                record.setRecordType(RecordType.Treatment);
            }
        }

        record.setDiagnosis((String) payload.get("diagnosis"));
        record.setSymptoms((String) payload.get("symptoms"));
        record.setTreatmentPlan((String) payload.get("treatment"));

        String visitDateStr = (String) payload.get("visitDate");
        if (visitDateStr != null) {
            try {
                record.setVisitDate(LocalDateTime.parse(visitDateStr, DateTimeFormatter.ISO_DATE_TIME));
            } catch (Exception e) {
                record.setVisitDate(LocalDateTime.now());
            }
        } else {
            record.setVisitDate(LocalDateTime.now());
        }

        String nextVisitStr = (String) payload.get("nextVisitDate");
        if (nextVisitStr != null) {
            try {
                LocalDateTime nextVisitDateTime = LocalDateTime.parse(nextVisitStr, DateTimeFormatter.ISO_DATE_TIME);
                record.setNextVisitDate(nextVisitDateTime.toLocalDate());
            } catch (Exception e) {
                // ignore
            }
        }

        HealthRecord saved = healthRecordRepository.save(record);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("id", saved.getId());
        response.put("recordType", saved.getRecordType() != null ? saved.getRecordType().name() : null);
        response.put("diagnosis", saved.getDiagnosis());
        response.put("symptoms", saved.getSymptoms());
        response.put("treatment", saved.getTreatmentPlan());
        response.put("visitDate", saved.getVisitDate() != null ? saved.getVisitDate().toLocalDate().toString() : null);
        response.put("nextVisitDate", saved.getNextVisitDate() != null ? saved.getNextVisitDate().toString() : null);
        String vetName = null;
        if (saved.getVeterinarian() != null) {
            vetName = saved.getVeterinarian().getFirstName() + " " + saved.getVeterinarian().getLastName();
        }
        response.put("veterinarianName", vetName);

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    private Map<String, Object> buildVaccination(Vaccination v) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", v.getId());
        m.put("vaccineName", v.getVaccineName());
        m.put("vaccineType", v.getVaccineType());
        m.put("manufacturer", v.getManufacturer());
        m.put("batchNumber", v.getBatchNumber());
        m.put("vaccinationDate", null);
        m.put("expirationDate", v.getExpirationDate() != null ? v.getExpirationDate().toString() : null);
        return m;
    }

    private Map<String, Object> buildHealthRecord(HealthRecord hr) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", hr.getId());
        m.put("recordType", hr.getRecordType() != null ? hr.getRecordType().name() : null);
        m.put("diagnosis", hr.getDiagnosis());
        m.put("symptoms", hr.getSymptoms());
        m.put("treatment", hr.getTreatmentPlan());
        m.put("visitDate", hr.getVisitDate() != null ? hr.getVisitDate().toLocalDate().toString() : null);
        m.put("nextVisitDate", hr.getNextVisitDate() != null ? hr.getNextVisitDate().toString() : null);
        String vetName = null;
        if (hr.getVeterinarian() != null) {
            vetName = hr.getVeterinarian().getFirstName() + " " + hr.getVeterinarian().getLastName();
        }
        m.put("veterinarianName", vetName);
        return m;
    }
}

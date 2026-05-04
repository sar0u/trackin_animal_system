package com.hbtech.cheptel.service;

import com.hbtech.cheptel.dto.request.CreateHealthRecordRequest;
import com.hbtech.cheptel.dto.request.CreateVaccinationRequest;
import com.hbtech.cheptel.dto.response.HealthSheetResponse;
import com.hbtech.cheptel.entity.Animal;
import com.hbtech.cheptel.entity.HealthRecord;
import com.hbtech.cheptel.entity.User;
import com.hbtech.cheptel.entity.Vaccination;
import com.hbtech.cheptel.repository.HealthRecordRepository;
import com.hbtech.cheptel.repository.VaccinationRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class VeterinaireService {

    private final AnimalService animalService;
    private final VaccinationRepository vaccinationRepository;
    private final HealthRecordRepository healthRecordRepository;
    private final CurrentUserService currentUserService;

    public VeterinaireService(
            AnimalService animalService,
            VaccinationRepository vaccinationRepository,
            HealthRecordRepository healthRecordRepository,
            CurrentUserService currentUserService
    ) {
        this.animalService = animalService;
        this.vaccinationRepository = vaccinationRepository;
        this.healthRecordRepository = healthRecordRepository;
        this.currentUserService = currentUserService;
    }

    // ============================
    // FICHE MÉDICALE PAR RFID
    // ============================

    public HealthSheetResponse getHealthSheetByRfid(String rfidTag) {

        Animal animal = animalService.getByRfidOrThrow(rfidTag);

        List<HealthSheetResponse.VaccinationDto> vaccinations =
                vaccinationRepository
                        .findByAnimalIdOrderByVaccinationDateDesc(animal.getId())
                        .stream()
                        .map(v -> HealthSheetResponse.VaccinationDto.builder()
                                .id(v.getId())
                                .vaccineName(v.getVaccineName())
                                .vaccineType(v.getVaccineType())
                                .manufacturer(v.getManufacturer())
                                .batchNumber(v.getBatchNumber())
                                .vaccinationDate(v.getVaccinationDate())
                                .expirationDate(v.getExpirationDate())
                                .build())
                        .toList();

        List<HealthSheetResponse.HealthRecordDto> healthRecords =
                healthRecordRepository
                        .findByAnimalIdOrderByVisitDateDesc(animal.getId())
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

        return HealthSheetResponse.builder()
                .animalId(animal.getId())
                .rfidTag(animal.getRfidTag())
                .species(animal.getSpecies() != null ? animal.getSpecies().name() : null)
                .breed(animal.getBreed())
                .weight(animal.getWeight())
                .status(animal.getStatus() != null ? animal.getStatus().name() : null)
                .farmId(animal.getFarm() != null ? animal.getFarm().getId() : null)
                .farmName(animal.getFarm() != null ? animal.getFarm().getName() : null)
                .vaccinations(vaccinations)
                .healthRecords(healthRecords)
                .build();
    }

    // ============================
    // AJOUT VACCINATION
    // ============================

    public HealthSheetResponse.VaccinationDto addVaccination(
            String rfidTag,
            CreateVaccinationRequest request
    ) {
        Animal animal = animalService.getByRfidOrThrow(rfidTag);

        Vaccination vaccination = Vaccination.builder()
                .animal(animal)
                .vaccineName(request.getVaccineName())
                .vaccineType(request.getVaccineType())
                .manufacturer(request.getManufacturer())
                .batchNumber(request.getBatchNumber())
                .vaccinationDate(request.getVaccinationDate())
                .expirationDate(request.getExpirationDate())
                .build();

        Vaccination saved = vaccinationRepository.save(vaccination);

        return HealthSheetResponse.VaccinationDto.builder()
                .id(saved.getId())
                .vaccineName(saved.getVaccineName())
                .vaccineType(saved.getVaccineType())
                .manufacturer(saved.getManufacturer())
                .batchNumber(saved.getBatchNumber())
                .vaccinationDate(saved.getVaccinationDate())
                .expirationDate(saved.getExpirationDate())
                .build();
    }

    // ============================
    // AJOUT DOSSIER MÉDICAL
    // ============================

    public HealthSheetResponse.HealthRecordDto addHealthRecord(
            String rfidTag,
            CreateHealthRecordRequest request
    ) {
        Animal animal = animalService.getByRfidOrThrow(rfidTag);
        User veterinarian = currentUserService.getCurrentUserOrThrow();

        HealthRecord record = HealthRecord.builder()
                .animal(animal)
                .recordType(request.getRecordType())
                .diagnosis(request.getDiagnosis())
                .symptoms(request.getSymptoms())
                .treatment(request.getTreatment())
                .veterinarian(veterinarian)
                .visitDate(request.getVisitDate())
                .nextVisitDate(request.getNextVisitDate())
                .build();

        HealthRecord saved = healthRecordRepository.save(record);

        return HealthSheetResponse.HealthRecordDto.builder()
                .id(saved.getId())
                .recordType(saved.getRecordType() != null ? saved.getRecordType().name() : null)
                .diagnosis(saved.getDiagnosis())
                .symptoms(saved.getSymptoms())
                .treatment(saved.getTreatment())
                .visitDate(saved.getVisitDate())
                .nextVisitDate(saved.getNextVisitDate())
                .veterinarianName(veterinarian.getUsername())
                .build();
    }
}
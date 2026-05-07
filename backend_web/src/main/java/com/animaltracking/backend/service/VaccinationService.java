package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.Vaccination;
import java.util.List;

public interface VaccinationService {
    List<Vaccination> getAllVaccinations();
    Vaccination getVaccinationById(Long id);
    List<Vaccination> getVaccinationsByHealthRecord(Long recordId);
    Vaccination createVaccination(Vaccination vaccination);
    Vaccination updateVaccination(Long id, Vaccination vaccinationDetails);
    void deleteVaccination(Long id);
}
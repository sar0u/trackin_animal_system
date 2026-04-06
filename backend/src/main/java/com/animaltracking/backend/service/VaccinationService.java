package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.Vaccination;
import java.util.List;

public interface VaccinationService {
    List<Vaccination> getAllVaccinations();
    Vaccination getVaccinationById(Integer id);
    List<Vaccination> getVaccinationsByHealthRecord(Integer recordId);
    Vaccination createVaccination(Vaccination vaccination);
    Vaccination updateVaccination(Integer id, Vaccination vaccinationDetails);
    void deleteVaccination(Integer id);
}
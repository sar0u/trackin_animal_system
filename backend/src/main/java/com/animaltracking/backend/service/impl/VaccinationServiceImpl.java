package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.Vaccination;
import com.animaltracking.backend.repository.VaccinationRepository;
import com.animaltracking.backend.service.VaccinationService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@Transactional
public class VaccinationServiceImpl implements VaccinationService {

    @Autowired
    private VaccinationRepository vaccinationRepository;

    @Override
    public List<Vaccination> getAllVaccinations() {
        return vaccinationRepository.findAll();
    }

    @Override
    public Vaccination getVaccinationById(Integer id) {
        return vaccinationRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Vaccination non trouvée (ID: " + id + ")"));
    }

    @Override
    public List<Vaccination> getVaccinationsByHealthRecord(Integer recordId) {
        return vaccinationRepository.findByHealthRecordId(recordId);
    }

    @Override
    public Vaccination createVaccination(Vaccination vaccination) {
        return vaccinationRepository.save(vaccination);
    }

    @Override
    public Vaccination updateVaccination(Integer id, Vaccination vaccinationDetails) {
        Vaccination vaccination = getVaccinationById(id);

        vaccination.setVaccineName(vaccinationDetails.getVaccineName());
        vaccination.setBatchNumber(vaccinationDetails.getBatchNumber());
        vaccination.setExpirationDate(vaccinationDetails.getExpirationDate());

        if (vaccinationDetails.getHealthRecord() != null) {
            vaccination.setHealthRecord(vaccinationDetails.getHealthRecord());
        }

        return vaccinationRepository.save(vaccination);
    }

    @Override
    public void deleteVaccination(Integer id) {
        Vaccination vaccination = getVaccinationById(id);
        vaccinationRepository.delete(vaccination);
    }
}
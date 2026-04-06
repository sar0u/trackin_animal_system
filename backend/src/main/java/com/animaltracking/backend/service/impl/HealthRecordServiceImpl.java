package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.HealthRecord;
import com.animaltracking.backend.repository.HealthRecordRepository;
import com.animaltracking.backend.service.HealthRecordService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@Transactional
public class HealthRecordServiceImpl implements HealthRecordService {

    @Autowired
    private HealthRecordRepository healthRecordRepository;

    @Override
    public List<HealthRecord> getAllRecords() {
        return healthRecordRepository.findAll();
    }

    @Override
    public HealthRecord getRecordById(Integer id) {
        return healthRecordRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Dossier médical non trouvé (ID: " + id + ")"));
    }

    @Override
    public List<HealthRecord> getRecordsByAnimal(Integer animalId) {
        return healthRecordRepository.findByAnimalId(animalId);
    }

    @Override
    public HealthRecord createRecord(HealthRecord record) {
        return healthRecordRepository.save(record);
    }

    @Override
    public HealthRecord updateRecord(Integer id, HealthRecord recordDetails) {
        HealthRecord record = getRecordById(id);
        record.setVisitTimestamp(recordDetails.getVisitTimestamp());
        record.setRecordType(recordDetails.getRecordType());
        record.setClinicalDiagnosis(recordDetails.getClinicalDiagnosis());
        record.setTreatmentPlan(recordDetails.getTreatmentPlan());

        if (recordDetails.getAnimal() != null) record.setAnimal(recordDetails.getAnimal());
        if (recordDetails.getVeterinarian() != null) record.setVeterinarian(recordDetails.getVeterinarian());

        return healthRecordRepository.save(record);
    }

    @Override
    public void deleteRecord(Integer id) {
        HealthRecord record = getRecordById(id);
        healthRecordRepository.delete(record);
    }
}
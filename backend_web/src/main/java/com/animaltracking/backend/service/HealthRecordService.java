package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.HealthRecord;
import java.util.List;

public interface HealthRecordService {
    List<HealthRecord> getAllRecords();
    HealthRecord getRecordById(Long id);
    List<HealthRecord> getRecordsByAnimal(Long animalId);
    HealthRecord createRecord(HealthRecord record);
    HealthRecord updateRecord(Long id, HealthRecord recordDetails);
    void deleteRecord(Long id);
}
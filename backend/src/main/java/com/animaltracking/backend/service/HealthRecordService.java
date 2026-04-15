package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.HealthRecord;
import java.util.List;

public interface HealthRecordService {
    List<HealthRecord> getAllRecords();
    HealthRecord getRecordById(Integer id);
    List<HealthRecord> getRecordsByAnimal(Integer animalId);
    HealthRecord createRecord(HealthRecord record);
    HealthRecord updateRecord(Integer id, HealthRecord recordDetails);
    void deleteRecord(Integer id);
}
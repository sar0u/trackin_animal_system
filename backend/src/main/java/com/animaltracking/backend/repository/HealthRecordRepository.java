package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.HealthRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface HealthRecordRepository extends JpaRepository<HealthRecord, Integer> {
    List<HealthRecord> findByAnimalId(Integer animalId);
    List<HealthRecord> findByVeterinarianId(Integer vetId);
}
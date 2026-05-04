package com.hbtech.cheptel.repository;

import com.hbtech.cheptel.entity.HealthRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface HealthRecordRepository extends JpaRepository<HealthRecord, Long> {

    List<HealthRecord> findByAnimalIdOrderByVisitDateDesc(Long animalId);
}
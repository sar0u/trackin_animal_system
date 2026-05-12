package com.dzcheptel.backend.repository;

import com.dzcheptel.backend.entity.HealthRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface HealthRecordRepository extends JpaRepository<HealthRecord, Long> {

    @Query("SELECT DISTINCT hr FROM HealthRecord hr "
            + "LEFT JOIN FETCH hr.animal a "
            + "LEFT JOIN FETCH a.rfidTagEntity "
            + "LEFT JOIN FETCH a.owner "
            + "LEFT JOIN FETCH a.farm "
            + "LEFT JOIN FETCH hr.veterinarian")
    List<HealthRecord> findAllFetched();

    List<HealthRecord> findByAnimalId(Long animalId);
    List<HealthRecord> findByVeterinarianId(Long vetId);
}
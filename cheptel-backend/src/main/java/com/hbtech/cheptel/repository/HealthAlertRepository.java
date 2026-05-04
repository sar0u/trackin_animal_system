package com.hbtech.cheptel.repository;

import com.hbtech.cheptel.entity.HealthAlert;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface HealthAlertRepository extends JpaRepository<HealthAlert, Long> {

    List<HealthAlert> findByIsResolvedFalseOrderByDueDateAsc();

    List<HealthAlert> findByAnimalIdAndIsResolvedFalseOrderByDueDateAsc(Long animalId);

    long countByIsResolvedFalse();
}
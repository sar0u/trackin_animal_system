package com.dzcheptel.backend.repository;

import com.dzcheptel.backend.entity.Alert;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AlertRepository extends JpaRepository<Alert, Long> {

    List<Alert> findByFarmId(Long farmId);

    List<Alert> findByFarmIdAndIsResolvedFalse(Long farmId);

    List<Alert> findByAnimalId(Long animalId);
}

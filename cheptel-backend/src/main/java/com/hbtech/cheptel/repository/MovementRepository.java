package com.hbtech.cheptel.repository;

import com.hbtech.cheptel.entity.Movement;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MovementRepository extends JpaRepository<Movement, Long> {
    List<Movement> findByAnimalIdOrderByMovementDateDesc(Long animalId);
    List<Movement> findByFromFarmIdOrToFarmIdOrderByMovementDateDesc(Long fromFarmId, Long toFarmId);
}
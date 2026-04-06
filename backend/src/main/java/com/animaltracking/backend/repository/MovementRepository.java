package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.Movement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface MovementRepository extends JpaRepository<Movement, Integer> {
    List<Movement> findByAnimalId(Integer animalId);
    List<Movement> findByDestinationFarmId(Integer farmId);
}
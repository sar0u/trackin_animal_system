package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.Movement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface MovementRepository extends JpaRepository<Movement, Integer> {

    // Spring va chercher le champ "animalId" dans la classe Movement
    List<Movement> findByAnimalId(Integer animalId);

    // Spring va chercher le champ "destinationFarmId" dans la classe Movement
    List<Movement> findByDestinationFarmId(Integer destinationFarmId);
}
package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.Movement;
import java.util.List;

public interface MovementService {
    List<Movement> getAllMovements();
    Movement getMovementById(Integer id);
    List<Movement> getMovementsByAnimal(Integer animalId);
    Movement createMovement(Movement movement);
    void deleteMovement(Integer id);
}
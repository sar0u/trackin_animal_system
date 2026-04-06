package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.Movement;
import com.animaltracking.backend.repository.MovementRepository;
import com.animaltracking.backend.service.MovementService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@Transactional
public class MovementServiceImpl implements MovementService {

    @Autowired
    private MovementRepository movementRepository;

    @Override
    public List<Movement> getAllMovements() {
        return movementRepository.findAll();
    }

    @Override
    public Movement getMovementById(Integer id) {
        return movementRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Mouvement non trouvé (ID: " + id + ")"));
    }

    @Override
    public List<Movement> getMovementsByAnimal(Integer animalId) {
        return movementRepository.findByAnimalId(animalId);
    }

    @Override
    public Movement createMovement(Movement movement) {
        // En général, les mouvements sont créés via trigger,
        // mais on garde la méthode pour l'insertion manuelle si besoin.
        return movementRepository.save(movement);
    }

    @Override
    public void deleteMovement(Integer id) {
        Movement movement = getMovementById(id);
        movementRepository.delete(movement);
    }
}
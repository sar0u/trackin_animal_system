package com.hbtech.cheptel.service;

import com.hbtech.cheptel.dto.CreateMovementRequest;
import com.hbtech.cheptel.dto.response.MovementResponse;
import com.hbtech.cheptel.entity.*;
import com.hbtech.cheptel.repository.AnimalRepository;
import com.hbtech.cheptel.repository.FarmRepository;
import org.springframework.stereotype.Service;
import com.hbtech.cheptel.repository.MovementRepository;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class MovementService {

    private final MovementRepository movementRepository;
    private final AnimalRepository animalRepository;
    private final FarmRepository farmRepository;
    private final CurrentUserService currentUserService;

    public MovementService(
            MovementRepository movementRepository,
            AnimalRepository animalRepository,
            FarmRepository farmRepository,
            CurrentUserService currentUserService
    ) {
        this.movementRepository = movementRepository;
        this.animalRepository = animalRepository;
        this.farmRepository = farmRepository;
        this.currentUserService = currentUserService;
    }

    public MovementResponse createMovement(CreateMovementRequest request) {
        User currentUser = currentUserService.getCurrentUserOrThrow();

        Animal animal = animalRepository.findById(request.getAnimalId())
                .orElseThrow(() -> new RuntimeException("Animal introuvable"));

        Farm fromFarm = request.getFromFarmId() != null
                ? farmRepository.findById(request.getFromFarmId()).orElse(null)
                : animal.getFarm();

        Farm toFarm = request.getToFarmId() != null
                ? farmRepository.findById(request.getToFarmId()).orElse(null)
                : null;

        Movement movement = Movement.builder()
                .animal(animal)
                .movementType(request.getMovementType())
                .fromFarm(fromFarm)
                .toFarm(toFarm)
                .movementDate(request.getMovementDate() != null ? request.getMovementDate() : LocalDateTime.now())
                .price(request.getPrice())
                .counterpartyName(request.getCounterpartyName())
                .counterpartyPhone(request.getCounterpartyPhone())
                .documentReference(request.getDocumentReference())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .performedBy(currentUser)
                .notes(request.getNotes())
                .build();

        Movement saved = movementRepository.save(movement);

        // Mise à jour automatique du statut/ferme de l'animal
        applyMovementToAnimal(animal, request, toFarm);
        animalRepository.save(animal);

        return toResponse(saved);
    }

    private void applyMovementToAnimal(Animal animal, CreateMovementRequest request, Farm toFarm) {
        switch (request.getMovementType()) {
            case SALE -> animal.setStatus(AnimalStatus.SOLD);
            case TRANSFER -> {
                if (toFarm != null) animal.setFarm(toFarm);
            }
            case SLAUGHTER -> animal.setStatus(AnimalStatus.SLAUGHTERED);
            case DEATH -> animal.setStatus(AnimalStatus.DEAD);
        }
    }

    public List<MovementResponse> getMovementsByAnimal(Long animalId) {
        return movementRepository.findByAnimalIdOrderByMovementDateDesc(animalId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private MovementResponse toResponse(Movement m) {
        return MovementResponse.builder()
                .id(m.getId())
                .animalId(m.getAnimal().getId())
                .animalRfidTag(m.getAnimal().getRfidTag())
                .movementType(m.getMovementType().name())
                .fromFarmId(m.getFromFarm() != null ? m.getFromFarm().getId() : null)
                .fromFarmName(m.getFromFarm() != null ? m.getFromFarm().getName() : null)
                .toFarmId(m.getToFarm() != null ? m.getToFarm().getId() : null)
                .toFarmName(m.getToFarm() != null ? m.getToFarm().getName() : null)
                .movementDate(m.getMovementDate())
                .price(m.getPrice())
                .counterpartyName(m.getCounterpartyName())
                .counterpartyPhone(m.getCounterpartyPhone())
                .documentReference(m.getDocumentReference())
                .latitude(m.getLatitude())
                .longitude(m.getLongitude())
                .performedByUsername(m.getPerformedBy().getUsername())
                .notes(m.getNotes())
                .createdAt(m.getCreatedAt())
                .build();
    }
}
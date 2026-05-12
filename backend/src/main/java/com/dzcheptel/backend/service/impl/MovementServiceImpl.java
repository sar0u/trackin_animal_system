package com.dzcheptel.backend.service.impl;

import com.dzcheptel.backend.entity.Movement;
import com.dzcheptel.backend.repository.MovementRepository;
import com.dzcheptel.backend.service.MovementService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MovementServiceImpl implements MovementService {

    private final MovementRepository movementRepository;

    @Override
    public List<Map<String, Object>> listForApi() {
        return movementRepository.findAllFetched().stream()
                .map(this::mapToSafeMap)
                .collect(Collectors.toList());
    }

    @Override
    public Map<String, Object> getForApi(Long id) {
        Movement movement = movementRepository.findFetchedById(id)
                .orElseThrow(() -> new EntityNotFoundException("Mouvement non trouvé"));
        return mapToSafeMap(movement);
    }

    private Map<String, Object> mapToSafeMap(Movement m) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", m.getId());
        map.put("reason", m.getReason());
        map.put("approvalStatus", m.getApprovalStatus());
        map.put("notes", m.getNotes());
        map.put("createdAt", m.getCreatedAt());

        if (m.getAnimal() != null) {
            Map<String, Object> animal = new HashMap<>();
            animal.put("id", m.getAnimal().getId());
            animal.put("species", m.getAnimal().getSpecies());
            if (m.getAnimal().getRfidTagEntity() != null) {
                animal.put("rfidCode", m.getAnimal().getRfidTagEntity().getRfidCode());
            }
            map.put("animal", animal);
        }

        if (m.getFromFarm() != null) {
            Map<String, Object> fromFarm = new HashMap<>();
            fromFarm.put("id", m.getFromFarm().getId());
            fromFarm.put("name", m.getFromFarm().getName());
            map.put("fromFarm", fromFarm);
        }

        if (m.getToFarm() != null) {
            Map<String, Object> toFarm = new HashMap<>();
            toFarm.put("id", m.getToFarm().getId());
            toFarm.put("name", m.getToFarm().getName());
            map.put("toFarm", toFarm);
        }

        if (m.getTreatedBy() != null) {
            Map<String, Object> treatedBy = new HashMap<>();
            treatedBy.put("id", m.getTreatedBy().getId());
            treatedBy.put("username", m.getTreatedBy().getUsername());
            treatedBy.put("firstName", m.getTreatedBy().getFirstName());
            treatedBy.put("lastName", m.getTreatedBy().getLastName());
            map.put("treatedBy", treatedBy);
        }

        return map;
    }
}

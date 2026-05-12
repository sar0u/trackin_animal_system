package com.dzcheptel.backend.service.impl;

import com.dzcheptel.backend.entity.Subsidy;
import com.dzcheptel.backend.repository.SubsidyRepository;
import com.dzcheptel.backend.service.SubsidyService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SubsidyServiceImpl implements SubsidyService {

    private final SubsidyRepository subsidyRepository;

    @Override
    public List<Map<String, Object>> listForApi() {
        return subsidyRepository.findAllFetched().stream()
                .map(this::mapToSafeMap)
                .collect(Collectors.toList());
    }

    @Override
    public Map<String, Object> getForApi(Long id) {
        Subsidy subsidy = subsidyRepository.findFetchedById(id)
                .orElseThrow(() -> new EntityNotFoundException("Subvention introuvable"));
        return mapToSafeMap(subsidy);
    }

    private Map<String, Object> mapToSafeMap(Subsidy s) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", s.getId());
        map.put("amount", s.getAmount());
        map.put("type", s.getType());
        map.put("status", s.getStatus());
        map.put("requestDate", s.getRequestDate());
        map.put("approvedDate", s.getApprovedDate());
        map.put("paidDate", s.getPaidDate());
        map.put("notes", s.getNotes());
        map.put("createdAt", s.getCreatedAt());
        map.put("updatedAt", s.getUpdatedAt());

        if (s.getAnimal() != null) {
            Map<String, Object> animal = new HashMap<>();
            animal.put("id", s.getAnimal().getId());
            animal.put("species", s.getAnimal().getSpecies());
            if (s.getAnimal().getRfidTagEntity() != null) {
                animal.put("rfidCode", s.getAnimal().getRfidTagEntity().getRfidCode());
            }
            if (s.getAnimal().getFarm() != null) {
                Map<String, Object> farm = new HashMap<>();
                farm.put("id", s.getAnimal().getFarm().getId());
                farm.put("name", s.getAnimal().getFarm().getName());
                animal.put("farm", farm);
            }
            if (s.getAnimal().getOwner() != null) {
                Map<String, Object> owner = new HashMap<>();
                owner.put("id", s.getAnimal().getOwner().getId());
                owner.put("firstName", s.getAnimal().getOwner().getFirstName());
                owner.put("lastName", s.getAnimal().getOwner().getLastName());
                animal.put("owner", owner);
            }
            map.put("animal", animal);
        }

        if (s.getTreatedBy() != null) {
            Map<String, Object> treatedBy = new HashMap<>();
            treatedBy.put("id", s.getTreatedBy().getId());
            treatedBy.put("username", s.getTreatedBy().getUsername());
            treatedBy.put("firstName", s.getTreatedBy().getFirstName());
            treatedBy.put("lastName", s.getTreatedBy().getLastName());
            map.put("treatedBy", treatedBy);
        }

        return map;
    }
}

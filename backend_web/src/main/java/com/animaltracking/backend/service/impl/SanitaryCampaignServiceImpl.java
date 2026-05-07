package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.SanitaryCampaign;
import com.animaltracking.backend.repository.SanitaryCampaignRepository;
import com.animaltracking.backend.service.SanitaryCampaignService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class SanitaryCampaignServiceImpl implements SanitaryCampaignService {

    private final SanitaryCampaignRepository repo;

    @Override
    @Transactional(readOnly = true)
    public List<SanitaryCampaign> getAll() {
        return repo.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public SanitaryCampaign getById(Long id) {
        return repo.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Campagne sanitaire introuvable : " + id));
    }

    @Override
    public SanitaryCampaign create(SanitaryCampaign campaign) {
        return repo.save(campaign);
    }

    @Override
    public SanitaryCampaign update(Long id, SanitaryCampaign payload) {
        SanitaryCampaign existing = getById(id);
        existing.setName(payload.getName());
        existing.setDescription(payload.getDescription());
        existing.setVaccineName(payload.getVaccineName());
        existing.setTargetSpecies(payload.getTargetSpecies());
        existing.setStartDate(payload.getStartDate());
        existing.setEndDate(payload.getEndDate());
        existing.setStatus(payload.getStatus());
        return repo.save(existing);
    }

    @Override
    public void delete(Long id) {
        repo.deleteById(id);
    }
}

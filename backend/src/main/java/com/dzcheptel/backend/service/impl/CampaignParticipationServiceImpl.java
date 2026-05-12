package com.dzcheptel.backend.service.impl;

import com.dzcheptel.backend.entity.CampaignParticipation;
import com.dzcheptel.backend.repository.CampaignParticipationRepository;
import com.dzcheptel.backend.service.CampaignParticipationService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class CampaignParticipationServiceImpl implements CampaignParticipationService {

    private final CampaignParticipationRepository repo;

    @Override
    @Transactional(readOnly = true)
    public List<CampaignParticipation> getAll() {
        return repo.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public CampaignParticipation getById(Long id) {
        return repo.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Participation introuvable : " + id));
    }

    @Override
    public CampaignParticipation create(CampaignParticipation participation) {
        return repo.save(participation);
    }

    @Override
    public CampaignParticipation update(Long id, CampaignParticipation payload) {
        CampaignParticipation existing = getById(id);
        existing.setVaccinationDate(payload.getVaccinationDate());
        existing.setStatus(payload.getStatus());
        existing.setNotes(payload.getNotes());
        if (payload.getVeterinarian() != null) existing.setVeterinarian(payload.getVeterinarian());
        return repo.save(existing);
    }

    @Override
    public void delete(Long id) {
        repo.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<CampaignParticipation> getByCampaign(Long campaignId) {
        return repo.findByCampaignId(campaignId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<CampaignParticipation> getByAnimal(Long animalId) {
        return repo.findByAnimalId(animalId);
    }
}

package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.CampaignParticipation;

import java.util.List;

public interface CampaignParticipationService {
    List<CampaignParticipation> getAll();
    CampaignParticipation getById(Long id);
    CampaignParticipation create(CampaignParticipation participation);
    CampaignParticipation update(Long id, CampaignParticipation payload);
    void delete(Long id);
    List<CampaignParticipation> getByCampaign(Long campaignId);
    List<CampaignParticipation> getByAnimal(Long animalId);
}

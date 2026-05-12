package com.dzcheptel.backend.repository;

import com.dzcheptel.backend.entity.CampaignParticipation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CampaignParticipationRepository extends JpaRepository<CampaignParticipation, Long> {

    List<CampaignParticipation> findByCampaignId(Long campaignId);

    List<CampaignParticipation> findByAnimalId(Long animalId);
}

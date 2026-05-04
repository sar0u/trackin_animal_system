package com.hbtech.cheptel.repository;

import com.hbtech.cheptel.entity.CampaignParticipation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CampaignParticipationRepository extends JpaRepository<CampaignParticipation, Long> {

    List<CampaignParticipation> findByCampaignId(Long campaignId);

    List<CampaignParticipation> findByVeterinarianId(Long veterinarianId);

    long countByCampaignIdAndStatus(Long campaignId, String status);
}
package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.CampaignStatus;
import com.animaltracking.backend.entity.SanitaryCampaign;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SanitaryCampaignRepository extends JpaRepository<SanitaryCampaign, Long> {

    List<SanitaryCampaign> findByStatus(CampaignStatus status);
}

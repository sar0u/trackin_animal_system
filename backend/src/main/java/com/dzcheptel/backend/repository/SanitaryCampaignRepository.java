package com.dzcheptel.backend.repository;

import com.dzcheptel.backend.entity.CampaignStatus;
import com.dzcheptel.backend.entity.SanitaryCampaign;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SanitaryCampaignRepository extends JpaRepository<SanitaryCampaign, Long> {

    List<SanitaryCampaign> findByStatus(CampaignStatus status);
}

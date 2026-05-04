package com.hbtech.cheptel.repository;

import com.hbtech.cheptel.entity.SanitaryCampaign;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SanitaryCampaignRepository extends JpaRepository<SanitaryCampaign, Long> {

    List<SanitaryCampaign> findAllByOrderByStartDateDesc();

    List<SanitaryCampaign> findByStatus(String status);
}
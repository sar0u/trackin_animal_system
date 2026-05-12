package com.dzcheptel.backend.service;

import com.dzcheptel.backend.entity.SanitaryCampaign;

import java.util.List;

public interface SanitaryCampaignService {
    List<SanitaryCampaign> getAll();
    SanitaryCampaign getById(Long id);
    SanitaryCampaign create(SanitaryCampaign campaign);
    SanitaryCampaign update(Long id, SanitaryCampaign payload);
    void delete(Long id);
}

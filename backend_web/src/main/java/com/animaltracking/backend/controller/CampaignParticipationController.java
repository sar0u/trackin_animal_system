package com.animaltracking.backend.controller;

import com.animaltracking.backend.entity.CampaignParticipation;
import com.animaltracking.backend.service.CampaignParticipationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/campaign-participations")
@RequiredArgsConstructor
public class CampaignParticipationController {

    private final CampaignParticipationService service;

    @GetMapping
    public List<CampaignParticipation> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<CampaignParticipation> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @GetMapping("/campaign/{campaignId}")
    public List<CampaignParticipation> getByCampaign(@PathVariable Long campaignId) {
        return service.getByCampaign(campaignId);
    }

    @GetMapping("/animal/{animalId}")
    public List<CampaignParticipation> getByAnimal(@PathVariable Long animalId) {
        return service.getByAnimal(animalId);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('Administrator','Veterinarian')")
    public ResponseEntity<CampaignParticipation> create(@RequestBody CampaignParticipation participation) {
        return ResponseEntity.ok(service.create(participation));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Administrator','Veterinarian')")
    public ResponseEntity<CampaignParticipation> update(@PathVariable Long id,
                                                         @RequestBody CampaignParticipation payload) {
        return ResponseEntity.ok(service.update(id, payload));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}

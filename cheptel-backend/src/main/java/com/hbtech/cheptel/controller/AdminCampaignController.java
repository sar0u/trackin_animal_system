package com.hbtech.cheptel.controller;

import com.hbtech.cheptel.entity.*;
import com.hbtech.cheptel.repository.*;
import com.hbtech.cheptel.service.CurrentUserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.*;

@RestController
@RequestMapping("/admin/campaigns")
@PreAuthorize("hasRole('ADMIN')")
public class AdminCampaignController {

    private final SanitaryCampaignRepository campaignRepository;
    private final AnimalRepository animalRepository;
    private final CampaignParticipationRepository participationRepository;
    private final CurrentUserService currentUserService;

    public AdminCampaignController(
            SanitaryCampaignRepository campaignRepository,
            AnimalRepository animalRepository,
            CampaignParticipationRepository participationRepository,
            CurrentUserService currentUserService
    ) {
        this.campaignRepository = campaignRepository;
        this.animalRepository = animalRepository;
        this.participationRepository = participationRepository;
        this.currentUserService = currentUserService;
    }

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getAllCampaigns() {
        List<Map<String, Object>> result = campaignRepository.findAllByOrderByStartDateDesc()
                .stream()
                .map(this::toMap)
                .toList();
        return ResponseEntity.ok(result);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getCampaignDetails(@PathVariable Long id) {
        SanitaryCampaign campaign = campaignRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Campagne introuvable"));

        Map<String, Object> result = toMap(campaign);

        long total = participationRepository.countByCampaignIdAndStatus(id, "DONE") +
                participationRepository.countByCampaignIdAndStatus(id, "PENDING") +
                participationRepository.countByCampaignIdAndStatus(id, "REFUSED");

        long done = participationRepository.countByCampaignIdAndStatus(id, "DONE");
        long pending = participationRepository.countByCampaignIdAndStatus(id, "PENDING");

        result.put("totalAnimaux", total);
        result.put("vaccinés", done);
        result.put("enAttente", pending);

        List<Map<String, Object>> participations = participationRepository.findByCampaignId(id)
                .stream()
                .map(p -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", p.getId());
                    map.put("animalRfid", p.getAnimal() != null ? p.getAnimal().getRfidTag() : null);
                    map.put("animalSpecies", p.getAnimal() != null ? p.getAnimal().getSpecies().name() : null);
                    map.put("farmName", p.getAnimal() != null && p.getAnimal().getFarm() != null ? p.getAnimal().getFarm().getName() : null);
                    map.put("veterinarian", p.getVeterinarian() != null ? p.getVeterinarian().getUsername() : null);
                    map.put("vaccinationDate", p.getVaccinationDate());
                    map.put("status", p.getStatus());
                    map.put("notes", p.getNotes());
                    return map;
                })
                .toList();

        result.put("participations", participations);

        return ResponseEntity.ok(result);
    }

    @PostMapping
    public ResponseEntity<?> createCampaign(@RequestBody Map<String, Object> request) {
        User admin = currentUserService.getCurrentUserOrThrow();

        String name = getString(request.get("name"));
        if (name == null || name.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Nom obligatoire"));
        }

        SanitaryCampaign campaign = SanitaryCampaign.builder()
                .name(name)
                .description(getString(request.get("description")))
                .vaccineName(getString(request.get("vaccineName")))
                .targetSpecies(request.get("targetSpecies") != null ? request.get("targetSpecies").toString() : "ALL")
                .startDate(parseDate(request.get("startDate")))
                .endDate(parseDate(request.get("endDate")))
                .status("PLANNED")
                .createdBy(admin)
                .build();

        SanitaryCampaign saved = campaignRepository.save(campaign);

        // Auto-enroll les animaux concernés
        List<Animal> animals = animalRepository.findAll().stream()
                .filter(a -> a.getStatus() == AnimalStatus.ACTIVE)
                .filter(a -> {
                    String targetSpecies = campaign.getTargetSpecies();
                    if ("ALL".equals(targetSpecies)) return true;
                    return a.getSpecies() != null && a.getSpecies().name().equals(targetSpecies);
                })
                .toList();

        for (Animal animal : animals) {
            CampaignParticipation participation = CampaignParticipation.builder()
                    .campaign(saved)
                    .animal(animal)
                    .status("PENDING")
                    .build();
            participationRepository.save(participation);
        }

        return ResponseEntity.ok(Map.of(
                "message", "Campagne créée avec " + animals.size() + " animaux enrôlés",
                "id", saved.getId()
        ));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> request
    ) {
        SanitaryCampaign campaign = campaignRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Campagne introuvable"));

        campaign.setStatus(request.get("status"));
        campaignRepository.save(campaign);

        return ResponseEntity.ok(Map.of("message", "Statut mis à jour"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteCampaign(@PathVariable Long id) {
        campaignRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "Campagne supprimée"));
    }

    private Map<String, Object> toMap(SanitaryCampaign c) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", c.getId());
        map.put("name", c.getName());
        map.put("description", c.getDescription());
        map.put("vaccineName", c.getVaccineName());
        map.put("targetSpecies", c.getTargetSpecies());
        map.put("startDate", c.getStartDate());
        map.put("endDate", c.getEndDate());
        map.put("status", c.getStatus());
        map.put("createdBy", c.getCreatedBy() != null ? c.getCreatedBy().getUsername() : null);
        map.put("createdAt", c.getCreatedAt());
        return map;
    }

    private String getString(Object v) {
        if (v == null) return null;
        String s = v.toString().trim();
        return s.isEmpty() ? null : s;
    }

    private LocalDate parseDate(Object v) {
        if (v == null) return null;
        try {
            return LocalDate.parse(v.toString());
        } catch (Exception e) {
            return null;
        }
    }
}
package com.hbtech.cheptel.controller;

import com.hbtech.cheptel.dto.request.CreateHealthRecordRequest;
import com.hbtech.cheptel.dto.request.CreateVaccinationRequest;
import com.hbtech.cheptel.dto.response.HealthSheetResponse;
import com.hbtech.cheptel.entity.*;
import com.hbtech.cheptel.repository.*;
import com.hbtech.cheptel.service.CurrentUserService;
import com.hbtech.cheptel.service.VeterinaireService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/veterinaire")
public class VeterinaireController {

    private final VeterinaireService veterinaireService;
    private final SanitaryCampaignRepository campaignRepository;
    private final CampaignParticipationRepository participationRepository;
    private final CurrentUserService currentUserService;

    public VeterinaireController(
            VeterinaireService veterinaireService,
            SanitaryCampaignRepository campaignRepository,
            CampaignParticipationRepository participationRepository,
            CurrentUserService currentUserService
    ) {
        this.veterinaireService = veterinaireService;
        this.campaignRepository = campaignRepository;
        this.participationRepository = participationRepository;
        this.currentUserService = currentUserService;
    }

    // ============================
    // FICHE SANTÉ
    // ============================

    @GetMapping("/animals/rfid/{rfidTag}/health")
    @PreAuthorize("hasAnyRole('VETERINAIRE','ADMIN')")
    public ResponseEntity<HealthSheetResponse> getHealthSheet(
            @PathVariable String rfidTag
    ) {
        return ResponseEntity.ok(
                veterinaireService.getHealthSheetByRfid(rfidTag)
        );
    }

    // ============================
    // AJOUT VACCINATION
    // ============================

    @PostMapping("/animals/rfid/{rfidTag}/vaccinations")
    @PreAuthorize("hasAnyRole('VETERINAIRE','ADMIN')")
    public ResponseEntity<HealthSheetResponse.VaccinationDto> addVaccination(
            @PathVariable String rfidTag,
            @RequestBody CreateVaccinationRequest request
    ) {
        return ResponseEntity.ok(
                veterinaireService.addVaccination(rfidTag, request)
        );
    }

    // ============================
    // AJOUT DOSSIER MÉDICAL
    // ============================

    @PostMapping("/animals/rfid/{rfidTag}/health-records")
    @PreAuthorize("hasAnyRole('VETERINAIRE','ADMIN')")
    public ResponseEntity<HealthSheetResponse.HealthRecordDto> addHealthRecord(
            @PathVariable String rfidTag,
            @RequestBody CreateHealthRecordRequest request
    ) {
        return ResponseEntity.ok(
                veterinaireService.addHealthRecord(rfidTag, request)
        );
    }

    // ============================
    // CAMPAGNES SANITAIRES
    // ============================

    @GetMapping("/campaigns")
    @PreAuthorize("hasAnyRole('VETERINAIRE','ADMIN')")
    public ResponseEntity<?> getActiveCampaigns() {
        List<SanitaryCampaign> campaigns = campaignRepository.findByStatus("ACTIVE");

        List<Map<String, Object>> result = campaigns.stream().map(c -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", c.getId());
            map.put("name", c.getName());
            map.put("description", c.getDescription());
            map.put("vaccineName", c.getVaccineName());
            map.put("targetSpecies", c.getTargetSpecies());
            map.put("startDate", c.getStartDate());
            map.put("endDate", c.getEndDate());
            map.put("status", c.getStatus());

            long pending = participationRepository.countByCampaignIdAndStatus(c.getId(), "PENDING");
            long done = participationRepository.countByCampaignIdAndStatus(c.getId(), "DONE");

            map.put("enAttente", pending);
            map.put("vaccinés", done);

            return map;
        }).toList();

        return ResponseEntity.ok(result);
    }

    @PutMapping("/campaigns/{campaignId}/participate/{animalId}")
    @PreAuthorize("hasAnyRole('VETERINAIRE','ADMIN')")
    public ResponseEntity<?> markParticipation(
            @PathVariable Long campaignId,
            @PathVariable Long animalId,
            @RequestBody Map<String, Object> request
    ) {
        User veto = currentUserService.getCurrentUserOrThrow();

        List<CampaignParticipation> participations =
                participationRepository.findByCampaignId(campaignId);

        CampaignParticipation participation = participations.stream()
                .filter(p -> p.getAnimal().getId().equals(animalId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Participation introuvable"));

        participation.setStatus("DONE");
        participation.setVeterinarian(veto);

        if (request.get("vaccinationDate") != null) {
            try {
                participation.setVaccinationDate(
                        LocalDate.parse(request.get("vaccinationDate").toString())
                );
            } catch (Exception ignored) {}
        }

        if (request.get("notes") != null) {
            participation.setNotes(request.get("notes").toString());
        }

        participationRepository.save(participation);

        return ResponseEntity.ok(Map.of("message", "Participation enregistrée"));
    }
}
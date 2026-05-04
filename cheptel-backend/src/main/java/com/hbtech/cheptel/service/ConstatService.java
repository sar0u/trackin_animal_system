package com.hbtech.cheptel.service;

import com.hbtech.cheptel.dto.response.ConstatResponse;
import com.hbtech.cheptel.entity.*;
import com.hbtech.cheptel.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
public class ConstatService {

    private final ConstatRepository constatRepository;
    private final FarmRepository farmRepository;
    private final ControlSessionRepository controlSessionRepository;
    private final CurrentUserService currentUserService;

    public ConstatService(
            ConstatRepository constatRepository,
            FarmRepository farmRepository,
            ControlSessionRepository controlSessionRepository,
            CurrentUserService currentUserService
    ) {
        this.constatRepository = constatRepository;
        this.farmRepository = farmRepository;
        this.controlSessionRepository = controlSessionRepository;
        this.currentUserService = currentUserService;
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public ConstatResponse createConstat(Map<String, Object> request) {

        User controleur = currentUserService.getCurrentUserOrThrow();

        System.out.println("====== CRÉATION CONSTAT ======");
        System.out.println("Utilisateur : " + controleur.getUsername() + " (ID: " + controleur.getId() + ")");
        System.out.println("Données reçues : " + request);

        Farm farm = null;
        try {
            Object farmIdObj = request.get("farmId");
            if (farmIdObj != null && !farmIdObj.toString().isBlank()) {
                Long farmId = Long.valueOf(farmIdObj.toString());
                farm = farmRepository.findById(farmId).orElse(null);
                System.out.println("Farm ID=" + farmId + " → " + (farm != null ? farm.getName() : "INTROUVABLE"));
            }
        } catch (Exception e) {
            System.out.println("Erreur farmId : " + e.getMessage());
        }

        ControlSession session = null;
        try {
            Object sessionIdObj = request.get("controlSessionId");
            if (sessionIdObj != null && !sessionIdObj.toString().isBlank()) {
                Long sessionId = Long.valueOf(sessionIdObj.toString());
                session = controlSessionRepository.findById(sessionId).orElse(null);
            }
        } catch (Exception ignored) {}

        String type = "AUTRE";
        if (request.get("type") != null && !request.get("type").toString().isBlank()) {
            type = request.get("type").toString();
        }

        String description = "";
        if (request.get("description") != null) {
            description = request.get("description").toString().trim();
        }

        if (description.isEmpty()) {
            throw new RuntimeException("La description est obligatoire");
        }

        Double latitude = parseDouble(request.get("latitude"));
        Double longitude = parseDouble(request.get("longitude"));

        String photoUrl = parseString(request.get("photoUrl"));
        String attachmentsJson = parseString(request.get("attachmentsJson"));
        String localisationText = parseString(request.get("localisationText"));
        String voiceMemoUrl = parseString(request.get("voiceMemoUrl"));
        String documentUrl = parseString(request.get("documentUrl"));

        Constat constat = new Constat();
        constat.setControleur(controleur);
        constat.setFarm(farm);
        constat.setControlSession(session);
        constat.setType(type);
        constat.setDescription(description);
        constat.setLatitude(latitude);
        constat.setLongitude(longitude);
        constat.setLocalisationText(localisationText);
        constat.setPhotoUrl(photoUrl);
        constat.setVoiceMemoUrl(voiceMemoUrl);
        constat.setDocumentUrl(documentUrl);
        constat.setAttachmentsJson(attachmentsJson);
        constat.setStatus("PENDING");
        constat.setCreatedAt(LocalDateTime.now());

        System.out.println("Tentative de sauvegarde...");

        Constat saved = constatRepository.saveAndFlush(constat);

        System.out.println("✅ Constat sauvegardé ! ID = " + saved.getId());
        System.out.println("==============================");

        return buildResponse(saved);
    }

    public List<ConstatResponse> listAll() {
        return constatRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(this::buildResponse)
                .toList();
    }

    private ConstatResponse buildResponse(Constat c) {
        return ConstatResponse.builder()
                .id(c.getId())
                .controleurUsername(c.getControleur() != null ? c.getControleur().getUsername() : null)
                .farmId(c.getFarm() != null ? c.getFarm().getId() : null)
                .farmName(c.getFarm() != null ? c.getFarm().getName() : null)
                .controlSessionId(c.getControlSession() != null ? c.getControlSession().getId() : null)
                .type(c.getType())
                .description(c.getDescription())
                .latitude(c.getLatitude())
                .longitude(c.getLongitude())
                .localisationText(c.getLocalisationText())
                .photoUrl(c.getPhotoUrl())
                .voiceMemoUrl(c.getVoiceMemoUrl())
                .documentUrl(c.getDocumentUrl())
                .attachmentsJson(c.getAttachmentsJson())
                .status(c.getStatus())
                .createdAt(c.getCreatedAt())
                .build();
    }

    private Double parseDouble(Object value) {
        if (value == null) return null;
        try {
            return Double.valueOf(value.toString());
        } catch (Exception e) {
            return null;
        }
    }

    private String parseString(Object value) {
        if (value == null) return null;
        String s = value.toString().trim();
        return s.isEmpty() ? null : s;
    }
}
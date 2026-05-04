package com.hbtech.cheptel.service;

import com.hbtech.cheptel.dto.response.ControlCheckResponse;
import com.hbtech.cheptel.entity.Animal;
import com.hbtech.cheptel.entity.ControlSession;
import com.hbtech.cheptel.entity.Farm;
import com.hbtech.cheptel.entity.User;
import com.hbtech.cheptel.repository.AnimalRepository;
import com.hbtech.cheptel.repository.ControlSessionRepository;
import com.hbtech.cheptel.repository.FarmRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
public class ControleService {

    private final AnimalRepository animalRepository;
    private final FarmRepository farmRepository;
    private final ControlSessionRepository controlSessionRepository;
    private final CurrentUserService currentUserService;

    public ControleService(
            AnimalRepository animalRepository,
            FarmRepository farmRepository,
            ControlSessionRepository controlSessionRepository,
            CurrentUserService currentUserService
    ) {
        this.animalRepository = animalRepository;
        this.farmRepository = farmRepository;
        this.controlSessionRepository = controlSessionRepository;
        this.currentUserService = currentUserService;
    }

    public ControlCheckResponse checkEffectif(Long farmId, List<String> scannedTags) {

        if (farmId == null) {
            throw new RuntimeException("Veuillez sélectionner une ferme.");
        }

        if (scannedTags == null || scannedTags.isEmpty()) {
            throw new RuntimeException("Aucun tag scanné.");
        }

        User controleur = currentUserService.getCurrentUserOrThrow();

        Farm farm = farmRepository.findById(farmId)
                .orElseThrow(() -> new RuntimeException(
                        "Ferme introuvable en base de données. ID reçu : " + farmId
                ));

        List<Animal> expectedAnimals = animalRepository.findByFarmId(farm.getId());

        Set<String> expectedTags = new HashSet<>();
        for (Animal animal : expectedAnimals) {
            expectedTags.add(animal.getRfidTag());
        }

        Set<String> scannedSet = new HashSet<>(scannedTags);

        Set<String> missingTags = new HashSet<>(expectedTags);
        missingTags.removeAll(scannedSet);

        Set<String> unknownTags = new HashSet<>(scannedSet);
        unknownTags.removeAll(expectedTags);

        String result = missingTags.isEmpty() && unknownTags.isEmpty()
                ? "OK"
                : "ECART_DETECTE";

        ControlSession session = ControlSession.builder()
                .controleur(controleur)
                .farm(farm)
                .expectedCount(expectedAnimals.size())
                .detectedCount(scannedSet.size())
                .missingCount(missingTags.size())
                .unknownCount(unknownTags.size())
                .scannedTags(scannedTags)
                .startedAt(LocalDateTime.now())
                .endedAt(LocalDateTime.now())
                .result(result)
                .build();

        ControlSession savedSession = controlSessionRepository.save(session);

        return ControlCheckResponse.builder()
                .sessionId(savedSession.getId())
                .farmId(farm.getId())
                .farmName(farm.getName())
                .expectedCount(expectedAnimals.size())
                .detectedCount(scannedSet.size())
                .missingCount(missingTags.size())
                .unknownCount(unknownTags.size())
                .missingTags(missingTags.stream().toList())
                .unknownTags(unknownTags.stream().toList())
                .result(result)
                .build();
    }
}
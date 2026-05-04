package com.hbtech.cheptel.controller;

import com.hbtech.cheptel.entity.*;
import com.hbtech.cheptel.entity.MovementType;
import com.hbtech.cheptel.repository.*;
import com.hbtech.cheptel.service.CurrentUserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/movements")
public class MovementController {

    private final MovementRepository movementRepository;
    private final AnimalRepository animalRepository;
    private final FarmRepository farmRepository;
    private final CurrentUserService currentUserService;

    public MovementController(
            MovementRepository movementRepository,
            AnimalRepository animalRepository,
            FarmRepository farmRepository,
            CurrentUserService currentUserService
    ) {
        this.movementRepository = movementRepository;
        this.animalRepository = animalRepository;
        this.farmRepository = farmRepository;
        this.currentUserService = currentUserService;
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('FERMIER','ADMIN')")
    public ResponseEntity<?> createMovement(@RequestBody Map<String, Object> request) {

        User currentUser = currentUserService.getCurrentUserOrThrow();

        System.out.println("=== DEBUG MOUVEMENT ===");
        System.out.println("User : " + currentUser.getUsername());
        System.out.println("Payload : " + request);

        try {
            Long animalId = toLong(request.get("animalId"));

            if (animalId == null) {
                return ResponseEntity.badRequest()
                        .body(Map.of("message", "animalId obligatoire"));
            }

            Animal animal = animalRepository.findById(animalId)
                    .orElseThrow(() -> new RuntimeException("Animal introuvable : " + animalId));

            String movementTypeStr = request.get("movementType") != null
                    ? request.get("movementType").toString()
                    : "SALE";

            MovementType movementType;
            try {
                movementType = MovementType.valueOf(movementTypeStr.toUpperCase());
            } catch (Exception e) {
                return ResponseEntity.badRequest()
                        .body(Map.of("message", "Type invalide : " + movementTypeStr));
            }

            Farm fromFarm = animal.getFarm();

            Farm toFarm = null;
            Long toFarmId = toLong(request.get("toFarmId"));
            if (toFarmId != null) {
                toFarm = farmRepository.findById(toFarmId).orElse(null);
            }

            BigDecimal price = null;
            if (request.get("price") != null) {
                try {
                    price = new BigDecimal(request.get("price").toString());
                } catch (Exception ignored) {}
            }

            Movement movement = Movement.builder()
                    .animal(animal)
                    .movementType(movementType)
                    .fromFarm(fromFarm)
                    .toFarm(toFarm)
                    .movementDate(LocalDateTime.now())
                    .price(price)
                    .counterpartyName(toStr(request.get("counterpartyName")))
                    .counterpartyPhone(toStr(request.get("counterpartyPhone")))
                    .documentReference(toStr(request.get("documentReference")))
                    .latitude(toDouble(request.get("latitude")))
                    .longitude(toDouble(request.get("longitude")))
                    .performedBy(currentUser)
                    .notes(toStr(request.get("notes")))
                    .build();

            Movement saved = movementRepository.save(movement);

            switch (movementType) {
                case SALE -> animal.setStatus(AnimalStatus.SOLD);
                case SLAUGHTER -> animal.setStatus(AnimalStatus.SLAUGHTERED);
                case DEATH -> animal.setStatus(AnimalStatus.DEAD);
                case TRANSFER -> {
                    if (toFarm != null) {
                        animal.setFarm(toFarm);
                    }
                }
                default -> {}
            }

            animalRepository.save(animal);

            System.out.println("✅ Mouvement créé ID : " + saved.getId());

            Map<String, Object> response = new HashMap<>();
            response.put("id", saved.getId());
            response.put("animalId", animal.getId());
            response.put("animalRfidTag", animal.getRfidTag());
            response.put("movementType", saved.getMovementType().name());
            response.put("movementDate", saved.getMovementDate().toString());
            response.put("price", saved.getPrice());
            response.put("counterpartyName", saved.getCounterpartyName());
            response.put("notes", saved.getNotes());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            System.out.println("❌ Erreur mouvement : " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.badRequest()
                    .body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping("/animal/{animalId}")
    @PreAuthorize("hasAnyRole('FERMIER','VETERINAIRE','CONTROLEUR','ADMIN')")
    public ResponseEntity<?> getMovementsByAnimal(@PathVariable Long animalId) {

        List<Movement> movements =
                movementRepository.findByAnimalIdOrderByMovementDateDesc(animalId);

        List<Map<String, Object>> result = movements.stream().map(m -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", m.getId());
            map.put("animalId", m.getAnimal().getId());
            map.put("animalRfidTag", m.getAnimal().getRfidTag());
            map.put("movementType", m.getMovementType().name());
            map.put("fromFarmName", m.getFromFarm() != null ? m.getFromFarm().getName() : null);
            map.put("toFarmName", m.getToFarm() != null ? m.getToFarm().getName() : null);
            map.put("movementDate", m.getMovementDate().toString());
            map.put("price", m.getPrice());
            map.put("counterpartyName", m.getCounterpartyName());
            map.put("performedByUsername", m.getPerformedBy().getUsername());
            map.put("notes", m.getNotes());
            return map;
        }).toList();

        return ResponseEntity.ok(result);
    }

    private Long toLong(Object v) {
        if (v == null) return null;
        try { return Long.valueOf(v.toString()); } catch (Exception e) { return null; }
    }

    private Double toDouble(Object v) {
        if (v == null) return null;
        try { return Double.valueOf(v.toString()); } catch (Exception e) { return null; }
    }

    private String toStr(Object v) {
        if (v == null) return null;
        return v.toString();
    }
}
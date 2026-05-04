package com.hbtech.cheptel.controller;

import com.hbtech.cheptel.entity.HealthAlert;
import com.hbtech.cheptel.repository.HealthAlertRepository;
import com.hbtech.cheptel.service.AlertGeneratorService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/alerts")
public class HealthAlertController {

    private final HealthAlertRepository healthAlertRepository;
    private final AlertGeneratorService alertGeneratorService;

    public HealthAlertController(
            HealthAlertRepository healthAlertRepository,
            AlertGeneratorService alertGeneratorService
    ) {
        this.healthAlertRepository = healthAlertRepository;
        this.alertGeneratorService = alertGeneratorService;
    }

    @PostMapping("/generate")
    @PreAuthorize("hasAnyRole('VETERINAIRE','FERMIER','ADMIN')")
    public ResponseEntity<?> generateAlerts() {
        alertGeneratorService.generateAll();
        return ResponseEntity.ok(Map.of("message", "Alertes générées"));
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('VETERINAIRE','FERMIER','ADMIN')")
    public ResponseEntity<List<HealthAlert>> getPendingAlerts() {
        alertGeneratorService.generateAll();

        return ResponseEntity.ok(
                healthAlertRepository.findByIsResolvedFalseOrderByDueDateAsc()
        );
    }

    @PutMapping("/{id}/resolve")
    @PreAuthorize("hasAnyRole('VETERINAIRE','ADMIN')")
    public ResponseEntity<?> resolveAlert(@PathVariable Long id) {
        HealthAlert alert = healthAlertRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Alerte introuvable"));

        alert.setIsResolved(true);
        alert.setResolvedAt(LocalDateTime.now());

        healthAlertRepository.save(alert);

        return ResponseEntity.ok(Map.of("message", "Alerte résolue"));
    }
}
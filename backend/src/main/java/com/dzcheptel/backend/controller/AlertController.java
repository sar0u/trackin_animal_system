package com.dzcheptel.backend.controller;

import com.dzcheptel.backend.entity.Alert;
import com.dzcheptel.backend.repository.AlertRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/alerts")
public class AlertController {

    private final AlertRepository alertRepository;

    public AlertController(AlertRepository alertRepository) {
        this.alertRepository = alertRepository;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('Farmer','Veterinarian','Inspector','Administrator')")
    public List<Alert> getAll() {
        return alertRepository.findAll();
    }

    @GetMapping("/farm/{farmId}")
    @PreAuthorize("hasAnyRole('Farmer','Veterinarian','Inspector','Administrator')")
    public List<Alert> getByFarm(@PathVariable Long farmId, @RequestParam(value = "unresolvedOnly", defaultValue = "false") boolean unresolvedOnly) {
        return unresolvedOnly
                ? alertRepository.findByFarmIdAndIsResolvedFalse(farmId)
                : alertRepository.findByFarmId(farmId);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('Farmer','Veterinarian','Administrator')")
    public Alert create(@RequestBody Alert alert) {
        return alertRepository.save(alert);
    }

    @PutMapping("/{id}/resolve")
    @PreAuthorize("hasAnyRole('Farmer','Veterinarian','Administrator')")
    public ResponseEntity<?> resolve(@PathVariable Long id) {
        return alertRepository.findById(id)
                .map(a -> {
                    a.setIsResolved(true);
                    alertRepository.save(a);
                    return ResponseEntity.ok(Map.of("message", "Alerte résolue"));
                })
                .orElse(ResponseEntity.notFound().build());
    }
}

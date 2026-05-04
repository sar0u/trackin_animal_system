package com.hbtech.cheptel.controller;

import com.hbtech.cheptel.entity.Farm;
import com.hbtech.cheptel.entity.Subvention;
import com.hbtech.cheptel.entity.User;
import com.hbtech.cheptel.repository.FarmRepository;
import com.hbtech.cheptel.repository.SubventionRepository;
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
@RequestMapping("/admin/subventions")
@PreAuthorize("hasRole('ADMIN')")
public class AdminSubventionController {

    private final SubventionRepository subventionRepository;
    private final FarmRepository farmRepository;
    private final CurrentUserService currentUserService;

    public AdminSubventionController(
            SubventionRepository subventionRepository,
            FarmRepository farmRepository,
            CurrentUserService currentUserService
    ) {
        this.subventionRepository = subventionRepository;
        this.farmRepository = farmRepository;
        this.currentUserService = currentUserService;
    }

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getAll() {
        List<Map<String, Object>> result = subventionRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(this::toMap)
                .toList();

        return ResponseEntity.ok(result);
    }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody Map<String, Object> request) {
        Long farmId = Long.valueOf(request.get("farmId").toString());

        Farm farm = farmRepository.findById(farmId)
                .orElseThrow(() -> new RuntimeException("Ferme introuvable"));

        BigDecimal amount = new BigDecimal(request.get("amount").toString());

        Integer year = Integer.valueOf(request.get("year").toString());

        String type = request.get("type") != null
                ? request.get("type").toString()
                : "AIDE_STANDARD";

        String reason = request.get("reason") != null
                ? request.get("reason").toString()
                : null;

        Subvention subvention = Subvention.builder()
                .farm(farm)
                .ownerName(farm.getOwner() != null ? farm.getOwner().getFullName() : null)
                .amount(amount)
                .type(type)
                .year(year)
                .status("PENDING")
                .reason(reason)
                .build();

        Subvention saved = subventionRepository.save(subvention);

        return ResponseEntity.ok(toMap(saved));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateStatus(
            @PathVariable Long id,
            @RequestBody Map<String, Object> request
    ) {
        User admin = currentUserService.getCurrentUserOrThrow();

        Subvention subvention = subventionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Subvention introuvable"));

        String status = request.get("status").toString();

        subvention.setStatus(status);

        if ("APPROVED".equals(status) || "PAID".equals(status)) {
            subvention.setApprovedBy(admin);
            subvention.setApprovedAt(LocalDateTime.now());
        }

        if (request.get("reason") != null) {
            subvention.setReason(request.get("reason").toString());
        }

        Subvention saved = subventionRepository.save(subvention);

        return ResponseEntity.ok(toMap(saved));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        subventionRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "Subvention supprimée"));
    }

    private Map<String, Object> toMap(Subvention s) {
        Map<String, Object> map = new HashMap<>();

        map.put("id", s.getId());
        map.put("farmId", s.getFarm().getId());
        map.put("farmName", s.getFarm().getName());
        map.put("ownerName", s.getOwnerName());
        map.put("amount", s.getAmount());
        map.put("type", s.getType());
        map.put("year", s.getYear());
        map.put("status", s.getStatus());
        map.put("reason", s.getReason());
        map.put("approvedBy", s.getApprovedBy() != null ? s.getApprovedBy().getUsername() : null);
        map.put("approvedAt", s.getApprovedAt());
        map.put("createdAt", s.getCreatedAt());

        return map;
    }
}
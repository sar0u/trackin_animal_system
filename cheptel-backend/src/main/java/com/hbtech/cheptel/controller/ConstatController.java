package com.hbtech.cheptel.controller;

import com.hbtech.cheptel.dto.response.ConstatResponse;
import com.hbtech.cheptel.service.ConstatService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/constats")
public class ConstatController {

    private final ConstatService constatService;

    public ConstatController(ConstatService constatService) {
        this.constatService = constatService;
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('CONTROLEUR','ADMIN')")
    public ResponseEntity<?> create(@RequestBody Map<String, Object> request) {
        System.out.println("=== POST /constats reçu ===");
        System.out.println("Body : " + request);

        try {
            ConstatResponse response = constatService.createConstat(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.out.println("❌ Erreur : " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.badRequest()
                    .body(Map.of("message", e.getMessage() != null ? e.getMessage() : "Erreur inconnue"));
        }
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('CONTROLEUR','ADMIN')")
    public ResponseEntity<List<ConstatResponse>> list() {
        return ResponseEntity.ok(constatService.listAll());
    }
}
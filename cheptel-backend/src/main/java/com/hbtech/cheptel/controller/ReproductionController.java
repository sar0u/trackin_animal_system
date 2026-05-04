package com.hbtech.cheptel.controller;


import com.hbtech.cheptel.dto.request.CreateReproductionRequest;
import com.hbtech.cheptel.dto.response.ReproductionResponse;
import com.hbtech.cheptel.service.ReproductionService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/reproductions")
public class ReproductionController {

    private final ReproductionService reproductionService;

    public ReproductionController(ReproductionService reproductionService) {
        this.reproductionService = reproductionService;
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('VETERINAIRE','ADMIN')")
    public ResponseEntity<?> createReproduction(@RequestBody CreateReproductionRequest request) {
        try {
            ReproductionResponse response = reproductionService.createReproduction(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping("/female/{femaleId}")
    @PreAuthorize("hasAnyRole('VETERINAIRE','FERMIER','ADMIN')")
    public ResponseEntity<List<ReproductionResponse>> getReproductionsByFemale(
            @PathVariable Long femaleId
    ) {
        return ResponseEntity.ok(
                reproductionService.getReproductionsByFemale(femaleId)
        );
    }
}
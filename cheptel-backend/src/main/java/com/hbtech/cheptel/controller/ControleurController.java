package com.hbtech.cheptel.controller;

import com.hbtech.cheptel.dto.request.ControlCheckRequest;
import com.hbtech.cheptel.dto.response.ControlCheckResponse;
import com.hbtech.cheptel.dto.response.ConstatResponse;
import com.hbtech.cheptel.service.ConstatService;
import com.hbtech.cheptel.service.ControleService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/controleur")
public class ControleurController {

    private final ControleService controleService;
    private final ConstatService constatService;

    public ControleurController(
            ControleService controleService,
            ConstatService constatService
    ) {
        this.controleService = controleService;
        this.constatService = constatService;
    }

    @PostMapping("/check")
    @PreAuthorize("hasAnyRole('CONTROLEUR','ADMIN')")
    public ResponseEntity<ControlCheckResponse> checkEffectif(
            @RequestBody ControlCheckRequest request
    ) {
        return ResponseEntity.ok(
                controleService.checkEffectif(
                        request.getFarmId(),
                        request.getScannedRfidTags()
                )
        );
    }

    @GetMapping("/anomalies")
    @PreAuthorize("hasAnyRole('CONTROLEUR','ADMIN')")
    public ResponseEntity<List<ConstatResponse>> getAnomalies() {
        return ResponseEntity.ok(constatService.listAll());
    }
}
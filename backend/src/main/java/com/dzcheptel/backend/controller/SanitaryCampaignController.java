package com.dzcheptel.backend.controller;

import com.dzcheptel.backend.entity.SanitaryCampaign;
import com.dzcheptel.backend.repository.UserRepository;
import com.dzcheptel.backend.service.SanitaryCampaignService;
import com.dzcheptel.backend.service.impl.UserDetailsImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/sanitary-campaigns")
@RequiredArgsConstructor
public class SanitaryCampaignController {

    private final SanitaryCampaignService service;
    private final UserRepository userRepository;

    @GetMapping
    public List<SanitaryCampaign> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<SanitaryCampaign> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    @PreAuthorize("hasRole('Administrator')")
    public ResponseEntity<SanitaryCampaign> create(@RequestBody SanitaryCampaign campaign) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof UserDetailsImpl udi) {
            userRepository.findById(udi.getId()).ifPresent(campaign::setCreatedBy);
        }
        return ResponseEntity.ok(service.create(campaign));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    public ResponseEntity<SanitaryCampaign> update(@PathVariable Long id, @RequestBody SanitaryCampaign payload) {
        return ResponseEntity.ok(service.update(id, payload));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}

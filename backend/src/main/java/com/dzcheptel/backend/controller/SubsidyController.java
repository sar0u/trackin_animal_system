package com.dzcheptel.backend.controller;

import com.dzcheptel.backend.entity.Subsidy;
import com.dzcheptel.backend.repository.SubsidyRepository;
import com.dzcheptel.backend.repository.UserRepository;
import com.dzcheptel.backend.service.impl.UserDetailsImpl;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/subsidies")
@RequiredArgsConstructor
public class SubsidyController {

    private final SubsidyRepository subsidyRepository;
    private final UserRepository userRepository;
    private final com.dzcheptel.backend.service.SubsidyService subsidyService;

    @GetMapping
    public List<Map<String, Object>> getAll() {
        return subsidyService.listForApi();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(subsidyService.getForApi(id));
    }

    @PostMapping
    @Transactional
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<Subsidy> create(@RequestBody Subsidy subsidy) {
        return ResponseEntity.ok(subsidyRepository.save(subsidy));
    }

    @PutMapping("/{id}")
    @Transactional
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<Subsidy> update(@PathVariable Long id, @RequestBody Subsidy payload) {
        Subsidy subsidy = subsidyRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Subvention introuvable"));
        subsidy.setAnimal(payload.getAnimal());
        subsidy.setAmount(payload.getAmount());
        subsidy.setType(payload.getType());
        subsidy.setStatus(payload.getStatus());
        subsidy.setRequestDate(payload.getRequestDate());
        subsidy.setApprovedDate(payload.getApprovedDate());
        subsidy.setPaidDate(payload.getPaidDate());
        subsidy.setTreatedBy(payload.getTreatedBy());
        subsidy.setNotes(payload.getNotes());
        return ResponseEntity.ok(subsidyRepository.save(subsidy));
    }

    @PutMapping("/{id}/status")
    @Transactional
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<Map<String, Object>> updateStatus(@PathVariable Long id, @RequestBody Map<String, String> payload) {
        Subsidy subsidy = subsidyRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Subvention introuvable"));
        
        String newStatus = payload.get("status");
        if (newStatus != null) {
            subsidy.setStatus(com.dzcheptel.backend.entity.SubsidyStatus.valueOf(newStatus));

            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth != null && auth.getPrincipal() instanceof UserDetailsImpl udi) {
                userRepository.findById(udi.getId()).ifPresent(subsidy::setTreatedBy);
            }

            if ("Approved".equals(newStatus) && subsidy.getApprovedDate() == null) {
                subsidy.setApprovedDate(java.time.LocalDate.now());
            }
            if ("Paid".equals(newStatus) && subsidy.getPaidDate() == null) {
                subsidy.setPaidDate(java.time.LocalDate.now());
            }
        }
        
        subsidyRepository.save(subsidy);
        return ResponseEntity.ok(subsidyService.getForApi(id));
    }

    @DeleteMapping("/{id}")
    @Transactional
    @PreAuthorize("hasRole('Administrator')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        subsidyRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}

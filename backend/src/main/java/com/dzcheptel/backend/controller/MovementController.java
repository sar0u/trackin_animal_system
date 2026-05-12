package com.dzcheptel.backend.controller;

import com.dzcheptel.backend.entity.ApprovalStatus;
import com.dzcheptel.backend.entity.Movement;
import com.dzcheptel.backend.entity.User;
import com.dzcheptel.backend.repository.MovementRepository;
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
@RequestMapping("/movements")
@RequiredArgsConstructor
public class MovementController {

    private final MovementRepository movementRepository;
    private final UserRepository userRepository;
    private final com.dzcheptel.backend.service.MovementService movementService;

    @GetMapping
    public List<Map<String, Object>> getAll() {
        return movementService.listForApi();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getById(@PathVariable Long id) {
        return ResponseEntity.ok(movementService.getForApi(id));
    }

    @PostMapping
    @Transactional
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<Movement> create(@RequestBody Movement movement) {
        return ResponseEntity.ok(movementRepository.save(movement));
    }

    @PutMapping("/{id}")
    @Transactional
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<Movement> update(@PathVariable Long id, @RequestBody Movement payload) {
        Movement movement = movementRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Mouvement non trouve"));
        movement.setReason(payload.getReason());
        movement.setNotes(payload.getNotes());
        movement.setFromFarm(payload.getFromFarm());
        movement.setToFarm(payload.getToFarm());
        movement.setAnimal(payload.getAnimal());
        movement.setApprovalStatus(payload.getApprovalStatus());
        movement.setTreatedBy(payload.getTreatedBy());
        return ResponseEntity.ok(movementRepository.save(movement));
    }

    @PutMapping("/{id}/status")
    @Transactional
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<Map<String, Object>> updateStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Movement movement = movementRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Mouvement non trouve"));
        ApprovalStatus status = ApprovalStatus.valueOf(body.getOrDefault("status", "Pending"));
        movement.setApprovalStatus(status);
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof UserDetailsImpl udi) {
            userRepository.findById(udi.getId()).ifPresent(movement::setTreatedBy);
        }
        movementRepository.save(movement);
        return ResponseEntity.ok(movementService.getForApi(id));
    }

    @PutMapping("/{id}/approve")
    @Transactional
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<Movement> approve(@PathVariable Long id, @RequestBody Map<String, Long> body) {
        Movement movement = movementRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Mouvement non trouve"));

        Long approvedById = body.get("treatedById");
        if (approvedById != null) {
            User approver = userRepository.findById(approvedById)
                    .orElseThrow(() -> new EntityNotFoundException("Utilisateur approbateur introuvable"));
            movement.setTreatedBy(approver);
        }
        movement.setApprovalStatus(ApprovalStatus.Approved);
        return ResponseEntity.ok(movementRepository.save(movement));
    }

    @DeleteMapping("/{id}")
    @Transactional
    @PreAuthorize("hasRole('Administrator')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        movementRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}

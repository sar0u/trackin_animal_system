package com.dzcheptel.backend.controller;

import com.dzcheptel.backend.entity.ControlSession;
import com.dzcheptel.backend.entity.ControlSessionResult;
import com.dzcheptel.backend.service.ControlSessionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/control-sessions")
@RequiredArgsConstructor
public class ControlSessionController {

    private final ControlSessionService service;

    @GetMapping
    public List<ControlSession> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ControlSession> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @GetMapping("/farm/{farmId}")
    public List<ControlSession> getByFarm(@PathVariable Long farmId) {
        return service.getByFarm(farmId);
    }

    @GetMapping("/result/{result}")
    public List<ControlSession> getByResult(@PathVariable ControlSessionResult result) {
        return service.getByResult(result);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<ControlSession> create(@RequestBody ControlSession session) {
        return ResponseEntity.ok(service.create(session));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<ControlSession> update(@PathVariable Long id, @RequestBody ControlSession payload) {
        return ResponseEntity.ok(service.update(id, payload));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}

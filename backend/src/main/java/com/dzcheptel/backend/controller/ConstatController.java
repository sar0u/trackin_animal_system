package com.dzcheptel.backend.controller;

import com.dzcheptel.backend.entity.Constat;
import com.dzcheptel.backend.entity.ConstatImage;
import com.dzcheptel.backend.entity.ConstatStatus;
import com.dzcheptel.backend.service.ConstatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/constats")
@RequiredArgsConstructor
public class ConstatController {

    private final ConstatService service;

    @GetMapping
    public List<Constat> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Constat> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @GetMapping("/session/{sessionId}")
    public List<Constat> getBySession(@PathVariable Long sessionId) {
        return service.getBySession(sessionId);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<Constat> create(@RequestBody Constat constat) {
        return ResponseEntity.ok(service.create(constat));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<Constat> update(@PathVariable Long id, @RequestBody Constat payload) {
        return ResponseEntity.ok(service.update(id, payload));
    }

    @PutMapping("/{id}/status")
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<Constat> updateStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        ConstatStatus status = ConstatStatus.valueOf(body.getOrDefault("status", "PENDING"));
        return ResponseEntity.ok(service.updateStatus(id, status));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

    // Gestion des images attachées aux constats

    @GetMapping("/{id}/images")
    public List<ConstatImage> getImages(@PathVariable Long id) {
        return service.getImages(id);
    }

    @PostMapping("/{id}/images")
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<ConstatImage> addImage(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String imageUrl = body.get("imageUrl");
        return ResponseEntity.ok(service.addImage(id, imageUrl));
    }

    @DeleteMapping("/{id}/images/{imageId}")
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<Void> deleteImage(@PathVariable Long id, @PathVariable Long imageId) {
        service.deleteImage(id, imageId);
        return ResponseEntity.noContent().build();
    }
}

package com.dzcheptel.backend.controller;

import com.dzcheptel.backend.entity.Notification;
import com.dzcheptel.backend.repository.NotificationRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationRepository notificationRepository;

    @GetMapping
    public List<Notification> getAll() {
        return notificationRepository.findAll();
    }

    @GetMapping("/user/{userId}")
    public List<Notification> getByUser(@PathVariable Long userId) {
        return notificationRepository.findByUserId(userId);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Notification> getById(@PathVariable Long id) {
        return ResponseEntity.ok(notificationRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Notification introuvable")));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<Notification> create(@RequestBody Notification notification) {
        return ResponseEntity.ok(notificationRepository.save(notification));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('Administrator','Inspector')")
    public ResponseEntity<Notification> update(@PathVariable Long id, @RequestBody Notification payload) {
        Notification notification = notificationRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Notification introuvable"));
        notification.setUser(payload.getUser());
        notification.setTitle(payload.getTitle());
        notification.setBody(payload.getBody());
        notification.setType(payload.getType());
        notification.setIsRead(payload.getIsRead());
        notification.setAnimal(payload.getAnimal());
        notification.setFarm(payload.getFarm());
        return ResponseEntity.ok(notificationRepository.save(notification));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('Administrator')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        notificationRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}

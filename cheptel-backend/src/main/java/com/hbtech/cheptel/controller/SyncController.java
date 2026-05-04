package com.hbtech.cheptel.controller;

import com.hbtech.cheptel.entity.SyncRecord;
import com.hbtech.cheptel.repository.SyncRecordRepository;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/sync")
public class SyncController {

    private final SyncRecordRepository syncRecordRepository;

    public SyncController(SyncRecordRepository syncRecordRepository) {
        this.syncRecordRepository = syncRecordRepository;
    }

    // Télécharger les mises à jour depuis le serveur
    @GetMapping("/download")
    @PreAuthorize("hasAnyRole('FERMIER','VETERINAIRE','CONTROLEUR','ADMIN')")
    public ResponseEntity<List<SyncRecord>> download(
            @RequestParam("lastSync")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime lastSync) {
        return ResponseEntity.ok(
                syncRecordRepository.findBySyncedAtAfterOrderBySyncedAtAsc(lastSync)
        );
    }

    // Uploader les données créées hors ligne
    @PostMapping("/upload")
    @PreAuthorize("hasAnyRole('FERMIER','VETERINAIRE','CONTROLEUR','ADMIN')")
    public ResponseEntity<String> upload(@RequestBody List<SyncRecord> records) {
        syncRecordRepository.saveAll(records);
        return ResponseEntity.ok("Synchronisation réussie : " + records.size() + " enregistrements");
    }
}
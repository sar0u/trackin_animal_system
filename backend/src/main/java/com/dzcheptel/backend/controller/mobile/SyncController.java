package com.dzcheptel.backend.controller.mobile;

import com.dzcheptel.backend.entity.SyncRecord;
import com.dzcheptel.backend.repository.SyncRecordRepository;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/mobile/sync")
public class SyncController {

    private final SyncRecordRepository syncRecordRepository;

    public SyncController(SyncRecordRepository syncRecordRepository) {
        this.syncRecordRepository = syncRecordRepository;
    }

    @GetMapping("/download")
    @PreAuthorize("hasAnyRole('Farmer','Veterinarian','Inspector','Administrator')")
    public ResponseEntity<List<SyncRecord>> download(
            @RequestParam("lastSync")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime lastSync) {
        return ResponseEntity.ok(syncRecordRepository.findBySyncedAtAfter(lastSync));
    }

    @PostMapping("/upload")
    @PreAuthorize("hasAnyRole('Farmer','Veterinarian','Inspector','Administrator')")
    public ResponseEntity<?> upload(@RequestBody List<SyncRecord> records) {
        List<SyncRecord> saved = syncRecordRepository.saveAll(records);
        return ResponseEntity.ok(Map.of(
                "saved", saved.size(),
                "message", "Synchronisation réussie"
        ));
    }
}

package com.dzcheptel.backend.repository;

import com.dzcheptel.backend.entity.SyncRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface SyncRecordRepository extends JpaRepository<SyncRecord, Long> {

    List<SyncRecord> findByUserId(Long userId);

    List<SyncRecord> findByEntityTypeAndEntityId(String entityType, Long entityId);

    List<SyncRecord> findBySyncedAtAfter(LocalDateTime since);

    List<SyncRecord> findByUserIdAndSyncedAtAfter(Long userId, LocalDateTime since);
}

package com.hbtech.cheptel.repository;

import com.hbtech.cheptel.entity.SyncRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface SyncRecordRepository extends JpaRepository<SyncRecord, Long> {
    List<SyncRecord> findBySyncedAtAfterOrderBySyncedAtAsc(LocalDateTime since);
}
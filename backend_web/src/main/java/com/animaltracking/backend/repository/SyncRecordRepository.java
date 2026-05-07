package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.SyncRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SyncRecordRepository extends JpaRepository<SyncRecord, Long> {

    List<SyncRecord> findByUserId(Long userId);

    List<SyncRecord> findByEntityTypeAndEntityId(String entityType, Long entityId);
}

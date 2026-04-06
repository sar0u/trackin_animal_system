package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {

    List<AuditLog> findByUserId(Integer userId);

    List<AuditLog> findByAffectedTable(String affectedTable);

    List<AuditLog> findByPerformedAction(String action);

    List<AuditLog> findByEventTimestampBetween(LocalDateTime start, LocalDateTime end);

    List<AuditLog> findByUserIdAndEventTimestampBetween(Integer userId, LocalDateTime start, LocalDateTime end);
}
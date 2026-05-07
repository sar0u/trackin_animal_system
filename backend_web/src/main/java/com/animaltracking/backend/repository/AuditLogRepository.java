package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {

    @Query("SELECT DISTINCT a FROM AuditLog a LEFT JOIN FETCH a.user ORDER BY a.createdAt DESC")
    List<AuditLog> findAllFetchedOrderByCreatedAtDesc();
}
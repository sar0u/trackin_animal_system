package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.AuditLog;

import java.util.List;

public interface AuditLogService {

    AuditLog createLog(AuditLog log);

    List<AuditLog> getLogsByUser(Integer userId);

    List<AuditLog> getAllLogs();
}
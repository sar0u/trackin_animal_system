package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.AuditLog;
import java.util.List;

public interface AuditLogService {
    List<AuditLog> getAllAuditLogs();
}
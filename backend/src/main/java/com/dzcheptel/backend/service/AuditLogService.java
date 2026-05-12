package com.dzcheptel.backend.service;

import com.dzcheptel.backend.entity.AuditLog;

import java.util.List;

public interface AuditLogService {

    List<AuditLog> getAllAuditLogsFetched();
}

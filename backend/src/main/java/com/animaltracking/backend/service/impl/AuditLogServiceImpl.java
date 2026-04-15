package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.AuditLog;
import com.animaltracking.backend.repository.AuditLogRepository;
import com.animaltracking.backend.service.AuditLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AuditLogServiceImpl implements AuditLogService {

    private final AuditLogRepository auditLogRepository;

    @Override
    public List<AuditLog> getAllAuditLogs() {
        return auditLogRepository.findAll();
    }
}
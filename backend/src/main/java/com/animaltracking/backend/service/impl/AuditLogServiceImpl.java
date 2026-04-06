package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.AuditLog;
import com.animaltracking.backend.repository.AuditLogRepository;
import com.animaltracking.backend.service.AuditLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class AuditLogServiceImpl implements AuditLogService {

    private final AuditLogRepository auditLogRepository;

    @Override
    public AuditLog createLog(AuditLog log) {
        return auditLogRepository.save(log);
    }

    @Override
    public List<AuditLog> getLogsByUser(Integer userId) {
        return auditLogRepository.findByUserId(userId);
    }

    @Override
    public List<AuditLog> getAllLogs() {
        return auditLogRepository.findAll();
    }
}
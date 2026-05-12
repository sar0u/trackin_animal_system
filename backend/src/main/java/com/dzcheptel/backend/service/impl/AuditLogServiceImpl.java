package com.dzcheptel.backend.service.impl;

import com.dzcheptel.backend.entity.AuditLog;
import com.dzcheptel.backend.repository.AuditLogRepository;
import com.dzcheptel.backend.service.AuditLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AuditLogServiceImpl implements AuditLogService {

    private final AuditLogRepository auditLogRepository;

    @Override
    @Transactional(readOnly = true)
    public List<AuditLog> getAllAuditLogsFetched() {
        return auditLogRepository.findAllFetchedOrderByCreatedAtDesc();
    }
}

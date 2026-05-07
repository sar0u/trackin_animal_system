package com.animaltracking.backend.controller;

import com.animaltracking.backend.entity.AuditLog;
import com.animaltracking.backend.service.AuditLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/audit-logs")
@RequiredArgsConstructor
public class AuditLogController {

    private final AuditLogService auditLogService;

    @GetMapping
    @PreAuthorize("hasRole('Administrator')")
    public List<Map<String, Object>> getAllLogsSafe() {
        List<AuditLog> logsDb = auditLogService.getAllAuditLogsFetched();
        List<Map<String, Object>> safeLogs = new ArrayList<>();

        for (AuditLog log : logsDb) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", log.getId());
            map.put("userId", log.getUser() != null ? log.getUser().getId() : null);
            map.put("action", log.getAction());
            map.put("entityType", log.getEntityType());
            map.put("entityId", log.getEntityId());
            map.put("createdAt", log.getCreatedAt() != null ? log.getCreatedAt().toString() : null);
            map.put("oldValues", log.getOldValues());
            map.put("newValues", log.getNewValues());
            map.put("ipAddress", log.getIpAddress());
            map.put("details", log.getDetails());
            safeLogs.add(map);
        }

        return safeLogs;
    }
}

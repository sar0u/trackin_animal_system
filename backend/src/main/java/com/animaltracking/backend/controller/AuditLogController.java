package com.animaltracking.backend.controller;

import com.animaltracking.backend.entity.AuditLog;
import com.animaltracking.backend.service.AuditLogService;
import lombok.RequiredArgsConstructor;
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
    public List<Map<String, Object>> getAllLogsSafe() {
        List<AuditLog> logsDb = auditLogService.getAllAuditLogs();
        List<Map<String, Object>> safeLogs = new ArrayList<>();

        for (AuditLog log : logsDb) {
            Map<String, Object> map = new HashMap<>();

            // On mappe les données de la BDD vers les noms attendus par Vue.js
            map.put("id", log.getId());
            map.put("userId", log.getUserId());

            // Si tu mets "CREATE - Utilisateur" dans ta BDD, Vue.js affichera tout dans "actionType"
            map.put("actionType", log.getPerformedAction());
            map.put("entityName", "Base de données"); // Valeur par défaut car la colonne n'est plus dans le SQL

            // Sécurité anti-crash pour la date
            map.put("eventTimestamp", log.getEventTimestamp() != null ? log.getEventTimestamp().toString() : null);

            // Mapping des JSON
            map.put("oldValues", log.getOldValuesJson());
            map.put("newValues", log.getNewValuesJson());

            safeLogs.add(map);
        }
        return safeLogs;
    }
}
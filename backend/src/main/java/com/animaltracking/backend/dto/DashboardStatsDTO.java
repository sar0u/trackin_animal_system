package com.animaltracking.backend.dto;

import lombok.Data;
import java.util.List;
import java.util.Map;

@Data
public class DashboardStatsDTO {
    private long totalUsers;
    private long totalFarms;
    private long totalAnimals;
    private long activeAlerts;

    private Map<String, Long> speciesStats; // Exemple: {"Bovin": 150, "Ovin": 300}
    private Map<String, Long> userProfiles; // Exemple: {"Éleveurs": 100, "Vétérinaires": 20}
    private Map<String, Integer> healthStats; // Exemple: {"sain": 95, "alerte": 5}

    private List<MovementDTO> recentMovements;
    private List<FraudDTO> recentFrauds;
    private int fraudRate;

    @Data
    public static class MovementDTO {
        private Integer id;
        private String time;
        private String date;
        private String origin;
        private String destination;
        private String species;
        private Integer quantity;
        private String status;
    }

    @Data
    public static class FraudDTO {
        private Integer id;
        private String type;
        private String farmId;
        private String description;
        private String timeAgo;
        private String severity; // "HIGH" ou "INFO"
    }
}
package com.animaltracking.backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "constats")
public class Constat {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "controller_id", nullable = false)
    private Long controllerId;

    @Column(name = "farm_id", nullable = false)
    private Long farmId;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String description;

    @Column(name = "constat_type")
    private String constatType = "General";

    private String severity = "Normal"; // Normal, Minor, Critical

    private String status = "Pending"; // Pending, Resolved

    @Column(name = "scanned_count")
    private Integer scannedCount;

    @Column(name = "registered_count")
    private Integer registeredCount;

    private Integer difference;

    @Column(name = "missing_tags", columnDefinition = "TEXT")
    private String missingTags;

    // Getters / Setters
}

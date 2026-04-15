package com.animaltracking.backend.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "scan_sessions")
public class ScanSession {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "controller_id", nullable = false)
    private Long controllerId;

    @Column(name = "farm_id", nullable = false)
    private Long farmId;

    @Column(name = "session_date")
    private LocalDateTime sessionDate;

    @Column(columnDefinition = "TEXT")
    private String scannedTags; // Liste des tags séparés par des virgules

    @Column(name = "total_scanned")
    private Integer totalScanned;

    @Column(name = "total_registered")
    private Integer totalRegistered;

    private Integer difference;

    @Column(name = "is_consistent")
    private Boolean isConsistent;

    private String status;

    // Getters et Setters
}

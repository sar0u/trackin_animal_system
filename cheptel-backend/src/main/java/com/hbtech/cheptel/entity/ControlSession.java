package com.hbtech.cheptel.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "control_sessions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ControlSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "controleur_id", nullable = false)
    private User controleur;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "farm_id", nullable = false)
    private Farm farm;

    @Column(name = "expected_count")
    private Integer expectedCount;

    @Column(name = "detected_count")
    private Integer detectedCount;

    @Column(name = "missing_count")
    private Integer missingCount;

    @Column(name = "unknown_count")
    private Integer unknownCount;

    @ElementCollection
    @CollectionTable(name = "control_session_scanned_tags", joinColumns = @JoinColumn(name = "session_id"))
    @Column(name = "rfid_tag")
    private List<String> scannedTags = new ArrayList<>();

    @Column(name = "started_at")
    private LocalDateTime startedAt = LocalDateTime.now();

    @Column(name = "ended_at")
    private LocalDateTime endedAt;

    @Column(length = 1000)
    private String result; // ex: "OK", "ECART_DETECTE"
}
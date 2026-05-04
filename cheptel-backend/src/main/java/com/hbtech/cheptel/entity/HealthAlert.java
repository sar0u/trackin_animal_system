package com.hbtech.cheptel.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "health_alerts")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HealthAlert {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "animal_id", nullable = false)
    private Animal animal;

    @Enumerated(EnumType.STRING)
    @Column(name = "alert_type", nullable = false)
    private AlertType alertType;

    @Column(length = 500)
    private String message;

    @Column(name = "due_date", nullable = false)
    private LocalDate dueDate;

    @Column(name = "is_resolved")
    private Boolean isResolved = false;

    @Enumerated(EnumType.STRING)
    @Column(name = "severity")
    private AlertSeverity severity = AlertSeverity.WARNING;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }

        if (isResolved == null) {
            isResolved = false;
        }

        if (severity == null) {
            severity = AlertSeverity.WARNING;
        }
    }
}
package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "health_records")
public class HealthRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "animal_id", nullable = false)
    private Long animalId;

    @Column(name = "record_type", nullable = false)
    private String recordType; // Vaccination, Treatment, Disease...

    @Column(columnDefinition = "TEXT")
    private String diagnosis;

    @Column(columnDefinition = "TEXT")
    private String symptoms;

    @Column(columnDefinition = "TEXT")
    private String treatment;

    @Column(name = "veterinarian_id")
    private Long veterinarianId;

    @Column(name = "visit_date")
    private LocalDate visitDate;

    @Column(name = "next_visit_date")
    private LocalDate nextVisitDate;

    @Column(columnDefinition = "TEXT")
    private String notes;

    // Getters / Setters
}
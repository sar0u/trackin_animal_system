package com.animaltracking.backend.entity;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "subsidies")
public class Subsidy {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "farm_id", nullable = false)
    private Long farmId;

    @Column(name = "animal_id")
    private Long animalId;

    private Double amount;

    @Column(name = "subsidy_type")
    private String subsidyType; // ex: "Alimentation", "Aide COVID", "Vaccination"

    private String status = "Pending"; // Pending, Approved, Paid

    @Column(name = "request_date")
    private LocalDate requestDate = LocalDate.now();

    @Column(name = "approved_by")
    private Long approvedBy;

    // Getters / Setters
}

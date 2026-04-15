package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Entity
@Table(name = "vaccinations")
public class Vaccination {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "health_record_id", nullable = false)
    private Long healthRecordId;

    @Column(name = "vaccine_name", nullable = false)
    private String vaccineName;

    @Column(name = "vaccine_type")
    private String vaccineType;

    private String manufacturer;

    @Column(name = "batch_number")
    private String batchNumber;

    private String dose;

    @Column(name = "expiration_date")
    private LocalDate expirationDate;

    @Column(name = "next_dose_date")
    private LocalDate nextDoseDate;

    @Column(name = "administered_by")
    private Long administeredBy;

    // Getters / Setters
}
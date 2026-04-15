package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Entity
@Table(name = "Vaccinations") // Correspond au SQL
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Vaccination {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "HealthRecordId", nullable = false)
    private HealthRecord healthRecord;

    @Column(name = "VaccineName", nullable = false)
    private String vaccineName;

    @Column(name = "BatchNumber")
    private String batchNumber;

    @Column(name = "ExpirationDate")
    private LocalDate expirationDate;
}
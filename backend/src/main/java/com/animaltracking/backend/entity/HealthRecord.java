package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "HealthRecords") // Corrigé pour correspondre au SQL (S et Majuscule)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class HealthRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "AnimalId", nullable = false)
    private Animal animal;

    @ManyToOne
    @JoinColumn(name = "VeterinarianId", nullable = false)
    private User veterinarian;

    @Column(name = "VisitTimestamp", nullable = false)
    private LocalDateTime visitTimestamp;

    @Column(name = "NextVisitDate", nullable = false)
    private LocalDate nextvisitdate;

    @Enumerated(EnumType.STRING)
    @Column(name = "RecordType", nullable = false)
    private RecordType recordType;

    @Column(name = "ClinicalDiagnosis")
    private String clinicalDiagnosis;

    @Column(name = "TreatmentPlan")
    private String treatmentPlan;


}
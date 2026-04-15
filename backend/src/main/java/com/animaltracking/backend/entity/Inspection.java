package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "inspections")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Inspection {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @Column(name = "InspectorId", nullable = false)
    private Integer inspectorId;

    @Column(name = "AnimalId")
    private Integer animalId;

    @Column(name = "FarmId")
    private Integer farmId;

    @Column(name = "InspectionDate", nullable = false)
    private LocalDateTime inspectionDate;

    @Column(name = "Result", nullable = false)
    @Enumerated(EnumType.STRING)
    private InspectionResult result;

    @Column(name = "FraudType")
    @Enumerated(EnumType.STRING)
    private FraudType fraudType;

    @Column(name = "Status")
    @Enumerated(EnumType.STRING)
    private InspectionStatus status;

    @Column(name = "Notes")
    private String notes;

    @Column(name = "CreatedAt", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "inspection", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<InspectionImage> images;
}
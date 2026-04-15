package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "Animals")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Animal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @OneToOne
    @JoinColumn(name = "RfidTagId")
    private RfidTag rfidTag;

    @Column(name = "SpeciesName", nullable = false)
    private String species;

    @Column(name = "BreedName")
    private String breed;

    @Column(name = "AnimalGender")
    @Enumerated(EnumType.STRING)
    private AnimalGender animalGender;

    @Column(name = "BirthDate", nullable = false)
    private LocalDate birthDate;

    @Column(name = "CurrentWeightKilograms")
    private Double currentWeightKilograms;

    @Column(name = "LifeStatus")
    @Enumerated(EnumType.STRING)
    private LifeStatus lifeStatus;

    @Column(name = "OriginType")
    @Enumerated(EnumType.STRING)
    private OriginType originType;

    @Column(name = "HealthStatus")
    @Enumerated(EnumType.STRING)
    private HealthStatus healthStatus;

    @Column(name = "ReproductionStatus")
    @Enumerated(EnumType.STRING)
    private ReproductionStatus reproductionStatus;

    @ManyToOne
    @JoinColumn(name = "CurrentFarmId", nullable = false)
    private Farm currentFarm;

}
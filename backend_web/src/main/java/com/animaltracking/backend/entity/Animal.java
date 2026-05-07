package com.animaltracking.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "animals")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Animal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    // Charge la puce RFID en même temps que l'animal pour éviter les erreurs lazy-loading
    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "rfid_tag_id")
    private RfidTag rfidTag;

    @Enumerated(EnumType.STRING)
    @Column(name = "species", nullable = false)
    private Species species;

    @Column(name = "breed")
    private String breed;

    @Enumerated(EnumType.STRING)
    @Column(name = "gender")
    private Gender gender;

    @Column(name = "birth_date")
    private LocalDate birthDate;

    @Column(name = "birth_place")
    private String birthPlace;

    @Column(name = "acquisition_place")
    private String acquisitionPlace;

    @Column(name = "weight", precision = 10, scale = 2)
    private BigDecimal weight;

    @Enumerated(EnumType.STRING)
    @Column(name = "life_status")
    private LifeStatus lifeStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "origin_type")
    private OriginType originType;

    @Enumerated(EnumType.STRING)
    @Column(name = "health_status")
    private HealthStatus healthStatus;

    @ManyToOne
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @ManyToOne
    @JoinColumn(name = "farm_id", nullable = false)
    private Farm farm;

    @ManyToOne
    @JoinColumn(name = "mother_id")
    @JsonIgnoreProperties({"mother", "father"})
    private Animal mother;

    @ManyToOne
    @JoinColumn(name = "father_id")
    @JsonIgnoreProperties({"mother", "father"})
    private Animal father;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

}
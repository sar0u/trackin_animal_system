package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "Farms") // Correspond au SQL
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Farm {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "OwnerId", nullable = false)
    private Owner owner;

    @Column(name = "FarmName", nullable = false)
    private String farmName;

    @Column(name = "GeographicAddress")
    private String geographicAddress;

    @Column(name = "LatitudeCoordinate")
    private Double latitudeCoordinate;

    @Column(name = "LongitudeCoordinate")
    private Double longitudeCoordinate;

    // --- COLONNES NON PRÉSENTES DANS TON SCRIPT SQL ---

    @Transient // N'existe pas dans ton CREATE TABLE Farms
    private String farmCode;

    @Transient // N'existe pas dans ton CREATE TABLE Farms
    private Boolean isActive;

    @Transient // N'existe pas dans ton CREATE TABLE Farms
    private LocalDateTime createdAt;
}
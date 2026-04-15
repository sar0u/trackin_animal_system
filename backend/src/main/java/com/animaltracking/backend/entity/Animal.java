package com.animaltracking.backend.entity;

import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
@Table(name = "animals")
public class Animal {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "rfid_tag", unique = true, nullable = false)
    private String rfidTag;

    private String species;
    private String breed;
    private String gender;
    private String status = "Active";
    private String color;
    private Double weight;

    @Column(name = "birth_date")
    private LocalDate birthDate;

    @Column(name = "birth_place")
    private String birthPlace;

    @Column(name = "origin_type")
    private String originType;

    @Column(name = "health_status")
    private String healthStatus = "Healthy";

    @Column(name = "farm_id")
    private Long farmId;

    @Column(name = "owner_id")
    private Long ownerId;

    @Column(name = "mother_rfid")
    private String motherRfid;

    // Getters / Setters
}
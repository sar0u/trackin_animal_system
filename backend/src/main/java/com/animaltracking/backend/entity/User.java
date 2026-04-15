package com.animaltracking.backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String role; // Administrator, Veterinarian, Owner, Controller

    private String email;

    @Column(name = "full_name")
    private String fullName;

    private String phone;

    @Column(name = "farm_id")
    private Long farmId;

    @Column(name = "is_active")
    private Boolean isActive = true;

    // Getters / Setters
}
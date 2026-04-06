package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "Owners") // Correspond au SQL
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Owner {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @OneToOne
    @JoinColumn(name = "UserId")
    private User user;

    @Column(name = "FullOwnerName", nullable = false)
    private String fullOwnerName;

    @Column(name = "ContactPhoneNumber")
    private String contactPhoneNumber;

    // --- COLONNES NON PRÉSENTES DANS TON SCRIPT SQL ---

    @Transient // N'existe pas dans ton CREATE TABLE Owners
    private String nationalId;

    @Transient // N'existe pas dans ton CREATE TABLE Owners
    private LocalDateTime createdAt;
}
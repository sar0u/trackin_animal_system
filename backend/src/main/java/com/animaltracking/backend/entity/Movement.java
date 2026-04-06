package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "Movements") // Correspond au SQL
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Movement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "AnimalId", nullable = false)
    private Animal animal;

    @ManyToOne
    @JoinColumn(name = "DepartureFarmId", nullable = false)
    private Farm departureFarm;

    @ManyToOne
    @JoinColumn(name = "DestinationFarmId", nullable = false)
    private Farm destinationFarm;

    @Column(name = "MovementTimestamp", updatable = false, insertable = false)
    private LocalDateTime movementTimestamp;

    @Column(name = "MovementReason")
    private String movementReason;

    // --- COLONNES NON PRÉSENTES DANS TON SCRIPT SQL ---

    @Transient // N'existe pas dans ton CREATE TABLE Movements
    private String transportMethod;

    @Transient // N'existe pas dans ton CREATE TABLE Movements
    private User recordedByUser;
}
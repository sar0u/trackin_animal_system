package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "Movements") // "M" majuscule comme dans ton SQL
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class Movement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id; // Utilise Integer car c'est un INT en SQL

    @Column(name = "AnimalId", nullable = false)
    private Integer animalId;

    @Column(name = "DepartureFarmId", nullable = false)
    private Integer departureFarmId; // Correspond au SQL

    @Column(name = "DestinationFarmId", nullable = false)
    private Integer destinationFarmId; // Correspond au SQL

    @Column(name = "MovementTimestamp", insertable = false, updatable = false)
    private LocalDateTime movementTimestamp;

    @Column(name = "MovementReason")
    private String movementReason;
}
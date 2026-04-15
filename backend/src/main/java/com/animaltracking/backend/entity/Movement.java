package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "movements")
public class Movement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "animal_id", nullable = false)
    private Long animalId;

    @Column(name = "from_farm_id")
    private Long fromFarmId;

    @Column(name = "to_farm_id")
    private Long toFarmId;

    @Column(name = "from_location")
    private String fromLocation;

    @Column(name = "to_location")
    private String toLocation;

    private String reason;

    @Column(name = "move_date", nullable = false)
    private LocalDate moveDate;

    @Column(name = "approved_by")
    private Long approvedBy;

    // Getters / Setters
}
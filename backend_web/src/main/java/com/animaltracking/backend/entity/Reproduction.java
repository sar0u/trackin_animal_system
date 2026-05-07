package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "reproductions")
@Getter
@Setter
@NoArgsConstructor
public class Reproduction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "female_id", nullable = false)
    private Animal female;

    @ManyToOne
    @JoinColumn(name = "male_id")
    private Animal male;

    @Column(name = "breeding_date", nullable = false)
    private LocalDate breedingDate;

    @Column(name = "expected_birth_date")
    private LocalDate expectedBirthDate;

    @Column(name = "actual_birth_date")
    private LocalDate actualBirthDate;

    @Column(name = "offspring_count")
    private int offspringCount = 0;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private ReproductionStatus status = ReproductionStatus.IN_PROGRESS;

    @ManyToOne
    @JoinColumn(name = "veterinarian_id")
    private User veterinarian;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private LocalDateTime updatedAt;
}

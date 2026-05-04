package com.hbtech.cheptel.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "reproductions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Reproduction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Femelle concernée
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "female_id", nullable = false)
    private Animal female;

    // Mâle concerné
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "male_id")
    private Animal male;

    @Column(name = "breeding_date", nullable = false)
    private LocalDate breedingDate;

    @Column(name = "expected_birth_date")
    private LocalDate expectedBirthDate;

    @Column(name = "actual_birth_date")
    private LocalDate actualBirthDate;

    @Column(name = "offspring_count")
    private Integer offspringCount;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private ReproductionRecordStatus status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "veterinarian_id")
    private User veterinarian;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }

        if (updatedAt == null) {
            updatedAt = LocalDateTime.now();
        }

        if (status == null) {
            status = ReproductionRecordStatus.IN_PROGRESS;
        }

        if (offspringCount == null) {
            offspringCount = 0;
        }
    }

    @PreUpdate
    public void preUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
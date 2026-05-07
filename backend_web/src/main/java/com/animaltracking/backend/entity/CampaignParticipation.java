package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "campaign_participations",
       uniqueConstraints = @UniqueConstraint(columnNames = {"campaign_id", "animal_id"}))
@Getter
@Setter
@NoArgsConstructor
public class CampaignParticipation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "campaign_id", nullable = false)
    private SanitaryCampaign campaign;

    @ManyToOne
    @JoinColumn(name = "animal_id", nullable = false)
    private Animal animal;

    @ManyToOne
    @JoinColumn(name = "veterinarian_id")
    private User veterinarian;

    @Column(name = "vaccination_date")
    private LocalDate vaccinationDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private ParticipationStatus status = ParticipationStatus.Pending;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;
}

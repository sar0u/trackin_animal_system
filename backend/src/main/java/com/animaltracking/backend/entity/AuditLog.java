package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "AuditLogs") // Corrigé pour correspondre au SQL (Majuscules et Pluriel)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long id;

    @ManyToOne
    @JoinColumn(name = "UserId")
    private User user;

    @Column(name = "PerformedAction")
    private String performedAction;

    @Column(name = "EventTimestamp", updatable = false, insertable = false)
    private LocalDateTime eventTimestamp;

    @Column(name = "OldValuesJson", columnDefinition = "json")
    private String oldValuesJson;

    @Column(name = "NewValuesJson", columnDefinition = "json")
    private String newValuesJson;

    // --- COLONNES NON PRÉSENTES DANS TON SCRIPT SQL ---
    // On les marque en @Transient pour éviter les erreurs "Unknown column"

    @Transient
    private String affectedTable;

    @Transient
    private Integer affectedRecordId;

    @Transient
    private String ipAddress;
}
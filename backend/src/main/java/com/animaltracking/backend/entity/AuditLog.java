package com.animaltracking.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "AuditLogs")
public class AuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Id")
    private Long id; // BIGINT en SQL correspond à Long en Java

    @Column(name = "UserId")
    private Integer userId;

    @Column(name = "PerformedAction")
    private String performedAction;

    @Column(name = "EventTimestamp", insertable = false, updatable = false)
    private LocalDateTime eventTimestamp;

    @Column(name = "OldValuesJson", columnDefinition = "JSON")
    private String oldValuesJson;

    @Column(name = "NewValuesJson", columnDefinition = "JSON")
    private String newValuesJson;

    // --- Constructeur vide obligatoire pour JPA ---
    public AuditLog() {
    }

    // --- Getters et Setters explicites ---
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getPerformedAction() {
        return performedAction;
    }

    public void setPerformedAction(String performedAction) {
        this.performedAction = performedAction;
    }

    public LocalDateTime getEventTimestamp() {
        return eventTimestamp;
    }

    public void setEventTimestamp(LocalDateTime eventTimestamp) {
        this.eventTimestamp = eventTimestamp;
    }

    public String getOldValuesJson() {
        return oldValuesJson;
    }

    public void setOldValuesJson(String oldValuesJson) {
        this.oldValuesJson = oldValuesJson;
    }

    public String getNewValuesJson() {
        return newValuesJson;
    }

    public void setNewValuesJson(String newValuesJson) {
        this.newValuesJson = newValuesJson;
    }
}
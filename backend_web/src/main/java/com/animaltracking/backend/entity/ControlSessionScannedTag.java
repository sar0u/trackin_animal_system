package com.animaltracking.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "control_session_scanned_tags")
@IdClass(ControlSessionScannedTagId.class)
@Getter
@Setter
@NoArgsConstructor
public class ControlSessionScannedTag {

    @Id
    @ManyToOne
    @JoinColumn(name = "session_id", nullable = false)
    @JsonIgnore
    private ControlSession session;

    @Id
    @Column(name = "rfid_tag", length = 100, nullable = false)
    private String rfidTag;

    @Column(name = "is_recognized")
    private Boolean isRecognized = false;

    @Column(name = "scanned_at", insertable = false, updatable = false)
    private LocalDateTime scannedAt;
}

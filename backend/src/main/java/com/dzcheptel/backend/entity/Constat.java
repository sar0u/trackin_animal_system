package com.dzcheptel.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "constats")
@Getter
@Setter
@NoArgsConstructor
public class Constat {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "control_session_id")
    @JsonIgnoreProperties({"scannedTags"})
    private ControlSession controlSession;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private ConstatType type;

    @Column(name = "description", columnDefinition = "TEXT", nullable = false)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private ConstatStatus status = ConstatStatus.PENDING;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "resolved_at")
    private LocalDateTime resolvedAt;

    @OneToMany(mappedBy = "constat", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ConstatImage> images = new ArrayList<>();
}

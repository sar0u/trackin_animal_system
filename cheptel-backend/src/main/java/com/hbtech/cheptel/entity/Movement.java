package com.hbtech.cheptel.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "movements")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Movement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "animal_id", nullable = false)
    private Animal animal;

    @Enumerated(EnumType.STRING)
    @Column(name = "movement_type", nullable = false)
    private MovementType movementType;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "from_farm_id")
    private Farm fromFarm;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "to_farm_id")
    private Farm toFarm;

    @Column(name = "movement_date", nullable = false)
    private LocalDateTime movementDate;

    private BigDecimal price;

    @Column(name = "counterparty_name")
    private String counterpartyName;

    @Column(name = "counterparty_phone")
    private String counterpartyPhone;

    @Column(name = "document_reference")
    private String documentReference;

    private Double latitude;
    private Double longitude;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "performed_by", nullable = false)
    private User performedBy;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}
package com.hbtech.cheptel.dto.response;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MovementResponse {
    private Long id;
    private Long animalId;
    private String animalRfidTag;
    private String movementType;
    private Long fromFarmId;
    private String fromFarmName;
    private Long toFarmId;
    private String toFarmName;
    private LocalDateTime movementDate;
    private BigDecimal price;
    private String counterpartyName;
    private String counterpartyPhone;
    private String documentReference;
    private Double latitude;
    private Double longitude;
    private String performedByUsername;
    private String notes;
    private LocalDateTime createdAt;
}
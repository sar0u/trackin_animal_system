package com.hbtech.cheptel.dto.response;

import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReproductionResponse {

    private Long id;

    private Long femaleId;
    private String femaleRfidTag;

    private Long maleId;
    private String maleRfidTag;

    private LocalDate breedingDate;
    private LocalDate expectedBirthDate;
    private LocalDate actualBirthDate;

    private Integer offspringCount;
    private String status;

    private String veterinarianUsername;
    private String notes;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
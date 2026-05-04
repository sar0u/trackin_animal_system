package com.hbtech.cheptel.dto.response;

import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HealthSheetResponse {

    private Long animalId;
    private String rfidTag;
    private String species;
    private String breed;
    private Double weight;
    private String status;

    private Long farmId;
    private String farmName;

    private List<VaccinationDto> vaccinations;
    private List<HealthRecordDto> healthRecords;

    @Getter
    @Setter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class VaccinationDto {
        private Long id;
        private String vaccineName;
        private String vaccineType;
        private String manufacturer;
        private String batchNumber;
        private LocalDate vaccinationDate;
        private LocalDate expirationDate;
    }

    @Getter
    @Setter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class HealthRecordDto {
        private Long id;
        private String recordType;
        private String diagnosis;
        private String symptoms;
        private String treatment;
        private LocalDateTime visitDate;
        private LocalDateTime nextVisitDate;
        private String veterinarianName;
    }
}
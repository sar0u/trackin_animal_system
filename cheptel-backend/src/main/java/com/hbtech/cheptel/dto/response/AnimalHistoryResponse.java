package com.hbtech.cheptel.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@Builder
public class AnimalHistoryResponse {
    private Long animalId;
    private String rfidTag;
    private String species;
    private String breed;
    private String status;
    private String farmName;
    private List<HealthSheetResponse.VaccinationDto> vaccinations;
    private List<HealthSheetResponse.HealthRecordDto> healthRecords;
}
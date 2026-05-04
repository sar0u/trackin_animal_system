package com.hbtech.cheptel.dto.response;

import com.hbtech.cheptel.entity.AnimalStatus;
import com.hbtech.cheptel.entity.Gender;
import com.hbtech.cheptel.entity.Species;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@Builder
public class AnimalResponse {
    private Long id;
    private String rfidTag;
    private Species species;
    private String breed;
    private Gender gender;
    private Double weight;
    private AnimalStatus status;
    private String color;
    private LocalDate birthDate;

    private Long farmId;
    private String farmName;
}
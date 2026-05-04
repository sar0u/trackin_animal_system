package com.hbtech.cheptel.dto.request;

import com.hbtech.cheptel.entity.ReproductionRecordStatus;

import java.time.LocalDate;

public class CreateReproductionRequest {

    private Long femaleId;
    private Long maleId;
    private LocalDate breedingDate;
    private LocalDate expectedBirthDate;
    private LocalDate actualBirthDate;
    private Integer offspringCount;
    private ReproductionRecordStatus status;
    private String notes;

    public Long getFemaleId() {
        return femaleId;
    }

    public void setFemaleId(Long femaleId) {
        this.femaleId = femaleId;
    }

    public Long getMaleId() {
        return maleId;
    }

    public void setMaleId(Long maleId) {
        this.maleId = maleId;
    }

    public LocalDate getBreedingDate() {
        return breedingDate;
    }

    public void setBreedingDate(LocalDate breedingDate) {
        this.breedingDate = breedingDate;
    }

    public LocalDate getExpectedBirthDate() {
        return expectedBirthDate;
    }

    public void setExpectedBirthDate(LocalDate expectedBirthDate) {
        this.expectedBirthDate = expectedBirthDate;
    }

    public LocalDate getActualBirthDate() {
        return actualBirthDate;
    }

    public void setActualBirthDate(LocalDate actualBirthDate) {
        this.actualBirthDate = actualBirthDate;
    }

    public Integer getOffspringCount() {
        return offspringCount;
    }

    public void setOffspringCount(Integer offspringCount) {
        this.offspringCount = offspringCount;
    }

    public ReproductionRecordStatus getStatus() {
        return status;
    }

    public void setStatus(ReproductionRecordStatus status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
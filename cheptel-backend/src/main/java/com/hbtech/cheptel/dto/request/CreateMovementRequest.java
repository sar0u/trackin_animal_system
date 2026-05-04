package com.hbtech.cheptel.dto;

import com.hbtech.cheptel.entity.MovementType;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class CreateMovementRequest {

    private Long animalId;
    private MovementType movementType;
    private Long fromFarmId;
    private Long toFarmId;
    private LocalDateTime movementDate;
    private BigDecimal price;
    private String counterpartyName;
    private String counterpartyPhone;
    private String documentReference;
    private Double latitude;
    private Double longitude;
    private String notes;

    // Getters & Setters
    public Long getAnimalId() { return animalId; }
    public void setAnimalId(Long animalId) { this.animalId = animalId; }

    public MovementType getMovementType() { return movementType; }
    public void setMovementType(MovementType movementType) { this.movementType = movementType; }

    public Long getFromFarmId() { return fromFarmId; }
    public void setFromFarmId(Long fromFarmId) { this.fromFarmId = fromFarmId; }

    public Long getToFarmId() { return toFarmId; }
    public void setToFarmId(Long toFarmId) { this.toFarmId = toFarmId; }

    public LocalDateTime getMovementDate() { return movementDate; }
    public void setMovementDate(LocalDateTime movementDate) { this.movementDate = movementDate; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public String getCounterpartyName() { return counterpartyName; }
    public void setCounterpartyName(String counterpartyName) { this.counterpartyName = counterpartyName; }

    public String getCounterpartyPhone() { return counterpartyPhone; }
    public void setCounterpartyPhone(String counterpartyPhone) { this.counterpartyPhone = counterpartyPhone; }

    public String getDocumentReference() { return documentReference; }
    public void setDocumentReference(String documentReference) { this.documentReference = documentReference; }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
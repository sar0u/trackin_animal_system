package com.hbtech.cheptel.dto.request;

import java.util.List;

public class ControlCheckRequest {

    private Long farmId;
    private List<String> scannedRfidTags;

    public ControlCheckRequest() {
    }

    public ControlCheckRequest(Long farmId, List<String> scannedRfidTags) {
        this.farmId = farmId;
        this.scannedRfidTags = scannedRfidTags;
    }

    public Long getFarmId() {
        return farmId;
    }

    public void setFarmId(Long farmId) {
        this.farmId = farmId;
    }

    public List<String> getScannedRfidTags() {
        return scannedRfidTags;
    }

    public void setScannedRfidTags(List<String> scannedRfidTags) {
        this.scannedRfidTags = scannedRfidTags;
    }
}
package com.dzcheptel.backend.entity;

import java.io.Serializable;
import java.util.Objects;

public class ControlSessionScannedTagId implements Serializable {

    private Long session;
    private String rfidTag;

    public ControlSessionScannedTagId() {}

    public ControlSessionScannedTagId(Long session, String rfidTag) {
        this.session = session;
        this.rfidTag = rfidTag;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ControlSessionScannedTagId)) return false;
        ControlSessionScannedTagId that = (ControlSessionScannedTagId) o;
        return Objects.equals(session, that.session) && Objects.equals(rfidTag, that.rfidTag);
    }

    @Override
    public int hashCode() {
        return Objects.hash(session, rfidTag);
    }
}

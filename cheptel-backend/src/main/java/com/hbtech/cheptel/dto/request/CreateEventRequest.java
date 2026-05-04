package com.hbtech.cheptel.dto.request;

import com.hbtech.cheptel.entity.EventType;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class CreateEventRequest {
    private EventType eventType;
    private LocalDateTime eventDate;
    private Double latitude;
    private Double longitude;
    private String location;
    private String notes;
}
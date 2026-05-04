package com.hbtech.cheptel.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
public class EventResponse {
    private Long id;
    private String eventType;
    private LocalDateTime eventDate;
    private Double latitude;
    private Double longitude;
    private String location;
    private String notes;
    private String performedBy;
    private LocalDateTime createdAt;
}
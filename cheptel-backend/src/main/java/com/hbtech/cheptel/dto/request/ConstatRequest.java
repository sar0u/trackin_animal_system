package com.hbtech.cheptel.dto.request;

import com.hbtech.cheptel.entity.ConstatType;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ConstatRequest {
    private Long farmId;
    private Long controlSessionId; // optionnel
    private ConstatType type;
    private String description;
    private Double latitude;
    private Double longitude;
    private String localisationText;
    private String photoUrl;
    private String voiceMemoUrl;
}
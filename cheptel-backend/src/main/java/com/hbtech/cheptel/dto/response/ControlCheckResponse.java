package com.hbtech.cheptel.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ControlCheckResponse {

    private Long sessionId;
    private Long farmId;
    private String farmName;
    private Integer expectedCount;
    private Integer detectedCount;
    private Integer missingCount;
    private Integer unknownCount;
    private List<String> missingTags;
    private List<String> unknownTags;
    private String result;
}
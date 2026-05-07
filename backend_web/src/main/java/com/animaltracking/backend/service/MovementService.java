package com.animaltracking.backend.service;

import java.util.List;
import java.util.Map;

public interface MovementService {
    List<Map<String, Object>> listForApi();
    Map<String, Object> getForApi(Long id);
}

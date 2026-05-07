package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.ControlSession;
import com.animaltracking.backend.entity.ControlSessionResult;

import java.util.List;

public interface ControlSessionService {
    List<ControlSession> getAll();
    ControlSession getById(Long id);
    ControlSession create(ControlSession session);
    ControlSession update(Long id, ControlSession payload);
    void delete(Long id);
    List<ControlSession> getByFarm(Long farmId);
    List<ControlSession> getByResult(ControlSessionResult result);
}

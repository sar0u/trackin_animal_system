package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.ControlSession;
import com.animaltracking.backend.entity.ControlSessionResult;
import com.animaltracking.backend.repository.ControlSessionRepository;
import com.animaltracking.backend.service.ControlSessionService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class ControlSessionServiceImpl implements ControlSessionService {

    private final ControlSessionRepository repo;

    @Override
    @Transactional(readOnly = true)
    public List<ControlSession> getAll() {
        return repo.findAllFetched();
    }

    @Override
    @Transactional(readOnly = true)
    public ControlSession getById(Long id) {
        return repo.findFetchedById(id)
                .orElseThrow(() -> new EntityNotFoundException("Session de contrôle introuvable : " + id));
    }

    @Override
    public ControlSession create(ControlSession session) {
        return repo.save(session);
    }

    @Override
    public ControlSession update(Long id, ControlSession payload) {
        ControlSession existing = getById(id);
        existing.setExpectedCount(payload.getExpectedCount());
        existing.setStartedAt(payload.getStartedAt());
        existing.setEndedAt(payload.getEndedAt());
        existing.setResult(payload.getResult());
        if (payload.getController() != null) existing.setController(payload.getController());
        if (payload.getFarm() != null) existing.setFarm(payload.getFarm());
        return repo.save(existing);
    }

    @Override
    public void delete(Long id) {
        repo.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ControlSession> getByFarm(Long farmId) {
        return repo.findByFarmId(farmId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ControlSession> getByResult(ControlSessionResult result) {
        return repo.findByResult(result);
    }
}

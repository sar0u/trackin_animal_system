package com.dzcheptel.backend.service.impl;

import com.dzcheptel.backend.entity.Reproduction;
import com.dzcheptel.backend.repository.ReproductionRepository;
import com.dzcheptel.backend.service.ReproductionService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
@RequiredArgsConstructor
public class ReproductionServiceImpl implements ReproductionService {

    private final ReproductionRepository repo;

    @Override
    @Transactional(readOnly = true)
    public List<Reproduction> getAll() {
        return repo.findAllFetched();
    }

    @Override
    @Transactional(readOnly = true)
    public Reproduction getById(Long id) {
        return repo.findFetchedById(id)
                .orElseThrow(() -> new EntityNotFoundException("Reproduction introuvable : " + id));
    }

    @Override
    public Reproduction create(Reproduction reproduction) {
        return repo.save(reproduction);
    }

    @Override
    public Reproduction update(Long id, Reproduction payload) {
        Reproduction existing = getById(id);
        existing.setBreedingDate(payload.getBreedingDate());
        existing.setExpectedBirthDate(payload.getExpectedBirthDate());
        existing.setActualBirthDate(payload.getActualBirthDate());
        existing.setOffspringCount(payload.getOffspringCount());
        existing.setStatus(payload.getStatus());
        existing.setNotes(payload.getNotes());
        if (payload.getMale() != null) existing.setMale(payload.getMale());
        if (payload.getVeterinarian() != null) existing.setVeterinarian(payload.getVeterinarian());
        return repo.save(existing);
    }

    @Override
    public void delete(Long id) {
        repo.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Reproduction> getByFemale(Long femaleId) {
        return repo.findByFemaleId(femaleId);
    }
}

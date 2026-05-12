package com.dzcheptel.backend.service;

import com.dzcheptel.backend.entity.Reproduction;

import java.util.List;

public interface ReproductionService {
    List<Reproduction> getAll();
    Reproduction getById(Long id);
    Reproduction create(Reproduction reproduction);
    Reproduction update(Long id, Reproduction payload);
    void delete(Long id);
    List<Reproduction> getByFemale(Long femaleId);
}

package com.hbtech.cheptel.repository;

import com.hbtech.cheptel.entity.Reproduction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReproductionRepository extends JpaRepository<Reproduction, Long> {

    List<Reproduction> findByFemaleIdOrderByBreedingDateDesc(Long femaleId);

    List<Reproduction> findByMaleIdOrderByBreedingDateDesc(Long maleId);
}
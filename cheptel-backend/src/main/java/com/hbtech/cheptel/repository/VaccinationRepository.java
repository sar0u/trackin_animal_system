package com.hbtech.cheptel.repository;

import com.hbtech.cheptel.entity.Vaccination;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VaccinationRepository extends JpaRepository<Vaccination, Long> {

    List<Vaccination> findByAnimalIdOrderByVaccinationDateDesc(Long animalId);
}
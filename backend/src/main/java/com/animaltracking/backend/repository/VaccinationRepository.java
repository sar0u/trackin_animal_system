package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.Vaccination;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface VaccinationRepository extends JpaRepository<Vaccination, Integer> {
    List<Vaccination> findByHealthRecordId(Integer healthRecordId);
    // Utile pour les rappels de vaccins
    List<Vaccination> findByVaccineNameContaining(String name);
}
package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.Vaccination;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface VaccinationRepository extends JpaRepository<Vaccination, Long> {
    List<Vaccination> findByHealthRecordId(Long healthRecordId);

    // Recherche les vaccinations par nom du vaccin
    List<Vaccination> findByVaccineNameContaining(String name);
}
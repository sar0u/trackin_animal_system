package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.Inspection;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List; // 🟢 N'oublie pas l'import

public interface InspectionRepository extends JpaRepository<Inspection, Integer> {

    // 🟢 CORRECTION 3 : La méthode manquante
    List<Inspection> findByAnimalId(Integer animalId);

}
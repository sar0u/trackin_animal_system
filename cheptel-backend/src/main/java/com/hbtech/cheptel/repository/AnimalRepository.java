package com.hbtech.cheptel.repository;

import com.hbtech.cheptel.entity.Animal;
import com.hbtech.cheptel.entity.AnimalStatus;
import com.hbtech.cheptel.entity.Species;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface AnimalRepository extends JpaRepository<Animal, Long> {

    Optional<Animal> findByRfidTag(String rfidTag);

    List<Animal> findByFarmId(Long farmId);

    long countByFarmId(Long farmId);

    long countByFarmIdAndStatus(Long farmId, AnimalStatus status);

    long countByStatus(AnimalStatus status);

    long countBySpeciesAndStatus(Species species, AnimalStatus status);
}


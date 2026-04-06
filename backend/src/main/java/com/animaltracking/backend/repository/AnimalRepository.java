package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.Animal;
import com.animaltracking.backend.entity.HealthStatus;
import com.animaltracking.backend.entity.LifeStatus;
import com.animaltracking.backend.entity.ReproductionStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface AnimalRepository extends JpaRepository<Animal, Integer> {

    Optional<Animal> findByAnimalCode(String animalCode);

    Boolean existsByAnimalCode(String animalCode);

    Optional<Animal> findByRfidTagId(Integer rfidTagId);

    List<Animal> findByOwnerId(Integer ownerId);

    List<Animal> findByCurrentFarmId(Integer farmId);

    List<Animal> findByOwnerIdAndLifeStatus(Integer ownerId, LifeStatus status);

    List<Animal> findByLifeStatus(LifeStatus lifeStatus);

    List<Animal> findByHealthStatus(HealthStatus healthStatus);

    List<Animal> findByReproductionStatus(ReproductionStatus reproductionStatus);

    List<Animal> findBySpeciesContainingIgnoreCase(String species);

    List<Animal> findByBreedContainingIgnoreCase(String breed);

    List<Animal> findByBirthDateBetween(LocalDate start, LocalDate end);
}
package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.Animal;
import com.animaltracking.backend.entity.HealthStatus;
import com.animaltracking.backend.entity.LifeStatus;
import com.animaltracking.backend.entity.Species;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface AnimalRepository extends JpaRepository<Animal, Long> {

    // Récupère tous les animaux avec leurs relations chargées d'un coup
    @Query("SELECT DISTINCT a FROM Animal a "
            + "LEFT JOIN FETCH a.rfidTag "
            + "LEFT JOIN FETCH a.farm f LEFT JOIN FETCH f.owner "
            + "LEFT JOIN FETCH a.owner "
            + "LEFT JOIN FETCH a.mother "
            + "LEFT JOIN FETCH a.father")
    List<Animal> findAllFetched();

    @Query("SELECT DISTINCT a FROM Animal a "
            + "LEFT JOIN FETCH a.rfidTag "
            + "LEFT JOIN FETCH a.farm f LEFT JOIN FETCH f.owner "
            + "LEFT JOIN FETCH a.owner "
            + "LEFT JOIN FETCH a.mother "
            + "LEFT JOIN FETCH a.father "
            + "WHERE a.id = :id")
    Optional<Animal> findFetchedById(Long id);

    Optional<Animal> findByRfidTagId(Long rfidTagId);

    List<Animal> findByFarmId(Long farmId);

    List<Animal> findByLifeStatus(LifeStatus lifeStatus);

    List<Animal> findByHealthStatus(HealthStatus healthStatus);

    List<Animal> findBySpecies(Species species);

    List<Animal> findByBreedContainingIgnoreCase(String breed);

    List<Animal> findByBirthDateBetween(LocalDate start, LocalDate end);
}
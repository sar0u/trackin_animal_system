package com.dzcheptel.backend.repository;

import com.dzcheptel.backend.entity.Animal;
import com.dzcheptel.backend.entity.AnimalStatus;
import com.dzcheptel.backend.entity.HealthStatus;
import com.dzcheptel.backend.entity.Species;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface AnimalRepository extends JpaRepository<Animal, Long> {

    @Query("SELECT DISTINCT a FROM Animal a "
            + "LEFT JOIN FETCH a.rfidTagEntity "
            + "LEFT JOIN FETCH a.farm f LEFT JOIN FETCH f.owner "
            + "LEFT JOIN FETCH a.owner "
            + "LEFT JOIN FETCH a.mother "
            + "LEFT JOIN FETCH a.father")
    List<Animal> findAllFetched();

    @Query("SELECT DISTINCT a FROM Animal a "
            + "LEFT JOIN FETCH a.rfidTagEntity "
            + "LEFT JOIN FETCH a.farm f LEFT JOIN FETCH f.owner "
            + "LEFT JOIN FETCH a.owner "
            + "LEFT JOIN FETCH a.mother "
            + "LEFT JOIN FETCH a.father "
            + "WHERE a.id = :id")
    Optional<Animal> findFetchedById(Long id);

    @Query("SELECT a FROM Animal a "
            + "LEFT JOIN FETCH a.rfidTagEntity rt "
            + "LEFT JOIN FETCH a.farm "
            + "LEFT JOIN FETCH a.owner "
            + "WHERE rt.rfidCode = :rfidCode")
    Optional<Animal> findByRfidCode(String rfidCode);

    Optional<Animal> findByRfidTagEntityId(Long rfidTagId);

    List<Animal> findByFarmId(Long farmId);

    List<Animal> findByStatus(AnimalStatus status);

    List<Animal> findByHealthStatus(HealthStatus healthStatus);

    List<Animal> findBySpecies(Species species);

    List<Animal> findByBreedContainingIgnoreCase(String breed);

    List<Animal> findByBirthDateBetween(LocalDate start, LocalDate end);

    long countByFarmIdAndStatus(Long farmId, AnimalStatus status);

    long countByStatus(AnimalStatus status);

    long countBySpeciesAndStatus(Species species, AnimalStatus status);
}

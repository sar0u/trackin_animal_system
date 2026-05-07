package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.Reproduction;
import com.animaltracking.backend.entity.ReproductionStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface ReproductionRepository extends JpaRepository<Reproduction, Long> {

    @Query("SELECT r FROM Reproduction r "
            + "LEFT JOIN FETCH r.female "
            + "LEFT JOIN FETCH r.male "
            + "LEFT JOIN FETCH r.veterinarian")
    List<Reproduction> findAllFetched();

    @Query("SELECT r FROM Reproduction r "
            + "LEFT JOIN FETCH r.female "
            + "LEFT JOIN FETCH r.male "
            + "LEFT JOIN FETCH r.veterinarian "
            + "WHERE r.id = :id")
    Optional<Reproduction> findFetchedById(Long id);

    List<Reproduction> findByFemaleId(Long femaleId);

    List<Reproduction> findByStatus(ReproductionStatus status);
}

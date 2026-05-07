package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.Constat;
import com.animaltracking.backend.entity.ConstatStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface ConstatRepository extends JpaRepository<Constat, Long> {

    @Query("SELECT DISTINCT c FROM Constat c "
            + "LEFT JOIN FETCH c.images "
            + "LEFT JOIN FETCH c.controlSession cs "
            + "LEFT JOIN FETCH cs.controller "
            + "LEFT JOIN FETCH cs.farm")
    List<Constat> findAllFetched();

    @Query("SELECT c FROM Constat c "
            + "LEFT JOIN FETCH c.controlSession cs "
            + "LEFT JOIN FETCH cs.controller "
            + "LEFT JOIN FETCH cs.farm "
            + "LEFT JOIN FETCH c.images "
            + "WHERE c.id = :id")
    Optional<Constat> findFetchedById(Long id);

    List<Constat> findByStatus(ConstatStatus status);

    List<Constat> findByControlSessionId(Long sessionId);
}

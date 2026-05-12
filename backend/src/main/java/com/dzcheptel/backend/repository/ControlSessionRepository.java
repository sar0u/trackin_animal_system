package com.dzcheptel.backend.repository;

import com.dzcheptel.backend.entity.ControlSession;
import com.dzcheptel.backend.entity.ControlSessionResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface ControlSessionRepository extends JpaRepository<ControlSession, Long> {

    @Query("SELECT cs FROM ControlSession cs "
            + "LEFT JOIN FETCH cs.controller "
            + "LEFT JOIN FETCH cs.farm f LEFT JOIN FETCH f.owner")
    List<ControlSession> findAllFetched();

    @Query("SELECT cs FROM ControlSession cs "
            + "LEFT JOIN FETCH cs.controller "
            + "LEFT JOIN FETCH cs.farm f LEFT JOIN FETCH f.owner "
            + "WHERE cs.id = :id")
    Optional<ControlSession> findFetchedById(Long id);

    List<ControlSession> findByFarmId(Long farmId);

    List<ControlSession> findByResult(ControlSessionResult result);
}

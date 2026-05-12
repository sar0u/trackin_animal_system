package com.dzcheptel.backend.repository;

import com.dzcheptel.backend.entity.Subsidy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface SubsidyRepository extends JpaRepository<Subsidy, Long> {

    @Query("SELECT DISTINCT s FROM Subsidy s "
            + "LEFT JOIN FETCH s.animal a LEFT JOIN FETCH a.rfidTagEntity "
            + "LEFT JOIN FETCH a.farm f LEFT JOIN FETCH f.owner "
            + "LEFT JOIN FETCH a.owner "
            + "LEFT JOIN FETCH s.treatedBy")
    List<Subsidy> findAllFetched();

    @Query("SELECT s FROM Subsidy s "
            + "LEFT JOIN FETCH s.animal a LEFT JOIN FETCH a.rfidTagEntity "
            + "LEFT JOIN FETCH a.farm f LEFT JOIN FETCH f.owner "
            + "LEFT JOIN FETCH a.owner "
            + "LEFT JOIN FETCH s.treatedBy "
            + "WHERE s.id = :id")
    Optional<Subsidy> findFetchedById(Long id);

    List<Subsidy> findByStatus(com.dzcheptel.backend.entity.SubsidyStatus status);
}

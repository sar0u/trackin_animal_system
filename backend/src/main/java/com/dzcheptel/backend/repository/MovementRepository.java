package com.dzcheptel.backend.repository;

import com.dzcheptel.backend.entity.Movement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface MovementRepository extends JpaRepository<Movement, Long> {

    @Query("SELECT DISTINCT m FROM Movement m "
            + "LEFT JOIN FETCH m.animal a LEFT JOIN FETCH a.rfidTagEntity "
            + "LEFT JOIN FETCH m.fromFarm ff LEFT JOIN FETCH ff.owner "
            + "LEFT JOIN FETCH m.toFarm tf LEFT JOIN FETCH tf.owner "
            + "LEFT JOIN FETCH m.treatedBy")
    List<Movement> findAllFetched();

    @Query("SELECT m FROM Movement m "
            + "LEFT JOIN FETCH m.animal a LEFT JOIN FETCH a.rfidTagEntity "
            + "LEFT JOIN FETCH m.fromFarm ff LEFT JOIN FETCH ff.owner "
            + "LEFT JOIN FETCH m.toFarm tf LEFT JOIN FETCH tf.owner "
            + "LEFT JOIN FETCH m.treatedBy "
            + "WHERE m.id = :id")
    Optional<Movement> findFetchedById(Long id);

    List<Movement> findByAnimalId(Long animalId);
}

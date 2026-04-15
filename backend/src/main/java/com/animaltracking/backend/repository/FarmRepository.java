package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.Farm;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface FarmRepository extends JpaRepository<Farm, Integer> {
    List<Farm> findByOwnerId(Integer ownerId);
}
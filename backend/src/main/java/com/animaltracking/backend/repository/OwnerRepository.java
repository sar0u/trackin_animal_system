package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.Owner;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface OwnerRepository extends JpaRepository<Owner, Integer> {

    Optional<Owner> findByUserId(Integer userId);

    Boolean existsByUserId(Integer userId);

}
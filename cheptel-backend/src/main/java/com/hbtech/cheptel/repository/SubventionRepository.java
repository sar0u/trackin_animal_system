package com.hbtech.cheptel.repository;

import com.hbtech.cheptel.entity.Subvention;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SubventionRepository extends JpaRepository<Subvention, Long> {

    List<Subvention> findAllByOrderByCreatedAtDesc();

    long countByStatus(String status);
}
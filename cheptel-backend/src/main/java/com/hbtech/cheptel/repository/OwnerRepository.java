package com.hbtech.cheptel.repository;

import com.hbtech.cheptel.entity.Owner;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OwnerRepository extends JpaRepository<Owner, Long> {
}
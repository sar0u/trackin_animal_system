package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.HardwareStatus;
import com.animaltracking.backend.entity.RfidTag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.List;

public interface RfidTagRepository extends JpaRepository<RfidTag, Long> {

    Optional<RfidTag> findByRfidCode(String rfidCode);

    Boolean existsByRfidCode(String rfidCode);

    List<RfidTag> findByTagStatus(HardwareStatus status);

}
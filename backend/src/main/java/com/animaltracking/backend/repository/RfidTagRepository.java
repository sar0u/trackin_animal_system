package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.RfidTag;
import com.animaltracking.backend.entity.HardwareStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface RfidTagRepository extends JpaRepository<RfidTag, Integer> {

    Optional<RfidTag> findByUniqueRfidCode(String uniqueRfidCode);

    Boolean existsByUniqueRfidCode(String uniqueRfidCode);

    List<RfidTag> findByHardwareStatus(HardwareStatus status);

    List<RfidTag> findByManufacturingDateBefore(LocalDate date);

    List<RfidTag> findByLastMaintenanceDateBefore(LocalDate date);
}
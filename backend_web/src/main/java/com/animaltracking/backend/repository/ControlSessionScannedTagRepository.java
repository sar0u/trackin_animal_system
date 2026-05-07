package com.animaltracking.backend.repository;

import com.animaltracking.backend.entity.ControlSessionScannedTag;
import com.animaltracking.backend.entity.ControlSessionScannedTagId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ControlSessionScannedTagRepository
        extends JpaRepository<ControlSessionScannedTag, ControlSessionScannedTagId> {

    List<ControlSessionScannedTag> findBySessionId(Long sessionId);
}

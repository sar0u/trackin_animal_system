package com.dzcheptel.backend.repository;

import com.dzcheptel.backend.entity.ControlSessionScannedTag;
import com.dzcheptel.backend.entity.ControlSessionScannedTagId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ControlSessionScannedTagRepository
        extends JpaRepository<ControlSessionScannedTag, ControlSessionScannedTagId> {

    List<ControlSessionScannedTag> findBySessionId(Long sessionId);
}

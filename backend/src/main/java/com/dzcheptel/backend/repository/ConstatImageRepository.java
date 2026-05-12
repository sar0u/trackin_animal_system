package com.dzcheptel.backend.repository;

import com.dzcheptel.backend.entity.ConstatImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ConstatImageRepository extends JpaRepository<ConstatImage, Long> {
    List<ConstatImage> findByConstatId(Long constatId);
}

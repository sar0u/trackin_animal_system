package com.hbtech.cheptel.repository;

import com.hbtech.cheptel.entity.AnimalEvent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AnimalEventRepository extends JpaRepository<AnimalEvent, Long> {

    List<AnimalEvent> findByAnimalIdOrderByEventDateDesc(Long animalId);
}
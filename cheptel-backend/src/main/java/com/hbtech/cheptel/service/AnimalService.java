package com.hbtech.cheptel.service;

import com.hbtech.cheptel.entity.Animal;
import com.hbtech.cheptel.repository.AnimalRepository;
import org.springframework.stereotype.Service;

@Service
public class AnimalService {

    private final AnimalRepository animalRepository;

    public AnimalService(AnimalRepository animalRepository) {
        this.animalRepository = animalRepository;
    }

    public Animal getByRfidOrThrow(String rfidTag) {
        return animalRepository.findByRfidTag(rfidTag)
                .orElseThrow(() -> new RuntimeException("Animal introuvable pour RFID: " + rfidTag));
    }

    public boolean existsByRfidTag(String rfidTag) {
        return animalRepository.findByRfidTag(rfidTag).isPresent();
    }
}
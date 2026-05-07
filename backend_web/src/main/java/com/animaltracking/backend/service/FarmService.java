package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.Farm;
import java.util.List;

public interface FarmService {
    List<Farm> getAllFarms();
    Farm getFarmById(Long id);
    Farm createFarm(Farm farm);
    Farm updateFarm(Long id, Farm farmDetails);
    Farm updateStatusAndVerification(Long id, String status, Boolean isVerified);
    void deleteFarm(Long id);
}
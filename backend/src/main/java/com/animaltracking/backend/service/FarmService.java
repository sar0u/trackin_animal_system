package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.Farm;
import java.util.List;

public interface FarmService {
    List<Farm> getAllFarms();
    Farm getFarmById(Integer id);
    Farm createFarm(Farm farm);
    Farm updateFarm(Integer id, Farm farmDetails);
    void deleteFarm(Integer id);
}
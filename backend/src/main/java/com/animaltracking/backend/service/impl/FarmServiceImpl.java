package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.Farm;
import com.animaltracking.backend.repository.FarmRepository;
import com.animaltracking.backend.service.FarmService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@Transactional
public class FarmServiceImpl implements FarmService {

    @Autowired
    private FarmRepository farmRepository;

    @Override
    public List<Farm> getAllFarms() {
        return farmRepository.findAll();
    }

    @Override
    public Farm getFarmById(Integer id) {
        return farmRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Ferme non trouvée (ID: " + id + ")"));
    }

    @Override
    public Farm createFarm(Farm farm) {
        return farmRepository.save(farm);
    }

    @Override
    public Farm updateFarm(Integer id, Farm farmDetails) {
        Farm farm = getFarmById(id);
        farm.setFarmName(farmDetails.getFarmName());
        farm.setGeographicAddress(farmDetails.getGeographicAddress());
        farm.setLatitudeCoordinate(farmDetails.getLatitudeCoordinate());
        farm.setLongitudeCoordinate(farmDetails.getLongitudeCoordinate());

        if (farmDetails.getOwner() != null) {
            farm.setOwner(farmDetails.getOwner());
        }

        return farmRepository.save(farm);
    }

    @Override
    public void deleteFarm(Integer id) {
        Farm farm = getFarmById(id);
        farmRepository.delete(farm);
    }
}
package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.Farm;
import com.animaltracking.backend.entity.FarmStatus;
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
    public Farm getFarmById(Long id) {
        return farmRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Ferme non trouvée (ID: " + id + ")"));
    }

    @Override
    public Farm createFarm(Farm farm) {
        return farmRepository.save(farm);
    }

    @Override
    public Farm updateFarm(Long id, Farm farmDetails) {
        Farm farm = getFarmById(id);
        farm.setName(farmDetails.getName());
        farm.setLocation(farmDetails.getLocation());
        farm.setLatitude(farmDetails.getLatitude());
        farm.setLongitude(farmDetails.getLongitude());
        farm.setCapacity(farmDetails.getCapacity());

        if (farmDetails.getStatus() != null) {
            farm.setStatus(farmDetails.getStatus());
        }

        if (farmDetails.getOwner() != null) {
            farm.setOwner(farmDetails.getOwner());
        }

        return farmRepository.save(farm);
    }

    @Override
    public Farm updateStatusAndVerification(Long id, String status, Boolean isVerified) {
        Farm farm = getFarmById(id);

        if (status != null && !status.trim().isEmpty()) {
            farm.setStatus(FarmStatus.valueOf(status));
        }

        if (isVerified != null) {
            farm.setIsVerified(isVerified);
        }

        return farmRepository.save(farm);
    }

    @Override
    public void deleteFarm(Long id) {
        Farm farm = getFarmById(id);
        farmRepository.delete(farm);
    }
}
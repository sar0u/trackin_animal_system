package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.Animal;
import com.animaltracking.backend.repository.AnimalRepository;
import com.animaltracking.backend.service.AnimalService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class AnimalServiceImpl implements AnimalService {

    @Autowired
    private AnimalRepository animalRepository;

    @Override
    public List<Animal> getAllAnimals() {
        return animalRepository.findAll();
    }

    @Override
    public Animal getAnimalById(Integer id) {
        return animalRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Animal non trouvé avec l'id : " + id));
    }

    @Override
    public Animal createAnimal(Animal animal) {
        return animalRepository.save(animal);
    }

    @Override
    public Animal updateAnimal(Integer id, Animal animalDetails) {
        Animal animal = getAnimalById(id);

        animal.setSpecies(animalDetails.getSpecies());
        animal.setBreed(animalDetails.getBreed());
        animal.setAnimalGender(animalDetails.getAnimalGender());
        animal.setBirthDate(animalDetails.getBirthDate());
        animal.setCurrentWeightKilograms(animalDetails.getCurrentWeightKilograms());
        animal.setLifeStatus(animalDetails.getLifeStatus());
        animal.setHealthStatus(animalDetails.getHealthStatus());
        animal.setOriginType(animalDetails.getOriginType());
        animal.setReproductionStatus(animalDetails.getReproductionStatus());

        // Mise à jour des relations si nécessaire
        if (animalDetails.getCurrentFarm() != null) animal.setCurrentFarm(animalDetails.getCurrentFarm());
        if (animalDetails.getRfidTag() != null) animal.setRfidTag(animalDetails.getRfidTag());

        return animalRepository.save(animal);
    }

    @Override
    public void deleteAnimal(Integer id) {
        Animal animal = getAnimalById(id);
        animalRepository.delete(animal);
    }
}
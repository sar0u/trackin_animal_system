package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.Animal;
import java.util.List;

public interface AnimalService {
    List<Animal> getAllAnimals();
    Animal getAnimalById(Integer id);
    Animal createAnimal(Animal animal);
    Animal updateAnimal(Integer id, Animal animalDetails);
    void deleteAnimal(Integer id);

    long countAllAnimals();
    java.util.Map<String, Long> getSpeciesDistribution();
    long getRecentBirthsCount();
}
package com.dzcheptel.backend.service;

import com.dzcheptel.backend.entity.Animal;

import java.util.List;

public interface AnimalService {
    List<Animal> getAllAnimals();

    // Récupère tous les animaux formatés pour la réponse API (Maps simples)
    List<java.util.Map<String, Object>> listAnimalsForApi();

    // Récupère un seul animal formaté pour la réponse API
    java.util.Map<String, Object> getAnimalForApi(Long id);

    Animal getAnimalById(Long id);
    Animal createAnimal(Animal animal);
    Animal updateAnimal(Long id, Animal animalDetails);
    void deleteAnimal(Long id);
}
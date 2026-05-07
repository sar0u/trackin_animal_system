package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.Animal;
import com.animaltracking.backend.entity.Farm;
import com.animaltracking.backend.entity.RfidTag;
import com.animaltracking.backend.entity.User;
import com.animaltracking.backend.repository.AnimalRepository;
import com.animaltracking.backend.service.AnimalService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

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
    @Transactional(readOnly = true)
    public List<Map<String, Object>> listAnimalsForApi() {
        return animalRepository.findAllFetched().stream().map(this::mapToSafeMap).collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getAnimalForApi(Long id) {
        Animal animal = animalRepository.findFetchedById(id)
                .orElseThrow(() -> new EntityNotFoundException("Animal non trouvé avec l'id : " + id));
        return mapToSafeMap(animal);
    }

    @Override
    public Animal getAnimalById(Long id) {
        return animalRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Animal non trouvé avec l'id : " + id));
    }

    @Override
    public Animal createAnimal(Animal animal) {
        return animalRepository.save(animal);
    }

    @Override
    public Animal updateAnimal(Long id, Animal animalDetails) {
        Animal animal = getAnimalById(id);

        animal.setSpecies(animalDetails.getSpecies());
        animal.setBreed(animalDetails.getBreed());
        animal.setGender(animalDetails.getGender());
        animal.setBirthDate(animalDetails.getBirthDate());
        animal.setWeight(animalDetails.getWeight());
        animal.setLifeStatus(animalDetails.getLifeStatus());
        animal.setHealthStatus(animalDetails.getHealthStatus());
        animal.setOriginType(animalDetails.getOriginType());
        animal.setBirthPlace(animalDetails.getBirthPlace());
        animal.setAcquisitionPlace(animalDetails.getAcquisitionPlace());
        animal.setNotes(animalDetails.getNotes());

        // Mise à jour des relations si nécessaire
        if (animalDetails.getFarm() != null) animal.setFarm(animalDetails.getFarm());
        if (animalDetails.getOwner() != null) animal.setOwner(animalDetails.getOwner());
        if (animalDetails.getMother() != null) animal.setMother(animalDetails.getMother());
        if (animalDetails.getFather() != null) animal.setFather(animalDetails.getFather());
        if (animalDetails.getRfidTag() != null) animal.setRfidTag(animalDetails.getRfidTag());

        return animalRepository.save(animal);
    }

    @Override
    public void deleteAnimal(Long id) {
        Animal animal = getAnimalById(id);
        animalRepository.delete(animal);
    }

    private Map<String, Object> mapToSafeMap(Animal a) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", a.getId());
        map.put("species", enumName(a.getSpecies()));
        map.put("gender", enumName(a.getGender()));
        map.put("breed", a.getBreed());
        map.put("birthDate", a.getBirthDate());
        map.put("birthPlace", a.getBirthPlace());
        map.put("acquisitionPlace", a.getAcquisitionPlace());
        map.put("weight", a.getWeight());
        map.put("lifeStatus", enumName(a.getLifeStatus()));
        map.put("originType", enumName(a.getOriginType()));
        map.put("healthStatus", enumName(a.getHealthStatus()));
        map.put("notes", a.getNotes());

        map.put("rfidTag", toRfidTagSummary(a.getRfidTag()));
        map.put("farm", toFarmSummary(a.getFarm()));
        map.put("owner", toUserSummary(a.getOwner()));

        if (a.getMother() != null) {
            Map<String, Object> mother = new HashMap<>();
            mother.put("id", a.getMother().getId());
            map.put("mother", mother);
        } else {
            map.put("mother", null);
        }

        if (a.getFather() != null) {
            Map<String, Object> father = new HashMap<>();
            father.put("id", a.getFather().getId());
            map.put("father", father);
        } else {
            map.put("father", null);
        }

        return map;
    }

    private static Map<String, Object> toRfidTagSummary(RfidTag t) {
        if (t == null) return null;
        Map<String, Object> map = new HashMap<>();
        map.put("id", t.getId());
        map.put("rfidCode", t.getRfidCode());
        map.put("tagType", enumName(t.getTagType()));
        map.put("tagStatus", enumName(t.getTagStatus()));
        return map;
    }

    private static Map<String, Object> toFarmSummary(Farm f) {
        if (f == null) return null;
        Map<String, Object> map = new HashMap<>();
        map.put("id", f.getId());
        map.put("name", f.getName());
        map.put("location", f.getLocation());
        map.put("latitude", f.getLatitude());
        map.put("longitude", f.getLongitude());
        map.put("capacity", f.getCapacity());
        map.put("status", f.getStatus() != null ? f.getStatus().name() : null);
        return map;
    }

    private static Map<String, Object> toUserSummary(User u) {
        if (u == null) return null;
        Map<String, Object> map = new HashMap<>();
        map.put("id", u.getId());
        map.put("username", u.getUsername());
        map.put("email", u.getEmail());
        map.put("firstName", u.getFirstName());
        map.put("lastName", u.getLastName());
        map.put("role", u.getRole() != null ? u.getRole().name() : null);
        map.put("isActive", u.getIsActive());
        return map;
    }

    private static String enumName(Enum<?> e) {
        return e == null ? null : e.name();
    }
}
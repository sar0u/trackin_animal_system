package com.hbtech.cheptel.service;


import com.hbtech.cheptel.dto.request.CreateReproductionRequest;
import com.hbtech.cheptel.dto.response.ReproductionResponse;
import com.hbtech.cheptel.entity.*;
import com.hbtech.cheptel.repository.AnimalRepository;
import com.hbtech.cheptel.repository.ReproductionRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ReproductionService {

    private final ReproductionRepository reproductionRepository;
    private final AnimalRepository animalRepository;
    private final CurrentUserService currentUserService;

    public ReproductionService(
            ReproductionRepository reproductionRepository,
            AnimalRepository animalRepository,
            CurrentUserService currentUserService
    ) {
        this.reproductionRepository = reproductionRepository;
        this.animalRepository = animalRepository;
        this.currentUserService = currentUserService;
    }

    public ReproductionResponse createReproduction(CreateReproductionRequest request) {
        User currentUser = currentUserService.getCurrentUserOrThrow();

        if (request.getFemaleId() == null) {
            throw new RuntimeException("La femelle est obligatoire");
        }

        if (request.getBreedingDate() == null) {
            throw new RuntimeException("La date d'accouplement est obligatoire");
        }

        Animal female = animalRepository.findById(request.getFemaleId())
                .orElseThrow(() -> new RuntimeException("Femelle introuvable"));

        if (female.getGender() != Gender.FEMALE) {
            throw new RuntimeException("L'animal sélectionné comme femelle n'est pas de sexe FEMALE");
        }

        Animal male = null;

        if (request.getMaleId() != null) {
            male = animalRepository.findById(request.getMaleId())
                    .orElseThrow(() -> new RuntimeException("Mâle introuvable"));

            if (male.getGender() != Gender.MALE) {
                throw new RuntimeException("L'animal sélectionné comme mâle n'est pas de sexe MALE");
            }
        }

        Reproduction reproduction = Reproduction.builder()
                .female(female)
                .male(male)
                .breedingDate(request.getBreedingDate())
                .expectedBirthDate(request.getExpectedBirthDate())
                .actualBirthDate(request.getActualBirthDate())
                .offspringCount(request.getOffspringCount() != null ? request.getOffspringCount() : 0)
                .status(request.getStatus() != null ? request.getStatus() : ReproductionRecordStatus.IN_PROGRESS)
                .veterinarian(currentUser)
                .notes(request.getNotes())
                .build();

        Reproduction saved = reproductionRepository.save(reproduction);

        // Mise à jour du statut reproductif de l'animal femelle
        if (saved.getStatus() == ReproductionRecordStatus.IN_PROGRESS) {
            female.setReproductionStatus(ReproductionStatus.PREGNANT);
        } else if (saved.getStatus() == ReproductionRecordStatus.SUCCESSFUL) {
            female.setReproductionStatus(ReproductionStatus.LACTATING);
        } else if (saved.getStatus() == ReproductionRecordStatus.FAILED ||
                saved.getStatus() == ReproductionRecordStatus.ABORTED) {
            female.setReproductionStatus(ReproductionStatus.NONE);
        }

        animalRepository.save(female);

        return toResponse(saved);
    }

    public List<ReproductionResponse> getReproductionsByFemale(Long femaleId) {
        return reproductionRepository
                .findByFemaleIdOrderByBreedingDateDesc(femaleId)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private ReproductionResponse toResponse(Reproduction r) {
        return ReproductionResponse.builder()
                .id(r.getId())
                .femaleId(r.getFemale().getId())
                .femaleRfidTag(r.getFemale().getRfidTag())
                .maleId(r.getMale() != null ? r.getMale().getId() : null)
                .maleRfidTag(r.getMale() != null ? r.getMale().getRfidTag() : null)
                .breedingDate(r.getBreedingDate())
                .expectedBirthDate(r.getExpectedBirthDate())
                .actualBirthDate(r.getActualBirthDate())
                .offspringCount(r.getOffspringCount())
                .status(r.getStatus() != null ? r.getStatus().name() : null)
                .veterinarianUsername(
                        r.getVeterinarian() != null ? r.getVeterinarian().getUsername() : null
                )
                .notes(r.getNotes())
                .createdAt(r.getCreatedAt())
                .updatedAt(r.getUpdatedAt())
                .build();
    }
}
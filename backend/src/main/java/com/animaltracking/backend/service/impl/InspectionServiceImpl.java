package com.animaltracking.backend.service.impl;

import com.animaltracking.backend.entity.Inspection;
import com.animaltracking.backend.entity.InspectionImage;
import com.animaltracking.backend.entity.InspectionStatus;
import com.animaltracking.backend.repository.InspectionRepository;
import com.animaltracking.backend.service.InspectionService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class InspectionServiceImpl implements InspectionService {

    @Autowired
    private InspectionRepository inspectionRepository;

    @Override
    public Inspection createInspection(Inspection inspection) {
        // Lier les images au contrôle avant sauvegarde
        if (inspection.getImages() != null && !inspection.getImages().isEmpty()) {
            for (InspectionImage img : inspection.getImages()) {
                img.setInspection(inspection);
            }
        }

        // Si aucune fraude n'est détectée, le statut doit être "Fermé"
        if (inspection.getResult() != com.animaltracking.backend.entity.InspectionResult.FraudDetected) {
            inspection.setStatus(InspectionStatus.Closed);
        } else if (inspection.getStatus() == InspectionStatus.Closed) {
            // Sécurité : si fraude détectée mais statut oublié, on le met en attente
            inspection.setStatus(InspectionStatus.Pending);
        }

        return inspectionRepository.save(inspection);
    }

    @Override
    public List<Inspection> getAllInspections() {
        return inspectionRepository.findAll();
    }

    @Override
    public Inspection updateInspectionStatus(Integer id, InspectionStatus newStatus) {
        Inspection inspection = inspectionRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Inspection introuvable"));

        inspection.setStatus(newStatus);
        return inspectionRepository.save(inspection);
    }

    @Override
    public Inspection getInspectionById(Integer id) {
        return inspectionRepository.findById(id)
                .orElseThrow(() -> new jakarta.persistence.EntityNotFoundException("Contrôle introuvable ID: " + id));
    }

    @Override
    public List<Inspection> getInspectionsByAnimal(Integer animalId) {
        return inspectionRepository.findByAnimalId(animalId);
    }

    @Override
    public void deleteInspection(Integer id) {
        Inspection inspection = getInspectionById(id);
        inspectionRepository.delete(inspection);
    }
}
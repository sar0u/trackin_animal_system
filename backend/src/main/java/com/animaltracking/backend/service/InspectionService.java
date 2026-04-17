package com.animaltracking.backend.service;

import com.animaltracking.backend.entity.Inspection;
import com.animaltracking.backend.entity.InspectionStatus;
import java.util.List;

public interface InspectionService {

    // Créer un nouveau rapport de contrôle
    Inspection createInspection(Inspection inspection);

    // Liste de tous les contrôles (pour l'admin)
    List<Inspection> getAllInspections();

    // Récupérer un contrôle par son ID
    Inspection getInspectionById(Integer id);

    // Récupérer les contrôles d'un animal
    List<Inspection> getInspectionsByAnimal(Integer animalId);

    // Mettre à jour le statut (ex: passer de 'UnderInvestigation' à 'Resolved')
    Inspection updateInspectionStatus(Integer id, InspectionStatus newStatus);

    // Supprimer un rapport (attention, souvent réservé à l'admin en cas d'erreur)
    void deleteInspection(Integer id);
}
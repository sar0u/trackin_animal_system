package com.animaltracking.backend.controller;

import com.animaltracking.backend.entity.Inspection;
import com.animaltracking.backend.entity.InspectionImage;
import com.animaltracking.backend.repository.InspectionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/inspections")
@RequiredArgsConstructor
public class InspectionController {

    private final InspectionRepository inspectionRepository;

    @GetMapping
    // @PreAuthorize("hasAuthority('Administrator')") // 🟢 GARDE ÇA EN COMMENTAIRE POUR LE MOMENT
    public List<Map<String, Object>> getAllInspectionsSafe() {

        System.out.println("🟢 API /inspections a été appelée par Vue.js !");

        List<Inspection> inspectionsFromDb = inspectionRepository.findAll();

        System.out.println("🟢 Nombre d'inspections trouvées dans la BDD : " + inspectionsFromDb.size());

        List<Map<String, Object>> safeInspectionsList = new ArrayList<>();

        for (Inspection i : inspectionsFromDb) {
            Map<String, Object> safeInsp = new HashMap<>();
            safeInsp.put("id", i.getId());
            safeInsp.put("inspectorId", i.getInspectorId());
            safeInsp.put("animalId", i.getAnimalId());
            safeInsp.put("farmId", i.getFarmId());
            safeInsp.put("inspectionDate", i.getInspectionDate());
            safeInsp.put("notes", i.getNotes());
            safeInsp.put("result", i.getResult() != null ? i.getResult().name() : "Compliant");
            safeInsp.put("fraudType", i.getFraudType() != null ? i.getFraudType().name() : "None");
            safeInsp.put("status", i.getStatus() != null ? i.getStatus().name() : "Closed");

            safeInspectionsList.add(safeInsp);
        }

        System.out.println("🟢 Conversion terminée. Envoi à Vue.js...");
        return safeInspectionsList;
    }

    // NOUVELLE ROUTE : Pour le Lazy-Loading des images côté Vue.js
    @GetMapping("/{id}/images")
    public org.springframework.http.ResponseEntity<?> getInspectionImages(@PathVariable Integer id) {

        // 1. On cherche l'inspection dans la base de données
        Inspection inspection = inspectionRepository.findById(id).orElse(null);

        // 2. Si elle n'existe pas, on renvoie une erreur 404
        if (inspection == null) {
            return org.springframework.http.ResponseEntity.notFound().build();
        }

        // 3. On renvoie uniquement sa liste d'images !
        // (Comme tu avais mis un @JsonIgnore sur l'Inspection dans InspectionImage.java,
        // cette liste s'enverra proprement sans faire crasher le serveur).
        return org.springframework.http.ResponseEntity.ok(inspection.getImages());
    }
}
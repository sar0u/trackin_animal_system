package com.hbtech.cheptel.service;

import com.hbtech.cheptel.entity.*;
import com.hbtech.cheptel.repository.AnimalRepository;
import com.hbtech.cheptel.repository.HealthAlertRepository;
import com.hbtech.cheptel.repository.VaccinationRepository;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class AlertGeneratorService {

    private final VaccinationRepository vaccinationRepository;
    private final AnimalRepository animalRepository;
    private final HealthAlertRepository healthAlertRepository;

    public AlertGeneratorService(
            VaccinationRepository vaccinationRepository,
            AnimalRepository animalRepository,
            HealthAlertRepository healthAlertRepository
    ) {
        this.vaccinationRepository = vaccinationRepository;
        this.animalRepository = animalRepository;
        this.healthAlertRepository = healthAlertRepository;
    }

    @Scheduled(cron = "0 0 6 * * *")
    public void scheduledGeneration() {
        generateAll();
    }

    public void generateAll() {

        System.out.println("========== GENERATION ALERTES ==========");

        List<Animal> animals = animalRepository.findAll()
                .stream()
                .filter(a -> a.getStatus() == AnimalStatus.ACTIVE)
                .toList();

        int created = 0;

        LocalDate today = LocalDate.now();
        LocalDate limit = today.plusDays(30);

        for (Animal animal : animals) {

            List<Vaccination> vaccinations =
                    vaccinationRepository.findByAnimalIdOrderByVaccinationDateDesc(animal.getId());

            for (Vaccination vaccination : vaccinations) {

                if (vaccination.getExpirationDate() == null) {
                    continue;
                }

                LocalDate expirationDate = vaccination.getExpirationDate();

                boolean expired = expirationDate.isBefore(today);
                boolean expiresToday = expirationDate.isEqual(today);
                boolean expiresSoon = expirationDate.isAfter(today)
                        && !expirationDate.isAfter(limit);

                if (!expired && !expiresToday && !expiresSoon) {
                    continue;
                }

                List<HealthAlert> existing =
                        healthAlertRepository.findByAnimalIdAndIsResolvedFalseOrderByDueDateAsc(animal.getId());

                boolean alreadyExists = existing.stream().anyMatch(alert ->
                        alert.getAlertType() == AlertType.VACCINATION_DUE
                                && alert.getMessage() != null
                                && alert.getMessage().contains(vaccination.getVaccineName())
                );

                if (alreadyExists) {
                    continue;
                }

                AlertSeverity severity;

                if (expired || expiresToday) {
                    severity = AlertSeverity.CRITICAL;
                } else {
                    severity = AlertSeverity.WARNING;
                }

                String message;

                if (expired) {
                    message = "Vaccin " + vaccination.getVaccineName()
                            + " expiré depuis le " + expirationDate;
                } else if (expiresToday) {
                    message = "Vaccin " + vaccination.getVaccineName()
                            + " expire aujourd'hui";
                } else {
                    message = "Vaccin " + vaccination.getVaccineName()
                            + " expire le " + expirationDate;
                }

                HealthAlert alert = HealthAlert.builder()
                        .animal(animal)
                        .alertType(AlertType.VACCINATION_DUE)
                        .message(message)
                        .dueDate(expirationDate)
                        .isResolved(false)
                        .severity(severity)
                        .build();

                healthAlertRepository.save(alert);
                created++;

                System.out.println("✅ Alerte créée : animal="
                        + animal.getRfidTag()
                        + ", vaccin="
                        + vaccination.getVaccineName());
            }
        }

        System.out.println("Total alertes créées : " + created);
        System.out.println("=========================================");
    }
}
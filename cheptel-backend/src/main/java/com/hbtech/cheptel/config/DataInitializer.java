package com.hbtech.cheptel.config;

import com.hbtech.cheptel.entity.*;
import com.hbtech.cheptel.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class DataInitializer {

    @Bean
    CommandLineRunner initData(
            UserRepository userRepository,
            FarmRepository farmRepository,
            OwnerRepository ownerRepository,
            AnimalRepository animalRepository,
            VaccinationRepository vaccinationRepository,
            HealthRecordRepository healthRecordRepository,
            ConstatRepository constatRepository,
            ControlSessionRepository controlSessionRepository,
            PasswordEncoder passwordEncoder
    ) {
        return args -> {
            if (userRepository.count() > 0) {
                System.out.println(">>> Base déjà initialisée.");
                return;
            }

            System.out.println(">>> Initialisation des données...");

            Owner owner1 = ownerRepository.save(Owner.builder()
                    .fullName("Ahmed Bensalem").phone("0555123456").email("ahmed@ferme.dz")
                    .build());

            Owner owner2 = ownerRepository.save(Owner.builder()
                    .fullName("Mohamed Kaci").phone("0661987654").email("mohamed@ferme.dz")
                    .build());

            Farm farm1 = farmRepository.save(Farm.builder()
                    .name("Ferme Al-Baraka").location("Route Nationale 5")
                    .wilaya("Blida").commune("Boufarik")
                    .latitude(36.5725).longitude(2.8638)
                    .owner(owner1).build());

            Farm farm2 = farmRepository.save(Farm.builder()
                    .name("Domaine des Plaines").location("Zone Agricole Nord")
                    .wilaya("Ain Defla").commune("Ain Defla")
                    .latitude(36.2642).longitude(1.9644)
                    .owner(owner2).build());

            String encoded = passwordEncoder.encode("password123");

            User fermier1 = userRepository.save(User.builder()
                    .username("fermier1").password(encoded)
                    .email("fermier1@cheptel.dz").role(Role.FERMIER)
                    .farm(farm1).enabled(true).build());

            User fermier2 = userRepository.save(User.builder()
                    .username("fermier2").password(encoded)
                    .email("fermier2@cheptel.dz").role(Role.FERMIER)
                    .farm(farm2).enabled(true).build());

            User veto1 = userRepository.save(User.builder()
                    .username("veto1").password(encoded)
                    .email("veto1@cheptel.dz").role(Role.VETERINAIRE)
                    .enabled(true).build());

            User controleur1 = userRepository.save(User.builder()
                    .username("controleur1").password(encoded)
                    .email("ctrl1@cheptel.dz").role(Role.CONTROLEUR)
                    .enabled(true).build());

            userRepository.save(User.builder()
                    .username("admin1").password(encoded)
                    .email("admin@cheptel.dz").role(Role.ADMIN)
                    .enabled(true).build());

            // Tous les animaux au format ID-XXXX
            Animal a1 = animalRepository.save(Animal.builder()
                    .rfidTag("ID-0001").species(Species.OVIN).breed("Sardi")
                    .gender(Gender.MALE).weight(55.0).status(AnimalStatus.ACTIVE)
                    .color("Blanc").birthDate(java.time.LocalDate.of(2025, 3, 1))
                    .farm(farm1).build());

            Animal a2 = animalRepository.save(Animal.builder()
                    .rfidTag("ID-0002").species(Species.OVIN).breed("Sardi")
                    .gender(Gender.FEMALE).weight(48.0).status(AnimalStatus.ACTIVE)
                    .color("Blanc").birthDate(java.time.LocalDate.of(2025, 4, 12))
                    .farm(farm1).build());

            Animal a3 = animalRepository.save(Animal.builder()
                    .rfidTag("ID-0003").species(Species.BOVIN).breed("Holstein")
                    .gender(Gender.FEMALE).weight(510.0).status(AnimalStatus.ACTIVE)
                    .color("Pie noir").birthDate(java.time.LocalDate.of(2023, 8, 21))
                    .farm(farm1).build());

            Animal a4 = animalRepository.save(Animal.builder()
                    .rfidTag("ID-0004").species(Species.BOVIN).breed("Charolaise")
                    .gender(Gender.FEMALE).weight(642.0).status(AnimalStatus.ACTIVE)
                    .color("Beige").birthDate(java.time.LocalDate.of(2022, 11, 15))
                    .farm(farm2).build());

            Animal a5 = animalRepository.save(Animal.builder()
                    .rfidTag("ID-0005").species(Species.BOVIN).breed("Charolaise")
                    .gender(Gender.MALE).weight(720.0).status(AnimalStatus.ACTIVE)
                    .color("Beige").birthDate(java.time.LocalDate.of(2022, 5, 8))
                    .farm(farm2).build());

            vaccinationRepository.save(Vaccination.builder()
                    .animal(a4).vaccineName("Fièvre Aphteuse").vaccineType("Virale")
                    .manufacturer("MerckVet").batchNumber("BN-902-X")
                    .vaccinationDate(java.time.LocalDate.of(2023, 9, 12))
                    .expirationDate(java.time.LocalDate.of(2026, 9, 12)).build());

            vaccinationRepository.save(Vaccination.builder()
                    .animal(a4).vaccineName("BVD Type I & II").vaccineType("Bactérienne")
                    .manufacturer("Zoetis").batchNumber("V-771-KJ")
                    .vaccinationDate(java.time.LocalDate.of(2023, 6, 4))
                    .expirationDate(java.time.LocalDate.of(2026, 6, 4)).build());

            healthRecordRepository.save(HealthRecord.builder()
                    .animal(a4).recordType(RecordType.TREATMENT)
                    .diagnosis("Mastite Clinique").symptoms("Inflammation mamelle")
                    .treatment("Cefalexine 10 jours").veterinarian(veto1)
                    .visitDate(java.time.LocalDateTime.of(2024, 3, 18, 10, 0))
                    .nextVisitDate(java.time.LocalDateTime.of(2024, 4, 18, 10, 0))
                    .build());

            System.out.println(">>> Données initialisées avec succès !");
        };
    }
}
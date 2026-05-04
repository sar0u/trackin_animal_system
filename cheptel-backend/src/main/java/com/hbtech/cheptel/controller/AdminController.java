package com.hbtech.cheptel.controller;

import com.hbtech.cheptel.entity.*;
import com.hbtech.cheptel.repository.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final UserRepository userRepository;
    private final FarmRepository farmRepository;
    private final AnimalRepository animalRepository;
    private final ConstatRepository constatRepository;
    private final HealthAlertRepository healthAlertRepository;
    private final MovementRepository movementRepository;
    private final OwnerRepository ownerRepository;
    private final VaccinationRepository vaccinationRepository;
    private final HealthRecordRepository healthRecordRepository;
    private final AnimalEventRepository animalEventRepository;
    private final AdminSettingRepository adminSettingRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminController(
            UserRepository userRepository,
            FarmRepository farmRepository,
            AnimalRepository animalRepository,
            ConstatRepository constatRepository,
            HealthAlertRepository healthAlertRepository,
            MovementRepository movementRepository,
            OwnerRepository ownerRepository,
            VaccinationRepository vaccinationRepository,
            HealthRecordRepository healthRecordRepository,
            AnimalEventRepository animalEventRepository,
            AdminSettingRepository adminSettingRepository,
            PasswordEncoder passwordEncoder
    ) {
        this.userRepository = userRepository;
        this.farmRepository = farmRepository;
        this.animalRepository = animalRepository;
        this.constatRepository = constatRepository;
        this.healthAlertRepository = healthAlertRepository;
        this.movementRepository = movementRepository;
        this.ownerRepository = ownerRepository;
        this.vaccinationRepository = vaccinationRepository;
        this.healthRecordRepository = healthRecordRepository;
        this.animalEventRepository = animalEventRepository;
        this.adminSettingRepository = adminSettingRepository;
        this.passwordEncoder = passwordEncoder;
    }

    // ============================================================
    // DASHBOARD
    // ============================================================

    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getDashboard() {
        Map<String, Object> stats = new HashMap<>();

        stats.put("totalUtilisateurs", userRepository.countByRoleNot(Role.ADMIN));
        stats.put("totalFermes", farmRepository.count());
        stats.put("totalAnimaux", animalRepository.count());
        stats.put("animauxActifs", animalRepository.countByStatus(AnimalStatus.ACTIVE));
        stats.put("animauxOvins", animalRepository.countBySpeciesAndStatus(Species.OVIN, AnimalStatus.ACTIVE));
        stats.put("animauxBovins", animalRepository.countBySpeciesAndStatus(Species.BOVIN, AnimalStatus.ACTIVE));
        stats.put("animauxVendus", animalRepository.countByStatus(AnimalStatus.SOLD));
        stats.put("animauxMorts", animalRepository.countByStatus(AnimalStatus.DEAD));
        stats.put("constatsEnAttente", constatRepository.countByStatus("PENDING"));
        stats.put("constatsFraude", constatRepository.countByType("FRAUDE"));
        stats.put("alertesActives", healthAlertRepository.countByIsResolvedFalse());
        stats.put("totalProprietaires", ownerRepository.count());
        stats.put("totalMovements", movementRepository.count());

        return ResponseEntity.ok(stats);
    }

    @GetMapping("/search")
    public ResponseEntity<?> globalSearch(@RequestParam String q) {
        if (q == null || q.trim().length() < 2) {
            return ResponseEntity.ok(Map.of(
                    "users", List.of(),
                    "farms", List.of(),
                    "animals", List.of(),
                    "constats", List.of()
            ));
        }

        String query = q.trim().toLowerCase();

        List<Map<String, Object>> users = userRepository.findAll()
                .stream()
                .filter(u ->
                        u.getUsername().toLowerCase().contains(query) ||
                                (u.getEmail() != null && u.getEmail().toLowerCase().contains(query))
                )
                .limit(5)
                .map(u -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", u.getId());
                    map.put("type", "USER");
                    map.put("title", u.getUsername());
                    map.put("subtitle", u.getRole().name() + (u.getEmail() != null ? " — " + u.getEmail() : ""));
                    map.put("route", "/users");
                    return map;
                })
                .toList();

        List<Map<String, Object>> farms = farmRepository.findAll()
                .stream()
                .filter(f ->
                        f.getName().toLowerCase().contains(query) ||
                                (f.getWilaya() != null && f.getWilaya().toLowerCase().contains(query)) ||
                                (f.getCommune() != null && f.getCommune().toLowerCase().contains(query))
                )
                .limit(5)
                .map(f -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", f.getId());
                    map.put("type", "FARM");
                    map.put("title", f.getName());
                    map.put("subtitle", (f.getWilaya() != null ? f.getWilaya() : "") +
                            (f.getCommune() != null ? " — " + f.getCommune() : ""));
                    map.put("route", "/farms");
                    return map;
                })
                .toList();

        List<Map<String, Object>> animals = animalRepository.findAll()
                .stream()
                .filter(a ->
                        a.getRfidTag().toLowerCase().contains(query) ||
                                (a.getBreed() != null && a.getBreed().toLowerCase().contains(query)) ||
                                (a.getFarm() != null && a.getFarm().getName().toLowerCase().contains(query))
                )
                .limit(5)
                .map(a -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", a.getId());
                    map.put("type", "ANIMAL");
                    map.put("title", a.getRfidTag());
                    map.put("subtitle", a.getSpecies().name() + (a.getFarm() != null ? " — " + a.getFarm().getName() : ""));
                    map.put("route", "/animals/" + a.getRfidTag());
                    return map;
                })
                .toList();

        List<Map<String, Object>> constats = constatRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .filter(c ->
                        c.getDescription() != null &&
                                c.getDescription().toLowerCase().contains(query)
                )
                .limit(5)
                .map(c -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", c.getId());
                    map.put("type", "CONSTAT");
                    map.put("title", "Constat #" + c.getId() + " — " + c.getType());
                    map.put("subtitle", c.getDescription().substring(0, Math.min(50, c.getDescription().length())));
                    map.put("route", "/constats");
                    return map;
                })
                .toList();

        return ResponseEntity.ok(Map.of(
                "users", users,
                "farms", farms,
                "animals", animals,
                "constats", constats
        ));
    }

    // ============================================================
    // STATS
    // ============================================================

    @GetMapping("/stats/by-wilaya")
    public ResponseEntity<List<Map<String, Object>>> getStatsByWilaya() {
        List<Farm> farms = farmRepository.findAll();
        Map<String, Map<String, Object>> wilayas = new LinkedHashMap<>();

        for (Farm farm : farms) {
            String wilaya = farm.getWilaya() != null ? farm.getWilaya() : "Inconnue";
            long count = animalRepository.countByFarmId(farm.getId());

            wilayas.computeIfAbsent(wilaya, k -> {
                Map<String, Object> m = new HashMap<>();
                m.put("wilaya", k);
                m.put("totalFermes", 0L);
                m.put("totalAnimaux", 0L);
                return m;
            });

            Map<String, Object> entry = wilayas.get(wilaya);
            entry.put("totalFermes", (Long) entry.get("totalFermes") + 1);
            entry.put("totalAnimaux", (Long) entry.get("totalAnimaux") + count);
        }

        return ResponseEntity.ok(new ArrayList<>(wilayas.values()));
    }

    @GetMapping("/stats/by-species")
    public ResponseEntity<List<Map<String, Object>>> getStatsBySpecies() {
        return ResponseEntity.ok(List.of(
                Map.of("species", "OVIN", "count",
                        animalRepository.countBySpeciesAndStatus(Species.OVIN, AnimalStatus.ACTIVE)),
                Map.of("species", "BOVIN", "count",
                        animalRepository.countBySpeciesAndStatus(Species.BOVIN, AnimalStatus.ACTIVE))
        ));
    }

    // ============================================================
    // USERS
    // ============================================================

    @PostMapping("/users")
    public ResponseEntity<?> createUser(@RequestBody Map<String, Object> request) {
        String username = getString(request.get("username"));
        String email = getString(request.get("email"));
        String phone = getString(request.get("phoneNumber"));
        String password = getString(request.get("password"));

        if (username == null || username.isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Nom d'utilisateur obligatoire"));
        }

        if (userRepository.findByUsername(username).isPresent()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Nom d'utilisateur déjà pris"));
        }

        if (email != null && userRepository.findByEmail(email).isPresent()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Email déjà utilisé"));
        }

        if (password == null || password.length() < 6) {
            return ResponseEntity.badRequest()
                    .body(Map.of("message", "Mot de passe minimum 6 caractères"));
        }

        // Depuis l'interface web admin, on ne crée que des ADMIN
        User user = User.builder()
                .username(username)
                .email(email)
                .phoneNumber(phone)
                .password(passwordEncoder.encode(password))
                .role(Role.ADMIN)
                .farm(null)
                .enabled(true)
                .build();

        userRepository.save(user);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(Map.of("message", "Compte administrateur créé avec succès"));
    }


    @PutMapping("/users/{id}")
    public ResponseEntity<?> updateUser(
            @PathVariable Long id,
            @RequestBody Map<String, Object> request
    ) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        String username = getString(request.get("username"));
        String email = getString(request.get("email"));
        String phone = getString(request.get("phoneNumber"));
        String role = getString(request.get("role"));

        if (username != null && !username.isBlank()) {
            var existing = userRepository.findByUsername(username);
            if (existing.isPresent() && !existing.get().getId().equals(id)) {
                return ResponseEntity.badRequest().body(Map.of("message", "Nom d'utilisateur déjà pris"));
            }
            user.setUsername(username);
        }

        if (email != null && !email.isBlank()) {
            var existing = userRepository.findByEmail(email);
            if (existing.isPresent() && !existing.get().getId().equals(id)) {
                return ResponseEntity.badRequest().body(Map.of("message", "Email déjà utilisé"));
            }
            user.setEmail(email);
        }

        if (phone != null) {
            user.setPhoneNumber(phone);
        }

        if (role != null && !role.isBlank()) {
            user.setRole(Role.valueOf(role.toUpperCase()));
        }

        Long farmId = toLong(request.get("farmId"));
        if (farmId != null) {
            farmRepository.findById(farmId).ifPresent(user::setFarm);
        } else {
            user.setFarm(null);
        }

        userRepository.save(user);

        return ResponseEntity.ok(Map.of("message", "Utilisateur modifié avec succès"));
    }

    @PutMapping("/users/{id}/toggle")
    public ResponseEntity<?> toggleUser(@PathVariable Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        user.setEnabled(!user.isEnabled());
        userRepository.save(user);

        return ResponseEntity.ok(Map.of(
                "message", user.isEnabled() ? "Compte activé" : "Compte désactivé",
                "enabled", user.isEnabled()
        ));
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        user.setEnabled(false);
        userRepository.save(user);

        return ResponseEntity.ok(Map.of("message", "Compte désactivé"));
    }

    @GetMapping("/users")
    public ResponseEntity<List<Map<String, Object>>> getAllUsers() {
        return ResponseEntity.ok(
                userRepository.findAll()
                        .stream()
                        .map(this::userToMap)
                        .toList()
        );
    }

    // ============================================================
    // FARMS
    // ============================================================

    @GetMapping("/farms")
    public ResponseEntity<List<Map<String, Object>>> getAllFarms() {
        return ResponseEntity.ok(
                farmRepository.findAll()
                        .stream()
                        .map(f -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("id", f.getId());
                            map.put("name", f.getName());
                            map.put("location", f.getLocation());
                            map.put("wilaya", f.getWilaya());
                            map.put("commune", f.getCommune());
                            map.put("latitude", f.getLatitude());
                            map.put("longitude", f.getLongitude());
                            map.put("ownerName", f.getOwner() != null ? f.getOwner().getFullName() : null);
                            map.put("ownerPhone", f.getOwner() != null ? f.getOwner().getPhone() : null);
                            map.put("totalAnimaux", animalRepository.countByFarmId(f.getId()));
                            return map;
                        })
                        .toList()
        );
    }

    @GetMapping("/farms/{id}")
    public ResponseEntity<?> getFarmDetails(@PathVariable Long id) {
        Farm farm = farmRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Ferme introuvable"));

        List<Animal> animals = animalRepository.findByFarmId(id);

        Map<String, Object> result = new HashMap<>();
        result.put("id", farm.getId());
        result.put("name", farm.getName());
        result.put("location", farm.getLocation());
        result.put("wilaya", farm.getWilaya());
        result.put("commune", farm.getCommune());
        result.put("latitude", farm.getLatitude());
        result.put("longitude", farm.getLongitude());
        result.put("ownerName", farm.getOwner() != null ? farm.getOwner().getFullName() : null);
        result.put("ownerEmail", farm.getOwner() != null ? farm.getOwner().getEmail() : null);
        result.put("ownerPhone", farm.getOwner() != null ? farm.getOwner().getPhone() : null);
        result.put("totalAnimaux", animals.size());
        result.put("actifs", animals.stream().filter(a -> a.getStatus() == AnimalStatus.ACTIVE).count());
        result.put("ovins", animals.stream().filter(a -> a.getSpecies() == Species.OVIN).count());
        result.put("bovins", animals.stream().filter(a -> a.getSpecies() == Species.BOVIN).count());

        return ResponseEntity.ok(result);
    }

    // ============================================================
    // ANIMALS
    // ============================================================

    @GetMapping("/animals")
    public ResponseEntity<List<Map<String, Object>>> getAllAnimals(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String species,
            @RequestParam(required = false) Long farmId
    ) {
        List<Animal> animals = animalRepository.findAll();

        if (status != null && !status.isBlank()) {
            animals = animals.stream()
                    .filter(a -> a.getStatus().name().equalsIgnoreCase(status))
                    .toList();
        }

        if (species != null && !species.isBlank()) {
            animals = animals.stream()
                    .filter(a -> a.getSpecies().name().equalsIgnoreCase(species))
                    .toList();
        }

        if (farmId != null) {
            animals = animals.stream()
                    .filter(a -> a.getFarm().getId().equals(farmId))
                    .toList();
        }

        List<Map<String, Object>> result = animals.stream().map(a -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", a.getId());
            map.put("rfidTag", a.getRfidTag());
            map.put("species", a.getSpecies().name());
            map.put("breed", a.getBreed());
            map.put("gender", a.getGender() != null ? a.getGender().name() : null);
            map.put("weight", a.getWeight());
            map.put("status", a.getStatus().name());
            map.put("color", a.getColor());
            map.put("birthDate", a.getBirthDate());
            map.put("farmId", a.getFarm().getId());
            map.put("farmName", a.getFarm().getName());
            map.put("farmWilaya", a.getFarm().getWilaya());
            map.put("motherId", a.getMother() != null ? a.getMother().getId() : null);
            map.put("motherRfid", a.getMother() != null ? a.getMother().getRfidTag() : null);
            map.put("fatherId", a.getFather() != null ? a.getFather().getId() : null);
            map.put("fatherRfid", a.getFather() != null ? a.getFather().getRfidTag() : null);
            return map;
        }).toList();

        return ResponseEntity.ok(result);
    }

    /**
     * IMPORTANT :
     * Cet endpoint accepte :
     * - ID numérique : /admin/animals/4/history
     * - Tag RFID : /admin/animals/ID-0007/history
     * - Tag RFID : /admin/animals/2024-MA-99238/history
     */
    @GetMapping("/animals/{identifier}/history")
    public ResponseEntity<?> getAnimalHistory(@PathVariable String identifier) {
        Animal animal;

        try {
            Long id = Long.valueOf(identifier);
            animal = animalRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Animal introuvable avec ID : " + id));
        } catch (NumberFormatException e) {
            animal = animalRepository.findByRfidTag(identifier)
                    .orElseThrow(() -> new RuntimeException("Animal introuvable avec RFID : " + identifier));
        }

        return ResponseEntity.ok(buildAnimalHistory(animal));
    }

    private Map<String, Object> buildAnimalHistory(Animal animal) {
        Map<String, Object> result = new HashMap<>();

        result.put("id", animal.getId());
        result.put("rfidTag", animal.getRfidTag());
        result.put("species", animal.getSpecies() != null ? animal.getSpecies().name() : null);
        result.put("breed", animal.getBreed());
        result.put("gender", animal.getGender() != null ? animal.getGender().name() : null);
        result.put("weight", animal.getWeight());
        result.put("status", animal.getStatus() != null ? animal.getStatus().name() : null);
        result.put("color", animal.getColor());
        result.put("birthDate", animal.getBirthDate());

        result.put("currentFarm", animal.getFarm() != null ? animal.getFarm().getName() : null);
        result.put("currentFarmId", animal.getFarm() != null ? animal.getFarm().getId() : null);
        result.put("currentFarmWilaya", animal.getFarm() != null ? animal.getFarm().getWilaya() : null);

        result.put("mother", animal.getMother() != null ? simpleAnimalMap(animal.getMother()) : null);
        result.put("father", animal.getFather() != null ? simpleAnimalMap(animal.getFather()) : null);

        result.put("movements",
                movementRepository.findByAnimalIdOrderByMovementDateDesc(animal.getId())
                        .stream()
                        .map(m -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("id", m.getId());
                            map.put("type", m.getMovementType() != null ? m.getMovementType().name() : null);
                            map.put("fromFarm", m.getFromFarm() != null ? m.getFromFarm().getName() : null);
                            map.put("toFarm", m.getToFarm() != null ? m.getToFarm().getName() : null);
                            map.put("date", m.getMovementDate());
                            map.put("price", m.getPrice());
                            map.put("counterpartyName", m.getCounterpartyName());
                            map.put("performedBy", m.getPerformedBy() != null ? m.getPerformedBy().getUsername() : null);
                            map.put("notes", m.getNotes());
                            return map;
                        }).toList()
        );

        result.put("vaccinations",
                vaccinationRepository.findByAnimalIdOrderByVaccinationDateDesc(animal.getId())
                        .stream()
                        .map(v -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("id", v.getId());
                            map.put("vaccineName", v.getVaccineName());
                            map.put("vaccineType", v.getVaccineType());
                            map.put("manufacturer", v.getManufacturer());
                            map.put("batchNumber", v.getBatchNumber());
                            map.put("vaccinationDate", v.getVaccinationDate());
                            map.put("expirationDate", v.getExpirationDate());
                            map.put("veterinarian", v.getVeterinarian() != null ? v.getVeterinarian().getUsername() : null);
                            return map;
                        }).toList()
        );

        result.put("healthRecords",
                healthRecordRepository.findByAnimalIdOrderByVisitDateDesc(animal.getId())
                        .stream()
                        .map(r -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("id", r.getId());
                            map.put("recordType", r.getRecordType() != null ? r.getRecordType().name() : null);
                            map.put("diagnosis", r.getDiagnosis());
                            map.put("symptoms", r.getSymptoms());
                            map.put("treatment", r.getTreatment());
                            map.put("visitDate", r.getVisitDate());
                            map.put("nextVisitDate", r.getNextVisitDate());
                            map.put("isResolved", r.getIsResolved());
                            map.put("severity", r.getSeverity() != null ? r.getSeverity().name() : null);
                            map.put("veterinarian", r.getVeterinarian() != null ? r.getVeterinarian().getUsername() : null);
                            return map;
                        }).toList()
        );

        result.put("events",
                animalEventRepository.findByAnimalIdOrderByEventDateDesc(animal.getId())
                        .stream()
                        .map(e -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("id", e.getId());
                            map.put("eventType", e.getEventType() != null ? e.getEventType().name() : null);
                            map.put("eventDate", e.getEventDate());
                            map.put("location", e.getLocation());
                            map.put("latitude", e.getLatitude());
                            map.put("longitude", e.getLongitude());
                            map.put("performedBy", e.getPerformedBy() != null ? e.getPerformedBy().getUsername() : null);
                            map.put("notes", e.getNotes());
                            return map;
                        }).toList()
        );

        List<Map<String, Object>> offspring = animalRepository.findAll()
                .stream()
                .filter(a ->
                        (a.getMother() != null && a.getMother().getId().equals(animal.getId())) ||
                                (a.getFather() != null && a.getFather().getId().equals(animal.getId()))
                )
                .map(a -> {
                    Map<String, Object> map = simpleAnimalMap(a);
                    map.put("birthDate", a.getBirthDate());
                    map.put("status", a.getStatus() != null ? a.getStatus().name() : null);
                    map.put("relation",
                            a.getMother() != null && a.getMother().getId().equals(animal.getId())
                                    ? "Fils/Fille côté mère"
                                    : "Fils/Fille côté père"
                    );
                    return map;
                })
                .toList();

        result.put("offspring", offspring);

        return result;
    }

    // ============================================================
    // CONSTATS
    // ============================================================

    @GetMapping("/constats")
    public ResponseEntity<List<Map<String, Object>>> getAllConstats() {
        return ResponseEntity.ok(
                constatRepository.findAllByOrderByCreatedAtDesc()
                        .stream()
                        .map(c -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("id", c.getId());
                            map.put("type", c.getType());
                            map.put("description", c.getDescription());
                            map.put("status", c.getStatus());
                            map.put("latitude", c.getLatitude());
                            map.put("longitude", c.getLongitude());
                            map.put("photoUrl", c.getPhotoUrl());
                            map.put("attachmentsJson", c.getAttachmentsJson());
                            map.put("createdAt", c.getCreatedAt());
                            map.put("controleurUsername", c.getControleur() != null ? c.getControleur().getUsername() : null);
                            map.put("farmName", c.getFarm() != null ? c.getFarm().getName() : null);
                            map.put("farmWilaya", c.getFarm() != null ? c.getFarm().getWilaya() : null);
                            return map;
                        }).toList()
        );
    }

    @PutMapping("/constats/{id}/status")
    public ResponseEntity<?> updateConstatStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> request
    ) {
        Constat constat = constatRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Constat introuvable"));

        String newStatus = request.get("status");

        if (newStatus == null || newStatus.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Statut obligatoire"));
        }

        constat.setStatus(newStatus);
        constatRepository.save(constat);

        return ResponseEntity.ok(Map.of("message", "Statut mis à jour"));
    }

    // ============================================================
    // ALERTS
    // ============================================================

    @GetMapping("/alerts")
    public ResponseEntity<List<Map<String, Object>>> getAllAlerts() {
        return ResponseEntity.ok(
                healthAlertRepository.findAll()
                        .stream()
                        .sorted(Comparator.comparing(a ->
                                a.getDueDate() != null ? a.getDueDate() : java.time.LocalDate.now()
                        ))
                        .map(a -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("id", a.getId());
                            map.put("alertType", a.getAlertType() != null ? a.getAlertType().name() : null);
                            map.put("message", a.getMessage());
                            map.put("dueDate", a.getDueDate());
                            map.put("isResolved", a.getIsResolved());
                            map.put("severity", a.getSeverity() != null ? a.getSeverity().name() : null);
                            map.put("createdAt", a.getCreatedAt());
                            map.put("animalRfidTag", a.getAnimal() != null ? a.getAnimal().getRfidTag() : null);
                            map.put("farmName",
                                    a.getAnimal() != null && a.getAnimal().getFarm() != null
                                            ? a.getAnimal().getFarm().getName()
                                            : null);
                            return map;
                        }).toList()
        );
    }

    // ============================================================
    // FRAUD
    // ============================================================

    @GetMapping("/fraud/indicators")
    public ResponseEntity<Map<String, Object>> getFraudIndicators() {
        Map<String, Object> indicators = new HashMap<>();

        indicators.put("totalFraudes", constatRepository.countByType("FRAUDE"));
        indicators.put("totalManquants", constatRepository.countByType("MANQUANT"));
        indicators.put("constatsNonResolus", constatRepository.countByStatus("PENDING"));
        indicators.put("animauxActifs", animalRepository.countByStatus(AnimalStatus.ACTIVE));

        long fermesVides = farmRepository.findAll()
                .stream()
                .filter(f -> animalRepository.countByFarmId(f.getId()) == 0)
                .count();

        indicators.put("fermesVides", fermesVides);

        return ResponseEntity.ok(indicators);
    }

    // ============================================================
    // AUDIT
    // ============================================================

    @GetMapping("/audit")
    public ResponseEntity<List<Map<String, Object>>> getAuditLog() {
        List<Map<String, Object>> log = new ArrayList<>();

        constatRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .limit(25)
                .forEach(c -> {
                    Map<String, Object> entry = new HashMap<>();
                    entry.put("type", "CONSTAT");
                    entry.put("action", "Déclaration : " + c.getType());
                    entry.put("user", c.getControleur() != null ? c.getControleur().getUsername() : null);
                    entry.put("details", c.getDescription());
                    entry.put("timestamp", c.getCreatedAt());
                    log.add(entry);
                });

        movementRepository.findAll()
                .stream()
                .sorted(Comparator.comparing(Movement::getMovementDate).reversed())
                .limit(25)
                .forEach(m -> {
                    Map<String, Object> entry = new HashMap<>();
                    entry.put("type", "MOUVEMENT");
                    entry.put("action", m.getMovementType().name() + " — " + m.getAnimal().getRfidTag());
                    entry.put("user", m.getPerformedBy() != null ? m.getPerformedBy().getUsername() : null);
                    entry.put("details", m.getNotes());
                    entry.put("timestamp", m.getMovementDate());
                    log.add(entry);
                });

        log.sort((a, b) -> {
            Object ta = a.get("timestamp");
            Object tb = b.get("timestamp");
            if (ta == null || tb == null) return 0;
            return tb.toString().compareTo(ta.toString());
        });

        return ResponseEntity.ok(log);
    }

    // ============================================================
    // EXPORTS
    // ============================================================

    @GetMapping("/export/animals")
    public ResponseEntity<List<Map<String, Object>>> exportAnimals() {
        return ResponseEntity.ok(
                animalRepository.findAll()
                        .stream()
                        .map(a -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("rfidTag", a.getRfidTag());
                            map.put("species", a.getSpecies().name());
                            map.put("breed", a.getBreed());
                            map.put("gender", a.getGender() != null ? a.getGender().name() : null);
                            map.put("weight", a.getWeight());
                            map.put("status", a.getStatus().name());
                            map.put("color", a.getColor());
                            map.put("birthDate", a.getBirthDate());
                            map.put("farmName", a.getFarm().getName());
                            map.put("farmWilaya", a.getFarm().getWilaya());
                            return map;
                        }).toList()
        );
    }

    @GetMapping("/export/farms")
    public ResponseEntity<List<Map<String, Object>>> exportFarms() {
        return ResponseEntity.ok(
                farmRepository.findAll()
                        .stream()
                        .map(f -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("id", f.getId());
                            map.put("name", f.getName());
                            map.put("location", f.getLocation());
                            map.put("wilaya", f.getWilaya());
                            map.put("commune", f.getCommune());
                            map.put("ownerName", f.getOwner() != null ? f.getOwner().getFullName() : null);
                            map.put("ownerPhone", f.getOwner() != null ? f.getOwner().getPhone() : null);
                            map.put("latitude", f.getLatitude());
                            map.put("longitude", f.getLongitude());
                            map.put("totalAnimaux", animalRepository.countByFarmId(f.getId()));
                            return map;
                        }).toList()
        );
    }

    @GetMapping("/export/constats")
    public ResponseEntity<List<Map<String, Object>>> exportConstats() {
        return ResponseEntity.ok(
                constatRepository.findAllByOrderByCreatedAtDesc()
                        .stream()
                        .map(c -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("id", c.getId());
                            map.put("type", c.getType());
                            map.put("description", c.getDescription());
                            map.put("status", c.getStatus());
                            map.put("controleur", c.getControleur() != null ? c.getControleur().getUsername() : null);
                            map.put("ferme", c.getFarm() != null ? c.getFarm().getName() : null);
                            map.put("wilaya", c.getFarm() != null ? c.getFarm().getWilaya() : null);
                            map.put("createdAt", c.getCreatedAt());
                            return map;
                        }).toList()
        );
    }

    @GetMapping("/export/alerts")
    public ResponseEntity<List<Map<String, Object>>> exportAlerts() {
        return ResponseEntity.ok(
                healthAlertRepository.findAll()
                        .stream()
                        .map(a -> {
                            Map<String, Object> map = new HashMap<>();
                            map.put("id", a.getId());
                            map.put("alertType", a.getAlertType() != null ? a.getAlertType().name() : null);
                            map.put("message", a.getMessage());
                            map.put("dueDate", a.getDueDate());
                            map.put("isResolved", a.getIsResolved());
                            map.put("severity", a.getSeverity() != null ? a.getSeverity().name() : null);
                            map.put("animalRfidTag", a.getAnimal() != null ? a.getAnimal().getRfidTag() : null);
                            map.put("farmName",
                                    a.getAnimal() != null && a.getAnimal().getFarm() != null
                                            ? a.getAnimal().getFarm().getName()
                                            : null);
                            return map;
                        }).toList()
        );
    }

    // ============================================================
    // SETTINGS
    // ============================================================

    @GetMapping("/settings")
    public ResponseEntity<?> getSettings() {
        return ResponseEntity.ok(adminSettingRepository.findAll());
    }

    @PutMapping("/settings/{key}")
    public ResponseEntity<?> updateSetting(
            @PathVariable String key,
            @RequestBody Map<String, String> request
    ) {
        String value = request.get("value");

        AdminSetting setting = adminSettingRepository
                .findBySettingKey(key)
                .orElseGet(() -> AdminSetting.builder()
                        .settingKey(key)
                        .description("Paramètre système")
                        .build());

        setting.setSettingValue(value);
        adminSettingRepository.save(setting);

        return ResponseEntity.ok(Map.of("message", "Paramètre mis à jour"));
    }

    // ============================================================
    // UTILS
    // ============================================================

    private Map<String, Object> userToMap(User u) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", u.getId());
        map.put("username", u.getUsername());
        map.put("email", u.getEmail());
        map.put("phoneNumber", u.getPhoneNumber());
        map.put("role", u.getRole().name());
        map.put("enabled", u.isEnabled());
        map.put("farmId", u.getFarm() != null ? u.getFarm().getId() : null);
        map.put("farmName", u.getFarm() != null ? u.getFarm().getName() : null);
        map.put("createdAt", u.getCreatedAt());
        return map;
    }

    private Map<String, Object> simpleAnimalMap(Animal a) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", a.getId());
        map.put("rfidTag", a.getRfidTag());
        map.put("species", a.getSpecies() != null ? a.getSpecies().name() : null);
        map.put("breed", a.getBreed());
        map.put("gender", a.getGender() != null ? a.getGender().name() : null);
        return map;
    }

    private Long toLong(Object value) {
        if (value == null) return null;
        if (value.toString().isBlank()) return null;
        try {
            return Long.valueOf(value.toString());
        } catch (Exception e) {
            return null;
        }
    }

    private String getString(Object value) {
        if (value == null) return null;
        return value.toString();
    }
}
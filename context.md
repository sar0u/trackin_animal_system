# BIBLE DU PROJET — DZCheptel
# Système National Intelligent de Traçabilité du Cheptel

**Organisation :** HB Technologies SPA  
**Version :** 2.0 — Mise à jour complète 25/04/2026  
**Périmètre :** Algérie (national)

---

## 1. PRÉSENTATION DU PROJET

### Description
Plateforme client/serveur sécurisée de gestion du cycle de vie, de traçabilité et de contrôle du bétail à l'échelle nationale. Elle couvre les espèces Ovin, Bovin, Caprin via identification RFID (UHF et NFC).

### Problèmes adressés
- Processus manuels/partiellement numérisés → mauvaise visibilité
- Difficulté à contrôler les effectifs déclarés
- Absence de système centralisé → risques élevés de fraude (doubles déclarations, animaux fictifs, mouvements non déclarés)
- Suivi sanitaire limité et peu structuré
- Gestion des subventions complexe et opaque

### Objectifs
1. Assurer une identification unique et fiable des animaux
2. Garantir la traçabilité complète du cheptel
3. Numériser la gestion des exploitations agricoles
4. Optimiser le suivi sanitaire et reproductif
5. Permettre un contrôle effectif des subventions
6. Réduire les risques de fraude
7. Fournir des outils d'aide à la décision pour les autorités
8. Renforcer le contrôle par les inspecteurs et vétérinaires

---

## 2. STACK TECHNIQUE

| Couche | Technologie | Détails |
|--------|-------------|---------|
| **Frontend** | Vue.js 3 | Composition API avec `<script setup>` |
| **Routing** | Vue Router 4 | Guards d'authentification, meta `requiresAdmin` |
| **État** | Pinia | Store minimal (non utilisé activement — état géré localement) |
| **HTTP Client** | Axios | Intercepteurs JWT + gestion 401/403 automatique |
| **Cartographie** | Leaflet.js | Cartes interactives GPS (fermes, fraudes) |
| **Icônes** | FontAwesome | Intégration CDN |
| **Build Frontend** | Vite | Port dev : 5173 |
| **Backend** | Java Spring Boot 3+ | Spring Security, Spring Data JPA, Hibernate |
| **Auth** | JWT (HS256) | Token 24h, filtre `OncePerRequestFilter` |
| **Réduction boilerplate** | Lombok | `@Data`, `@Builder`, `@RequiredArgsConstructor` |
| **Documentation API** | Swagger / OpenAPI 3.0 | Schéma Bearer JWT |
| **Base de données** | MySQL | BDD `dz_cheptel_db` v2.1 |
| **BDD — Logique** | Triggers MySQL | 9 triggers, colonnes `GENERATED ALWAYS AS`, ENUMs |
| **Email** | Spring Mail + JavaMailSender | Codes de réinitialisation de mot de passe |

---

## 3. RÔLES ET PERMISSIONS

### 4 rôles utilisateurs

| Rôle | Description |
|------|-------------|
| `Administrator` | Accès complet à tout. Gère les utilisateurs, la plateforme, les audits. |
| `Veterinarian` | Accès aux dossiers médicaux, vaccinations, mise à jour de la santé animale. |
| `Farmer` | Crée et gère ses propres animaux et fermes. |
| `Inspector` | Réalise les inspections de terrain, gère les mouvements, les subventions, les sessions de scan. |

### Matrice de permissions par endpoint

| Ressource | GET (liste/détail) | POST (créer) | PUT (modifier) | DELETE |
|-----------|-------------------|--------------|----------------|--------|
| `/api/users` | Tous authentifiés | Administrator | Administrator | Administrator |
| `/api/animals` | Tous authentifiés | Admin, Farmer | Admin, Veterinarian | Administrator |
| `/api/farms` | Tous authentifiés | Admin, Farmer | Admin, Farmer | Administrator |
| `/api/health-records` | Tous authentifiés | Admin, Veterinarian | Admin, Veterinarian | Administrator |
| `/api/vaccinations` | Tous authentifiés | Admin, Veterinarian | Admin, Veterinarian | Administrator |
| `/api/inspections` | Tous authentifiés | Admin, Inspector | Admin, Inspector | Administrator |
| `/api/movements` | Tous authentifiés | Admin, Inspector | Admin, Inspector | Administrator |
| `/api/rfid-tags` | Tous authentifiés | Administrator | Admin, Inspector | Administrator |
| `/api/scan-sessions` | Tous authentifiés | Admin, Inspector | Admin, Inspector | Administrator |
| `/api/subsidies` | Tous authentifiés | Admin, Inspector | Admin, Inspector | Administrator |
| `/api/notifications` | Tous authentifiés | Admin, Inspector | Admin, Inspector | Administrator |
| `/api/audit-logs` | **Administrator uniquement** | — | — | — |
| `/api/animal-status-history` | Tous authentifiés | — | — | — |
| `/api/auth/**` | **Public (sans token)** | Public | — | — |

---

## 4. ARCHITECTURE BASE DE DONNÉES — SCHÉMA COMPLET

**Nom de la BDD :** `dz_cheptel_db`  
**Fichier SQL :** `database2.sql`

### 4.1 Tables (17 tables)

#### `users`
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | BIGINT | PK, AUTO_INCREMENT |
| username | VARCHAR(100) | UNIQUE, NOT NULL |
| email | VARCHAR(191) | UNIQUE, NOT NULL |
| password | VARCHAR(255) | NOT NULL (bcrypt) |
| first_name, last_name | VARCHAR(100) | NOT NULL |
| phone | VARCHAR(20) | nullable |
| role | ENUM | Administrator, Veterinarian, Farmer, Inspector |
| is_active | BOOLEAN | DEFAULT TRUE (soft-delete) |
| reset_code | VARCHAR | nullable (code 6 chiffres) |
| reset_code_expiration | TIMESTAMP | nullable (expiration 15 min) |
| created_at, updated_at | TIMESTAMP | auto |

#### `farms`
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | BIGINT | PK |
| owner_id | BIGINT | FK → users.id ON DELETE RESTRICT |
| name | VARCHAR(150) | NOT NULL |
| location | VARCHAR(255) | adresse textuelle |
| latitude, longitude | DECIMAL | coordonnées GPS |
| capacity | INT | hectares |
| status | ENUM | Active, Suspended, Closed |
| is_verified | BOOLEAN | |
| created_at, updated_at | TIMESTAMP | |

#### `rfid_tags`
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | BIGINT | PK |
| rfid_code | VARCHAR(100) | UNIQUE |
| tag_type | ENUM | UHF, NFC |
| tag_status | ENUM | **InStock**, Assigned, Defective, Lost |
| created_at | TIMESTAMP | |

#### `animals` (entité centrale)
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | BIGINT | PK |
| rfid_tag_id | BIGINT | UNIQUE, FK → rfid_tags ON DELETE SET NULL |
| owner_id | BIGINT | FK → users ON DELETE RESTRICT |
| farm_id | BIGINT | FK → farms ON DELETE RESTRICT |
| species | ENUM | Ovin, Bovin, Caprin, Autre |
| breed | VARCHAR | race |
| gender | ENUM | Male, Female, Unknown |
| birth_date | DATE | CHECK: pas dans le futur (trigger) |
| birth_place, acquisition_place | VARCHAR | |
| weight | DECIMAL | CHECK > 0 (trigger) |
| origin_type | ENUM | Born, Purchased, Imported |
| life_status | ENUM | **Active**, Sold, Lost, Dead, Slaughtered |
| health_status | ENUM | **Healthy**, UnderTreatment, Critical, Quarantined |
| reproduction_status | ENUM | None, Pregnant, Breeding, Castrated |
| vaccination_status | ENUM | UpToDate, Expired, Not_vaccinated |
| mother_id, father_id | BIGINT | FK auto-référence → animals ON DELETE SET NULL |
| notes | TEXT | |
| created_at, updated_at | TIMESTAMP | |

#### `movements` (source de vérité des transferts)
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | BIGINT | PK |
| animal_id | BIGINT | FK → animals ON DELETE RESTRICT |
| from_farm_id | BIGINT | FK → farms ON DELETE RESTRICT |
| to_farm_id | BIGINT | FK → farms ON DELETE RESTRICT |
| reason | VARCHAR(255) | |
| move_date | TIMESTAMP | |
| approved_by | BIGINT | FK → users ON DELETE SET NULL |
| approval_status | ENUM | **Pending**, Approved, Rejected |
| notes | TEXT | |
| created_at | TIMESTAMP | |

#### `health_records`
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | BIGINT | PK |
| animal_id | BIGINT | FK → animals ON DELETE RESTRICT |
| veterinarian_id | BIGINT | FK → users ON DELETE SET NULL |
| record_type | ENUM | Vaccination, Treatment, Disease, Checkup, Surgery, LabTest, Injury |
| diagnosis, symptoms, treatment_plan | TEXT | |
| visit_date | DATETIME | |
| next_visit_date | DATE | |
| is_validated | BOOLEAN | validé par vétérinaire |
| geo_latitude, geo_longitude | DECIMAL(10,8 / 11,8) | géolocalisation de l'intervention |
| notes | TEXT | |
| created_at, updated_at | TIMESTAMP | |

#### `vaccinations`
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | BIGINT | PK |
| health_record_id | BIGINT | FK → health_records ON DELETE CASCADE |
| vaccine_name, vaccine_type, manufacturer, batch_number, dose | VARCHAR | |
| expiration_date, next_dose_date | DATE | |
| administered_by | BIGINT | FK → users ON DELETE SET NULL |
| created_at | TIMESTAMP | |

#### `subsidies`
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | BIGINT | PK |
| animal_id | BIGINT | FK → animals ON DELETE SET NULL |
| amount | DECIMAL(12,2) | CHECK > 0 |
| subsidy_type | VARCHAR(100) | ex: "Aide Bio", "Bien-être animal", "Modernisation" |
| status | ENUM | Pending, Approved, Rejected, Paid |
| request_date, approved_date, paid_date | TIMESTAMP | |
| approved_by | BIGINT | FK → users ON DELETE SET NULL |
| notes | TEXT | |
| created_at, updated_at | TIMESTAMP | |

#### `inspections`
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | BIGINT | PK |
| inspector_id | BIGINT | FK → users ON DELETE RESTRICT |
| animal_id | BIGINT | FK → animals ON DELETE SET NULL |
| inspection_date | TIMESTAMP | |
| constat_type | VARCHAR(50) | DEFAULT 'General' |
| result | ENUM | Compliant, Fraud, Suspicious, Pending |
| description | TEXT | |
| scanned_count, registered_count | INT | |
| **difference** | INT | **GENERATED ALWAYS AS** (scanned_count - registered_count) STORED |
| status | ENUM | Pending, UnderReview, Resolved, Rejected |
| resolved_at | TIMESTAMP NULL | |
| resolved_by | BIGINT | FK → users ON DELETE SET NULL |
| geo_latitude, geo_longitude | DECIMAL | coordonnées GPS du terrain |
| notes | TEXT | |
| created_at, updated_at | TIMESTAMP | |

#### `inspection_images`
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | BIGINT | PK |
| inspection_id | BIGINT | FK → inspections ON DELETE CASCADE |
| image_url | TEXT | URL de la photo |
| image_type | ENUM | Photo, Screenshot, Document |
| created_at | TIMESTAMP | |

#### `inspection_missing_tags` & `inspection_unknown_tags`
- Tables de détail associées aux inspections
- FK → inspections ON DELETE CASCADE, FK → rfid_tags ON DELETE CASCADE
- UNIQUE KEY sur (inspection_id, tag_id)

#### `scan_sessions` (sessions de lecture UHF par lot)
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | BIGINT | PK |
| controller_id | BIGINT | FK → users ON DELETE RESTRICT |
| farm_id | BIGINT | FK → farms ON DELETE RESTRICT |
| session_date | TIMESTAMP | |
| total_scanned, total_registered | INT | |
| **difference** | INT | **GENERATED ALWAYS AS** (total_scanned - total_registered) STORED |
| is_consistent | BOOLEAN | |
| status | ENUM | Pending, Confirmed, Disputed |
| confirmed_at | TIMESTAMP NULL | |
| notes | TEXT | |
| created_at | TIMESTAMP | |

#### `scanned_tags`
- Détail des tags lus pendant une session
- UNIQUE KEY sur (scan_session_id, tag_id)

#### `notifications`
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | BIGINT | PK |
| user_id | BIGINT | FK → users ON DELETE CASCADE |
| title | VARCHAR(200) | |
| body | TEXT | |
| type | ENUM | Alert, Reminder, Warning, Info |
| is_read | BOOLEAN | |
| animal_id | BIGINT | FK → animals ON DELETE SET NULL |
| farm_id | BIGINT | FK → farms ON DELETE SET NULL |
| created_at | TIMESTAMP | |

#### `audit_logs` (IMMUABLE — seul INSERT autorisé)
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | BIGINT | PK |
| user_id | BIGINT | FK → users ON DELETE SET NULL |
| action | VARCHAR(255) | ex: CREATE, UPDATE, DELETE |
| entity_type | VARCHAR(50) | ex: Animal, User, Farm |
| entity_id | BIGINT | |
| old_values, new_values | JSON | état avant/après |
| details | TEXT | |
| ip_address | VARCHAR(45) | IPv4/IPv6 |
| created_at | TIMESTAMP | |

#### `animal_status_history`
| Colonne | Type | Contraintes |
|---------|------|-------------|
| id | BIGINT | PK |
| animal_id | BIGINT | FK → animals ON DELETE CASCADE |
| changed_by | BIGINT | FK → users ON DELETE SET NULL |
| old_life_status, new_life_status | VARCHAR(50) | |
| old_health_status, new_health_status | VARCHAR(50) | |
| reason | TEXT | |
| changed_at | TIMESTAMP | |

### 4.2 ENUMs MySQL (19 enums)

| ENUM | Valeurs |
|------|---------|
| `users.role` | Administrator, Veterinarian, Farmer, Inspector |
| `farms.status` | Active, Suspended, Closed |
| `rfid_tags.tag_type` | UHF, NFC |
| `rfid_tags.tag_status` | InStock, Assigned, Defective, Lost |
| `animals.species` | Ovin, Bovin, Caprin, Autre |
| `animals.gender` | Male, Female, Unknown |
| `animals.origin_type` | Born, Purchased, Imported |
| `animals.life_status` | Active, Sold, Lost, Dead, Slaughtered |
| `animals.health_status` | Healthy, UnderTreatment, Critical, Quarantined |
| `animals.reproduction_status` | None, Pregnant, Breeding, Castrated |
| `animals.vaccination_status` | UpToDate, Expired, Not_vaccinated |
| `movements.approval_status` | Pending, Approved, Rejected |
| `health_records.record_type` | Vaccination, Treatment, Disease, Checkup, Surgery, LabTest, Injury |
| `subsidies.status` | Pending, Approved, Rejected, Paid |
| `inspections.result` | Compliant, Fraud, Suspicious, Pending |
| `inspections.status` | Pending, UnderReview, Resolved, Rejected |
| `inspection_images.image_type` | Photo, Screenshot, Document |
| `scan_sessions.status` | Pending, Confirmed, Disputed |
| `notifications.type` | Alert, Reminder, Warning, Info |

### 4.3 Triggers MySQL (9 triggers)

| # | Nom | Événement | Table | Logique |
|---|-----|-----------|-------|---------|
| 1 | `before_animal_insert_tag_check` | BEFORE INSERT | animals | Bloque si le tag RFID n'est pas "InStock" ou si birth_date est dans le futur (SIGNAL SQLSTATE 45000) |
| 2 | `before_animal_update_tag_check` | BEFORE UPDATE | animals | Même validation lors d'une mise à jour d'animal |
| 3 | `after_animal_insert` | AFTER INSERT | animals | Marque le tag RFID comme "Assigned" quand un animal est créé avec un tag |
| 4 | `after_animal_tag_update` | AFTER UPDATE | animals | Libère l'ancien tag (→ InStock) et marque le nouveau tag comme Assigned lors d'un changement de tag |
| 5 | `after_animal_status_update` | AFTER UPDATE | animals | Libère automatiquement le tag RFID (→ InStock) si life_status passe à Dead, Sold ou Slaughtered |
| 6 | `after_animal_status_history` | AFTER UPDATE | animals | Insère une ligne dans `animal_status_history` à chaque changement de life_status ou health_status |
| 7 | `after_animal_health_update` | AFTER UPDATE | animals | Insère dans `audit_logs` lors d'un changement de health_status ou de weight |
| 8 | `before_movement_insert` | BEFORE INSERT | movements | Bloque si l'animal n'est pas Active, si from_farm = to_farm, ou si l'animal n'existe pas |
| 9 | `after_movement_approved` | AFTER UPDATE | movements | Quand approval_status passe à "Approved", met à jour `animals.farm_id` vers to_farm_id |

> **Note importante :** Les erreurs levées par les triggers (SIGNAL SQLSTATE '45000') sont interceptées par le `GlobalExceptionHandler` Java et renvoyées au frontend en HTTP 400 avec le message MySQL comme corps de la réponse.

### 4.4 Vue SQL

**`v_active_animals`** — Animaux actifs avec détails ferme et propriétaire  
```sql
SELECT a.id, a.species, a.breed, a.gender, a.birth_date, a.weight,
       a.health_status, a.vaccination_status,
       CONCAT(u.first_name, ' ', u.last_name) AS owner_name,
       f.name AS farm_name, f.location AS farm_location, rt.rfid_code
FROM animals a
JOIN users u ON a.owner_id = u.id
JOIN farms f ON a.farm_id = f.id
LEFT JOIN rfid_tags rt ON a.rfid_tag_id = rt.id
WHERE a.life_status = 'Active'
```

---

## 5. BACKEND SPRING BOOT — INVENTAIRE COMPLET

**Chemin de base :** `backend/src/main/java/com/animaltracking/backend/`

### 5.1 Contrôleurs et Endpoints (15 contrôleurs, 80+ endpoints)

#### `AuthController` — `/api/auth/**` (public)
| Méthode | Path | Rôle | Description |
|---------|------|------|-------------|
| POST | `/api/auth/login` | Public | Authentification → retourne JwtResponse |
| POST | `/api/auth/forgot-password` | Public | Envoie un code 6 chiffres par email |
| POST | `/api/auth/verify-code` | Public | Vérifie le code de réinitialisation |
| POST | `/api/auth/reset-password` | Public | Réinitialise le mot de passe |

#### `UserController` — `/api/users`
| Méthode | Path | Rôle | Description |
|---------|------|------|-------------|
| GET | `/api/users` | Tous | Liste tous les utilisateurs (safe map) |
| GET | `/api/users/{id}` | Tous | Détail d'un utilisateur |
| POST | `/api/users` | Administrator | Créer un utilisateur (mdp bcrypt) |
| PUT | `/api/users/{id}` | Administrator | Modifier un utilisateur |
| DELETE | `/api/users/{id}` | Administrator | Supprimer un utilisateur |

#### `AnimalController` — `/api/animals`
| Méthode | Path | Rôle | Description |
|---------|------|------|-------------|
| GET | `/api/animals` | Tous | Liste (safe map, évite LazyInit) |
| GET | `/api/animals/{id}` | Tous | Détail animal |
| POST | `/api/animals` | Admin, Farmer | Créer un animal |
| PUT | `/api/animals/{id}` | Admin, Veterinarian | Modifier un animal |
| DELETE | `/api/animals/{id}` | Administrator | Supprimer |

#### `FarmController` — `/api/farms`
| Méthode | Path | Rôle | Description |
|---------|------|------|-------------|
| GET | `/api/farms` | Tous | Liste toutes les fermes |
| GET | `/api/farms/{id}` | Tous | Détail ferme |
| POST | `/api/farms` | Admin, Farmer | Créer une ferme |
| PUT | `/api/farms/{id}` | Admin, Farmer | Modifier |
| DELETE | `/api/farms/{id}` | Administrator | Supprimer |

#### `HealthRecordController` — `/api/health-records`
| Méthode | Path | Rôle | Description |
|---------|------|------|-------------|
| GET | `/api/health-records` | Tous | Liste |
| GET | `/api/health-records/animal/{id}` | Tous | Dossiers d'un animal |
| POST | `/api/health-records` | Admin, Veterinarian | Créer |
| PUT | `/api/health-records/{id}` | Admin, Veterinarian | Modifier |
| DELETE | `/api/health-records/{id}` | Administrator | Supprimer |

#### `VaccinationController` — `/api/vaccinations`
| Méthode | Path | Rôle | Description |
|---------|------|------|-------------|
| GET | `/api/vaccinations` | Tous | Liste |
| GET | `/api/vaccinations/record/{recordId}` | Tous | Vaccins d'un dossier médical |
| POST | `/api/vaccinations` | Admin, Veterinarian | Créer |
| PUT | `/api/vaccinations/{id}` | Admin, Veterinarian | Modifier |
| DELETE | `/api/vaccinations/{id}` | Administrator | Supprimer |

#### `InspectionController` — `/api/inspections`
| Méthode | Path | Rôle | Description |
|---------|------|------|-------------|
| GET | `/api/inspections` | Tous | Liste (safe, avec JOIN FETCH) |
| GET | `/api/inspections/{id}` | Tous | Détail |
| GET | `/api/inspections/animal/{animalId}` | Tous | Inspections d'un animal |
| GET | `/api/inspections/{id}/images` | Tous | Photos d'une inspection |
| POST | `/api/inspections` | Admin, Inspector | Créer |
| PUT | `/api/inspections/{id}/status` | Admin, Inspector | Changer le statut |
| DELETE | `/api/inspections/{id}` | Administrator | Supprimer (cascade images) |

#### `MovementController` — `/api/movements`
| Méthode | Path | Rôle | Description |
|---------|------|------|-------------|
| GET | `/api/movements` | Tous | Liste (safe map) |
| GET | `/api/movements/{id}` | Tous | Détail |
| POST | `/api/movements` | Admin, Inspector | Créer (trigger valide) |
| PUT | `/api/movements/{id}` | Admin, Inspector | Modifier |
| PUT | `/api/movements/{id}/approve` | Admin, Inspector | Approuver → trigger met à jour farm_id |
| DELETE | `/api/movements/{id}` | Administrator | Supprimer |

#### `RfidTagController` — `/api/rfid-tags`
| Méthode | Path | Rôle | Description |
|---------|------|------|-------------|
| GET | `/api/rfid-tags` | Tous | Liste |
| GET | `/api/rfid-tags/{id}` | Tous | Détail |
| POST | `/api/rfid-tags` | Administrator | Créer un tag (InStock par défaut) |
| PUT | `/api/rfid-tags/{id}` | Admin, Inspector | Modifier |
| DELETE | `/api/rfid-tags/{id}` | Administrator | Supprimer |

#### `ScanSessionController` — `/api/scan-sessions`
| Méthode | Path | Rôle | Description |
|---------|------|------|-------------|
| GET | `/api/scan-sessions` | Tous | Liste |
| GET | `/api/scan-sessions/{id}` | Tous | Détail |
| POST | `/api/scan-sessions` | Admin, Inspector | Créer session de scan UHF |
| PUT | `/api/scan-sessions/{id}` | Admin, Inspector | Modifier |
| DELETE | `/api/scan-sessions/{id}` | Administrator | Supprimer |

#### `SubsidyController` — `/api/subsidies`
| Méthode | Path | Rôle | Description |
|---------|------|------|-------------|
| GET | `/api/subsidies` | Tous | Liste (safe) |
| GET | `/api/subsidies/{id}` | Tous | Détail |
| POST | `/api/subsidies` | Admin, Inspector | Créer |
| PUT | `/api/subsidies/{id}` | Admin, Inspector | Modifier |
| PUT | `/api/subsidies/{id}/status` | Admin, Inspector | Changer le statut (Approved/Paid/Rejected) |
| DELETE | `/api/subsidies/{id}` | Administrator | Supprimer |

#### `NotificationController` — `/api/notifications`
| Méthode | Path | Rôle | Description |
|---------|------|------|-------------|
| GET | `/api/notifications` | Tous | Liste |
| GET | `/api/notifications/user/{userId}` | Tous | Notifs d'un utilisateur |
| GET | `/api/notifications/{id}` | Tous | Détail |
| POST | `/api/notifications` | Admin, Inspector | Créer |
| PUT | `/api/notifications/{id}` | Admin, Inspector | Modifier |
| DELETE | `/api/notifications/{id}` | Administrator | Supprimer |

#### `AuditLogController` — `/api/audit-logs`
| Méthode | Path | Rôle | Description |
|---------|------|------|-------------|
| GET | `/api/audit-logs` | **Administrator uniquement** | Journal immuable (eager fetch User) |

#### `AnimalStatusHistoryController` — `/api/animal-status-history`
| Méthode | Path | Rôle | Description |
|---------|------|------|-------------|
| GET | `/api/animal-status-history` | Tous | Liste complète |
| GET | `/api/animal-status-history/animal/{id}` | Tous | Historique d'un animal (DESC par date) |

#### `TestController`
- `GET /` → "Backend is running successfully"
- `GET /test` → "API is working!"

### 5.2 Entités Java (17 entités + 19 enums)

Les entités Java mirrorent exactement le schéma MySQL. Points notables :
- `Animal.rfidTag` : fetch **EAGER** (nécessaire pour la majorité des opérations)
- Les réponses API utilisent `Map<String, Object>` pour éviter les `LazyInitializationException` sur les collections Hibernate
- `Inspection` → cascade DELETE vers `InspectionImage`

**Enums Java** (chemin : `entity/`) : UserRole, Species, Gender, LifeStatus, HealthStatus, VaccinationStatus, ReproductionStatus, OriginType, RecordType, ApprovalStatus, InspectionResult, InspectionStatus, SubsidyStatus, ScanSessionStatus, NotificationType, TagType, HardwareStatus, FarmStatus, FraudType

### 5.3 DTOs
- `dto/LoginRequest.java` — `{username, password}`
- `dto/JwtResponse.java` — `{token, type="Bearer", id, username, email, firstName, lastName, role}`

### 5.4 Services
Chaque service a une interface + une implémentation dans `service/impl/` :  
AuthService, UserService, AnimalService, FarmService, HealthRecordService, VaccinationService, RfidTagService, InspectionService, MovementService, SubsidyService, AuditLogService  
+ `CustomUserDetailsService` (Spring Security) + `EmailService` (JavaMailSender)

### 5.5 Repositories (17 repositories)
Tous étendent `JpaRepository<Entity, Long>`. Les repositories complexes utilisent des JPQL avec `LEFT JOIN FETCH` pour éviter le N+1 :
- `AnimalRepository` — `findAllFetched()`, `findFetchedById()`, filtres par species, health, life_status, farm…
- `InspectionRepository` — `findAllFetched()` avec JOIN FETCH inspector, animal
- `MovementRepository` — `findAllFetched()` avec JOIN FETCH animal, farms, approvedBy
- `SubsidyRepository` — `findAllFetched()` avec JOIN FETCH animal, approvedBy
- `AuditLogRepository` — `findAllFetchedOrderByCreatedAtDesc()` avec JOIN FETCH user

### 5.6 Sécurité

**JWT (JwtUtils)**
- Algorithme : HS256, clé générée dynamiquement au démarrage
- Expiration : 24 heures (86 400 000 ms)
- Méthodes : `generateJwtToken(Authentication)`, `getUserNameFromJwtToken(String)`, `validateJwtToken(String)`

**AuthTokenFilter** (`OncePerRequestFilter`)
1. Extrait le token du header `Authorization: Bearer {token}`
2. Valide avec JwtUtils
3. Charge l'utilisateur via `CustomUserDetailsService`
4. Injecte dans `SecurityContext`

**SecurityConfig**
- CORS autorisé : `http://localhost:*`, `http://127.0.0.1:*`
- Méthodes CORS : GET, POST, PUT, DELETE, OPTIONS
- Session : **STATELESS**
- CSRF : désactivé
- Routes publiques : `/api/auth/**`, `/v3/api-docs/**`, `/swagger-ui/**`

**UserDetailsImpl**
- Authority format : `"ROLE_Administrator"`, `"ROLE_Farmer"`, etc.
- Vérifie `isActive == true` avant d'autoriser la connexion (`DisabledException` si inactif)

### 5.7 Système d'Audit

**AuditInterceptor** (intercepte toutes les requêtes HTTP) :
1. Extrait l'userId depuis `SecurityContext`
2. Extrait l'IP depuis header `X-Forwarded-For` ou `remoteAddr`
3. Stocke dans `AuditContextHolder` (ThreadLocal)
4. Nettoie après la requête

### 5.8 Gestion des Exceptions

`GlobalExceptionHandler` (`@ControllerAdvice`) :
- `EntityNotFoundException` / `ResourceNotFoundException` → HTTP 404
- `SQLException` avec SQLSTATE 45000 → HTTP 400 (message MySQL du trigger)
- `DataIntegrityViolationException` / `JpaSystemException` → HTTP 400
- `Exception` générique → HTTP 500

### 5.9 Initialisation

Au démarrage (`CommandLineRunner` dans `BackendApplication.java`) :
- Crée le superadmin si absent : username=`superadmin`, email=`admin@test.com`, password=`admin123` (bcrypt), role=`Administrator`

---

## 6. FRONTEND VUE.JS — INVENTAIRE COMPLET

**Chemin :** `SECTION KAMI/src/`

### 6.1 Structure des fichiers

```
src/
├── App.vue                    Racine — layout conditionnel admin/farmer
├── main.js                    Bootstrap, Pinia
├── router/index.js            Routes + guards d'authentification
├── services/api.js            Instance Axios + intercepteurs JWT
├── stores/counter.js          Pinia store (minimal, non utilisé activement)
├── components/
│   ├── AppSidebar.vue         Sidebar admin (fixe, 260px)
│   ├── AppTopbar.vue          Topbar admin (sticky)
│   ├── FarmSidebar.vue        Placeholder interface éleveur (non implémenté)
│   └── FarmTopbar.vue         Placeholder interface éleveur (non implémenté)
└── views/
    ├── LoginView.vue          Auth multi-étapes + récupération mdp
    ├── DashboardView.vue      Dashboard KPIs nationaux
    ├── GestionUsers.vue       CRUD utilisateurs
    ├── GestionFermes.vue      Gestion des exploitations + carte
    ├── GestionAnimals.vue     Catalogue national du cheptel
    ├── GestionMouvements.vue  Suivi des transferts d'animaux
    ├── GestionSubventions.vue Gestion des aides financières
    ├── FraudManagement.vue    Inspections + cartographie fraudes
    └── AuditLog.vue           Journal de traçabilité immuable
```

### 6.2 Routes Vue Router

| Route | Composant | Meta | Description |
|-------|-----------|------|-------------|
| `/` | LoginView | — | Page de connexion |
| `/dashboard` | DashboardView | requiresAdmin | Tableau de bord |
| `/users` | GestionUsers | requiresAdmin | Gestion utilisateurs |
| `/farms` | GestionFermes | requiresAdmin | Gestion fermes |
| `/animals` | GestionAnimals | requiresAdmin | Catalogue animaux |
| `/movements` | GestionMouvements | requiresAdmin | Mouvements |
| `/subsidies` | GestionSubventions | requiresAdmin | Subventions |
| `/fraude` | FraudManagement | requiresAdmin | Fraude & inspections |
| `/audit` | AuditLog | requiresAdmin | Journal d'audit |
| `/sub` | — | — | Redirect → `/subsidies` |

**Guard `beforeEach` :**
- Vérifie `localStorage.getItem('isAdminAuthenticated') === 'true'`
- Vérifie `localStorage.getItem('user_role') === 'Administrator'`
- Non authentifié → redirect `/`
- Déjà connecté sur `/` → redirect `/dashboard`

### 6.3 Service API (`services/api.js`)

- **Base URL :** `VITE_API_BASE_URL` ou `http://localhost:8080/api`
- **Timeout :** 10 secondes
- **Request interceptor :** Ajoute `Authorization: Bearer {token}` depuis localStorage
- **Response interceptor :**
  - 401/403 → purge localStorage (5 clés) + redirect login
  - 500 → log serveur
  - Connexion refusée → log "serveur inaccessible"

### 6.4 localStorage — Clés utilisées

| Clé | Valeur | Rôle |
|-----|--------|------|
| `token` | JWT string | Envoyé dans chaque requête |
| `user_role` | `"Administrator"` | Guard de route |
| `user_name` | username string | Affiché dans topbar |
| `user_email` | email string | Affiché dans topbar |
| `isAdminAuthenticated` | `"true"` / `"false"` | Guard de route |

### 6.5 Vues détaillées

#### `LoginView.vue` — Authentification multi-étapes
4 étapes dans le même composant :
1. **Login** : username + password → POST `/auth/login` → vérifie role === Administrator
2. **Email** : saisie email pour demande de reset → POST `/auth/forgot-password`
3. **Code** : saisie code 6 chiffres → POST `/auth/verify-code`
4. **Nouveau mot de passe** : saisie + confirmation (min 8 chars) → POST `/auth/reset-password`

#### `DashboardView.vue` — KPIs nationaux
- Chargement parallèle : `Promise.all([users, farms, animals, inspections])`
- **4 KPI cards** : Total utilisateurs, Exploitations, Effectif bétail (RFID), Alertes actives (fraudes)
- **Répartition des profils** : barres de progression par rôle
- **État sanitaire global** : grille 4 statuts (Sain, En observation, Quarantaine/Fraude, En attente)
- **Donut chart CSS** : distribution espèces (conic-gradient), cercle intérieur avec total
- **Timeline fraudes** : 3 dernières fraudes détectées avec lien vers `/fraude`

#### `GestionUsers.vue` — CRUD utilisateurs
- Table paginée (20 items/page) avec avatars initiales colorés par rôle
- Filtres : recherche full-text + filtre par rôle + plage de dates
- Modal Créer/Modifier : prénom, nom, username, email, password (create), rôle
- Couleurs rôles : admin=rouge, farmer=vert, veto=violet, inspector=jaune/orange

#### `GestionFermes.vue` — Exploitations
- Table paginée (7 items/page)
- Filtres : recherche + plage de capacité (Ha min/max)
- Stats bottom : Total fermes, Capacité totale, Distribution par taille
- **Carte Leaflet** en modale : centrée Algérie (28.0339, 1.6596), marqueurs avec popup nom/capacité

#### `GestionAnimals.vue` — Catalogue cheptel
- Table paginée (8 items/page) : tag RFID, ID ferme, espèce, badge santé, date naissance, poids
- **4 stat cards** : total, répartition espèces, taux santé %, alertes sanitaires
- Filtres : recherche (tag, ferme, owner) + espèce + santé + date naissance min
- **Modal détail** : Santé & Prévention, Origine & Acquisition, Généalogie (mère/père), Exploitation, Notes
- **Bar chart poids moyen** par espèce avec badge GMQ
- **Progress bars espèces** avec couleurs

#### `GestionMouvements.vue` — Transferts d'animaux
- Table paginée : ID mouvement (#MV-{id}), ID animal, Départ, Destination, Raison, Date, Statut
- **4 KPI cards** : total ce mois, en attente, rejetés (fraude), taux de conformité %
- Filtres : recherche + plage dates + statut (Approved/Pending/Rejected)
- Modal détail : info approbateur, notes

#### `GestionSubventions.vue` — Aides financières
- Table paginée : ID (#SUB-{year}-{id}), ID Animal (ANI-{id}), Type, Montant (DZD), Statut, Dates
- **4 KPI cards** : Budget total alloué, Demandes en attente, Taux de paiement %, Alertes conformité
- Filtres : recherche + statut + type
- **Modal détail** + **Gestionnaire de statut** : 4 boutons (Pending/Approved/Paid/Rejected) avec confirmation
  - Auto-set `approvedDate` lors du passage à Approved
  - Auto-set `paidDate` lors du passage à Paid
- **Bar chart** distribution des fonds par type de subvention
- Formatage monétaire : `Intl.NumberFormat` en DZD

#### `FraudManagement.vue` — Inspections & fraudes
- Table paginée (20 items/page) : ID (#INS-{id}), Inspecteur, Cible (ferme/animal), Date, Résultat, Statut
- **4 KPI cards** : Total inspections, Taux de fraude %, Enquêtes en cours (UnderReview), Score conformité %
- Filtres : recherche (inspecteur, ferme) + résultat + statut + tri par date
- Lignes en rose pour résultat Fraud
- **Modal détail** :
  - Analyse des écarts (scannés vs enregistrés, différence en rouge si ≠ 0)
  - Infos générales, agent, cible GPS, notes
  - **Preuves photographiques** : chargement lazy ("Charger les images") → grille avec lightbox
- **Carte Leaflet** (cartographie des fraudes) : marqueurs rouges personnalisés, clic → modal détail
  - Coordonnées GPS lues depuis le dictionnaire des fermes (`farmsDict`) croisé avec l'inspection

#### `AuditLog.vue` — Journal immuable
- Table paginée (10 items/page) : ID Log, Utilisateur, Action/Cible, Fingerprint+IP, Horodatage, Old/New JSON
- Filtres : recherche full-text + onglets action (TOUT/CREATE/UPDATE/DELETE) + plage dates + type entité
- Badges actions : CREATE (vert), UPDATE (bleu), DELETE (rouge)
- Cellules JSON stylisées : null=gris, create/update=vert, delete=rouge
- Pagination intelligente avec "..." pour les grandes listes
- Tri auto par createdAt DESC

### 6.6 Composants de Navigation

#### `AppSidebar.vue`
- Fixe gauche (260px, 100vh)
- Logo DZCheptel + "ADMIN PANEL"
- Navigation : Dashboard, Utilisateurs, Subventions, Fermes, Animaux, Mouvements, Fraude, Audit
- Active state : fond #11D432 (vert brand) + texte blanc
- Bouton Déconnexion : purge localStorage + redirect `/`

#### `AppTopbar.vue`
- Sticky top (z-index 1000)
- **Recherche Spotlight** : filtre en temps réel sur 7 modules, dropdown animé avec icônes colorées
- **Profil** : avatar initiales (40px, fond vert clair), email en gras, @username en vert

### 6.7 Design System

| Token | Valeur |
|-------|--------|
| **Primary Green** | `#11D432` (brand DZCheptel) |
| **Navy Blue** | `#1e3a8a` |
| **Light Gray BG** | `#f8fafc`, `#f3f4f6` |
| **Border** | `#cbd5e1`, `#e2e8f0` |
| **Text Dark** | `#0f172a`, `#1a202c` |
| **Text Muted** | `#64748b`, `#94a3b8` |
| **Border radius cards** | 12–16px |
| **Sidebar width** | 260px |
| **Font** | Sans-serif système |

---

## 7. RÈGLES MÉTIER CRITIQUES — RÉCAPITULATIF

Ces règles sont **impossibles à contourner** car elles sont encodées directement dans MySQL via des triggers :

1. **Poids positif obligatoire** — Un poids ≤ 0 est rejeté par trigger BEFORE INSERT/UPDATE sur `animals`
2. **Date de naissance ≤ aujourd'hui** — Une date future est bloquée par trigger BEFORE INSERT sur `animals`
3. **Tag RFID disponible** — Impossible d'assigner un tag qui n'est pas en statut "InStock"
4. **Libération automatique du tag** — Quand un animal passe à `Dead`, `Sold` ou `Slaughtered`, son tag retourne automatiquement à "InStock"
5. **Mouvements d'animaux actifs seulement** — Seul un animal en statut "Active" peut faire l'objet d'un mouvement
6. **Fermes différentes obligatoires** — `from_farm_id ≠ to_farm_id` est vérifié par trigger
7. **Mise à jour ferme via approbation uniquement** — Le backend ne modifie jamais `animals.farm_id` directement. C'est l'approbation d'un mouvement qui déclenche la mise à jour via trigger
8. **Audit immuable** — `audit_logs` n'accepte que des INSERT. Aucun UPDATE ni DELETE n'est possible sur cette table
9. **Historique automatique** — Chaque changement de `life_status` ou `health_status` génère automatiquement une ligne dans `animal_status_history`

---

## 8. FLUX FONCTIONNELS CLÉS

### Flux d'Authentification
```
1. POST /api/auth/login {username, password}
2. Backend vérifie bcrypt + isActive + génère JWT (24h)
3. Frontend stocke : token, user_role, user_name, user_email, isAdminAuthenticated=true
4. Router guard autorise l'accès aux routes protégées
5. Chaque requête API : Authorization: Bearer {token}
6. Expiration/401 → purge localStorage + redirect login
```

### Flux de Mouvement d'Animal
```
1. Inspecteur crée un Movement (status: Pending)
   → Trigger BEFORE INSERT valide : animal Active, fermes différentes
2. Inspecteur/Admin approuve : PUT /api/movements/{id}/approve
   → Backend set approval_status = 'Approved'
   → Trigger AFTER UPDATE set animals.farm_id = to_farm_id
3. La ferme de l'animal est maintenant mise à jour automatiquement
```

### Cycle de Vie d'un Tag RFID
```
InStock → (assigné à un animal) → Assigned
         ← (animal mort/vendu/abattu) ← trigger libère
         ← (tag arraché et remplacé) ← trigger libère l'ancien
         → (déclaré perdu/défectueux) → Lost / Defective
```

### Flux d'Inspection de Terrain
```
1. Inspecteur crée une Inspection (result: Pending, status: Pending)
   - scanned_count et registered_count renseignés
   - difference calculée automatiquement (colonne GENERATED)
2. Inspecteur peut uploader des photos (InspectionImage)
3. Inspecteur met à jour le résultat : Compliant / Fraud / Suspicious
4. Status passe à UnderReview, puis Resolved ou Rejected
5. Admin peut consulter via /fraude avec carte GPS
```

---

## 9. CONFIGURATION ET DÉPLOIEMENT

| Paramètre | Valeur |
|-----------|--------|
| **Port backend** | `8080` |
| **Port frontend (dev)** | `5173` (Vite) |
| **Base de données** | `dz_cheptel_db` (MySQL) |
| **Compte admin par défaut** | username: `superadmin` / email: `admin@test.com` / password: `admin123` |
| **JWT expiration** | 24 heures |
| **Reset code expiration** | 15 minutes |
| **CORS autorisé** | `http://localhost:*`, `http://127.0.0.1:*` |
| **Swagger UI** | `http://localhost:8080/swagger-ui.html` |
| **API Docs** | `http://localhost:8080/v3/api-docs` |

### Variables d'environnement Frontend (`.env`)
```
VITE_API_BASE_URL=http://localhost:8080/api
```

### Application Properties Backend
- Spring Mail configuré avec `ton.email@gmail.com` comme expéditeur
- JPA : DDL auto (create / update selon environnement)
- MySQL driver : `com.mysql.cj.jdbc.Driver`

---

## 10. APPLICATION MOBILE FLUTTER — `frontend_app/`

**Technologie :** Flutter (Dart), SDK >=3.0.0 <4.0.0  
**Plateformes cibles :** Android, iOS, Windows desktop

### 10.1 Structure des fichiers

```
frontend_app/lib/
├── main.dart                    # Point d'entrée — AuthWrapper (routage par rôle)
├── models/
│   ├── animal.dart              # Modèle Animal
│   ├── user.dart                # Modèle Utilisateur (auth)
│   └── health_record.dart       # Modèle Dossier Médical
├── screens/
│   ├── login_screen.dart        # Authentification JWT
│   ├── register_screen.dart     # Inscription (Farmer/Vet/Inspector)
│   ├── home_farmer.dart         # Dashboard éleveur
│   ├── home_vet.dart            # Dashboard vétérinaire
│   ├── home_controller.dart     # Dashboard inspecteur
│   ├── animal_form_screen.dart  # Formulaire création/modification animal
│   ├── dashboard_screen.dart    # Dashboard général
│   ├── notifications_screen.dart
│   ├── audit_log_screen.dart    # Journal d'audit
│   ├── constat_screen.dart      # Déclaration de constat terrain
│   ├── rfid_scanner_screen.dart # Scanner RFID mobile (mobile_scanner)
│   ├── uhf_scanner_screen.dart  # Scanner UHF longue portée (inspecteur)
│   ├── farmer_screen.dart
│   ├── vet_screen.dart
│   └── controller_screen.dart
├── services/
│   ├── api_service.dart         # Client HTTP (330 lignes) — base URL configurable
│   ├── app_localizations.dart   # Multi-langue (523 lignes)
│   ├── local_db_service.dart    # SQLite local (179 lignes) — cache offline
│   ├── sync_service.dart        # Sync offline/online (84 lignes)
│   ├── notification_service.dart # Notifications push (52 lignes)
│   ├── nfc_service.dart         # Lecteur NFC (71 lignes)
│   └── alarm_service.dart       # Alarmes (40 lignes)
└── widgets/
    ├── app_widgets.dart
    └── translated_widget.dart
```

### 10.2 Dépendances clés

| Package | Version | Usage |
|---------|---------|-------|
| `http` | ^1.2.0 | Client HTTP pour les appels API |
| `shared_preferences` | ^2.2.2 | Stockage local token/rôle |
| `mobile_scanner` | ^5.1.1 | Scanner QR/Code-barres (tags RFID) |
| `nfc_manager` | ^3.3.0 | Lecture NFC |
| `sqflite` | ^2.3.2 | Base SQLite locale (cache offline) |
| `flutter_local_notifications` | ^17.0.0 | Notifications push locales |
| `connectivity_plus` | ^5.0.2 | Détection réseau |
| `flutter_secure_storage` | ^9.0.0 | Stockage sécurisé des credentials |
| `fl_chart` | ^0.67.0 | Graphiques dashboard |
| `intl` | ^0.19.0 | Internationalisation |

### 10.3 Trois dashboards par rôle

| Rôle | Dashboard | Fonctionnalités principales |
|------|-----------|----------------------------|
| **Farmer** | `home_farmer.dart` | Gestion animaux, scan RFID, ajout/modif/suppression, mode offline |
| **Veterinarian** | `home_vet.dart` | Vue toutes fermes, scan animal, ajout dossiers médicaux |
| **Inspector** | `home_controller.dart` | Scanner UHF longue portée, vérification inventaire, déclaration constats |

### 10.4 Fonctionnalités spécifiques mobile

- **Scan RFID individuel** : `rfid_scanner_screen.dart` via `mobile_scanner`
- **Scan UHF longue portée** : `uhf_scanner_screen.dart` pour vérifications inventaire (inspecteurs)
- **NFC** : `nfc_service.dart` pour lecture tags NFC
- **Mode offline** : SQLite local + queue d'actions en attente + sync à la reconnexion
- **Multi-langue** : `AppLocalizations` avec préférence sauvegardée
- **Auth** : JWT stocké dans `SharedPreferences`, "Se souvenir de moi"

---

## 11. BACKEND NODE.JS/EXPRESS — `backend_app/`

**Technologie :** Express.js 5.2.1 (Node.js)  
**Port :** `8000`  
**Base de données :** MySQL — `dz_cheptel_db_1`

### 11.1 Structure des fichiers

```
backend_app/
├── Config/
│   ├── Db.js              # Pool de connexion MySQL (host: localhost, DB: dz_cheptel_db_1)
│   └── Swagger.js         # Configuration Swagger/OpenAPI
├── Controllers/
│   ├── AuthController.js         # Login, register, reset password
│   ├── FarmerController.js       # CRUD animaux éleveur, scan RFID
│   ├── VetController.js          # Vue fermes/animaux, dossiers médicaux
│   ├── InspectionController.js   # Scan UHF, inventaire, constats
│   └── InspectionImageController.js # Upload photos d'inspection
├── Routes/
│   ├── auth.js
│   ├── farmer.js
│   ├── vet.js
│   ├── inspection.js
│   └── inspectionimage.js
├── middleware/
│   └── Auth.js            # Vérification JWT + RBAC (requireRole)
├── models/
│   └── Multerconfig.js    # Config upload fichiers
├── utils/
├── uploads/               # Stockage photos inspections
├── App.js                 # Configuration Express
└── Server.js              # Démarrage (port 8000)
```

### 11.2 Endpoints API

#### Auth — `/api/auth/**` (public)
| Méthode | Path | Description |
|---------|------|-------------|
| POST | `/api/auth/login` | Login → retourne JWT + infos ferme (si Farmer) |
| POST | `/api/auth/register` | Inscription (crée ferme automatiquement si Farmer) |
| POST | `/api/auth/forgot-password` | Vérifie l'existence du compte |
| POST | `/api/auth/reset-password` | Réinitialise le mot de passe (bcrypt) |

#### Farmer — `/api/farmer/**` (rôle: Farmer)
| Méthode | Path | Description |
|---------|------|-------------|
| GET | `/api/farmer/scan/{rfidCode}` | Scanner un animal par RFID (vérif propriété) |
| GET | `/api/farmer/animals` | Liste des animaux de l'éleveur |
| POST | `/api/farmer/animals` | Créer un animal |
| PUT | `/api/farmer/animals/{id}` | Modifier un animal |
| DELETE | `/api/farmer/animals/{id}` | Supprimer un animal |

#### Vet — `/api/vet/**` (rôle: Veterinarian)
| Méthode | Path | Description |
|---------|------|-------------|
| GET | `/api/vet/farms` | Liste toutes fermes avec comptage animaux |
| GET | `/api/vet/farm/{farmId}/animals` | Animaux d'une ferme |
| GET | `/api/vet/scan/{rfidCode}` | Scanner animal + historique médical complet |
| POST | `/api/vet/health-record` | Ajouter dossier médical (vaccination, traitement…) |

#### Inspection — `/api/inspection/**` (rôle: Inspector)
| Méthode | Path | Description |
|---------|------|-------------|
| POST | `/api/inspection/verify-scan` | Comparer tags UHF scannés vs animaux enregistrés |
| POST | `/api/inspection/confirm` | Confirmer le bilan d'inventaire (crée inspection officielle) |
| POST | `/api/inspection/declare` | Déclarer un constat terrain |
| GET | `/api/inspection/list` | Liste toutes les inspections |
| GET | `/api/inspection/my` | Inspections de l'inspecteur connecté |
| POST | `/api/inspection/{inspectionId}/images` | Upload photos d'inspection (Multer) |

#### Utilitaire
| Méthode | Path | Description |
|---------|------|-------------|
| GET | `/health` | Health check |

### 11.3 Middleware & Sécurité

- **JWT Auth** : Validation token, extraction user/rôle, expiration 24h
- **RBAC** : `requireRole()` par endpoint
- **bcryptjs** : Hashage mots de passe (10 rounds de sel)
- **CORS** : Activé globalement
- **Multer** : Upload multi-part pour photos d'inspection

### 11.4 Logique métier notable

**verifyScan (InspectionController)** — Vérification inventaire UHF :
1. Reçoit liste de tags RFID scannés en UHF longue portée
2. Croise avec les animaux enregistrés sur la ferme
3. Retourne : nb enregistrés, nb scannés, tags inconnus, tags manquants, flag cohérence

**register (AuthController)** — Auto-création ferme :
- Si rôle = Farmer → création automatique d'une ferme liée au compte à l'inscription

### 11.5 Configuration

| Paramètre | Valeur |
|-----------|--------|
| **Port** | `8000` |
| **Base de données** | `dz_cheptel_db_1` (MySQL, localhost:3306) |
| **JWT expiration** | 24 heures |
| **Swagger UI** | `http://localhost:8000/api-docs` |
| **Upload** | `uploads/` (local filesystem) |

---

## 12. ARCHITECTURE GLOBALE DU SYSTÈME

```
┌─────────────────────────────────────────────────────────────────┐
│                     DZCheptel — Système Complet                 │
├───────────────────┬─────────────────────┬───────────────────────┤
│   Interface Admin │  Application Mobile │   Interface Éleveur   │
│   (Vue.js 3 Web)  │  (Flutter Mobile)   │  (à implémenter)      │
│   Port: 5173      │  Android/iOS/Win    │                       │
│   "SECTION KAMI"  │  "frontend_app"     │                       │
├───────────────────┴─────────────────────┴───────────────────────┤
│                           APIs REST                             │
├───────────────────────────┬─────────────────────────────────────┤
│  Backend Spring Boot      │  Backend Node.js/Express            │
│  (Java, Port: 8080)       │  (Port: 8000)                       │
│  "backend/"               │  "backend_app/"                     │
│  Rôles: Admin, Farmer,    │  Rôles: Farmer, Veterinarian,       │
│  Vet, Inspector           │  Inspector                          │
├───────────────────────────┴─────────────────────────────────────┤
│                    MySQL (localhost:3306)                        │
│  dz_cheptel_db (Spring)  │  dz_cheptel_db_1 (Node.js)          │
└─────────────────────────────────────────────────────────────────┘
```

### Deux backends distincts

| Aspect | Spring Boot (`backend/`) | Node.js (`backend_app/`) |
|--------|--------------------------|--------------------------|
| **Langage** | Java | JavaScript (Node.js) |
| **Port** | 8080 | 8000 |
| **Base de données** | `dz_cheptel_db` | `dz_cheptel_db_1` |
| **Rôles couverts** | 4 rôles (Admin, Farmer, Vet, Inspector) | 3 rôles (Farmer, Vet, Inspector) |
| **Périmètre** | CRUD complet + audit + fraude | Opérations terrain (scan, santé, inspection) |
| **Auth** | JWT HS256 dynamique | JWT jsonwebtoken fixe |
| **Swagger** | `localhost:8080/swagger-ui.html` | `localhost:8000/api-docs` |

### Deux frontends distincts

| Aspect | Vue.js (`SECTION KAMI/`) | Flutter (`frontend_app/`) |
|--------|--------------------------|---------------------------|
| **Type** | Application web admin | Application mobile terrain |
| **Utilisateurs** | Administrateurs | Farmers, Vétérinaires, Inspecteurs |
| **Connectivité** | Toujours en ligne | Offline-first (SQLite) |
| **Scan** | Pas de scan RFID | Scanner RFID + UHF + NFC |
| **Backend cible** | Spring Boot (8080) | Node.js (8000) |

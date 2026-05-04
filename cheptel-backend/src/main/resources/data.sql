-- ============================================================
-- BASE DE DONNÉES CHEPTEL — VERSION FINALE
-- Compatible avec le code Spring Boot existant
-- Normalisée 3FN — Méthode Merise
-- ============================================================

DROP DATABASE IF EXISTS cheptel_db;

CREATE DATABASE cheptel_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE cheptel_db;

-- ============================================================
-- 1. TABLE OWNERS (Propriétaires)
-- ============================================================
CREATE TABLE owners (
                        id BIGINT AUTO_INCREMENT PRIMARY KEY,
                        full_name VARCHAR(150) NOT NULL,
                        phone VARCHAR(20),
                        email VARCHAR(150),
                        address VARCHAR(255),
                        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        INDEX idx_owners_email (email),
                        INDEX idx_owners_phone (phone)
);

-- ============================================================
-- 2. TABLE FARMS (Fermes)
-- ============================================================
CREATE TABLE farms (
                       id BIGINT AUTO_INCREMENT PRIMARY KEY,
                       name VARCHAR(150) NOT NULL,
                       location VARCHAR(255),
                       wilaya VARCHAR(100),
                       commune VARCHAR(100),
                       latitude DOUBLE,
                       longitude DOUBLE,
                       surface_area DECIMAL(10,2),
                       owner_id BIGINT NOT NULL,
                       created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                       updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                       FOREIGN KEY (owner_id) REFERENCES owners(id),
                       INDEX idx_farms_owner (owner_id),
                       INDEX idx_farms_wilaya (wilaya)
);

-- ============================================================
-- 3. TABLE USERS (Utilisateurs - login)
-- ============================================================
CREATE TABLE users (
                       id BIGINT AUTO_INCREMENT PRIMARY KEY,
                       username VARCHAR(50) UNIQUE NOT NULL,
                       password VARCHAR(255) NOT NULL,
                       email VARCHAR(150) UNIQUE,
                       phone_number VARCHAR(20) UNIQUE,
                       role ENUM('ADMIN', 'FERMIER', 'VETERINAIRE', 'CONTROLEUR') NOT NULL,
                       farm_id BIGINT,
                       enabled BOOLEAN DEFAULT TRUE,
                       last_login DATETIME,
                       created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                       updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                       FOREIGN KEY (farm_id) REFERENCES farms(id),
                       INDEX idx_users_email (email),
                       INDEX idx_users_role (role),
                       INDEX idx_users_farm (farm_id)
);

-- ============================================================
-- 4. TABLE ANIMALS (Animaux)
-- ============================================================
CREATE TABLE animals (
                         id BIGINT AUTO_INCREMENT PRIMARY KEY,
                         rfid_tag VARCHAR(64) UNIQUE NOT NULL,
                         qr_code VARCHAR(100) UNIQUE,
                         species ENUM('OVIN', 'BOVIN', 'CAPRIN', 'EQUIN') NOT NULL,
                         breed VARCHAR(100),
                         gender ENUM('MALE', 'FEMALE') NOT NULL,
                         weight DOUBLE,
                         color VARCHAR(50),
                         birth_date DATE,
                         status ENUM('ACTIVE', 'SOLD', 'QUARANTINED', 'LOST', 'DEAD', 'SLAUGHTERED') NOT NULL DEFAULT 'ACTIVE',
                         reproduction_status ENUM('NONE', 'IN_HEAT', 'PREGNANT', 'LACTATING', 'CASTRATED') DEFAULT 'NONE',
                         farm_id BIGINT NOT NULL,
                         mother_id BIGINT,
                         father_id BIGINT,
                         is_active BOOLEAN DEFAULT TRUE,
                         archived_at DATETIME,
                         created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                         updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                         FOREIGN KEY (farm_id) REFERENCES farms(id),
                         FOREIGN KEY (mother_id) REFERENCES animals(id) ON DELETE SET NULL,
                         FOREIGN KEY (father_id) REFERENCES animals(id) ON DELETE SET NULL,
                         INDEX idx_animals_rfid (rfid_tag),
                         INDEX idx_animals_farm (farm_id),
                         INDEX idx_animals_status (status),
                         INDEX idx_animals_species (species)
);

-- ============================================================
-- 5. TABLE VACCINATIONS
-- ============================================================
CREATE TABLE vaccinations (
                              id BIGINT AUTO_INCREMENT PRIMARY KEY,
                              animal_id BIGINT NOT NULL,
                              vaccine_name VARCHAR(150) NOT NULL,
                              vaccine_type VARCHAR(50),
                              manufacturer VARCHAR(100),
                              batch_number VARCHAR(50),
                              vaccination_date DATE NOT NULL,
                              expiration_date DATE,
                              next_vaccination_date DATE,
                              veterinarian_id BIGINT,
                              notes TEXT,
                              created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                              FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE,
                              FOREIGN KEY (veterinarian_id) REFERENCES users(id),
                              INDEX idx_vacc_animal (animal_id),
                              INDEX idx_vacc_date (vaccination_date)
);

-- ============================================================
-- 6. TABLE HEALTH_RECORDS (Dossiers médicaux)
-- ============================================================
CREATE TABLE health_records (
                                id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                animal_id BIGINT NOT NULL,
                                record_type ENUM('VACCINATION', 'TREATMENT', 'DISEASE', 'CHECKUP', 'SURGERY', 'LAB_TEST', 'INJURY') NOT NULL,
                                diagnosis VARCHAR(500),
                                symptoms TEXT,
                                treatment TEXT,
                                veterinarian_id BIGINT,
                                visit_date DATETIME NOT NULL,
                                next_visit_date DATETIME,
                                is_resolved BOOLEAN DEFAULT FALSE,
                                severity ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'LOW',
                                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE,
                                FOREIGN KEY (veterinarian_id) REFERENCES users(id),
                                INDEX idx_health_animal (animal_id),
                                INDEX idx_health_date (visit_date),
                                INDEX idx_health_type (record_type)
);

-- ============================================================
-- 7. TABLE ANIMAL_EVENTS (Cycle de vie)
-- ============================================================
CREATE TABLE animal_events (
                               id BIGINT AUTO_INCREMENT PRIMARY KEY,
                               animal_id BIGINT NOT NULL,
                               event_type ENUM(
        'BIRTH', 'PURCHASE', 'SALE', 'TRANSFER',
        'LOSS', 'THEFT', 'SLAUGHTER', 'DEATH',
        'VACCINATION', 'CHECKUP',
        'TAG_ASSIGNED', 'TAG_DEACTIVATED'
    ) NOT NULL,
                               event_date DATETIME NOT NULL,
                               latitude DOUBLE,
                               longitude DOUBLE,
                               location VARCHAR(255),
                               performed_by BIGINT,
                               notes TEXT,
                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                               FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE,
                               FOREIGN KEY (performed_by) REFERENCES users(id),
                               INDEX idx_event_animal (animal_id),
                               INDEX idx_event_date (event_date),
                               INDEX idx_event_type (event_type)
);

-- ============================================================
-- 8. TABLE MOVEMENTS (Mouvements / Transferts d'animaux)
-- NOUVELLE TABLE - Pour le suivi vente/achat/transfert
-- ============================================================
CREATE TABLE movements (
                           id BIGINT AUTO_INCREMENT PRIMARY KEY,
                           animal_id BIGINT NOT NULL,
                           movement_type ENUM('PURCHASE', 'SALE', 'TRANSFER', 'BIRTH', 'SLAUGHTER', 'DEATH') NOT NULL,
                           from_farm_id BIGINT,
                           to_farm_id BIGINT,
                           movement_date DATETIME NOT NULL,
                           price DECIMAL(12,2),
                           counterparty_name VARCHAR(150),
                           counterparty_phone VARCHAR(20),
                           document_reference VARCHAR(100),
                           latitude DOUBLE,
                           longitude DOUBLE,
                           performed_by BIGINT NOT NULL,
                           notes TEXT,
                           created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                           FOREIGN KEY (animal_id) REFERENCES animals(id),
                           FOREIGN KEY (from_farm_id) REFERENCES farms(id),
                           FOREIGN KEY (to_farm_id) REFERENCES farms(id),
                           FOREIGN KEY (performed_by) REFERENCES users(id),
                           INDEX idx_mov_animal (animal_id),
                           INDEX idx_mov_date (movement_date),
                           INDEX idx_mov_type (movement_type)
);

-- ============================================================
-- 9. TABLE REPRODUCTIONS (Suivi reproductif)
-- NOUVELLE TABLE - Pour le module reproduction du vétérinaire
-- ============================================================
CREATE TABLE reproductions (
                               id BIGINT AUTO_INCREMENT PRIMARY KEY,
                               female_id BIGINT NOT NULL,
                               male_id BIGINT,
                               breeding_date DATE NOT NULL,
                               expected_birth_date DATE,
                               actual_birth_date DATE,
                               offspring_count INT DEFAULT 0,
                               status ENUM('IN_PROGRESS', 'SUCCESSFUL', 'FAILED', 'ABORTED') DEFAULT 'IN_PROGRESS',
                               veterinarian_id BIGINT,
                               notes TEXT,
                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                               updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                               FOREIGN KEY (female_id) REFERENCES animals(id),
                               FOREIGN KEY (male_id) REFERENCES animals(id),
                               FOREIGN KEY (veterinarian_id) REFERENCES users(id),
                               INDEX idx_repro_female (female_id),
                               INDEX idx_repro_date (breeding_date),
                               INDEX idx_repro_status (status)
);

-- ============================================================
-- 10. TABLE HEALTH_ALERTS (Alertes sanitaires automatiques)
-- NOUVELLE TABLE - Pour les rappels de vaccination
-- ============================================================
CREATE TABLE health_alerts (
                               id BIGINT AUTO_INCREMENT PRIMARY KEY,
                               animal_id BIGINT NOT NULL,
                               alert_type ENUM('VACCINATION_DUE', 'CHECKUP_DUE', 'TREATMENT_FOLLOWUP', 'PREGNANCY_CHECK') NOT NULL,
                               message VARCHAR(500),
                               due_date DATE NOT NULL,
                               is_resolved BOOLEAN DEFAULT FALSE,
                               severity ENUM('INFO', 'WARNING', 'CRITICAL') DEFAULT 'WARNING',
                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                               resolved_at DATETIME,
                               FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE,
                               INDEX idx_alert_due (due_date),
                               INDEX idx_alert_resolved (is_resolved),
                               INDEX idx_alert_animal (animal_id)
);

-- ============================================================
-- 11. TABLE CONTROL_SESSIONS
-- ============================================================
CREATE TABLE control_sessions (
                                  id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                  controleur_id BIGINT NOT NULL,
                                  farm_id BIGINT NOT NULL,
                                  expected_count INT NOT NULL DEFAULT 0,
                                  detected_count INT NOT NULL DEFAULT 0,
                                  missing_count INT NOT NULL DEFAULT 0,
                                  unknown_count INT NOT NULL DEFAULT 0,
                                  started_at DATETIME NOT NULL,
                                  ended_at DATETIME,
                                  result VARCHAR(50),
                                  latitude DOUBLE,
                                  longitude DOUBLE,
                                  FOREIGN KEY (controleur_id) REFERENCES users(id),
                                  FOREIGN KEY (farm_id) REFERENCES farms(id),
                                  INDEX idx_ctrl_farm (farm_id),
                                  INDEX idx_ctrl_date (started_at)
);

-- ============================================================
-- 12. TABLE CONTROL_SESSION_SCANNED_TAGS (existante)
-- ============================================================
CREATE TABLE control_session_scanned_tags (
                                              session_id BIGINT NOT NULL,
                                              rfid_tag VARCHAR(64) NOT NULL,
                                              is_recognized BOOLEAN DEFAULT FALSE,
                                              scanned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                              PRIMARY KEY (session_id, rfid_tag),
                                              FOREIGN KEY (session_id) REFERENCES control_sessions(id) ON DELETE CASCADE
);

-- ============================================================
-- 13. TABLE CONSTATS
-- ============================================================
CREATE TABLE constats (
                          id BIGINT AUTO_INCREMENT PRIMARY KEY,
                          controleur_id BIGINT NOT NULL,
                          farm_id BIGINT,
                          control_session_id BIGINT,
                          type ENUM('FRAUDE', 'MANQUANT', 'DOUBLON', 'AUTRE') NOT NULL,
                          description TEXT NOT NULL,
                          latitude DOUBLE,
                          longitude DOUBLE,
                          localisation_text VARCHAR(255),
                          photo_url VARCHAR(500),
                          voice_memo_url VARCHAR(500),
                          document_url VARCHAR(500),
                          status ENUM('PENDING', 'IN_REVIEW', 'RESOLVED', 'REJECTED') DEFAULT 'PENDING',
                          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                          resolved_at DATETIME,
                          FOREIGN KEY (controleur_id) REFERENCES users(id),
                          FOREIGN KEY (farm_id) REFERENCES farms(id),
                          FOREIGN KEY (control_session_id) REFERENCES control_sessions(id),
                          INDEX idx_constat_status (status),
                          INDEX idx_constat_date (created_at),
                          INDEX idx_constat_farm (farm_id)
);

-- ============================================================
-- 14. TABLE SYNC_RECORDS (Pour le mode hors ligne mobile)
-- NOUVELLE TABLE - Synchronisation
-- ============================================================
CREATE TABLE sync_records (
                              id BIGINT AUTO_INCREMENT PRIMARY KEY,
                              user_id BIGINT,
                              entity_type VARCHAR(50) NOT NULL,
                              entity_id BIGINT NOT NULL,
                              action ENUM('CREATE', 'UPDATE', 'DELETE') NOT NULL,
                              data_json TEXT,
                              synced_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                              FOREIGN KEY (user_id) REFERENCES users(id),
                              INDEX idx_sync_user (user_id),
                              INDEX idx_sync_entity (entity_type, entity_id),
                              INDEX idx_sync_date (synced_at)
);


-- ============================================================
-- VUES UTILES
-- ============================================================

-- Vue : Statistiques par ferme (pour dashboard fermier)
CREATE VIEW v_farm_statistics AS
SELECT
    f.id AS farm_id,
    f.name AS farm_name,
    COUNT(a.id) AS total_animals,
    SUM(CASE WHEN a.status = 'ACTIVE' THEN 1 ELSE 0 END) AS active_count,
    SUM(CASE WHEN a.status = 'SOLD' THEN 1 ELSE 0 END) AS sold_count,
    SUM(CASE WHEN a.status = 'DEAD' THEN 1 ELSE 0 END) AS dead_count,
    SUM(CASE WHEN a.status = 'SLAUGHTERED' THEN 1 ELSE 0 END) AS slaughtered_count,
    SUM(CASE WHEN a.species = 'OVIN' THEN 1 ELSE 0 END) AS ovin_count,
    SUM(CASE WHEN a.species = 'BOVIN' THEN 1 ELSE 0 END) AS bovin_count
FROM farms f
         LEFT JOIN animals a ON f.id = a.farm_id AND a.is_active = TRUE
GROUP BY f.id, f.name;

-- Vue : Animaux nécessitant un vaccin (pour alertes)
CREATE VIEW v_pending_vaccinations AS
SELECT
    a.id AS animal_id,
    a.rfid_tag,
    a.species,
    a.farm_id,
    f.name AS farm_name,
    v.next_vaccination_date,
    DATEDIFF(v.next_vaccination_date, CURDATE()) AS days_remaining
FROM animals a
         JOIN farms f ON a.farm_id = f.id
         JOIN vaccinations v ON v.animal_id = a.id
WHERE v.next_vaccination_date IS NOT NULL
  AND v.next_vaccination_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
  AND a.is_active = TRUE
  AND a.status = 'ACTIVE';


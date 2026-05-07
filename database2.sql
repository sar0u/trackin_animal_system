-- ================================================================
-- dz_cheptel_db_1 — Bootstrap complet
-- Tables · Index · Triggers métier · Triggers audit · Données de test
-- ================================================================

DROP DATABASE IF EXISTS dz_cheptel_db_1;
CREATE DATABASE dz_cheptel_db_1
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE dz_cheptel_db_1;

-- ================================================================
-- TABLES
-- ================================================================

CREATE TABLE IF NOT EXISTS users (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(100) NOT NULL UNIQUE,
    email         VARCHAR(191) NOT NULL UNIQUE,
    password      VARCHAR(255) NOT NULL,
    first_name    VARCHAR(100) NOT NULL,
    last_name     VARCHAR(100) NOT NULL,
    phone         VARCHAR(20),
    role          ENUM('Administrator','Veterinarian','Farmer','Inspector') NOT NULL,
    is_active     BOOLEAN DEFAULT false,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS farms (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    owner_id    BIGINT NOT NULL,
    name        VARCHAR(150) NOT NULL,
    location    VARCHAR(255),
    latitude    DECIMAL(10,8),
    longitude   DECIMAL(11,8),
    capacity    INT DEFAULT 0,
    status      ENUM('Active','Suspended','Closed') DEFAULT 'Active',
    is_verified BOOLEAN DEFAULT FALSE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_farms_owner FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_farms_owner_id ON farms(owner_id);

CREATE TABLE IF NOT EXISTS rfid_tags (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    rfid_code   VARCHAR(100) NOT NULL UNIQUE,
    tag_type    ENUM('UHF','NFC') DEFAULT 'UHF',
    tag_status  ENUM('InStock','Assigned','Defective','Lost') DEFAULT 'InStock',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS animals (
    id                   BIGINT AUTO_INCREMENT PRIMARY KEY,
    rfid_tag_id          BIGINT UNIQUE,
    owner_id             BIGINT NOT NULL,
    farm_id              BIGINT NOT NULL,
    species              ENUM('Ovin','Bovin','Caprin','Autre') NOT NULL,
    breed                VARCHAR(100),
    gender               ENUM('Male','Female','Unknown') DEFAULT 'Unknown',
    birth_date           DATE,
    birth_place          VARCHAR(100),
    acquisition_place    VARCHAR(100),
    weight               DECIMAL(10,2),
    origin_type          ENUM('Born','Purchased','Imported') DEFAULT 'Born',
    life_status          ENUM('Active','Sold','Lost','Dead','Slaughtered') DEFAULT 'Active',
    health_status        ENUM('Healthy','UnderTreatment','Critical','Quarantined') DEFAULT 'Healthy',
    mother_id            BIGINT,
    father_id            BIGINT,
    notes                TEXT,
    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_animals_rfid   FOREIGN KEY (rfid_tag_id) REFERENCES rfid_tags(id) ON DELETE SET NULL,
    CONSTRAINT fk_animals_owner  FOREIGN KEY (owner_id)    REFERENCES users(id)     ON DELETE RESTRICT,
    CONSTRAINT fk_animals_farm   FOREIGN KEY (farm_id)     REFERENCES farms(id)     ON DELETE RESTRICT,
    CONSTRAINT fk_animals_mother FOREIGN KEY (mother_id)   REFERENCES animals(id)   ON DELETE SET NULL,
    CONSTRAINT fk_animals_father FOREIGN KEY (father_id)   REFERENCES animals(id)   ON DELETE SET NULL,
    CONSTRAINT chk_positive_weight CHECK (weight IS NULL OR weight > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_animals_owner_id    ON animals(owner_id);
CREATE INDEX idx_animals_farm_id     ON animals(farm_id);
CREATE INDEX idx_animals_mother_id   ON animals(mother_id);
CREATE INDEX idx_animals_father_id   ON animals(father_id);
CREATE INDEX idx_animals_rfid_tag_id ON animals(rfid_tag_id);
CREATE INDEX idx_animals_life_status ON animals(life_status);

CREATE TABLE IF NOT EXISTS movements (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    animal_id       BIGINT NOT NULL,
    from_farm_id    BIGINT NOT NULL,
    to_farm_id      BIGINT NOT NULL,
    reason          VARCHAR(255),
    treated_by     BIGINT,
    approval_status ENUM('Pending','Approved','Rejected') DEFAULT 'Pending',
    notes           TEXT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_movements_animal      FOREIGN KEY (animal_id)    REFERENCES animals(id) ON DELETE RESTRICT,
    CONSTRAINT fk_movements_from_farm   FOREIGN KEY (from_farm_id) REFERENCES farms(id)   ON DELETE RESTRICT,
    CONSTRAINT fk_movements_to_farm     FOREIGN KEY (to_farm_id)   REFERENCES farms(id)   ON DELETE RESTRICT,
    CONSTRAINT fk_movements_treated_by FOREIGN KEY (treated_by)  REFERENCES users(id)   ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_movements_animal_id    ON movements(animal_id);
CREATE INDEX idx_movements_from_farm_id ON movements(from_farm_id);
CREATE INDEX idx_movements_to_farm_id   ON movements(to_farm_id);
CREATE INDEX idx_movements_treated_by  ON movements(treated_by);
CREATE INDEX idx_movements_approval     ON movements(approval_status);

CREATE TABLE IF NOT EXISTS health_records (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    animal_id        BIGINT NOT NULL,
    veterinarian_id  BIGINT,
    record_type      ENUM('Vaccination','Treatment','Disease','Checkup','Surgery','LabTest','Injury') NOT NULL,
    diagnosis        TEXT,
    symptoms         TEXT,
    treatment_plan   TEXT,
    visit_date       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    next_visit_date  DATE,
    is_validated     BOOLEAN DEFAULT FALSE,
    notes            TEXT,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_health_records_animal       FOREIGN KEY (animal_id)       REFERENCES animals(id) ON DELETE RESTRICT,
    CONSTRAINT fk_health_records_veterinarian FOREIGN KEY (veterinarian_id) REFERENCES users(id)   ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_health_records_animal_id       ON health_records(animal_id);
CREATE INDEX idx_health_records_veterinarian_id ON health_records(veterinarian_id);
CREATE INDEX idx_health_records_record_type     ON health_records(record_type);

CREATE TABLE IF NOT EXISTS vaccinations (
    id                BIGINT AUTO_INCREMENT PRIMARY KEY,
    health_record_id  BIGINT NOT NULL,
    vaccine_name      VARCHAR(100) NOT NULL,
    vaccine_type      VARCHAR(50),
    manufacturer      VARCHAR(100),
    batch_number      VARCHAR(50),
    dose              VARCHAR(50),
    expiration_date   DATE,
    next_dose_date    DATE,
    administered_by   BIGINT,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vaccinations_health_record   FOREIGN KEY (health_record_id) REFERENCES health_records(id) ON DELETE CASCADE,
    CONSTRAINT fk_vaccinations_administered_by FOREIGN KEY (administered_by)  REFERENCES users(id)          ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_vaccinations_health_record_id ON vaccinations(health_record_id);
CREATE INDEX idx_vaccinations_administered_by  ON vaccinations(administered_by);
CREATE INDEX idx_vaccinations_next_dose_date   ON vaccinations(next_dose_date);

CREATE TABLE IF NOT EXISTS subsidies (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    animal_id     BIGINT,
    amount        DECIMAL(12,2) NOT NULL,
    subsidy_type  VARCHAR(100),
    status        ENUM('Pending','Approved','Rejected','Paid') DEFAULT 'Pending',
    request_date  DATE,
    approved_date DATE,
    paid_date     DATE,
    treated_by   BIGINT,
    notes         TEXT,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_subsidies_animal      FOREIGN KEY (animal_id)   REFERENCES animals(id) ON DELETE RESTRICT,
    CONSTRAINT fk_subsidies_treated_by FOREIGN KEY (treated_by) REFERENCES users(id)   ON DELETE SET NULL,
    CONSTRAINT chk_subsidy_amount CHECK (amount > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_subsidies_animal_id   ON subsidies(animal_id);
CREATE INDEX idx_subsidies_treated_by ON subsidies(treated_by);
CREATE INDEX idx_subsidies_status      ON subsidies(status);

CREATE TABLE IF NOT EXISTS notifications (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id    BIGINT NOT NULL,
    title      VARCHAR(200) NOT NULL,
    body       TEXT,
    type       ENUM('Alert','Reminder','Warning','Info') DEFAULT 'Info',
    is_read    BOOLEAN DEFAULT FALSE,
    animal_id  BIGINT,
    farm_id    BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user   FOREIGN KEY (user_id)   REFERENCES users(id)   ON DELETE CASCADE,
    CONSTRAINT fk_notifications_animal FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE SET NULL,
    CONSTRAINT fk_notifications_farm   FOREIGN KEY (farm_id)   REFERENCES farms(id)   ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_notifications_user_id   ON notifications(user_id);
CREATE INDEX idx_notifications_animal_id ON notifications(animal_id);
CREATE INDEX idx_notifications_farm_id   ON notifications(farm_id);
CREATE INDEX idx_notifications_is_read   ON notifications(is_read);

CREATE TABLE IF NOT EXISTS audit_logs (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT,
    action      VARCHAR(255) NOT NULL,
    entity_type VARCHAR(50),
    entity_id   BIGINT,
    old_values  JSON,
    new_values  JSON,
    details     TEXT,
    ip_address  VARCHAR(45),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_logs_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_audit_logs_user_id    ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity     ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);


CREATE TABLE IF NOT EXISTS control_sessions (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    controller_id    BIGINT NOT NULL,
    farm_id          BIGINT NOT NULL,
    expected_count   INT NOT NULL DEFAULT 0,
    started_at       DATETIME NOT NULL,
    ended_at         DATETIME,
    result           ENUM('CONFORME','NON_CONFORME','EN_COURS') DEFAULT 'EN_COURS',
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_control_sessions_controller FOREIGN KEY (controller_id) REFERENCES users(id)  ON DELETE RESTRICT,
    CONSTRAINT fk_control_sessions_farm       FOREIGN KEY (farm_id)       REFERENCES farms(id)  ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_control_sessions_controller_id ON control_sessions(controller_id);
CREATE INDEX idx_control_sessions_farm_id       ON control_sessions(farm_id);
CREATE INDEX idx_control_sessions_started_at    ON control_sessions(started_at);

CREATE TABLE IF NOT EXISTS control_session_scanned_tags (
    session_id   BIGINT NOT NULL,
    rfid_tag     VARCHAR(100) NOT NULL,
    is_recognized BOOLEAN DEFAULT FALSE,
    scanned_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (session_id, rfid_tag),
    CONSTRAINT fk_csst_session FOREIGN KEY (session_id) REFERENCES control_sessions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS constats (
    id                   BIGINT AUTO_INCREMENT PRIMARY KEY,
    control_session_id   BIGINT,
    type                 ENUM('FRAUDE','MANQUANT','DOUBLON','AUTRE') NOT NULL,
    description          TEXT NOT NULL,
    status               ENUM('PENDING','IN_REVIEW','RESOLVED','REJECTED') DEFAULT 'PENDING',
    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at          TIMESTAMP NULL,
    CONSTRAINT fk_constats_control_session  FOREIGN KEY (control_session_id) REFERENCES control_sessions(id)  ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_constats_status           ON constats(status);
CREATE INDEX idx_constats_created_at       ON constats(created_at);

CREATE TABLE IF NOT EXISTS constat_images (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    constat_id  BIGINT NOT NULL,
    image_url   VARCHAR(500) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_constat_images_constat FOREIGN KEY (constat_id) REFERENCES constats(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_constat_images_constat ON constat_images(constat_id);

CREATE TABLE IF NOT EXISTS reproductions (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    female_id           BIGINT NOT NULL,
    male_id             BIGINT,
    breeding_date       DATE NOT NULL,
    expected_birth_date DATE,
    actual_birth_date   DATE,
    offspring_count     INT DEFAULT 0,
    status              ENUM('IN_PROGRESS','SUCCESSFUL','FAILED','ABORTED') DEFAULT 'IN_PROGRESS',
    veterinarian_id     BIGINT,
    notes               TEXT,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_reproductions_female FOREIGN KEY (female_id)       REFERENCES animals(id) ON DELETE RESTRICT,
    CONSTRAINT fk_reproductions_male   FOREIGN KEY (male_id)         REFERENCES animals(id) ON DELETE SET NULL,
    CONSTRAINT fk_reproductions_vet    FOREIGN KEY (veterinarian_id) REFERENCES users(id)   ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_reproductions_female_id    ON reproductions(female_id);
CREATE INDEX idx_reproductions_breeding_date ON reproductions(breeding_date);
CREATE INDEX idx_reproductions_status       ON reproductions(status);

CREATE TABLE IF NOT EXISTS sanitary_campaigns (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(150) NOT NULL,
    description    TEXT,
    vaccine_name   VARCHAR(150),
    target_species ENUM('Ovin','Bovin','Caprin','Autre','All') DEFAULT 'All',
    start_date     DATE NOT NULL,
    end_date       DATE NOT NULL,
    status         ENUM('Planned','Active','Completed','Cancelled') DEFAULT 'Planned',
    created_by     BIGINT,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_sanitary_campaigns_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_sanitary_campaigns_status ON sanitary_campaigns(status);
CREATE INDEX idx_sanitary_campaigns_dates  ON sanitary_campaigns(start_date, end_date);

CREATE TABLE IF NOT EXISTS campaign_participations (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    campaign_id      BIGINT NOT NULL,
    animal_id        BIGINT NOT NULL,
    veterinarian_id  BIGINT,
    vaccination_date DATE,
    status           ENUM('Pending','Done','Refused') DEFAULT 'Pending',
    notes            TEXT,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_campaign_animal (campaign_id, animal_id),
    CONSTRAINT fk_camp_part_campaign FOREIGN KEY (campaign_id)     REFERENCES sanitary_campaigns(id) ON DELETE CASCADE,
    CONSTRAINT fk_camp_part_animal   FOREIGN KEY (animal_id)       REFERENCES animals(id)            ON DELETE RESTRICT,
    CONSTRAINT fk_camp_part_vet      FOREIGN KEY (veterinarian_id) REFERENCES users(id)              ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sync_records (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT,
    entity_type VARCHAR(50) NOT NULL,
    entity_id   BIGINT NOT NULL,
    action      ENUM('CREATE','UPDATE','DELETE') NOT NULL,
    data_json   TEXT,
    synced_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sync_records_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_sync_records_user_id    ON sync_records(user_id);
CREATE INDEX idx_sync_records_entity     ON sync_records(entity_type, entity_id);
CREATE INDEX idx_sync_records_synced_at  ON sync_records(synced_at);

CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id    BIGINT NOT NULL,
    contact    VARCHAR(150) NOT NULL,
    code_hash  VARCHAR(255) NOT NULL,
    used       BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL,
    CONSTRAINT fk_password_reset_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_password_reset_contact    ON password_reset_tokens(contact);
CREATE INDEX idx_password_reset_user_id    ON password_reset_tokens(user_id);
CREATE INDEX idx_password_reset_used       ON password_reset_tokens(used);
CREATE INDEX idx_password_reset_expires_at ON password_reset_tokens(expires_at);

-- ================================================================
-- TRIGGERS MÉTIER (8)
-- ================================================================
DELIMITER //

DROP TRIGGER IF EXISTS after_animal_status_update//
CREATE TRIGGER after_animal_status_update AFTER UPDATE ON animals FOR EACH ROW
BEGIN
    IF NEW.life_status IN ('Dead','Sold','Slaughtered') AND OLD.rfid_tag_id IS NOT NULL THEN
        UPDATE rfid_tags SET tag_status = 'InStock' WHERE id = OLD.rfid_tag_id;
    END IF;
END//

DROP TRIGGER IF EXISTS after_animal_insert//
CREATE TRIGGER after_animal_insert AFTER INSERT ON animals FOR EACH ROW
BEGIN
    IF NEW.rfid_tag_id IS NOT NULL THEN
        UPDATE rfid_tags SET tag_status = 'Assigned' WHERE id = NEW.rfid_tag_id;
    END IF;
END//

DROP TRIGGER IF EXISTS after_animal_tag_update//
CREATE TRIGGER after_animal_tag_update AFTER UPDATE ON animals FOR EACH ROW
BEGIN
    IF NOT (OLD.rfid_tag_id <=> NEW.rfid_tag_id) THEN
        IF OLD.rfid_tag_id IS NOT NULL THEN
            UPDATE rfid_tags SET tag_status = 'InStock' WHERE id = OLD.rfid_tag_id;
        END IF;
        IF NEW.rfid_tag_id IS NOT NULL THEN
            UPDATE rfid_tags SET tag_status = 'Assigned' WHERE id = NEW.rfid_tag_id;
        END IF;
    END IF;
END//


DROP TRIGGER IF EXISTS before_movement_insert//
CREATE TRIGGER before_movement_insert BEFORE INSERT ON movements FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(50);
    SELECT life_status INTO v_status FROM animals WHERE id = NEW.animal_id;
    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Opération refusée : animal introuvable.';
    END IF;
    IF v_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Opération refusée : impossible de déplacer un animal non actif.';
    END IF;
    IF NEW.from_farm_id = NEW.to_farm_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Opération refusée : la ferme de départ et d\'arrivée doivent être différentes.';
    END IF;
END//

DROP TRIGGER IF EXISTS after_movement_approved//
CREATE TRIGGER after_movement_approved AFTER UPDATE ON movements FOR EACH ROW
BEGIN
    IF OLD.approval_status <> NEW.approval_status AND NEW.approval_status = 'Approved' THEN
        UPDATE animals SET farm_id = NEW.to_farm_id WHERE id = NEW.animal_id;
    END IF;
END//

DROP TRIGGER IF EXISTS before_animal_insert_tag_check//
CREATE TRIGGER before_animal_insert_tag_check BEFORE INSERT ON animals FOR EACH ROW
BEGIN
    DECLARE v_tag_status VARCHAR(50);
    IF NEW.birth_date IS NOT NULL AND NEW.birth_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Opération refusée : la date de naissance ne peut pas être dans le futur.';
    END IF;
    IF NEW.rfid_tag_id IS NOT NULL THEN
        SELECT tag_status INTO v_tag_status FROM rfid_tags WHERE id = NEW.rfid_tag_id;
        IF v_tag_status IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Opération refusée : tag RFID introuvable.';
        END IF;
        IF v_tag_status <> 'InStock' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Opération refusée : tag RFID non disponible (défectueux, perdu ou déjà assigné).';
        END IF;
    END IF;
END//

DROP TRIGGER IF EXISTS before_animal_update_tag_check//
CREATE TRIGGER before_animal_update_tag_check BEFORE UPDATE ON animals FOR EACH ROW
BEGIN
    DECLARE v_tag_status VARCHAR(50);
    IF NEW.birth_date IS NOT NULL AND NEW.birth_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Opération refusée : la date de naissance ne peut pas être dans le futur.';
    END IF;
    IF NEW.rfid_tag_id IS NOT NULL AND NOT (OLD.rfid_tag_id <=> NEW.rfid_tag_id) THEN
        SELECT tag_status INTO v_tag_status FROM rfid_tags WHERE id = NEW.rfid_tag_id;
        IF v_tag_status IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Opération refusée : tag RFID introuvable.';
        END IF;
        IF v_tag_status <> 'InStock' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Opération refusée : tag RFID non disponible.';
        END IF;
    END IF;
END//

DELIMITER ;

-- ================================================================
-- TRIGGERS AUDIT (48) — générés par database/audit_triggers/generate.py
-- Pour régénérer : python database/audit_triggers/generate.py
-- ================================================================
-- ============================================================================
-- Audit triggers — DO NOT EDIT BY HAND.
-- Generated from manifest.yaml by generate.py.
-- Re-run after editing the manifest:
--     python generate.py
--
-- Idempotent: every CREATE is preceded by DROP TRIGGER IF EXISTS.
-- ============================================================================

-- ----- users (User) -----

DROP TRIGGER IF EXISTS audit_users_insert;
DELIMITER //
CREATE TRIGGER audit_users_insert AFTER INSERT ON users FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'User',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id', NEW.id,
            'username', NEW.username,
            'email', NEW.email,
            'first_name', NEW.first_name,
            'last_name', NEW.last_name,
            'phone', NEW.phone,
            'role', NEW.role,
            'is_active', NEW.is_active,
            'created_at', NEW.created_at,
            'updated_at', NEW.updated_at
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_users_update;
DELIMITER //
CREATE TRIGGER audit_users_update AFTER UPDATE ON users FOR EACH ROW
BEGIN
    DECLARE v_old JSON DEFAULT JSON_OBJECT();
    DECLARE v_new JSON DEFAULT JSON_OBJECT();
    DECLARE v_changed TINYINT DEFAULT 0;

    IF NOT (OLD.username <=> NEW.username) THEN
        SET v_old = JSON_SET(v_old, '$.username', OLD.username),
            v_new = JSON_SET(v_new, '$.username', NEW.username),
            v_changed = 1;
    END IF;
    IF NOT (OLD.email <=> NEW.email) THEN
        SET v_old = JSON_SET(v_old, '$.email', OLD.email),
            v_new = JSON_SET(v_new, '$.email', NEW.email),
            v_changed = 1;
    END IF;
    IF NOT (OLD.first_name <=> NEW.first_name) THEN
        SET v_old = JSON_SET(v_old, '$.first_name', OLD.first_name),
            v_new = JSON_SET(v_new, '$.first_name', NEW.first_name),
            v_changed = 1;
    END IF;
    IF NOT (OLD.last_name <=> NEW.last_name) THEN
        SET v_old = JSON_SET(v_old, '$.last_name', OLD.last_name),
            v_new = JSON_SET(v_new, '$.last_name', NEW.last_name),
            v_changed = 1;
    END IF;
    IF NOT (OLD.phone <=> NEW.phone) THEN
        SET v_old = JSON_SET(v_old, '$.phone', OLD.phone),
            v_new = JSON_SET(v_new, '$.phone', NEW.phone),
            v_changed = 1;
    END IF;
    IF NOT (OLD.role <=> NEW.role) THEN
        SET v_old = JSON_SET(v_old, '$.role', OLD.role),
            v_new = JSON_SET(v_new, '$.role', NEW.role),
            v_changed = 1;
    END IF;
    IF NOT (OLD.is_active <=> NEW.is_active) THEN
        SET v_old = JSON_SET(v_old, '$.is_active', OLD.is_active),
            v_new = JSON_SET(v_new, '$.is_active', NEW.is_active),
            v_changed = 1;
    END IF;
    IF NOT (OLD.password <=> NEW.password) THEN
        SET v_old = JSON_SET(v_old, '$.password_changed', FALSE),
            v_new = JSON_SET(v_new, '$.password_changed', TRUE),
            v_changed = 1;
    END IF;

    IF v_changed = 1 THEN
        SET v_old = JSON_SET(v_old, '$.updated_at', OLD.updated_at),
            v_new = JSON_SET(v_new, '$.updated_at', NEW.updated_at);

        INSERT INTO audit_logs
            (user_id, action, entity_type, entity_id,
             old_values, new_values, details, ip_address, created_at)
        VALUES (
            @audit_user_id,
            'UPDATE',
            'User',
            NEW.id,
            v_old,
            v_new,
            '',
            COALESCE(@audit_ip, 'SYSTEM'),
            NOW(6)
        );
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_users_delete;
DELIMITER //
CREATE TRIGGER audit_users_delete AFTER DELETE ON users FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'User',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'username', OLD.username,
            'email', OLD.email,
            'first_name', OLD.first_name,
            'last_name', OLD.last_name,
            'phone', OLD.phone,
            'role', OLD.role,
            'is_active', OLD.is_active,
            'created_at', OLD.created_at,
            'updated_at', OLD.updated_at
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ----- farms (Farm) -----

DROP TRIGGER IF EXISTS audit_farms_insert;
DELIMITER //
CREATE TRIGGER audit_farms_insert AFTER INSERT ON farms FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'Farm',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id', NEW.id,
            'owner_id', NEW.owner_id,
            'name', NEW.name,
            'location', NEW.location,
            'latitude', NEW.latitude,
            'longitude', NEW.longitude,
            'capacity', NEW.capacity,
            'status', NEW.status,
            'is_verified', NEW.is_verified,
            'created_at', NEW.created_at,
            'updated_at', NEW.updated_at
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_farms_update;
DELIMITER //
CREATE TRIGGER audit_farms_update AFTER UPDATE ON farms FOR EACH ROW
BEGIN
    DECLARE v_old JSON DEFAULT JSON_OBJECT();
    DECLARE v_new JSON DEFAULT JSON_OBJECT();
    DECLARE v_changed TINYINT DEFAULT 0;

    IF NOT (OLD.owner_id <=> NEW.owner_id) THEN
        SET v_old = JSON_SET(v_old, '$.owner_id', OLD.owner_id),
            v_new = JSON_SET(v_new, '$.owner_id', NEW.owner_id),
            v_changed = 1;
    END IF;
    IF NOT (OLD.name <=> NEW.name) THEN
        SET v_old = JSON_SET(v_old, '$.name', OLD.name),
            v_new = JSON_SET(v_new, '$.name', NEW.name),
            v_changed = 1;
    END IF;
    IF NOT (OLD.location <=> NEW.location) THEN
        SET v_old = JSON_SET(v_old, '$.location', OLD.location),
            v_new = JSON_SET(v_new, '$.location', NEW.location),
            v_changed = 1;
    END IF;
    IF NOT (OLD.latitude <=> NEW.latitude) THEN
        SET v_old = JSON_SET(v_old, '$.latitude', OLD.latitude),
            v_new = JSON_SET(v_new, '$.latitude', NEW.latitude),
            v_changed = 1;
    END IF;
    IF NOT (OLD.longitude <=> NEW.longitude) THEN
        SET v_old = JSON_SET(v_old, '$.longitude', OLD.longitude),
            v_new = JSON_SET(v_new, '$.longitude', NEW.longitude),
            v_changed = 1;
    END IF;
    IF NOT (OLD.capacity <=> NEW.capacity) THEN
        SET v_old = JSON_SET(v_old, '$.capacity', OLD.capacity),
            v_new = JSON_SET(v_new, '$.capacity', NEW.capacity),
            v_changed = 1;
    END IF;
    IF NOT (OLD.status <=> NEW.status) THEN
        SET v_old = JSON_SET(v_old, '$.status', OLD.status),
            v_new = JSON_SET(v_new, '$.status', NEW.status),
            v_changed = 1;
    END IF;
    IF NOT (OLD.is_verified <=> NEW.is_verified) THEN
        SET v_old = JSON_SET(v_old, '$.is_verified', OLD.is_verified),
            v_new = JSON_SET(v_new, '$.is_verified', NEW.is_verified),
            v_changed = 1;
    END IF;

    IF v_changed = 1 THEN
        SET v_old = JSON_SET(v_old, '$.updated_at', OLD.updated_at),
            v_new = JSON_SET(v_new, '$.updated_at', NEW.updated_at);

        INSERT INTO audit_logs
            (user_id, action, entity_type, entity_id,
             old_values, new_values, details, ip_address, created_at)
        VALUES (
            @audit_user_id,
            'UPDATE',
            'Farm',
            NEW.id,
            v_old,
            v_new,
            '',
            COALESCE(@audit_ip, 'SYSTEM'),
            NOW(6)
        );
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_farms_delete;
DELIMITER //
CREATE TRIGGER audit_farms_delete AFTER DELETE ON farms FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'Farm',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'owner_id', OLD.owner_id,
            'name', OLD.name,
            'location', OLD.location,
            'latitude', OLD.latitude,
            'longitude', OLD.longitude,
            'capacity', OLD.capacity,
            'status', OLD.status,
            'is_verified', OLD.is_verified,
            'created_at', OLD.created_at,
            'updated_at', OLD.updated_at
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ----- rfid_tags (RfidTag) -----

DROP TRIGGER IF EXISTS audit_rfid_tags_insert;
DELIMITER //
CREATE TRIGGER audit_rfid_tags_insert AFTER INSERT ON rfid_tags FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'RfidTag',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id', NEW.id,
            'rfid_code', NEW.rfid_code,
            'tag_type', NEW.tag_type,
            'tag_status', NEW.tag_status,
            'created_at', NEW.created_at
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_rfid_tags_update;
DELIMITER //
CREATE TRIGGER audit_rfid_tags_update AFTER UPDATE ON rfid_tags FOR EACH ROW
BEGIN
    DECLARE v_old JSON DEFAULT JSON_OBJECT();
    DECLARE v_new JSON DEFAULT JSON_OBJECT();
    DECLARE v_changed TINYINT DEFAULT 0;

    IF NOT (OLD.rfid_code <=> NEW.rfid_code) THEN
        SET v_old = JSON_SET(v_old, '$.rfid_code', OLD.rfid_code),
            v_new = JSON_SET(v_new, '$.rfid_code', NEW.rfid_code),
            v_changed = 1;
    END IF;
    IF NOT (OLD.tag_type <=> NEW.tag_type) THEN
        SET v_old = JSON_SET(v_old, '$.tag_type', OLD.tag_type),
            v_new = JSON_SET(v_new, '$.tag_type', NEW.tag_type),
            v_changed = 1;
    END IF;
    IF NOT (OLD.tag_status <=> NEW.tag_status) THEN
        SET v_old = JSON_SET(v_old, '$.tag_status', OLD.tag_status),
            v_new = JSON_SET(v_new, '$.tag_status', NEW.tag_status),
            v_changed = 1;
    END IF;

    IF v_changed = 1 THEN
        INSERT INTO audit_logs
            (user_id, action, entity_type, entity_id,
             old_values, new_values, details, ip_address, created_at)
        VALUES (
            @audit_user_id,
            'UPDATE',
            'RfidTag',
            NEW.id,
            v_old,
            v_new,
            '',
            COALESCE(@audit_ip, 'SYSTEM'),
            NOW(6)
        );
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_rfid_tags_delete;
DELIMITER //
CREATE TRIGGER audit_rfid_tags_delete AFTER DELETE ON rfid_tags FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'RfidTag',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'rfid_code', OLD.rfid_code,
            'tag_type', OLD.tag_type,
            'tag_status', OLD.tag_status,
            'created_at', OLD.created_at
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ----- animals (Animal) -----

DROP TRIGGER IF EXISTS audit_animals_insert;
DELIMITER //
CREATE TRIGGER audit_animals_insert AFTER INSERT ON animals FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'Animal',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id', NEW.id,
            'rfid_tag_id', NEW.rfid_tag_id,
            'owner_id', NEW.owner_id,
            'farm_id', NEW.farm_id,
            'species', NEW.species,
            'breed', NEW.breed,
            'gender', NEW.gender,
            'birth_date', NEW.birth_date,
            'birth_place', NEW.birth_place,
            'acquisition_place', NEW.acquisition_place,
            'weight', NEW.weight,
            'origin_type', NEW.origin_type,
            'life_status', NEW.life_status,
            'health_status', NEW.health_status,
            'mother_id', NEW.mother_id,
            'father_id', NEW.father_id,
            'notes', NEW.notes,
            'created_at', NEW.created_at,
            'updated_at', NEW.updated_at
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_animals_update;
DELIMITER //
CREATE TRIGGER audit_animals_update AFTER UPDATE ON animals FOR EACH ROW
BEGIN
    DECLARE v_old JSON DEFAULT JSON_OBJECT();
    DECLARE v_new JSON DEFAULT JSON_OBJECT();
    DECLARE v_changed TINYINT DEFAULT 0;

    IF NOT (OLD.rfid_tag_id <=> NEW.rfid_tag_id) THEN
        SET v_old = JSON_SET(v_old, '$.rfid_tag_id', OLD.rfid_tag_id),
            v_new = JSON_SET(v_new, '$.rfid_tag_id', NEW.rfid_tag_id),
            v_changed = 1;
    END IF;
    IF NOT (OLD.owner_id <=> NEW.owner_id) THEN
        SET v_old = JSON_SET(v_old, '$.owner_id', OLD.owner_id),
            v_new = JSON_SET(v_new, '$.owner_id', NEW.owner_id),
            v_changed = 1;
    END IF;
    IF NOT (OLD.farm_id <=> NEW.farm_id) THEN
        SET v_old = JSON_SET(v_old, '$.farm_id', OLD.farm_id),
            v_new = JSON_SET(v_new, '$.farm_id', NEW.farm_id),
            v_changed = 1;
    END IF;
    IF NOT (OLD.species <=> NEW.species) THEN
        SET v_old = JSON_SET(v_old, '$.species', OLD.species),
            v_new = JSON_SET(v_new, '$.species', NEW.species),
            v_changed = 1;
    END IF;
    IF NOT (OLD.breed <=> NEW.breed) THEN
        SET v_old = JSON_SET(v_old, '$.breed', OLD.breed),
            v_new = JSON_SET(v_new, '$.breed', NEW.breed),
            v_changed = 1;
    END IF;
    IF NOT (OLD.gender <=> NEW.gender) THEN
        SET v_old = JSON_SET(v_old, '$.gender', OLD.gender),
            v_new = JSON_SET(v_new, '$.gender', NEW.gender),
            v_changed = 1;
    END IF;
    IF NOT (OLD.birth_date <=> NEW.birth_date) THEN
        SET v_old = JSON_SET(v_old, '$.birth_date', OLD.birth_date),
            v_new = JSON_SET(v_new, '$.birth_date', NEW.birth_date),
            v_changed = 1;
    END IF;
    IF NOT (OLD.birth_place <=> NEW.birth_place) THEN
        SET v_old = JSON_SET(v_old, '$.birth_place', OLD.birth_place),
            v_new = JSON_SET(v_new, '$.birth_place', NEW.birth_place),
            v_changed = 1;
    END IF;
    IF NOT (OLD.acquisition_place <=> NEW.acquisition_place) THEN
        SET v_old = JSON_SET(v_old, '$.acquisition_place', OLD.acquisition_place),
            v_new = JSON_SET(v_new, '$.acquisition_place', NEW.acquisition_place),
            v_changed = 1;
    END IF;
    IF NOT (OLD.weight <=> NEW.weight) THEN
        SET v_old = JSON_SET(v_old, '$.weight', OLD.weight),
            v_new = JSON_SET(v_new, '$.weight', NEW.weight),
            v_changed = 1;
    END IF;
    IF NOT (OLD.origin_type <=> NEW.origin_type) THEN
        SET v_old = JSON_SET(v_old, '$.origin_type', OLD.origin_type),
            v_new = JSON_SET(v_new, '$.origin_type', NEW.origin_type),
            v_changed = 1;
    END IF;
    IF NOT (OLD.life_status <=> NEW.life_status) THEN
        SET v_old = JSON_SET(v_old, '$.life_status', OLD.life_status),
            v_new = JSON_SET(v_new, '$.life_status', NEW.life_status),
            v_changed = 1;
    END IF;
    IF NOT (OLD.health_status <=> NEW.health_status) THEN
        SET v_old = JSON_SET(v_old, '$.health_status', OLD.health_status),
            v_new = JSON_SET(v_new, '$.health_status', NEW.health_status),
            v_changed = 1;
    END IF;
    IF NOT (OLD.mother_id <=> NEW.mother_id) THEN
        SET v_old = JSON_SET(v_old, '$.mother_id', OLD.mother_id),
            v_new = JSON_SET(v_new, '$.mother_id', NEW.mother_id),
            v_changed = 1;
    END IF;
    IF NOT (OLD.father_id <=> NEW.father_id) THEN
        SET v_old = JSON_SET(v_old, '$.father_id', OLD.father_id),
            v_new = JSON_SET(v_new, '$.father_id', NEW.father_id),
            v_changed = 1;
    END IF;
    IF NOT (OLD.notes <=> NEW.notes) THEN
        SET v_old = JSON_SET(v_old, '$.notes', OLD.notes),
            v_new = JSON_SET(v_new, '$.notes', NEW.notes),
            v_changed = 1;
    END IF;

    IF v_changed = 1 THEN
        SET v_old = JSON_SET(v_old, '$.updated_at', OLD.updated_at),
            v_new = JSON_SET(v_new, '$.updated_at', NEW.updated_at);

        INSERT INTO audit_logs
            (user_id, action, entity_type, entity_id,
             old_values, new_values, details, ip_address, created_at)
        VALUES (
            @audit_user_id,
            'UPDATE',
            'Animal',
            NEW.id,
            v_old,
            v_new,
            '',
            COALESCE(@audit_ip, 'SYSTEM'),
            NOW(6)
        );
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_animals_delete;
DELIMITER //
CREATE TRIGGER audit_animals_delete AFTER DELETE ON animals FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'Animal',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'rfid_tag_id', OLD.rfid_tag_id,
            'owner_id', OLD.owner_id,
            'farm_id', OLD.farm_id,
            'species', OLD.species,
            'breed', OLD.breed,
            'gender', OLD.gender,
            'birth_date', OLD.birth_date,
            'birth_place', OLD.birth_place,
            'acquisition_place', OLD.acquisition_place,
            'weight', OLD.weight,
            'origin_type', OLD.origin_type,
            'life_status', OLD.life_status,
            'health_status', OLD.health_status,
            'mother_id', OLD.mother_id,
            'father_id', OLD.father_id,
            'notes', OLD.notes,
            'created_at', OLD.created_at,
            'updated_at', OLD.updated_at
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ----- movements (Movement) -----

DROP TRIGGER IF EXISTS audit_movements_insert;
DELIMITER //
CREATE TRIGGER audit_movements_insert AFTER INSERT ON movements FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'Movement',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id', NEW.id,
            'animal_id', NEW.animal_id,
            'from_farm_id', NEW.from_farm_id,
            'to_farm_id', NEW.to_farm_id,
            'reason', NEW.reason,
            'treated_by', NEW.treated_by,
            'approval_status', NEW.approval_status,
            'notes', NEW.notes,
            'created_at', NEW.created_at
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_movements_update;
DELIMITER //
CREATE TRIGGER audit_movements_update AFTER UPDATE ON movements FOR EACH ROW
BEGIN
    DECLARE v_old JSON DEFAULT JSON_OBJECT();
    DECLARE v_new JSON DEFAULT JSON_OBJECT();
    DECLARE v_changed TINYINT DEFAULT 0;

    IF NOT (OLD.animal_id <=> NEW.animal_id) THEN
        SET v_old = JSON_SET(v_old, '$.animal_id', OLD.animal_id),
            v_new = JSON_SET(v_new, '$.animal_id', NEW.animal_id),
            v_changed = 1;
    END IF;
    IF NOT (OLD.from_farm_id <=> NEW.from_farm_id) THEN
        SET v_old = JSON_SET(v_old, '$.from_farm_id', OLD.from_farm_id),
            v_new = JSON_SET(v_new, '$.from_farm_id', NEW.from_farm_id),
            v_changed = 1;
    END IF;
    IF NOT (OLD.to_farm_id <=> NEW.to_farm_id) THEN
        SET v_old = JSON_SET(v_old, '$.to_farm_id', OLD.to_farm_id),
            v_new = JSON_SET(v_new, '$.to_farm_id', NEW.to_farm_id),
            v_changed = 1;
    END IF;
    IF NOT (OLD.reason <=> NEW.reason) THEN
        SET v_old = JSON_SET(v_old, '$.reason', OLD.reason),
            v_new = JSON_SET(v_new, '$.reason', NEW.reason),
            v_changed = 1;
    END IF;
    IF NOT (OLD.treated_by <=> NEW.treated_by) THEN
        SET v_old = JSON_SET(v_old, '$.treated_by', OLD.treated_by),
            v_new = JSON_SET(v_new, '$.treated_by', NEW.treated_by),
            v_changed = 1;
    END IF;
    IF NOT (OLD.approval_status <=> NEW.approval_status) THEN
        SET v_old = JSON_SET(v_old, '$.approval_status', OLD.approval_status),
            v_new = JSON_SET(v_new, '$.approval_status', NEW.approval_status),
            v_changed = 1;
    END IF;
    IF NOT (OLD.notes <=> NEW.notes) THEN
        SET v_old = JSON_SET(v_old, '$.notes', OLD.notes),
            v_new = JSON_SET(v_new, '$.notes', NEW.notes),
            v_changed = 1;
    END IF;

    IF v_changed = 1 THEN
        INSERT INTO audit_logs
            (user_id, action, entity_type, entity_id,
             old_values, new_values, details, ip_address, created_at)
        VALUES (
            @audit_user_id,
            'UPDATE',
            'Movement',
            NEW.id,
            v_old,
            v_new,
            '',
            COALESCE(@audit_ip, 'SYSTEM'),
            NOW(6)
        );
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_movements_delete;
DELIMITER //
CREATE TRIGGER audit_movements_delete AFTER DELETE ON movements FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'Movement',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'animal_id', OLD.animal_id,
            'from_farm_id', OLD.from_farm_id,
            'to_farm_id', OLD.to_farm_id,
            'reason', OLD.reason,
            'treated_by', OLD.treated_by,
            'approval_status', OLD.approval_status,
            'notes', OLD.notes,
            'created_at', OLD.created_at
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ----- health_records (HealthRecord) -----

DROP TRIGGER IF EXISTS audit_health_records_insert;
DELIMITER //
CREATE TRIGGER audit_health_records_insert AFTER INSERT ON health_records FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'HealthRecord',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id', NEW.id,
            'animal_id', NEW.animal_id,
            'veterinarian_id', NEW.veterinarian_id,
            'record_type', NEW.record_type,
            'diagnosis', NEW.diagnosis,
            'symptoms', NEW.symptoms,
            'treatment_plan', NEW.treatment_plan,
            'visit_date', NEW.visit_date,
            'next_visit_date', NEW.next_visit_date,
            'is_validated', NEW.is_validated,
            'notes', NEW.notes,
            'created_at', NEW.created_at,
            'updated_at', NEW.updated_at
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_health_records_update;
DELIMITER //
CREATE TRIGGER audit_health_records_update AFTER UPDATE ON health_records FOR EACH ROW
BEGIN
    DECLARE v_old JSON DEFAULT JSON_OBJECT();
    DECLARE v_new JSON DEFAULT JSON_OBJECT();
    DECLARE v_changed TINYINT DEFAULT 0;

    IF NOT (OLD.animal_id <=> NEW.animal_id) THEN
        SET v_old = JSON_SET(v_old, '$.animal_id', OLD.animal_id),
            v_new = JSON_SET(v_new, '$.animal_id', NEW.animal_id),
            v_changed = 1;
    END IF;
    IF NOT (OLD.veterinarian_id <=> NEW.veterinarian_id) THEN
        SET v_old = JSON_SET(v_old, '$.veterinarian_id', OLD.veterinarian_id),
            v_new = JSON_SET(v_new, '$.veterinarian_id', NEW.veterinarian_id),
            v_changed = 1;
    END IF;
    IF NOT (OLD.record_type <=> NEW.record_type) THEN
        SET v_old = JSON_SET(v_old, '$.record_type', OLD.record_type),
            v_new = JSON_SET(v_new, '$.record_type', NEW.record_type),
            v_changed = 1;
    END IF;
    IF NOT (OLD.diagnosis <=> NEW.diagnosis) THEN
        SET v_old = JSON_SET(v_old, '$.diagnosis', OLD.diagnosis),
            v_new = JSON_SET(v_new, '$.diagnosis', NEW.diagnosis),
            v_changed = 1;
    END IF;
    IF NOT (OLD.symptoms <=> NEW.symptoms) THEN
        SET v_old = JSON_SET(v_old, '$.symptoms', OLD.symptoms),
            v_new = JSON_SET(v_new, '$.symptoms', NEW.symptoms),
            v_changed = 1;
    END IF;
    IF NOT (OLD.treatment_plan <=> NEW.treatment_plan) THEN
        SET v_old = JSON_SET(v_old, '$.treatment_plan', OLD.treatment_plan),
            v_new = JSON_SET(v_new, '$.treatment_plan', NEW.treatment_plan),
            v_changed = 1;
    END IF;
    IF NOT (OLD.visit_date <=> NEW.visit_date) THEN
        SET v_old = JSON_SET(v_old, '$.visit_date', OLD.visit_date),
            v_new = JSON_SET(v_new, '$.visit_date', NEW.visit_date),
            v_changed = 1;
    END IF;
    IF NOT (OLD.next_visit_date <=> NEW.next_visit_date) THEN
        SET v_old = JSON_SET(v_old, '$.next_visit_date', OLD.next_visit_date),
            v_new = JSON_SET(v_new, '$.next_visit_date', NEW.next_visit_date),
            v_changed = 1;
    END IF;
    IF NOT (OLD.is_validated <=> NEW.is_validated) THEN
        SET v_old = JSON_SET(v_old, '$.is_validated', OLD.is_validated),
            v_new = JSON_SET(v_new, '$.is_validated', NEW.is_validated),
            v_changed = 1;
    END IF;
    IF NOT (OLD.notes <=> NEW.notes) THEN
        SET v_old = JSON_SET(v_old, '$.notes', OLD.notes),
            v_new = JSON_SET(v_new, '$.notes', NEW.notes),
            v_changed = 1;
    END IF;

    IF v_changed = 1 THEN
        SET v_old = JSON_SET(v_old, '$.updated_at', OLD.updated_at),
            v_new = JSON_SET(v_new, '$.updated_at', NEW.updated_at);

        INSERT INTO audit_logs
            (user_id, action, entity_type, entity_id,
             old_values, new_values, details, ip_address, created_at)
        VALUES (
            @audit_user_id,
            'UPDATE',
            'HealthRecord',
            NEW.id,
            v_old,
            v_new,
            '',
            COALESCE(@audit_ip, 'SYSTEM'),
            NOW(6)
        );
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_health_records_delete;
DELIMITER //
CREATE TRIGGER audit_health_records_delete AFTER DELETE ON health_records FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'HealthRecord',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'animal_id', OLD.animal_id,
            'veterinarian_id', OLD.veterinarian_id,
            'record_type', OLD.record_type,
            'diagnosis', OLD.diagnosis,
            'symptoms', OLD.symptoms,
            'treatment_plan', OLD.treatment_plan,
            'visit_date', OLD.visit_date,
            'next_visit_date', OLD.next_visit_date,
            'is_validated', OLD.is_validated,
            'notes', OLD.notes,
            'created_at', OLD.created_at,
            'updated_at', OLD.updated_at
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ----- vaccinations (Vaccination) -----

DROP TRIGGER IF EXISTS audit_vaccinations_insert;
DELIMITER //
CREATE TRIGGER audit_vaccinations_insert AFTER INSERT ON vaccinations FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'Vaccination',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id', NEW.id,
            'health_record_id', NEW.health_record_id,
            'vaccine_name', NEW.vaccine_name,
            'vaccine_type', NEW.vaccine_type,
            'manufacturer', NEW.manufacturer,
            'batch_number', NEW.batch_number,
            'dose', NEW.dose,
            'expiration_date', NEW.expiration_date,
            'next_dose_date', NEW.next_dose_date,
            'administered_by', NEW.administered_by,
            'created_at', NEW.created_at
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_vaccinations_update;
DELIMITER //
CREATE TRIGGER audit_vaccinations_update AFTER UPDATE ON vaccinations FOR EACH ROW
BEGIN
    DECLARE v_old JSON DEFAULT JSON_OBJECT();
    DECLARE v_new JSON DEFAULT JSON_OBJECT();
    DECLARE v_changed TINYINT DEFAULT 0;

    IF NOT (OLD.health_record_id <=> NEW.health_record_id) THEN
        SET v_old = JSON_SET(v_old, '$.health_record_id', OLD.health_record_id),
            v_new = JSON_SET(v_new, '$.health_record_id', NEW.health_record_id),
            v_changed = 1;
    END IF;
    IF NOT (OLD.vaccine_name <=> NEW.vaccine_name) THEN
        SET v_old = JSON_SET(v_old, '$.vaccine_name', OLD.vaccine_name),
            v_new = JSON_SET(v_new, '$.vaccine_name', NEW.vaccine_name),
            v_changed = 1;
    END IF;
    IF NOT (OLD.vaccine_type <=> NEW.vaccine_type) THEN
        SET v_old = JSON_SET(v_old, '$.vaccine_type', OLD.vaccine_type),
            v_new = JSON_SET(v_new, '$.vaccine_type', NEW.vaccine_type),
            v_changed = 1;
    END IF;
    IF NOT (OLD.manufacturer <=> NEW.manufacturer) THEN
        SET v_old = JSON_SET(v_old, '$.manufacturer', OLD.manufacturer),
            v_new = JSON_SET(v_new, '$.manufacturer', NEW.manufacturer),
            v_changed = 1;
    END IF;
    IF NOT (OLD.batch_number <=> NEW.batch_number) THEN
        SET v_old = JSON_SET(v_old, '$.batch_number', OLD.batch_number),
            v_new = JSON_SET(v_new, '$.batch_number', NEW.batch_number),
            v_changed = 1;
    END IF;
    IF NOT (OLD.dose <=> NEW.dose) THEN
        SET v_old = JSON_SET(v_old, '$.dose', OLD.dose),
            v_new = JSON_SET(v_new, '$.dose', NEW.dose),
            v_changed = 1;
    END IF;
    IF NOT (OLD.expiration_date <=> NEW.expiration_date) THEN
        SET v_old = JSON_SET(v_old, '$.expiration_date', OLD.expiration_date),
            v_new = JSON_SET(v_new, '$.expiration_date', NEW.expiration_date),
            v_changed = 1;
    END IF;
    IF NOT (OLD.next_dose_date <=> NEW.next_dose_date) THEN
        SET v_old = JSON_SET(v_old, '$.next_dose_date', OLD.next_dose_date),
            v_new = JSON_SET(v_new, '$.next_dose_date', NEW.next_dose_date),
            v_changed = 1;
    END IF;
    IF NOT (OLD.administered_by <=> NEW.administered_by) THEN
        SET v_old = JSON_SET(v_old, '$.administered_by', OLD.administered_by),
            v_new = JSON_SET(v_new, '$.administered_by', NEW.administered_by),
            v_changed = 1;
    END IF;

    IF v_changed = 1 THEN
        INSERT INTO audit_logs
            (user_id, action, entity_type, entity_id,
             old_values, new_values, details, ip_address, created_at)
        VALUES (
            @audit_user_id,
            'UPDATE',
            'Vaccination',
            NEW.id,
            v_old,
            v_new,
            '',
            COALESCE(@audit_ip, 'SYSTEM'),
            NOW(6)
        );
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_vaccinations_delete;
DELIMITER //
CREATE TRIGGER audit_vaccinations_delete AFTER DELETE ON vaccinations FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'Vaccination',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'health_record_id', OLD.health_record_id,
            'vaccine_name', OLD.vaccine_name,
            'vaccine_type', OLD.vaccine_type,
            'manufacturer', OLD.manufacturer,
            'batch_number', OLD.batch_number,
            'dose', OLD.dose,
            'expiration_date', OLD.expiration_date,
            'next_dose_date', OLD.next_dose_date,
            'administered_by', OLD.administered_by,
            'created_at', OLD.created_at
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ----- subsidies (Subsidy) -----

DROP TRIGGER IF EXISTS audit_subsidies_insert;
DELIMITER //
CREATE TRIGGER audit_subsidies_insert AFTER INSERT ON subsidies FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'Subsidy',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id', NEW.id,
            'animal_id', NEW.animal_id,
            'amount', NEW.amount,
            'subsidy_type', NEW.subsidy_type,
            'status', NEW.status,
            'request_date', NEW.request_date,
            'approved_date', NEW.approved_date,
            'paid_date', NEW.paid_date,
            'treated_by', NEW.treated_by,
            'notes', NEW.notes,
            'created_at', NEW.created_at,
            'updated_at', NEW.updated_at
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_subsidies_update;
DELIMITER //
CREATE TRIGGER audit_subsidies_update AFTER UPDATE ON subsidies FOR EACH ROW
BEGIN
    DECLARE v_old JSON DEFAULT JSON_OBJECT();
    DECLARE v_new JSON DEFAULT JSON_OBJECT();
    DECLARE v_changed TINYINT DEFAULT 0;

    IF NOT (OLD.animal_id <=> NEW.animal_id) THEN
        SET v_old = JSON_SET(v_old, '$.animal_id', OLD.animal_id),
            v_new = JSON_SET(v_new, '$.animal_id', NEW.animal_id),
            v_changed = 1;
    END IF;
    IF NOT (OLD.amount <=> NEW.amount) THEN
        SET v_old = JSON_SET(v_old, '$.amount', OLD.amount),
            v_new = JSON_SET(v_new, '$.amount', NEW.amount),
            v_changed = 1;
    END IF;
    IF NOT (OLD.subsidy_type <=> NEW.subsidy_type) THEN
        SET v_old = JSON_SET(v_old, '$.subsidy_type', OLD.subsidy_type),
            v_new = JSON_SET(v_new, '$.subsidy_type', NEW.subsidy_type),
            v_changed = 1;
    END IF;
    IF NOT (OLD.status <=> NEW.status) THEN
        SET v_old = JSON_SET(v_old, '$.status', OLD.status),
            v_new = JSON_SET(v_new, '$.status', NEW.status),
            v_changed = 1;
    END IF;
    IF NOT (OLD.request_date <=> NEW.request_date) THEN
        SET v_old = JSON_SET(v_old, '$.request_date', OLD.request_date),
            v_new = JSON_SET(v_new, '$.request_date', NEW.request_date),
            v_changed = 1;
    END IF;
    IF NOT (OLD.approved_date <=> NEW.approved_date) THEN
        SET v_old = JSON_SET(v_old, '$.approved_date', OLD.approved_date),
            v_new = JSON_SET(v_new, '$.approved_date', NEW.approved_date),
            v_changed = 1;
    END IF;
    IF NOT (OLD.paid_date <=> NEW.paid_date) THEN
        SET v_old = JSON_SET(v_old, '$.paid_date', OLD.paid_date),
            v_new = JSON_SET(v_new, '$.paid_date', NEW.paid_date),
            v_changed = 1;
    END IF;
    IF NOT (OLD.treated_by <=> NEW.treated_by) THEN
        SET v_old = JSON_SET(v_old, '$.treated_by', OLD.treated_by),
            v_new = JSON_SET(v_new, '$.treated_by', NEW.treated_by),
            v_changed = 1;
    END IF;
    IF NOT (OLD.notes <=> NEW.notes) THEN
        SET v_old = JSON_SET(v_old, '$.notes', OLD.notes),
            v_new = JSON_SET(v_new, '$.notes', NEW.notes),
            v_changed = 1;
    END IF;

    IF v_changed = 1 THEN
        SET v_old = JSON_SET(v_old, '$.updated_at', OLD.updated_at),
            v_new = JSON_SET(v_new, '$.updated_at', NEW.updated_at);

        INSERT INTO audit_logs
            (user_id, action, entity_type, entity_id,
             old_values, new_values, details, ip_address, created_at)
        VALUES (
            @audit_user_id,
            'UPDATE',
            'Subsidy',
            NEW.id,
            v_old,
            v_new,
            '',
            COALESCE(@audit_ip, 'SYSTEM'),
            NOW(6)
        );
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_subsidies_delete;
DELIMITER //
CREATE TRIGGER audit_subsidies_delete AFTER DELETE ON subsidies FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'Subsidy',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'animal_id', OLD.animal_id,
            'amount', OLD.amount,
            'subsidy_type', OLD.subsidy_type,
            'status', OLD.status,
            'request_date', OLD.request_date,
            'approved_date', OLD.approved_date,
            'paid_date', OLD.paid_date,
            'treated_by', OLD.treated_by,
            'notes', OLD.notes,
            'created_at', OLD.created_at,
            'updated_at', OLD.updated_at
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ----- constats (Constat) -----

DROP TRIGGER IF EXISTS audit_constats_insert;
DELIMITER //
CREATE TRIGGER audit_constats_insert AFTER INSERT ON constats FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'Constat',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id', NEW.id,
            'control_session_id', NEW.control_session_id,
            'type', NEW.type,
            'description', NEW.description,
            'status', NEW.status,
            'created_at', NEW.created_at
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_constats_update;
DELIMITER //
CREATE TRIGGER audit_constats_update AFTER UPDATE ON constats FOR EACH ROW
BEGIN
    DECLARE v_old JSON DEFAULT JSON_OBJECT();
    DECLARE v_new JSON DEFAULT JSON_OBJECT();
    DECLARE v_changed TINYINT DEFAULT 0;

    IF NOT (OLD.type <=> NEW.type) THEN
        SET v_old = JSON_SET(v_old, '$.type', OLD.type),
            v_new = JSON_SET(v_new, '$.type', NEW.type),
            v_changed = 1;
    END IF;
    IF NOT (OLD.description <=> NEW.description) THEN
        SET v_old = JSON_SET(v_old, '$.description', OLD.description),
            v_new = JSON_SET(v_new, '$.description', NEW.description),
            v_changed = 1;
    END IF;
    IF NOT (OLD.status <=> NEW.status) THEN
        SET v_old = JSON_SET(v_old, '$.status', OLD.status),
            v_new = JSON_SET(v_new, '$.status', NEW.status),
            v_changed = 1;
    END IF;
    IF NOT (OLD.resolved_at <=> NEW.resolved_at) THEN
        SET v_old = JSON_SET(v_old, '$.resolved_at', OLD.resolved_at),
            v_new = JSON_SET(v_new, '$.resolved_at', NEW.resolved_at),
            v_changed = 1;
    END IF;


    IF v_changed = 1 THEN
        INSERT INTO audit_logs
            (user_id, action, entity_type, entity_id,
             old_values, new_values, details, ip_address, created_at)
        VALUES (
            @audit_user_id,
            'UPDATE',
            'Constat',
            NEW.id,
            v_old,
            v_new,
            '',
            COALESCE(@audit_ip, 'SYSTEM'),
            NOW(6)
        );
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_constats_delete;
DELIMITER //
CREATE TRIGGER audit_constats_delete AFTER DELETE ON constats FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'Constat',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'control_session_id', OLD.control_session_id,
            'type', OLD.type,
            'description', OLD.description,
            'status', OLD.status,
            'created_at', OLD.created_at
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ----- constat_images (ConstatImage) -----

DROP TRIGGER IF EXISTS audit_constat_images_insert;
DELIMITER //
CREATE TRIGGER audit_constat_images_insert AFTER INSERT ON constat_images FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'ConstatImage',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id', NEW.id,
            'constat_id', NEW.constat_id,
            'image_url', NEW.image_url,
            'uploaded_at', NEW.uploaded_at
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_constat_images_delete;
DELIMITER //
CREATE TRIGGER audit_constat_images_delete AFTER DELETE ON constat_images FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'ConstatImage',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'constat_id', OLD.constat_id,
            'image_url', OLD.image_url,
            'uploaded_at', OLD.uploaded_at
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ----- notifications (Notification) -----

DROP TRIGGER IF EXISTS audit_notifications_insert;
DELIMITER //
CREATE TRIGGER audit_notifications_insert AFTER INSERT ON notifications FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'Notification',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id', NEW.id,
            'user_id', NEW.user_id,
            'title', NEW.title,
            'body', NEW.body,
            'type', NEW.type,
            'is_read', NEW.is_read,
            'animal_id', NEW.animal_id,
            'farm_id', NEW.farm_id,
            'created_at', NEW.created_at
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_notifications_update;
DELIMITER //
CREATE TRIGGER audit_notifications_update AFTER UPDATE ON notifications FOR EACH ROW
BEGIN
    DECLARE v_old JSON DEFAULT JSON_OBJECT();
    DECLARE v_new JSON DEFAULT JSON_OBJECT();
    DECLARE v_changed TINYINT DEFAULT 0;

    IF NOT (OLD.user_id <=> NEW.user_id) THEN
        SET v_old = JSON_SET(v_old, '$.user_id', OLD.user_id),
            v_new = JSON_SET(v_new, '$.user_id', NEW.user_id),
            v_changed = 1;
    END IF;
    IF NOT (OLD.title <=> NEW.title) THEN
        SET v_old = JSON_SET(v_old, '$.title', OLD.title),
            v_new = JSON_SET(v_new, '$.title', NEW.title),
            v_changed = 1;
    END IF;
    IF NOT (OLD.body <=> NEW.body) THEN
        SET v_old = JSON_SET(v_old, '$.body', OLD.body),
            v_new = JSON_SET(v_new, '$.body', NEW.body),
            v_changed = 1;
    END IF;
    IF NOT (OLD.type <=> NEW.type) THEN
        SET v_old = JSON_SET(v_old, '$.type', OLD.type),
            v_new = JSON_SET(v_new, '$.type', NEW.type),
            v_changed = 1;
    END IF;
    IF NOT (OLD.is_read <=> NEW.is_read) THEN
        SET v_old = JSON_SET(v_old, '$.is_read', OLD.is_read),
            v_new = JSON_SET(v_new, '$.is_read', NEW.is_read),
            v_changed = 1;
    END IF;
    IF NOT (OLD.animal_id <=> NEW.animal_id) THEN
        SET v_old = JSON_SET(v_old, '$.animal_id', OLD.animal_id),
            v_new = JSON_SET(v_new, '$.animal_id', NEW.animal_id),
            v_changed = 1;
    END IF;
    IF NOT (OLD.farm_id <=> NEW.farm_id) THEN
        SET v_old = JSON_SET(v_old, '$.farm_id', OLD.farm_id),
            v_new = JSON_SET(v_new, '$.farm_id', NEW.farm_id),
            v_changed = 1;
    END IF;

    IF v_changed = 1 THEN
        INSERT INTO audit_logs
            (user_id, action, entity_type, entity_id,
             old_values, new_values, details, ip_address, created_at)
        VALUES (
            @audit_user_id,
            'UPDATE',
            'Notification',
            NEW.id,
            v_old,
            v_new,
            '',
            COALESCE(@audit_ip, 'SYSTEM'),
            NOW(6)
        );
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_notifications_delete;
DELIMITER //
CREATE TRIGGER audit_notifications_delete AFTER DELETE ON notifications FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'Notification',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'user_id', OLD.user_id,
            'title', OLD.title,
            'body', OLD.body,
            'type', OLD.type,
            'is_read', OLD.is_read,
            'animal_id', OLD.animal_id,
            'farm_id', OLD.farm_id,
            'created_at', OLD.created_at
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;


-- ----- control_sessions (ControlSession) -----

DROP TRIGGER IF EXISTS audit_control_sessions_insert;
DELIMITER //
CREATE TRIGGER audit_control_sessions_insert AFTER INSERT ON control_sessions FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'ControlSession',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id', NEW.id,
            'controller_id', NEW.controller_id,
            'farm_id', NEW.farm_id,
            'expected_count', NEW.expected_count,
            'started_at', NEW.started_at,
            'ended_at', NEW.ended_at,
            'result', NEW.result,
            'created_at', NEW.created_at
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_control_sessions_update;
DELIMITER //
CREATE TRIGGER audit_control_sessions_update AFTER UPDATE ON control_sessions FOR EACH ROW
BEGIN
    DECLARE v_old JSON DEFAULT JSON_OBJECT();
    DECLARE v_new JSON DEFAULT JSON_OBJECT();
    DECLARE v_changed TINYINT DEFAULT 0;

    IF NOT (OLD.result <=> NEW.result) THEN
        SET v_old = JSON_SET(v_old, '$.result', OLD.result),
            v_new = JSON_SET(v_new, '$.result', NEW.result),
            v_changed = 1;
    END IF;
    IF NOT (OLD.ended_at <=> NEW.ended_at) THEN
        SET v_old = JSON_SET(v_old, '$.ended_at', OLD.ended_at),
            v_new = JSON_SET(v_new, '$.ended_at', NEW.ended_at),
            v_changed = 1;
    END IF;
    IF NOT (OLD.expected_count <=> NEW.expected_count) THEN
        SET v_old = JSON_SET(v_old, '$.expected_count', OLD.expected_count),
            v_new = JSON_SET(v_new, '$.expected_count', NEW.expected_count),
            v_changed = 1;
    END IF;

    IF v_changed = 1 THEN
        INSERT INTO audit_logs
            (user_id, action, entity_type, entity_id,
             old_values, new_values, details, ip_address, created_at)
        VALUES (
            @audit_user_id,
            'UPDATE',
            'ControlSession',
            NEW.id,
            v_old,
            v_new,
            '',
            COALESCE(@audit_ip, 'SYSTEM'),
            NOW(6)
        );
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_control_sessions_delete;
DELIMITER //
CREATE TRIGGER audit_control_sessions_delete AFTER DELETE ON control_sessions FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'ControlSession',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'controller_id', OLD.controller_id,
            'farm_id', OLD.farm_id,
            'expected_count', OLD.expected_count,
            'started_at', OLD.started_at,
            'ended_at', OLD.ended_at,
            'result', OLD.result,
            'created_at', OLD.created_at
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ----- control_session_scanned_tags (ScannedTag) -----

DROP TRIGGER IF EXISTS audit_scanned_tags_insert;
DELIMITER //
CREATE TRIGGER audit_scanned_tags_insert AFTER INSERT ON control_session_scanned_tags FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'ScannedTag',
        NEW.session_id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'session_id', NEW.session_id,
            'rfid_tag', NEW.rfid_tag,
            'scanned_at', NEW.scanned_at,
            'is_recognized', NEW.is_recognized
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_scanned_tags_update;
DELIMITER //
CREATE TRIGGER audit_scanned_tags_update AFTER UPDATE ON control_session_scanned_tags FOR EACH ROW
BEGIN
    DECLARE v_old JSON DEFAULT JSON_OBJECT();
    DECLARE v_new JSON DEFAULT JSON_OBJECT();
    DECLARE v_changed TINYINT DEFAULT 0;

    IF NOT (OLD.is_recognized <=> NEW.is_recognized) THEN
        SET v_old = JSON_SET(v_old, '$.is_recognized', OLD.is_recognized),
            v_new = JSON_SET(v_new, '$.is_recognized', NEW.is_recognized),
            v_changed = 1;
    END IF;

    IF v_changed = 1 THEN
        INSERT INTO audit_logs
            (user_id, action, entity_type, entity_id,
             old_values, new_values, details, ip_address, created_at)
        VALUES (
            @audit_user_id,
            'UPDATE',
            'ScannedTag',
            NEW.session_id,
            v_old,
            v_new,
            '',
            COALESCE(@audit_ip, 'SYSTEM'),
            NOW(6)
        );
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_scanned_tags_delete;
DELIMITER //
CREATE TRIGGER audit_scanned_tags_delete AFTER DELETE ON control_session_scanned_tags FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'ScannedTag',
        OLD.session_id,
        JSON_OBJECT(
            'session_id', OLD.session_id,
            'rfid_tag', OLD.rfid_tag,
            'scanned_at', OLD.scanned_at,
            'is_recognized', OLD.is_recognized
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ----- reproductions (Reproduction) -----

DROP TRIGGER IF EXISTS audit_reproductions_insert;
DELIMITER //
CREATE TRIGGER audit_reproductions_insert AFTER INSERT ON reproductions FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'Reproduction',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id', NEW.id,
            'female_id', NEW.female_id,
            'male_id', NEW.male_id,
            'breeding_date', NEW.breeding_date,
            'expected_birth_date', NEW.expected_birth_date,
            'actual_birth_date', NEW.actual_birth_date,
            'offspring_count', NEW.offspring_count,
            'status', NEW.status,
            'veterinarian_id', NEW.veterinarian_id,
            'created_at', NEW.created_at
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_reproductions_update;
DELIMITER //
CREATE TRIGGER audit_reproductions_update AFTER UPDATE ON reproductions FOR EACH ROW
BEGIN
    DECLARE v_old JSON DEFAULT JSON_OBJECT();
    DECLARE v_new JSON DEFAULT JSON_OBJECT();
    DECLARE v_changed TINYINT DEFAULT 0;

    IF NOT (OLD.status <=> NEW.status) THEN
        SET v_old = JSON_SET(v_old, '$.status', OLD.status),
            v_new = JSON_SET(v_new, '$.status', NEW.status),
            v_changed = 1;
    END IF;
    IF NOT (OLD.actual_birth_date <=> NEW.actual_birth_date) THEN
        SET v_old = JSON_SET(v_old, '$.actual_birth_date', OLD.actual_birth_date),
            v_new = JSON_SET(v_new, '$.actual_birth_date', NEW.actual_birth_date),
            v_changed = 1;
    END IF;
    IF NOT (OLD.offspring_count <=> NEW.offspring_count) THEN
        SET v_old = JSON_SET(v_old, '$.offspring_count', OLD.offspring_count),
            v_new = JSON_SET(v_new, '$.offspring_count', NEW.offspring_count),
            v_changed = 1;
    END IF;
    IF NOT (OLD.notes <=> NEW.notes) THEN
        SET v_old = JSON_SET(v_old, '$.notes', OLD.notes),
            v_new = JSON_SET(v_new, '$.notes', NEW.notes),
            v_changed = 1;
    END IF;

    IF v_changed = 1 THEN
        SET v_old = JSON_SET(v_old, '$.updated_at', OLD.updated_at),
            v_new = JSON_SET(v_new, '$.updated_at', NEW.updated_at);
        INSERT INTO audit_logs
            (user_id, action, entity_type, entity_id,
             old_values, new_values, details, ip_address, created_at)
        VALUES (
            @audit_user_id,
            'UPDATE',
            'Reproduction',
            NEW.id,
            v_old,
            v_new,
            '',
            COALESCE(@audit_ip, 'SYSTEM'),
            NOW(6)
        );
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_reproductions_delete;
DELIMITER //
CREATE TRIGGER audit_reproductions_delete AFTER DELETE ON reproductions FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'Reproduction',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'female_id', OLD.female_id,
            'male_id', OLD.male_id,
            'breeding_date', OLD.breeding_date,
            'expected_birth_date', OLD.expected_birth_date,
            'actual_birth_date', OLD.actual_birth_date,
            'offspring_count', OLD.offspring_count,
            'status', OLD.status,
            'veterinarian_id', OLD.veterinarian_id
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ----- sanitary_campaigns (SanitaryCampaign) -----

DROP TRIGGER IF EXISTS audit_sanitary_campaigns_insert;
DELIMITER //
CREATE TRIGGER audit_sanitary_campaigns_insert AFTER INSERT ON sanitary_campaigns FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'SanitaryCampaign',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id', NEW.id,
            'name', NEW.name,
            'vaccine_name', NEW.vaccine_name,
            'target_species', NEW.target_species,
            'start_date', NEW.start_date,
            'end_date', NEW.end_date,
            'status', NEW.status,
            'created_by', NEW.created_by,
            'created_at', NEW.created_at
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_sanitary_campaigns_update;
DELIMITER //
CREATE TRIGGER audit_sanitary_campaigns_update AFTER UPDATE ON sanitary_campaigns FOR EACH ROW
BEGIN
    DECLARE v_old JSON DEFAULT JSON_OBJECT();
    DECLARE v_new JSON DEFAULT JSON_OBJECT();
    DECLARE v_changed TINYINT DEFAULT 0;

    IF NOT (OLD.status <=> NEW.status) THEN
        SET v_old = JSON_SET(v_old, '$.status', OLD.status),
            v_new = JSON_SET(v_new, '$.status', NEW.status),
            v_changed = 1;
    END IF;
    IF NOT (OLD.name <=> NEW.name) THEN
        SET v_old = JSON_SET(v_old, '$.name', OLD.name),
            v_new = JSON_SET(v_new, '$.name', NEW.name),
            v_changed = 1;
    END IF;
    IF NOT (OLD.description <=> NEW.description) THEN
        SET v_old = JSON_SET(v_old, '$.description', OLD.description),
            v_new = JSON_SET(v_new, '$.description', NEW.description),
            v_changed = 1;
    END IF;
    IF NOT (OLD.target_species <=> NEW.target_species) THEN
        SET v_old = JSON_SET(v_old, '$.target_species', OLD.target_species),
            v_new = JSON_SET(v_new, '$.target_species', NEW.target_species),
            v_changed = 1;
    END IF;
    IF NOT (OLD.start_date <=> NEW.start_date) THEN
        SET v_old = JSON_SET(v_old, '$.start_date', OLD.start_date),
            v_new = JSON_SET(v_new, '$.start_date', NEW.start_date),
            v_changed = 1;
    END IF;
    IF NOT (OLD.end_date <=> NEW.end_date) THEN
        SET v_old = JSON_SET(v_old, '$.end_date', OLD.end_date),
            v_new = JSON_SET(v_new, '$.end_date', NEW.end_date),
            v_changed = 1;
    END IF;
    IF NOT (OLD.vaccine_name <=> NEW.vaccine_name) THEN
        SET v_old = JSON_SET(v_old, '$.vaccine_name', OLD.vaccine_name),
            v_new = JSON_SET(v_new, '$.vaccine_name', NEW.vaccine_name),
            v_changed = 1;
    END IF;

    IF v_changed = 1 THEN
        SET v_old = JSON_SET(v_old, '$.updated_at', OLD.updated_at),
            v_new = JSON_SET(v_new, '$.updated_at', NEW.updated_at);
        INSERT INTO audit_logs
            (user_id, action, entity_type, entity_id,
             old_values, new_values, details, ip_address, created_at)
        VALUES (
            @audit_user_id,
            'UPDATE',
            'SanitaryCampaign',
            NEW.id,
            v_old,
            v_new,
            '',
            COALESCE(@audit_ip, 'SYSTEM'),
            NOW(6)
        );
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_sanitary_campaigns_delete;
DELIMITER //
CREATE TRIGGER audit_sanitary_campaigns_delete AFTER DELETE ON sanitary_campaigns FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'SanitaryCampaign',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'name', OLD.name,
            'vaccine_name', OLD.vaccine_name,
            'target_species', OLD.target_species,
            'start_date', OLD.start_date,
            'end_date', OLD.end_date,
            'status', OLD.status,
            'created_by', OLD.created_by
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ----- campaign_participations (CampaignParticipation) -----

DROP TRIGGER IF EXISTS audit_campaign_participations_insert;
DELIMITER //
CREATE TRIGGER audit_campaign_participations_insert AFTER INSERT ON campaign_participations FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'CREATE',
        'CampaignParticipation',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id', NEW.id,
            'campaign_id', NEW.campaign_id,
            'animal_id', NEW.animal_id,
            'veterinarian_id', NEW.veterinarian_id,
            'vaccination_date', NEW.vaccination_date,
            'status', NEW.status,
            'notes', NEW.notes,
            'created_at', NEW.created_at
        ),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_campaign_participations_update;
DELIMITER //
CREATE TRIGGER audit_campaign_participations_update AFTER UPDATE ON campaign_participations FOR EACH ROW
BEGIN
    DECLARE v_old JSON DEFAULT JSON_OBJECT();
    DECLARE v_new JSON DEFAULT JSON_OBJECT();
    DECLARE v_changed TINYINT DEFAULT 0;

    IF NOT (OLD.status <=> NEW.status) THEN
        SET v_old = JSON_SET(v_old, '$.status', OLD.status),
            v_new = JSON_SET(v_new, '$.status', NEW.status),
            v_changed = 1;
    END IF;
    IF NOT (OLD.vaccination_date <=> NEW.vaccination_date) THEN
        SET v_old = JSON_SET(v_old, '$.vaccination_date', OLD.vaccination_date),
            v_new = JSON_SET(v_new, '$.vaccination_date', NEW.vaccination_date),
            v_changed = 1;
    END IF;
    IF NOT (OLD.notes <=> NEW.notes) THEN
        SET v_old = JSON_SET(v_old, '$.notes', OLD.notes),
            v_new = JSON_SET(v_new, '$.notes', NEW.notes),
            v_changed = 1;
    END IF;

    IF v_changed = 1 THEN
        INSERT INTO audit_logs
            (user_id, action, entity_type, entity_id,
             old_values, new_values, details, ip_address, created_at)
        VALUES (
            @audit_user_id,
            'UPDATE',
            'CampaignParticipation',
            NEW.id,
            v_old,
            v_new,
            '',
            COALESCE(@audit_ip, 'SYSTEM'),
            NOW(6)
        );
    END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_campaign_participations_delete;
DELIMITER //
CREATE TRIGGER audit_campaign_participations_delete AFTER DELETE ON campaign_participations FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        @audit_user_id,
        'DELETE',
        'CampaignParticipation',
        OLD.id,
        JSON_OBJECT(
            'id', OLD.id,
            'campaign_id', OLD.campaign_id,
            'animal_id', OLD.animal_id,
            'veterinarian_id', OLD.veterinarian_id,
            'vaccination_date', OLD.vaccination_date,
            'status', OLD.status,
            'notes', OLD.notes
        ),
        JSON_OBJECT(),
        '',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ----- password_reset_tokens -----

DROP TRIGGER IF EXISTS audit_password_reset_insert;
DELIMITER //
CREATE TRIGGER audit_password_reset_insert AFTER INSERT ON password_reset_tokens FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        NEW.user_id,
        'CREATE',
        'PasswordResetToken',
        NEW.id,
        JSON_OBJECT(),
        JSON_OBJECT(
            'id',         NEW.id,
            'user_id',    NEW.user_id,
            'contact',    NEW.contact,
            'used',       NEW.used,
            'expires_at', NEW.expires_at
        ),
        'Password reset token created',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

DROP TRIGGER IF EXISTS audit_password_reset_delete;
DELIMITER //
CREATE TRIGGER audit_password_reset_delete AFTER DELETE ON password_reset_tokens FOR EACH ROW
BEGIN
    INSERT INTO audit_logs
        (user_id, action, entity_type, entity_id,
         old_values, new_values, details, ip_address, created_at)
    VALUES (
        OLD.user_id,
        'DELETE',
        'PasswordResetToken',
        OLD.id,
        JSON_OBJECT(
            'id',         OLD.id,
            'user_id',    OLD.user_id,
            'contact',    OLD.contact,
            'used',       OLD.used,
            'expires_at', OLD.expires_at
        ),
        JSON_OBJECT(),
        'Password reset token deleted/expired',
        COALESCE(@audit_ip, 'SYSTEM'),
        NOW(6)
    );
END//
DELIMITER ;

-- ================================================================
-- VUES
-- ================================================================

CREATE OR REPLACE VIEW v_active_animals AS
SELECT
    a.id,
    a.species,
    a.breed,
    a.gender,
    a.birth_date,
    a.weight,
    a.health_status,
    CONCAT(u.first_name, ' ', u.last_name) AS owner_name,
    f.name AS farm_name,
    f.location AS farm_location,
    rt.rfid_code
FROM animals a
JOIN users u ON u.id = a.owner_id
JOIN farms f ON f.id = a.farm_id
LEFT JOIN rfid_tags rt ON rt.id = a.rfid_tag_id
WHERE a.life_status = 'Active';

CREATE OR REPLACE VIEW v_farm_statistics AS
SELECT
    f.id   AS farm_id,
    f.name AS farm_name,
    COUNT(a.id) AS total_animals,
    SUM(CASE WHEN a.life_status = 'Active'      THEN 1 ELSE 0 END) AS active_count,
    SUM(CASE WHEN a.life_status = 'Sold'        THEN 1 ELSE 0 END) AS sold_count,
    SUM(CASE WHEN a.life_status = 'Dead'        THEN 1 ELSE 0 END) AS dead_count,
    SUM(CASE WHEN a.life_status = 'Slaughtered' THEN 1 ELSE 0 END) AS slaughtered_count,
    SUM(CASE WHEN a.species = 'Ovin'            THEN 1 ELSE 0 END) AS ovin_count,
    SUM(CASE WHEN a.species = 'Bovin'           THEN 1 ELSE 0 END) AS bovin_count,
    SUM(CASE WHEN a.species = 'Caprin'          THEN 1 ELSE 0 END) AS caprin_count
FROM farms f
LEFT JOIN animals a ON f.id = a.farm_id AND a.life_status = 'Active'
GROUP BY f.id, f.name;

CREATE OR REPLACE VIEW v_pending_vaccinations AS
SELECT
    a.id AS animal_id,
    rt.rfid_code,
    a.species,
    a.farm_id,
    f.name AS farm_name,
    v.next_dose_date,
    DATEDIFF(v.next_dose_date, CURDATE()) AS days_remaining
FROM animals a
JOIN farms f ON a.farm_id = f.id
JOIN vaccinations v ON v.health_record_id IN (
    SELECT id FROM health_records WHERE animal_id = a.id
)
LEFT JOIN rfid_tags rt ON rt.id = a.rfid_tag_id
WHERE v.next_dose_date IS NOT NULL
  AND v.next_dose_date <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
  AND a.life_status = 'Active';

-- ================================================================
-- DONNEES DE SIMULATION
-- Mot de passe pour tous les utilisateurs : Test1234!
-- Hash BCrypt : $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lh7y
-- ================================================================

-- Les triggers audit se declenchent pendant le seed ; les marquer SEED
SET @audit_user_id := NULL;
SET @audit_ip      := 'SEED';

-- ---- users (8 lignes) ----
INSERT INTO users (username, email, password, first_name, last_name, phone, role, is_active) VALUES
('admin',        'admin@cheptel.dz',    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lh7y', 'Karim',   'Benali',   '+213 555 001 001', 'Administrator', TRUE),
('vet_amira',    'amira@cheptel.dz',    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lh7y', 'Amira',   'Hadj',     '+213 555 002 001', 'Veterinarian',  TRUE),
('vet_youssef',  'youssef@cheptel.dz',  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lh7y', 'Youssef', 'Mebrouk',  '+213 555 002 002', 'Veterinarian',  TRUE),
('farmer_said',  'said@cheptel.dz',     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lh7y', 'Said',    'Bouzidi',  '+213 555 003 001', 'Farmer',        TRUE),
('farmer_nadia', 'nadia@cheptel.dz',    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lh7y', 'Nadia',   'Cherif',   '+213 555 003 002', 'Farmer',        TRUE),
('farmer_omar',  'omar@cheptel.dz',     '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lh7y', 'Omar',    'Tlemcani', '+213 555 003 003', 'Farmer',        TRUE),
('insp_dalila',  'dalila@cheptel.dz',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lh7y', 'Dalila',  'Mansouri', '+213 555 004 001', 'Inspector',     TRUE),
('insp_rachid',  'rachid@cheptel.dz',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lh7y', 'Rachid',  'Zerrouki', '+213 555 004 002', 'Inspector',     TRUE);

-- ---- rfid_tags (30 lignes) ----
-- Tags 1-8 seront assignes aux animaux 1-8 via after_animal_insert
-- Tags 29=Defective, 30=Lost (inseres directement avec statut final)
INSERT INTO rfid_tags (rfid_code, tag_type, tag_status) VALUES
('DZA-UHF-000001', 'UHF', 'InStock'),
('DZA-UHF-000002', 'UHF', 'InStock'),
('DZA-UHF-000003', 'UHF', 'InStock'),
('DZA-UHF-000004', 'UHF', 'InStock'),
('DZA-UHF-000005', 'UHF', 'InStock'),
('DZA-UHF-000006', 'UHF', 'InStock'),
('DZA-UHF-000007', 'UHF', 'InStock'),
('DZA-UHF-000008', 'UHF', 'InStock'),
('DZA-UHF-000009', 'UHF', 'InStock'),
('DZA-UHF-000010', 'UHF', 'InStock'),
('DZA-UHF-000011', 'UHF', 'InStock'),
('DZA-UHF-000012', 'UHF', 'InStock'),
('DZA-UHF-000013', 'UHF', 'InStock'),
('DZA-UHF-000014', 'UHF', 'InStock'),
('DZA-UHF-000015', 'UHF', 'InStock'),
('DZA-NFC-000016', 'NFC', 'InStock'),
('DZA-NFC-000017', 'NFC', 'InStock'),
('DZA-NFC-000018', 'NFC', 'InStock'),
('DZA-UHF-000019', 'UHF', 'InStock'),
('DZA-UHF-000020', 'UHF', 'InStock'),
('DZA-UHF-000021', 'UHF', 'InStock'),
('DZA-UHF-000022', 'UHF', 'InStock'),
('DZA-UHF-000023', 'UHF', 'InStock'),
('DZA-UHF-000024', 'UHF', 'InStock'),
('DZA-UHF-000025', 'UHF', 'InStock'),
('DZA-UHF-000026', 'UHF', 'InStock'),
('DZA-UHF-000027', 'UHF', 'InStock'),
('DZA-UHF-000028', 'UHF', 'InStock'),
('DZA-UHF-000029', 'UHF', 'Defective'),
('DZA-UHF-000030', 'UHF', 'Lost');

-- ---- farms (5 lignes) ----
-- owner: said=4, nadia=5, omar=6
INSERT INTO farms (owner_id, name, location, latitude, longitude, capacity, status, is_verified) VALUES
(4, 'Ferme Bouzidi',       'Setif, Algerie',   36.19112,  5.41373,  120, 'Active',    TRUE),
(4, 'Paturage El-Hajar',   'Batna, Algerie',   35.55970,  6.17415,   60, 'Active',    FALSE),
(5, 'Exploitation Cherif', 'Blida, Algerie',   36.47004,  2.82966,   80, 'Active',    TRUE),
(6, 'Ferme Tlemcani',      'Tlemcen, Algerie', 34.87833,  1.31667,  100, 'Active',    TRUE),
(6, 'Domaine El-Wadi',     'Djelfa, Algerie',  34.67040,  3.25190,   40, 'Suspended', FALSE);

-- ---- animals (20 lignes) ----
-- rfid_tag_id 1-8 declenchent after_animal_insert => tag_status='Assigned'
-- animals 15 (Sold) et 16 (Dead) ont un statut final non-Active
INSERT INTO animals (rfid_tag_id, owner_id, farm_id, species, breed, gender, birth_date, birth_place, weight, origin_type, life_status, health_status, notes) VALUES
(1,    4, 1, 'Ovin',   'Ouled Djellal',   'Male',   '2022-03-15', 'Setif',   72.5,  'Born',      'Active',  'Healthy',        NULL),
(2,    4, 1, 'Ovin',   'Ouled Djellal',   'Female', '2022-05-20', 'Setif',   58.0,  'Born',      'Active',  'Healthy',        'Gestante - agnelage prevu mars 2026'),
(3,    4, 2, 'Bovin',  'Charolais',        'Male',   '2020-08-10', 'Batna',   480.0, 'Purchased', 'Active',  'Healthy',        NULL),
(4,    4, 2, 'Bovin',  'Montbeliarde',     'Female', '2021-01-25', 'Batna',   390.0, 'Purchased', 'Active',  'UnderTreatment', 'Traitement mammite en cours'),
(5,    5, 3, 'Caprin', 'Alpine',           'Female', '2023-02-14', 'Blida',   38.5,  'Born',      'Active',  'Healthy',        NULL),
(6,    5, 3, 'Caprin', 'Alpine',           'Male',   '2023-02-14', 'Blida',   42.0,  'Born',      'Active',  'Healthy',        NULL),
(7,    6, 4, 'Ovin',   'Hamra',            'Female', '2021-11-03', 'Tlemcen', 54.0,  'Born',      'Active',  'Healthy',        NULL),
(8,    6, 4, 'Ovin',   'Hamra',            'Male',   '2021-11-03', 'Tlemcen', 66.5,  'Born',      'Active',  'Healthy',        NULL),
(NULL, 4, 1, 'Ovin',   'Rembi',            'Female', '2023-07-01', 'Setif',   49.0,  'Born',      'Active',  'Healthy',        NULL),
(NULL, 4, 1, 'Ovin',   'Rembi',            'Male',   '2023-07-01', 'Setif',   55.0,  'Born',      'Active',  'Healthy',        NULL),
(NULL, 5, 3, 'Ovin',   'Kabyle',           'Female', '2022-09-18', 'Blida',   47.0,  'Imported',  'Active',  'Quarantined',    'Quarantaine import - J7/21'),
(NULL, 5, 3, 'Caprin', 'Chevre locale',    'Female', '2020-06-30', 'Blida',   35.0,  'Born',      'Active',  'Healthy',        NULL),
(NULL, 6, 4, 'Bovin',  'Brune des Alpes',  'Female', '2019-04-12', 'Tlemcen', 420.0, 'Purchased', 'Active',  'Healthy',        NULL),
(NULL, 6, 4, 'Bovin',  'Limousin',         'Male',   '2018-09-05', 'Tlemcen', 610.0, 'Purchased', 'Active',  'Healthy',        NULL),
(NULL, 4, 1, 'Ovin',   'Ouled Djellal',    'Female', '2020-12-01', 'Setif',   61.0,  'Born',      'Sold',    'Healthy',        'Vendu le 2025-01-10'),
(NULL, 4, 2, 'Bovin',  'Charolais',        'Male',   '2017-03-22', 'Batna',   550.0, 'Purchased', 'Dead',    'Healthy',        'Decede - cause naturelle 2025-03-05'),
(NULL, 5, 3, 'Caprin', 'Alpine',           'Male',   '2024-01-10', 'Blida',   18.0,  'Born',      'Active',  'Healthy',        NULL),
(NULL, 6, 5, 'Ovin',   'Hamra',            'Female', '2023-05-15', 'Djelfa',  46.0,  'Born',      'Active',  'Critical',       'Fievre persistante - suivi veterinaire urgent'),
(NULL, 6, 4, 'Bovin',  'Montbeliarde',     'Female', '2022-08-20', 'Tlemcen', 375.0, 'Born',      'Active',  'Healthy',        NULL),
(NULL, 4, 1, 'Ovin',   'Rembi',            'Male',   '2024-04-01', 'Setif',   22.0,  'Born',      'Active',  'Healthy',        NULL);

-- ---- movements (6 lignes) ----
-- Mouvements Approved declenchent after_movement_approved => animals.farm_id mis a jour
-- NOTE: animaux 15 (Sold) et 16 (Dead) ne peuvent pas etre deplaces => on les exclut
INSERT INTO movements (animal_id, from_farm_id, to_farm_id, reason, treated_by, approval_status, notes) VALUES
(3,  2, 1, 'Regroupement troupeau',          1,    'Approved', 'Valide par admin'),
(7,  4, 3, 'Pret reproducteur',              1,    'Approved', 'Accord verbal proprietaires'),
(9,  1, 2, 'Surpopulation ferme principale', NULL, 'Pending',  NULL),
(13, 4, 1, 'Vente partielle',                NULL, 'Pending',  'En attente confirmation'),
(5,  3, 4, 'Echange reproducteur caprin',    NULL, 'Pending',  NULL),
(11, 3, 2, 'Deplacement quarantaine',        1,    'Rejected', 'Refus inspection sanitaire');

-- ---- health_records (10 lignes) ----
INSERT INTO health_records (animal_id, veterinarian_id, record_type, diagnosis, symptoms, treatment_plan, visit_date, next_visit_date, is_validated, notes) VALUES
(1,  2, 'Vaccination',  NULL,                          NULL,                           NULL,                                   '2025-09-15 09:00:00', '2026-09-15', TRUE,  'Vaccination annuelle FMD'),
(2,  2, 'Checkup',      'Gestation confirmee',         NULL,                           'Surveillance mensuelle',               '2025-11-20 10:30:00', '2026-01-20', TRUE,  'Gestation 4e mois'),
(4,  3, 'Treatment',    'Mammite subclinique',          'Gonflement quartier droit',    'Antibiotiques 5j + anti-inflam.',      '2025-12-10 08:00:00', '2025-12-17', TRUE,  NULL),
(5,  2, 'Vaccination',  NULL,                          NULL,                           NULL,                                   '2025-08-01 11:00:00', '2026-08-01', TRUE,  'Primo-vaccination rage'),
(7,  3, 'Checkup',      'Bonne condition corporelle',  NULL,                           NULL,                                   '2025-10-05 09:30:00', NULL,         TRUE,  NULL),
(11, 2, 'Disease',      'Suspicion brucellose',         'Avortement tardif, fievre',    'Isolement + serologie + declaration',  '2025-11-30 14:00:00', '2025-12-07', FALSE, 'En attente resultats labo'),
(13, 3, 'Checkup',      'Etat general satisfaisant',   NULL,                           NULL,                                   '2025-09-22 10:00:00', NULL,         TRUE,  NULL),
(18, 2, 'Disease',      'Fievre hemorragique',          'Hyperthermie 41.5C, prostration','Antipyretiques + rehydratation',    '2025-12-20 08:30:00', '2025-12-23', FALSE, 'Cas critique - surveillance 24h'),
(3,  3, 'Vaccination',  NULL,                          NULL,                           NULL,                                   '2025-07-10 09:00:00', '2026-07-10', TRUE,  'FMD rappel annuel post-transfert'),
(8,  2, 'Checkup',      'Condition corporelle 3/5',    NULL,                           'Complement alimentaire recommande',    '2025-10-18 11:30:00', '2026-01-18', TRUE,  NULL);

-- ---- vaccinations (5 lignes, liees aux health_records de type Vaccination) ----
INSERT INTO vaccinations (health_record_id, vaccine_name, vaccine_type, manufacturer, batch_number, dose, expiration_date, next_dose_date, administered_by) VALUES
(1, 'Aftovax',   'FMD bivalent',  'MCI Sante Animale', 'AFT-2025-0047', '2ml SC', '2026-06-30', '2026-09-15', 2),
(4, 'Rabisin',   'Antirabique',   'Merial',             'RAB-2025-1123', '1ml IM', '2027-01-31', '2026-08-01', 2),
(9, 'Aftovax',   'FMD bivalent',  'MCI Sante Animale', 'AFT-2025-0048', '2ml SC', '2026-06-30', '2026-07-10', 3),
(1, 'Pastovax',  'Pasteurellose', 'Ceva',               'PAS-2025-0312', '1ml IM', '2026-12-31', '2026-09-15', 2),
(4, 'Caprivax',  'Enterotoxemie', 'Biopharma',          'CAP-2025-0098', '1ml SC', '2026-08-01', '2026-08-01', 2);

-- ---- subsidies (6 lignes) ----
INSERT INTO subsidies (animal_id, amount, subsidy_type, status, request_date, approved_date, paid_date, treated_by, notes) VALUES
(1,  15000.00, 'Prime naissance ovin',     'Paid',     '2024-04-01', '2024-04-15', '2024-05-01', 1,    'Verse par virement'),
(2,  15000.00, 'Prime naissance ovin',     'Paid',     '2024-06-01', '2024-06-20', '2024-07-05', 1,    NULL),
(3,  45000.00, 'Aide modernisation bovin', 'Approved', '2025-02-10', '2025-03-01', NULL,         1,    'Paiement en cours'),
(5,  12000.00, 'Prime elevage caprin',     'Pending',  '2025-10-01', NULL,         NULL,         NULL, NULL),
(13, 40000.00, 'Aide reproduction bovin',  'Rejected', '2025-08-15', NULL,         NULL,         NULL, 'Dossier incomplet'),
(18, 20000.00, 'Indemnisation maladie',    'Pending',  '2025-12-21', NULL,         NULL,         NULL, 'Lie au cas fievre hemorragique');

-- ---- control_sessions (3 lignes) ----
INSERT INTO control_sessions (controller_id, farm_id, expected_count, started_at, ended_at, result) VALUES
(7, 1, 15, '2025-10-12 09:00:00', '2025-10-12 11:30:00', 'CONFORME'),
(8, 4,  8, '2025-11-05 10:30:00', '2025-11-05 12:00:00', 'NON_CONFORME'),
(7, 3,  6, '2025-12-01 08:00:00', '2025-12-01 09:00:00', 'CONFORME');

-- ---- constats (4 lignes) ----
INSERT INTO constats (control_session_id, type, description, status, resolved_at) VALUES
(1,    'AUTRE',    'Controle annuel ferme Bouzidi - conformite totale. RAS.',        'RESOLVED',  '2025-10-12 11:30:00'),
(2,    'FRAUDE',   'Tags RFID manquants sur 3 animaux - signalement fraude.',        'RESOLVED',  '2025-11-20 09:00:00'),
(3,    'MANQUANT', 'Animal 11 en quarantaine - suspicion brucellose. Attente labo.', 'IN_REVIEW', NULL),
(NULL, 'AUTRE',    'Controle en cours - aucune anomalie relevee pour le moment.',    'PENDING',   NULL);

-- ---- constat_images (8 lignes) ----
-- constat 1 (AUTRE/RESOLVED, ferme Bouzidi) : 1 photo de conformite
-- constat 2 (FRAUDE/RESOLVED, ferme Tlemcani) : 3 photos (animaux sans tag + PV)
-- constat 3 (MANQUANT/IN_REVIEW, ferme Cherif) : 2 photos (animal en quarantaine)
-- constat 4 (AUTRE/PENDING) : 2 photos generales de session
INSERT INTO constat_images (constat_id, image_url, uploaded_at) VALUES
(1, 'uploads/constats/1/photo_conformite_bouzidi_20251012.jpg',       '2025-10-12 11:35:00'),
(2, 'uploads/constats/2/photo_animal_sans_tag_01_20251105.jpg',       '2025-11-05 12:10:00'),
(2, 'uploads/constats/2/photo_animal_sans_tag_02_20251105.jpg',       '2025-11-05 12:12:00'),
(2, 'uploads/constats/2/photo_pv_fraude_tlemcani_20251105.jpg',       '2025-11-05 12:15:00'),
(3, 'uploads/constats/3/photo_animal11_quarantaine_20251201.jpg',     '2025-12-01 08:20:00'),
(3, 'uploads/constats/3/photo_enclos_isolement_cherif_20251201.jpg',  '2025-12-01 08:22:00'),
(4, 'uploads/constats/4/photo_troupeau_elhajar_01_20251210.jpg',      '2025-12-10 09:05:00'),
(4, 'uploads/constats/4/photo_troupeau_elhajar_02_20251210.jpg',      '2025-12-10 09:07:00');

-- ---- notifications (8 lignes) ----
INSERT INTO notifications (user_id, title, body, type, is_read, animal_id, farm_id) VALUES
(4, 'Rappel vaccination',           'Animal #1 (Ovin) - vaccin FMD a renouveler en septembre 2026.',             'Reminder', TRUE,  1,    1),
(4, 'Gestation confirmee',          'Animal #2 est en gestation. Prochain controle : 20 jan 2026.',              'Info',     TRUE,  2,    1),
(4, 'Traitement en cours',          'Animal #4 sous antibiotiques - mammite subclinique. Controle 17/12.',       'Alert',    FALSE, 4,    2),
(5, 'Quarantaine obligatoire',      'Animal #11 - quarantaine brucellose. Declaration DSV obligatoire.',         'Alert',    FALSE, 11,   3),
(6, 'Cas critique detecte',         'Animal #18 en etat critique - fievre hemorragique. Intervention urgente.', 'Alert',    FALSE, 18,   5),
(7, 'Resultat inspection',          'Inspection #1 ferme Bouzidi : Conforme. Aucune anomalie detectee.',        'Info',     TRUE,  NULL, 1),
(8, 'Fraude detectee',              'Inspection #2 ferme Tlemcani : 3 animaux non traces. Dossier transmis.',   'Warning',  TRUE,  NULL, 4),
(1, 'Subvention en attente',        'Subvention #4 (animal #5) - prime elevage caprin a examiner.',              'Reminder', FALSE, 5,    3);

-- ---- control_session_scanned_tags (10 lignes) ----
-- session 1 (ferme 1, expected=15) : 15 tags lus, tous reconnus
-- session 2 (ferme 4, expected=8)  : 10 tags lus, 8 reconnus + 2 inconnus
-- session 3 (ferme 3, expected=6)  : 6 tags lus, tous reconnus
INSERT INTO control_session_scanned_tags (session_id, rfid_tag, is_recognized, scanned_at) VALUES
(1, 'DZA-UHF-000001', TRUE,  '2025-10-12 09:05:00'),
(1, 'DZA-UHF-000002', TRUE,  '2025-10-12 09:07:00'),
(1, 'DZA-UHF-000009', TRUE,  '2025-10-12 09:09:00'),
(1, 'DZA-UHF-000010', TRUE,  '2025-10-12 09:11:00'),
(2, 'DZA-UHF-000007', TRUE,  '2025-11-05 10:35:00'),
(2, 'DZA-UHF-000008', TRUE,  '2025-11-05 10:37:00'),
(2, 'DZA-UHF-000099', FALSE, '2025-11-05 10:39:00'),
(2, 'DZA-UHF-000100', FALSE, '2025-11-05 10:41:00'),
(3, 'DZA-UHF-000005', TRUE,  '2025-12-01 08:05:00'),
(3, 'DZA-UHF-000006', TRUE,  '2025-12-01 08:07:00');

-- ---- reproductions (3 lignes) ----
-- animal 2 (femelle Ovin)  x animal 1 (male Ovin)  => gestation en cours
-- animal 12 (femelle Caprin) x animal 6 (male Caprin) => succes, 1 agneau
-- animal 19 (femelle Bovin) x animal 3 (male Bovin) => en cours
INSERT INTO reproductions (female_id, male_id, breeding_date, expected_birth_date, actual_birth_date, offspring_count, status, veterinarian_id, notes) VALUES
(2,  1, '2025-10-15', '2026-03-10', NULL,         0, 'IN_PROGRESS', 2, 'Gestation confirmee echo J30 - agnelage prevu mars 2026'),
(12, 6, '2025-07-01', '2025-11-25', '2025-11-28', 1, 'SUCCESSFUL',  2, 'Mise-bas normale - 1 chevreau male en bonne sante'),
(19, 3, '2025-11-20', '2026-08-25', NULL,         0, 'IN_PROGRESS', 3, 'Saillie naturelle - confirmation echo prevue janvier 2026');

-- ---- sanitary_campaigns (3 lignes) ----
INSERT INTO sanitary_campaigns (name, description, vaccine_name, target_species, start_date, end_date, status, created_by) VALUES
('Campagne FMD 2025',        'Vaccination nationale contre la fievre aphteuse - vague automne 2025',   'Aftovax',   'All',    '2025-09-01', '2025-11-30', 'Completed', 1),
('Campagne Rage Caprin 2025','Primo-vaccination antirabique elevages caprins region Nord',              'Rabisin',   'Caprin', '2025-07-15', '2025-09-30', 'Completed', 1),
('Campagne FMD 2026',        'Vaccination nationale contre la fievre aphteuse - vague printemps 2026', 'Aftovax',   'All',    '2026-03-01', '2026-05-31', 'Planned',   1);

-- ---- campaign_participations (6 lignes) ----
-- Campagne 1 (FMD 2025) : animaux 1, 3, 7 vaccines
-- Campagne 2 (Rage Caprin 2025) : animaux 5, 12 vaccines
-- Campagne 3 (FMD 2026) : animal 2 en attente
INSERT INTO campaign_participations (campaign_id, animal_id, veterinarian_id, vaccination_date, status, notes) VALUES
(1, 1,  2, '2025-09-15', 'Done',    'Aftovax 2ml SC - lot AFT-2025-0047'),
(1, 3,  3, '2025-07-10', 'Done',    'Aftovax 2ml SC - lot AFT-2025-0048 - post-transfert ferme'),
(1, 7,  2, '2025-09-20', 'Done',    'Aftovax 2ml SC - lot AFT-2025-0047'),
(2, 5,  2, '2025-08-01', 'Done',    'Rabisin 1ml IM - lot RAB-2025-1123'),
(2, 12, 2, '2025-08-05', 'Done',    'Rabisin 1ml IM - lot RAB-2025-1123'),
(3, 2,  2, NULL,         'Pending', 'Agnelage prevu mars 2026 - vaccination post-partum');

-- ---- sync_records (5 lignes) ----
INSERT INTO sync_records (user_id, entity_type, entity_id, action, data_json, synced_at) VALUES
(4, 'Animal',         1,  'UPDATE', '{"life_status":"Active","health_status":"Healthy"}',          '2025-12-01 08:00:00'),
(4, 'Animal',         4,  'UPDATE', '{"health_status":"UnderTreatment"}',                          '2025-12-10 08:30:00'),
(7, 'ControlSession', 1,  'CREATE', '{"farm_id":1,"expected_count":15,"result":"CONFORME"}',       '2025-10-12 12:00:00'),
(8, 'Constat',        2,  'CREATE', '{"type":"FRAUDE","control_session_id":2,"status":"RESOLVED"}', '2025-11-05 13:00:00'),
(5, 'Animal',         11, 'UPDATE', '{"health_status":"Quarantined","life_status":"Active"}',      '2025-11-30 15:00:00');

-- ---- password_reset_tokens (2 lignes) ----
INSERT INTO password_reset_tokens (user_id, contact, code_hash, used, expires_at) VALUES
(4, 'said@cheptel.dz',  '$2a$10$abcdefghijklmnopqrstuvABCDEFGHIJKLMNOPQRSTUVWXYZ012345', FALSE, '2026-01-15 10:30:00'),
(5, 'nadia@cheptel.dz', '$2a$10$zyxwvutsrqponmlkjihgfeZYXWVUTSRQPONMLKJIHGFEDCBA987654', TRUE,  '2025-12-20 14:00:00');


select * from farms;
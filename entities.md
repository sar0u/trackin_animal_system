# Entities Reference

## Relations entre entités

### Diagramme des relations (notation MCD — cardinalités MERISE)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          DIAGRAMME DES RELATIONS                              │
└──────────────────────────────────────────────────────────────────────────────┘

User ─────(1,n)──[possède]────(0,n)──── Farm
User ─────(1,n)──[possède]────(0,n)──── Animal
User ─────(1,n)──[effectue]───(0,n)──── AuditLog
User ─────(1,n)──[reçoit]─────(0,n)──── Notification
User ─────(1,n)──[valide]─────(0,n)──── Movement         (approved_by)
User ─────(1,n)──[valide]─────(0,n)──── Subsidy           (approved_by)
User ─────(1,n)──[inspecte]───(0,n)──── Inspection        (inspector_id)
User ─────(1,n)──[résout]─────(0,n)──── Inspection        (resolved_by)
User ─────(1,n)──[contrôle]───(0,n)──── ScanSession       (controller_id)
User ─────(1,n)──[soigne]─────(0,n)──── HealthRecord      (veterinarian_id)
User ─────(1,n)──[administre]─(0,n)──── Vaccination       (administered_by)
User ─────(1,n)──[modifie]────(0,n)──── AnimalStatusHistory (changed_by)

Farm ─────(1,n)──[héberge]────────(0,n)──── Animal         (farm_id)
Farm ─────(1,n)──[source de]──────(0,n)──── Movement       (from_farm_id)
Farm ─────(1,n)──[destination de]─(0,n)──── Movement       (to_farm_id)
Farm ─────(1,n)──[scannée dans]───(0,n)──── ScanSession    (farm_id)
Farm ─────(1,n)──[liée à]─────────(0,n)──── Notification   (farm_id)

Animal ──(0,1)──[identifié par]──(0,1)── RfidTag            (rfid_tag_id, UNIQUE)
Animal ──(0,1)──[mère de]────────(0,n)── Animal             (mother_id, self-ref)
Animal ──(0,1)──[père de]────────(0,n)── Animal             (father_id, self-ref)
Animal ──(1,n)──[a]──────────────(0,n)── HealthRecord       (animal_id)
Animal ──(1,n)──[subit]──────────(0,n)── Movement           (animal_id)
Animal ──(1,n)──[inspecté dans]──(0,n)── Inspection         (animal_id)
Animal ──(1,n)──[bénéficie de]───(0,n)── Subsidy            (animal_id)
Animal ──(1,n)──[mentionné dans]─(0,n)── Notification       (animal_id)
Animal ──(1,n)──[historique]─────(0,n)── AnimalStatusHistory (animal_id)

HealthRecord ──(1,n)──[contient]──────(0,n)── Vaccination     (health_record_id)

Inspection ──(1,n)──[produit]──────────(0,n)── InspectionImage      (inspection_id)
Inspection ──(1,n)──[signale absent]───(0,n)── InspectionMissingTag (inspection_id)
Inspection ──(1,n)──[signale inconnu]──(0,n)── InspectionUnknownTag (inspection_id)

ScanSession ──(1,n)──[contient]──(0,n)── ScannedTag         (scan_session_id)

RfidTag ──(1,n)──[référencé dans]──(0,n)── InspectionMissingTag (tag_id)
RfidTag ──(1,n)──[référencé dans]──(0,n)── InspectionUnknownTag (tag_id)
RfidTag ──(1,n)──[scanné dans]─────(0,n)── ScannedTag           (tag_id)
```

### Tableau des relations (clés étrangères)

| Table (côté Many) | Champ FK | Référence | ON DELETE | Obligatoire |
|---|---|---|---|---|
| Animal | owner_id | users.id | RESTRICT | Oui |
| Animal | farm_id | farms.id | RESTRICT | Oui |
| Animal | rfid_tag_id | rfid_tags.id | SET NULL | Non |
| Animal | mother_id | animals.id | SET NULL | Non |
| Animal | father_id | animals.id | SET NULL | Non |
| Farm | owner_id | users.id | RESTRICT | Oui |
| Movement | animal_id | animals.id | RESTRICT | Oui |
| Movement | from_farm_id | farms.id | RESTRICT | Oui |
| Movement | to_farm_id | farms.id | RESTRICT | Oui |
| Movement | approved_by | users.id | SET NULL | Non |
| HealthRecord | animal_id | animals.id | RESTRICT | Oui |
| HealthRecord | veterinarian_id | users.id | SET NULL | Non |
| Vaccination | health_record_id | health_records.id | CASCADE | Oui |
| Vaccination | administered_by | users.id | SET NULL | Non |
| Inspection | inspector_id | users.id | RESTRICT | Oui |
| Inspection | animal_id | animals.id | SET NULL | Non |
| Inspection | resolved_by | users.id | SET NULL | Non |
| InspectionImage | inspection_id | inspections.id | CASCADE | Oui |
| InspectionMissingTag | inspection_id | inspections.id | CASCADE | Oui |
| InspectionMissingTag | tag_id | rfid_tags.id | CASCADE | Oui |
| InspectionUnknownTag | inspection_id | inspections.id | CASCADE | Oui |
| InspectionUnknownTag | tag_id | rfid_tags.id | CASCADE | Oui |
| ScanSession | controller_id | users.id | RESTRICT | Oui |
| ScanSession | farm_id | farms.id | RESTRICT | Oui |
| ScannedTag | scan_session_id | scan_sessions.id | CASCADE | Oui |
| ScannedTag | tag_id | rfid_tags.id | CASCADE | Oui |
| Subsidy | animal_id | animals.id | SET NULL | Non |
| Subsidy | approved_by | users.id | SET NULL | Non |
| Notification | user_id | users.id | CASCADE | Oui |
| Notification | animal_id | animals.id | SET NULL | Non |
| Notification | farm_id | farms.id | SET NULL | Non |
| AuditLog | user_id | users.id | SET NULL | Non |
| AnimalStatusHistory | animal_id | animals.id | CASCADE | Oui |
| AnimalStatusHistory | changed_by | users.id | SET NULL | Non |

### Contraintes UNIQUE composites

| Table | Contrainte UNIQUE | Description |
|---|---|---|
| Animal | rfid_tag_id | Un tag RFID ne peut être assigné qu'à un seul animal |
| ScannedTag | (scan_session_id, tag_id) | Un tag ne peut être scanné qu'une fois par session |
| InspectionMissingTag | (inspection_id, tag_id) | Un tag manquant unique par inspection |
| InspectionUnknownTag | (inspection_id, tag_id) | Un tag inconnu unique par inspection |

### Colonnes calculées (dépendances fonctionnelles)

| Table | Colonne calculée | Dépendance | Type SQL |
|---|---|---|---|
| Inspection | difference | scannedCount - registeredCount | GENERATED ALWAYS (stored) |
| ScanSession | difference | totalScanned - totalRegistered | GENERATED ALWAYS (stored) |

---

## JPA Entities

### Animal
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| rfidTag | RfidTag | OneToOne(0,1)↔(0,1), eager, rfid_tag_id FK |
| species | Species (enum) | not null |
| breed | String | |
| gender | Gender (enum) | |
| birthDate | LocalDate | |
| birthPlace | String | |
| acquisitionPlace | String | |
| weight | Double | CHECK > 0 |
| lifeStatus | LifeStatus (enum) | default Active |
| originType | OriginType (enum) | default Born |
| healthStatus | HealthStatus (enum) | default Healthy |
| reproductionStatus | ReproductionStatus (enum) | default None |
| vaccinationStatus | VaccinationStatus (enum) | default Not_vaccinated |
| owner | User | ManyToOne(0,n)↔(1,n), not null, owner_id FK |
| farm | Farm | ManyToOne(0,n)↔(1,n), not null, farm_id FK |
| mother | Animal | ManyToOne(0,n)↔(0,1), self-ref, mother_id FK |
| father | Animal | ManyToOne(0,n)↔(0,1), self-ref, father_id FK |
| notes | String | TEXT |

**Relations inverses (OneToMany non mappées côté JPA) :**
- `HealthRecord[]` via animal_id
- `Movement[]` via animal_id
- `Inspection[]` via animal_id
- `Subsidy[]` via animal_id
- `Notification[]` via animal_id
- `AnimalStatusHistory[]` via animal_id

---

### AnimalStatusHistory
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| animal | Animal | ManyToOne(0,n)↔(1,n), not null, animal_id FK→CASCADE |
| changedBy | User | ManyToOne(0,n)↔(1,n), changed_by FK→SET NULL |
| oldLifeStatus | String | |
| newLifeStatus | String | |
| oldHealthStatus | String | |
| newHealthStatus | String | |
| reason | String | TEXT |
| changedAt | LocalDateTime | auto, not updatable |

*Alimenté automatiquement par le trigger `after_animal_status_history`.*

---

### AuditLog
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| user | User | ManyToOne(0,n)↔(1,n), user_id FK→SET NULL |
| action | String | not null |
| entityType | String | |
| entityId | Long | |
| oldValues | String | JSON (dénormalisé intentionnel) |
| newValues | String | JSON (dénormalisé intentionnel) |
| details | String | TEXT |
| ipAddress | String | IPv4/IPv6 (45 chars) |
| createdAt | LocalDateTime | auto, not updatable |

*Immuable par conception — pas d'UPDATE ni DELETE autorisés.*

---

### Farm
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| owner | User | ManyToOne(0,n)↔(1,n), not null, owner_id FK→RESTRICT |
| name | String | not null |
| location | String | |
| latitude | Double | |
| longitude | Double | |
| capacity | Integer | |
| status | FarmStatus (enum) | default Active |

**Relations inverses :**
- `Animal[]` via farm_id
- `Movement[]` via from_farm_id
- `Movement[]` via to_farm_id
- `ScanSession[]` via farm_id
- `Notification[]` via farm_id

---

### HealthRecord
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| animal | Animal | ManyToOne(0,n)↔(1,n), not null, animal_id FK→RESTRICT |
| veterinarian | User | ManyToOne(0,n)↔(1,n), veterinarian_id FK→SET NULL |
| recordType | RecordType (enum) | not null |
| diagnosis | String | TEXT |
| symptoms | String | TEXT |
| treatmentPlan | String | TEXT |
| visitDate | LocalDateTime | not null, default CURRENT_TIMESTAMP |
| nextVisitDate | LocalDate | |
| isValidated | Boolean | |
| geoLatitude | BigDecimal | precision(10,8) |
| geoLongitude | BigDecimal | precision(11,8) |
| notes | String | TEXT |
| createdAt | LocalDateTime | auto, not updatable |
| updatedAt | LocalDateTime | auto, not updatable |

**Relations inverses :**
- `Vaccination[]` via health_record_id (cascade DELETE)

---

### Inspection
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| inspector | User | ManyToOne(0,n)↔(1,n), not null, inspector_id FK→RESTRICT |
| animal | Animal | ManyToOne(0,n)↔(1,n), animal_id FK→SET NULL |
| inspectionDate | LocalDateTime | not null, default CURRENT_TIMESTAMP |
| result | InspectionResult (enum) | not null, default Pending |
| status | InspectionStatus (enum) | default Pending |
| constatType | String | default 'General' |
| description | String | TEXT |
| scannedCount | Integer | default 0 |
| registeredCount | Integer | default 0 |
| difference | Integer | **GENERATED** = scannedCount - registeredCount |
| geoLatitude | BigDecimal | precision(10,8) |
| geoLongitude | BigDecimal | precision(11,8) |
| resolvedAt | LocalDateTime | |
| resolvedBy | User | ManyToOne(0,n)↔(1,n), resolved_by FK→SET NULL |
| notes | String | TEXT |
| createdAt | LocalDateTime | auto, not updatable |
| updatedAt | LocalDateTime | auto, not updatable |
| images | List\<InspectionImage\> | OneToMany, cascade ALL, orphanRemoval |

**Relations inverses :**
- `InspectionImage[]` via inspection_id (cascade DELETE, mappedBy)
- `InspectionMissingTag[]` via inspection_id
- `InspectionUnknownTag[]` via inspection_id

---

### InspectionImage
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| inspection | Inspection | ManyToOne(0,n)↔(1,n), not null, inspection_id FK→CASCADE |
| imageUrl | String | TEXT, not null |
| imageType | String | default 'Photo' |
| createdAt | LocalDateTime | auto, not updatable |

---

### InspectionMissingTag
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| inspection | Inspection | ManyToOne(0,n)↔(1,n), not null, inspection_id FK→CASCADE |
| tag | RfidTag | ManyToOne(0,n)↔(1,n), not null, tag_id FK→CASCADE |

*UNIQUE (inspection_id, tag_id) — un tag absent unique par inspection.*

---

### InspectionUnknownTag
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| inspection | Inspection | ManyToOne(0,n)↔(1,n), not null, inspection_id FK→CASCADE |
| tag | RfidTag | ManyToOne(0,n)↔(1,n), not null, tag_id FK→CASCADE |

*UNIQUE (inspection_id, tag_id) — un tag inconnu unique par inspection.*

---

### Movement
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| animal | Animal | ManyToOne(0,n)↔(1,n), not null, animal_id FK→RESTRICT |
| fromFarm | Farm | ManyToOne(0,n)↔(1,n), not null, from_farm_id FK→RESTRICT |
| toFarm | Farm | ManyToOne(0,n)↔(1,n), not null, to_farm_id FK→RESTRICT |
| reason | String | |
| moveDate | LocalDateTime | auto, not updatable |
| approvedBy | User | ManyToOne(0,n)↔(1,n), approved_by FK→SET NULL |
| approvalStatus | ApprovalStatus (enum) | default Pending |
| notes | String | TEXT |
| createdAt | LocalDateTime | auto, not updatable |

*Trigger `before_movement_insert` : vérifie from_farm ≠ to_farm et animal actif.*
*Trigger `after_movement_approved` : met à jour animals.farm_id quand approuvé.*

---

### Notification
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| user | User | ManyToOne(0,n)↔(1,n), not null, user_id FK→CASCADE |
| title | String | not null |
| body | String | TEXT |
| type | NotificationType (enum) | default Info |
| isRead | Boolean | default false |
| animal | Animal | ManyToOne(0,n)↔(1,n), animal_id FK→SET NULL |
| farm | Farm | ManyToOne(0,n)↔(1,n), farm_id FK→SET NULL |
| createdAt | LocalDateTime | auto, not updatable |

---

### RfidTag
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| rfidCode | String | not null, UNIQUE (clé candidate) |
| tagType | TagType (enum) | default UHF |
| tagStatus | HardwareStatus (enum) | default InStock |

**Relations inverses :**
- `Animal` via rfid_tag_id (OneToOne inverse)
- `InspectionMissingTag[]` via tag_id
- `InspectionUnknownTag[]` via tag_id
- `ScannedTag[]` via tag_id

*Trigger `after_animal_status_update` : libère le tag (→ InStock) quand animal Dead/Sold/Slaughtered.*

---

### ScannedTag
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| scanSession | ScanSession | ManyToOne(0,n)↔(1,n), not null, scan_session_id FK→CASCADE |
| tag | RfidTag | ManyToOne(0,n)↔(1,n), not null, tag_id FK→CASCADE |
| scannedAt | LocalDateTime | auto, not updatable |

*UNIQUE (scan_session_id, tag_id) — un tag scanné une seule fois par session.*

---

### ScanSession
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| controller | User | ManyToOne(0,n)↔(1,n), not null, controller_id FK→RESTRICT |
| farm | Farm | ManyToOne(0,n)↔(1,n), not null, farm_id FK→RESTRICT |
| sessionDate | LocalDateTime | auto, not updatable |
| totalScanned | Integer | default 0 |
| totalRegistered | Integer | default 0 |
| difference | Integer | **GENERATED** = totalScanned - totalRegistered |
| isConsistent | Boolean | default false |
| status | ScanSessionStatus (enum) | default Pending |
| confirmedAt | LocalDateTime | |
| notes | String | TEXT |
| createdAt | LocalDateTime | auto, not updatable |

**Relations inverses :**
- `ScannedTag[]` via scan_session_id

---

### Subsidy
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| animal | Animal | ManyToOne(0,n)↔(1,n), animal_id FK→SET NULL |
| amount | BigDecimal | not null, precision(12,2), CHECK > 0 |
| type | String | VARCHAR(100) libre |
| status | SubsidyStatus (enum) | default Pending |
| requestDate | LocalDate | |
| approvedDate | LocalDate | |
| paidDate | LocalDate | |
| approvedBy | User | ManyToOne(0,n)↔(1,n), approved_by FK→SET NULL |
| notes | String | TEXT |
| createdAt | LocalDateTime | auto, not updatable |
| updatedAt | LocalDateTime | auto, not updatable |

---

### User
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| username | String | not null, UNIQUE (clé candidate) |
| email | String | not null, UNIQUE (clé candidate) |
| password | String | not null, write-only JSON |
| firstName | String | not null |
| lastName | String | not null |
| phone | String | |
| role | UserRole (enum) | not null |
| isActive | Boolean | default true |
| resetCode | String | |
| resetCodeExpiration | LocalDateTime | |
| createdAt | LocalDateTime | auto, not updatable |
| updatedAt | LocalDateTime | auto, not updatable |

**Relations inverses :**
- `Farm[]` via owner_id
- `Animal[]` via owner_id
- `AuditLog[]` via user_id
- `Notification[]` via user_id
- `Inspection[]` via inspector_id
- `ScanSession[]` via controller_id
- `HealthRecord[]` via veterinarian_id

---

### Vaccination
| Field | Type | Constraints |
|-------|------|-------------|
| id | Long | PK, auto-generated |
| healthRecord | HealthRecord | ManyToOne(0,n)↔(1,n), not null, health_record_id FK→CASCADE |
| vaccineName | String | not null |
| vaccineType | String | |
| manufacturer | String | |
| batchNumber | String | |
| dose | String | |
| expirationDate | LocalDate | |
| nextDoseDate | LocalDate | |
| administeredBy | User | ManyToOne(0,n)↔(1,n), administered_by FK→SET NULL |
| createdAt | LocalDateTime | auto, not updatable |

---

## Enums

| Enum | Values |
|------|--------|
| ApprovalStatus | Pending, Approved, Rejected |
| FarmStatus | Active, Suspended, Closed |
| FraudType | None, Theft, TagTampering, IllegalMovement, FakeVaccination, Other |
| Gender | Male, Female, Unknown |
| HardwareStatus | Assigned, Defective, InStock, Lost |
| HealthStatus | Healthy, UnderTreatment, Critical, Quarantined |
| InspectionResult | Compliant, Fraud, Suspicious, Pending |
| InspectionStatus | Pending, UnderReview, Resolved, Rejected |
| LifeStatus | Active, Sold, Lost, Dead, Slaughtered |
| NotificationType | Alert, Reminder, Warning, Info |
| OriginType | Born, Purchased, Imported |
| RecordType | Vaccination, Treatment, Disease, Checkup, Surgery, LabTest, Injury |
| ReproductionStatus | None, Pregnant, Breeding, Castrated |
| ScanSessionStatus | Pending, Confirmed, Disputed |
| Species | Ovin, Bovin, Caprin, Autre |
| SubsidyStatus | Pending, Approved, Rejected, Paid |
| TagType | UHF, NFC |
| UserRole | Administrator, Veterinarian, Farmer, Inspector |
| VaccinationStatus | UpToDate, Expired, Not_vaccinated |

---

## Analyse des besoins vs modèle

### Besoins couverts ✅

| Besoin (cahier) | Couverture |
|---|---|
| Identification unique RFID NFC/UHF | `RfidTag.rfidCode` UNIQUE, `TagType` UHF/NFC |
| Espèce, race, sexe, date naissance, statut | `Animal` (species, breed, gender, birthDate, lifeStatus) |
| Historique complet de chaque animal | `AnimalStatusHistory`, `HealthRecord`, `Movement`, `AuditLog` |
| Suivi sanitaire (vaccinations, maladies, traitements) | `HealthRecord.recordType` + `Vaccination` |
| Alertes automatiques sanitaires | `Notification` (Alert/Reminder/Warning) |
| Traçabilité de la descendance (mère/père) | `Animal.mother`, `Animal.father` (self-ref) |
| Suivi déplacements / transferts | `Movement` (fromFarm, toFarm, approvalStatus) |
| Gestion subventions (attribution, paiements) | `Subsidy` (amount, status, requestDate, approvedDate, paidDate) |
| Contrôle terrain RFID vs base | `ScanSession` + `ScannedTag` + `InspectionMissingTag/UnknownTag` |
| Détection fraude (tags manquants/inconnus) | `Inspection.result` Fraud/Suspicious |
| Journal d'audit complet | `AuditLog` (action, entityType, oldValues/newValues JSON) |
| 4 profils utilisateurs | `User.role` (Administrator/Veterinarian/Farmer/Inspector) |
| Géolocalisation des interventions | `HealthRecord.geoLatitude/geoLongitude`, `Inspection.geoLatitude/geoLongitude` |
| Horodatage de chaque événement | `createdAt` / `changedAt` sur toutes les entités |
| Validation par vétérinaire | `HealthRecord.isValidated` + `veterinarian_id` |
| Gestion des exploitations agricoles | `Farm` (name, location, latitude, longitude, capacity, status) |
| Sortie du système (vendu/abattu/mort) | `Animal.lifeStatus` + triggers libèrent le RFID |
| Blocage de mouvement (QuarantIne) | `Animal.healthStatus = Quarantined` + `Movement.approvalStatus` |

### Besoins manquants ou partiels ❌/⚠️

| Besoin | Problème | Entité à créer |
|---|---|---|
| Gestion des accouplements (événement daté) | Seul `Animal.reproductionStatus` existe, pas d'enregistrement d'accouplement | **`Mating`** |
| Suivi des gestations (date prévue mise bas) | `reproductionStatus = Pregnant` sans date prévue | **`Mating.expectedBirthDate`** |
| Planification campagnes sanitaires nationales | Aucune entité de campagne | **`SanitaryCampaign`** |
| Historique changement de propriétaire | Seul le changement de ferme est tracé (Movement), pas le changement d'owner | **`OwnershipHistory`** |
| Calcul automatique montants subvention | `Subsidy.type` est VARCHAR libre, pas de barème | **`SubsidyType`** avec règles |
| Restriction de mouvement sanitaire (durée) | `Quarantined` sans durée ni historique de restriction | **`MovementRestriction`** |
| QR code / code-barres | `TagType` limité à UHF/NFC | Ajouter `QR` à `TagType` ou `qrCode` dans `RfidTag` |
| Identifiant national officiel animal | RFID optionnel, aucun ID réglementaire obligatoire | Ajouter `nationalId` dans `Animal` |

---

## Conformité aux formes normales (BDD1)

| Règle | Statut | Détail |
|---|---|---|
| **1FN** — valeurs scalaires | ⚠️ | `AuditLog.oldValues/newValues` sont JSON (dénormalisé intentionnel pour audit) |
| **2FN** — dépendance totale à la PK | ✅ | Toutes les PK sont simples (id auto), pas de dépendance partielle possible |
| **3FN** — pas de dépendance transitive | ❌ | `Animal.vaccinationStatus` dérivable depuis `HealthRecord/Vaccination` |
| **3FN** — colonnes calculées | ⚠️ | `Inspection.difference` et `ScanSession.difference` sont GENERATED (acceptable en SQL) |
| **Contraintes CHECK** | ❌ | Manquent sur dates (approvedDate >= requestDate, birthDate <= NOW, etc.) |
| **Clé candidate obligatoire** | ❌ | `Animal.rfidTag` est optionnel — un animal peut exister sans identifiant physique |
| **Intégrité référentielle croisée** | ❌ | Même tag dans `InspectionMissingTag` ET `InspectionUnknownTag` possible pour la même inspection |

---

## Modifications recommandées (liste priorisée)

### Priorité HAUTE — Besoins manquants

1. Créer entité **`Mating`** (mère, père, dates, résultat, recordedBy)
2. Créer entité **`SanitaryCampaign`** + FK optionnel dans `HealthRecord.campaignId`
3. Créer entité **`OwnershipHistory`** (previousOwner, newOwner, transferDate, movement_id)
4. Ajouter **`TagType.QR`** ou champ `qrCode VARCHAR` dans `RfidTag`

### Priorité HAUTE — Anomalies BDD

5. **Supprimer `Animal.vaccinationStatus`** ou le gérer exclusivement via trigger (violation 3FN)
6. **Ajouter contraintes CHECK** : dates cohérentes dans Subsidy, Vaccination, Animal
7. **Rendre `rfid_tag_id` obligatoire** ou ajouter `nationalId VARCHAR(50) UNIQUE` dans `Animal`
8. **Empêcher intersection** `InspectionMissingTag ∩ InspectionUnknownTag` pour même (inspection, tag)

### Priorité MOYENNE — Améliorations

9. Créer table **`SubsidyType`** (code, label, calculationRule, unitAmount, maxAmount) et FK dans `Subsidy`
10. Créer entité **`MovementRestriction`** (animal/farm, raison, dates, isActive)
11. Ajouter **`Animal.nationalId`** VARCHAR(50) UNIQUE comme ID réglementaire

### Priorité BASSE — Conformité académique

12. Créer **vues SQL** : `v_animal_vaccination_status`, `v_farm_animal_count`, `v_subsidy_by_owner`
13. Documenter la dénormalisation intentionnelle dans les commentaires des entités

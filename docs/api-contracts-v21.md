# API contracts v2.1 (critical frontend endpoints)

This document defines the stable JSON fields used by the frontend for critical screens and statistics.

## `GET /api/inspections`

- `id`: number
- `inspectionDate`: ISO datetime string
- `result`: `Compliant | Fraud | Suspicious | Pending`
- `status`: `Pending | UnderReview | Resolved | Rejected`
- `constatType`: string nullable
- `description`: string nullable
- `scannedCount`: number nullable
- `registeredCount`: number nullable
- `difference`: number nullable
- `notes`: string nullable
- `inspectorId`: number nullable
- `inspectorName`: string nullable
- `animalId`: number nullable
- `farmId`: number nullable
- `farmName`: string nullable
- `farmLatitude`: number nullable
- `farmLongitude`: number nullable

## `GET /api/farms`

- `id`: number
- `owner`: object nullable (`id`, `firstName`, `lastName`, `username`)
- `name`: string
- `location`: string nullable
- `latitude`: number nullable
- `longitude`: number nullable
- `capacity`: number nullable
- `status`: `Active | Suspended | Closed` nullable

Frontend guard: if `status` is null/missing, display `Active`.

## `GET /api/users`

- `id`: number
- `username`: string
- `email`: string
- `firstName`: string
- `lastName`: string
- `role`: `Administrator | Veterinarian | Farmer | Inspector`
- `isActive`: boolean nullable
- `createdAt`: ISO datetime string nullable

## `GET /api/audit-logs`

- `id`: number
- `userId`: number nullable
- `action`: string
- `entityType`: string nullable
- `entityId`: number nullable
- `createdAt`: ISO datetime string nullable
- `oldValues`: json/string nullable
- `newValues`: json/string nullable
- `ipAddress`: string nullable
- `details`: string nullable

Frontend filter/search should use `entityType` (not `entityName`).

## `GET /api/animals` and `GET /api/animals/{id}`

Returns **`AnimalListItemDto`** (POJO stable, plus de sérialisation d’entités JPA sur ces GET).

Champs racine :

- `id`, `breed`, `birthDate`, `birthPlace`, `acquisitionPlace`, `weight`, `notes`
- `species`, `gender`, `lifeStatus`, `originType`, `healthStatus`, `reproductionStatus`, `vaccinationStatus` : **chaînes** (noms d’enum Java / MySQL), jamais d’objet enum JSON.

Objets imbriqués :

- `rfidTag` nullable : `{ id, rfidCode, tagType, tagStatus }` (tous string sauf `id` long)
- `farm` nullable : `{ id, name, location, latitude, longitude, capacity, status }`
- `owner` nullable : `{ id, username, email, firstName, lastName, role, isActive }`
- `mother` / `father` nullable : `{ id }` uniquement

Chargement : `AnimalRepository.findAllFetched()` / `findFetchedById` avec `JOIN FETCH` pour initialiser le graphe **dans la transaction** avant mapping vers DTO.

## `GET /api/movements`

Liste : entités `Movement` ; le repository utilise **`findAllFetched()`** (`JOIN FETCH` animal + rfidTag, fermes + propriétaire, approbateur) pour limiter les erreurs lazy à la sérialisation.

Champs utiles : `animal`, `fromFarm`, `toFarm`, `approvalStatus`, `moveDate`, `approvedBy`, `reason`, `notes`.

## `GET /api/subsidies`

Liste : entités `Subsidy` ; **`findAllFetched()`** charge animal + rfidTag + farm + owners + `approvedBy` en une requête JPQL.

Champs : `animal`, `amount`, `type` (colonne BDD `subsidy_type`), `status`, `requestDate`, `approvedDate`, `paidDate`, `approvedBy`, `notes`.

## Frontend routes (SECTION KAMI)

- Subventions: `/subsidies` (legacy `/sub` redirects to `/subsidies`).

const swaggerJsdoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'DZCheptel API',
      version: '2.0.0',
      description: 'API de traçabilité animale nationale — DZCheptel (HB Technologies SPA)',
    },
    servers: [{ url: 'http://localhost:8000', description: 'Serveur local' }],
    components: {
      securitySchemes: {
        bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
      },
      schemas: {

        // ─── Utilitaires ──────────────────────────────────────────────────────
        Error: {
          type: 'object',
          properties: { message: { type: 'string', example: 'Message d\'erreur' } },
        },
        MessageResponse: {
          type: 'object',
          properties: { message: { type: 'string', example: 'Opération réussie' } },
        },

        // ─── Auth ─────────────────────────────────────────────────────────────
        LoginRequest: {
          type: 'object',
          required: ['username', 'password'],
          properties: {
            username: { type: 'string', example: 'fermier1' },
            password: { type: 'string', example: 'password123' },
          },
        },
        LoginResponse: {
          type: 'object',
          properties: {
            token:    { type: 'string', example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' },
            role:     { type: 'string', enum: ['Farmer', 'Veterinarian', 'Inspector', 'Administrator'] },
            username: { type: 'string', example: 'fermier1' },
            userId:   { type: 'integer', example: 3 },
            fullName: { type: 'string', example: 'Ahmed Benali' },
            farmId:   { type: 'integer', nullable: true, example: 2, description: 'Rempli uniquement si rôle Farmer' },
            farmName: { type: 'string', nullable: true, example: 'Ferme El Baraka' },
          },
        },
        RegisterRequest: {
          type: 'object',
          required: ['username', 'password', 'email'],
          properties: {
            username:  { type: 'string', example: 'ahmed123' },
            password:  { type: 'string', minLength: 6, example: 'monMotDePasse' },
            email:     { type: 'string', format: 'email', example: 'ahmed@email.com' },
            firstName: { type: 'string', example: 'Ahmed' },
            lastName:  { type: 'string', example: 'Benali' },
            fullName:  { type: 'string', example: 'Ahmed Benali', description: 'Alternatif à firstName+lastName (Flutter)' },
            role:      { type: 'string', enum: ['Farmer', 'Veterinarian', 'Inspector'], default: 'Farmer' },
            phone:     { type: 'string', example: '0555000000' },
          },
        },

        // ─── Animal ��──────────────────────────────────────────────────────────
        AnimalResponse: {
          type: 'object',
          properties: {
            id:           { type: 'integer', example: 12 },
            rfidCode:     { type: 'string', nullable: true, example: 'DZ-2026-0001' },
            species:      { type: 'string', example: 'Ovin', enum: ['Ovin', 'Bovin', 'Caprin', 'Autre'] },
            breed:        { type: 'string', nullable: true, example: 'Ouled Djellal' },
            gender:       { type: 'string', enum: ['Male', 'Female', 'Unknown'] },
            birthDate:    { type: 'string', format: 'date', nullable: true },
            weight:       { type: 'number', nullable: true, example: 45.5 },
            notes:        { type: 'string', nullable: true },
            lifeStatus:   { type: 'string', enum: ['Active', 'Sold', 'Dead', 'Lost', 'Slaughtered'] },
            healthStatus: { type: 'string', enum: ['Healthy', 'UnderTreatment', 'Critical', 'Quarantined'] },
            farmName:     { type: 'string', example: 'Ferme El Baraka' },
            farmLocation: { type: 'string', nullable: true },
          },
        },
        CreateAnimalRequest: {
          type: 'object',
          required: ['species'],
          properties: {
            rfidCode:  { type: 'string', example: 'DZ-2026-0001', description: 'Optionnel — tag créé automatiquement si fourni' },
            species:   { type: 'string', example: 'Ovin', enum: ['Ovin', 'Bovin', 'Caprin', 'Autre'] },
            gender:    { type: 'string', enum: ['Male', 'Female', 'Unknown'], default: 'Unknown' },
            birthDate: { type: 'string', format: 'date', example: '2024-03-15' },
            weight:    { type: 'number', example: 32.5 },
            notes:     { type: 'string', example: 'Agneau né en mars' },
          },
        },
        CreateAnimalResponse: {
          type: 'object',
          properties: {
            message: { type: 'string', example: 'Animal créé avec succès' },
            animal: {
              type: 'object',
              properties: {
                id:        { type: 'integer', example: 12 },
                rfidCode:  { type: 'string', nullable: true },
                species:   { type: 'string' },
                gender:    { type: 'string' },
                birthDate: { type: 'string', nullable: true },
                weight:    { type: 'number', nullable: true },
                notes:     { type: 'string', nullable: true },
              },
            },
          },
        },
        UpdateAnimalRequest: {
          type: 'object',
          description: 'Tous les champs sont optionnels — seuls ceux fournis seront mis à jour',
          properties: {
            species:      { type: 'string', enum: ['Ovin', 'Bovin', 'Caprin', 'Autre'] },
            breed:        { type: 'string' },
            gender:       { type: 'string', enum: ['Male', 'Female', 'Unknown'] },
            birthDate:    { type: 'string', format: 'date' },
            weight:       { type: 'number' },
            notes:        { type: 'string' },
            lifeStatus:   { type: 'string', enum: ['Active', 'Sold', 'Dead', 'Lost', 'Slaughtered'] },
            healthStatus: { type: 'string', enum: ['Healthy', 'UnderTreatment', 'Critical', 'Quarantined'] },
          },
        },

        // ─── Farm ─────────────────────────────────────────────────────────────
        FarmResponse: {
          type: 'object',
          properties: {
            id:             { type: 'integer', example: 1 },
            owner_id:       { type: 'integer', example: 3 },
            owner_name:     { type: 'string', example: 'Ahmed Benali' },
            owner_username: { type: 'string', example: 'ahmed123' },
            name:           { type: 'string', example: 'Ferme El Baraka' },
            location:       { type: 'string', example: 'Sétif, Algérie', nullable: true },
            latitude:       { type: 'number', example: 36.19, nullable: true },
            longitude:      { type: 'number', example: 5.41, nullable: true },
            capacity:       { type: 'integer', example: 200, nullable: true, description: 'Capacité en hectares' },
            status:         { type: 'string', enum: ['Active', 'Suspended', 'Closed'], example: 'Active' },
            is_verified:    { type: 'boolean', example: false },
            animal_count:   { type: 'integer', example: 45 },
            created_at:     { type: 'string', format: 'date-time' },
            updated_at:     { type: 'string', format: 'date-time' },
          },
        },
        CreateFarmRequest: {
          type: 'object',
          required: ['name'],
          properties: {
            name:      { type: 'string', example: 'Ferme El Baraka' },
            location:  { type: 'string', example: 'Sétif, Algérie' },
            latitude:  { type: 'number', example: 36.19 },
            longitude: { type: 'number', example: 5.41 },
            capacity:  { type: 'integer', example: 200, description: 'Capacité en hectares' },
            status:    { type: 'string', enum: ['Active', 'Suspended', 'Closed'], default: 'Active' },
          },
        },
        UpdateFarmRequest: {
          type: 'object',
          description: 'Tous les champs sont optionnels',
          properties: {
            name:       { type: 'string' },
            location:   { type: 'string' },
            latitude:   { type: 'number' },
            longitude:  { type: 'number' },
            capacity:   { type: 'integer' },
            status:     { type: 'string', enum: ['Active', 'Suspended', 'Closed'] },
            isVerified: { type: 'boolean', description: 'Réservé à l\'administrateur' },
          },
        },

        // ─── Movements ────────────────────────────────────────────────────────
        MovementResponse: {
          type: 'object',
          properties: {
            id:               { type: 'integer', example: 7 },
            animal_id:        { type: 'integer', example: 12 },
            species:          { type: 'string', example: 'Ovin' },
            breed:            { type: 'string', nullable: true },
            rfid_code:        { type: 'string', nullable: true },
            from_farm_id:     { type: 'integer', example: 1 },
            from_farm_name:   { type: 'string', example: 'Ferme El Baraka' },
            to_farm_id:       { type: 'integer', example: 2 },
            to_farm_name:     { type: 'string', example: 'Ferme Beni Slimane' },
            reason:           { type: 'string', nullable: true, example: 'Vente' },
            move_date:        { type: 'string', format: 'date-time', nullable: true },
            approval_status:  { type: 'string', enum: ['Pending', 'Approved', 'Rejected'] },
            approved_by:      { type: 'integer', nullable: true },
            approved_by_name: { type: 'string', nullable: true },
            notes:            { type: 'string', nullable: true },
            created_at:       { type: 'string', format: 'date-time' },
          },
        },
        CreateMovementRequest: {
          type: 'object',
          required: ['animalId', 'fromFarmId', 'toFarmId'],
          properties: {
            animalId:   { type: 'integer', example: 12 },
            fromFarmId: { type: 'integer', example: 1 },
            toFarmId:   { type: 'integer', example: 2 },
            reason:     { type: 'string', example: 'Vente', nullable: true },
            moveDate:   { type: 'string', format: 'date-time', nullable: true },
            notes:      { type: 'string', nullable: true },
          },
        },
        ApproveMovementRequest: {
          type: 'object',
          required: ['status'],
          properties: {
            status: { type: 'string', enum: ['Approved', 'Rejected'], example: 'Approved' },
          },
        },

        // ─── Health Records ───────────────────────────────────────────────────
        HealthRecordResponse: {
          type: 'object',
          properties: {
            id:              { type: 'integer', example: 5 },
            animal_id:       { type: 'integer', example: 12 },
            species:         { type: 'string', example: 'Ovin' },
            rfid_code:       { type: 'string', nullable: true },
            veterinarian_id: { type: 'integer', nullable: true },
            vet_name:        { type: 'string', nullable: true, example: 'Dr. Karim Madi' },
            record_type:     { type: 'string', enum: ['Vaccination', 'Treatment', 'Disease', 'Checkup', 'Surgery', 'LabTest', 'Injury'] },
            diagnosis:       { type: 'string', nullable: true },
            symptoms:        { type: 'string', nullable: true },
            treatment_plan:  { type: 'string', nullable: true },
            visit_date:      { type: 'string', format: 'date-time', nullable: true },
            next_visit_date: { type: 'string', format: 'date', nullable: true },
            is_validated:    { type: 'boolean', example: false },
            notes:           { type: 'string', nullable: true },
            created_at:      { type: 'string', format: 'date-time' },
          },
        },
        CreateHealthRecordRequest: {
          type: 'object',
          required: ['animalId', 'recordType'],
          properties: {
            animalId:       { type: 'integer', example: 12 },
            recordType:     { type: 'string', enum: ['Vaccination', 'Treatment', 'Disease', 'Checkup', 'Surgery', 'LabTest', 'Injury'], example: 'Vaccination' },
            diagnosis:      { type: 'string', nullable: true, example: 'Pasteurellose' },
            symptoms:       { type: 'string', nullable: true },
            treatmentPlan:  { type: 'string', nullable: true },
            visitDate:      { type: 'string', format: 'date-time', nullable: true },
            nextVisitDate:  { type: 'string', format: 'date', nullable: true },
            notes:          { type: 'string', nullable: true },
          },
        },
        UpdateHealthRecordRequest: {
          type: 'object',
          description: 'Tous les champs sont optionnels',
          properties: {
            recordType:     { type: 'string', enum: ['Vaccination', 'Treatment', 'Disease', 'Checkup', 'Surgery', 'LabTest', 'Injury'] },
            diagnosis:      { type: 'string' },
            symptoms:       { type: 'string' },
            treatmentPlan:  { type: 'string' },
            visitDate:      { type: 'string', format: 'date-time' },
            nextVisitDate:  { type: 'string', format: 'date' },
            isValidated:    { type: 'boolean' },
            notes:          { type: 'string' },
          },
        },
        // Alias gardé pour compatibilité avec l'ancien endpoint /api/vet/health-record
        HealthRecordRequest: {
          type: 'object',
          required: ['rfidCode', 'recordType'],
          properties: {
            rfidCode:      { type: 'string', example: 'DZ-0007', description: 'Aussi accepté sous le nom rfidTag' },
            rfidTag:       { type: 'string', description: 'Alias de rfidCode (Flutter)' },
            recordType:    { type: 'string', enum: ['Vaccination', 'Treatment', 'Disease', 'Checkup', 'Surgery', 'LabTest', 'Injury'] },
            diagnosis:     { type: 'string', nullable: true },
            treatmentPlan: { type: 'string', nullable: true },
            treatment:     { type: 'string', description: 'Alias de treatmentPlan (Flutter)' },
          },
        },

        // ─── Vaccinations ─────────────────────────────────────────────────────
        VaccinationResponse: {
          type: 'object',
          properties: {
            id:                   { type: 'integer', example: 3 },
            health_record_id:     { type: 'integer', example: 5 },
            record_type:          { type: 'string' },
            visit_date:           { type: 'string', format: 'date-time' },
            species:              { type: 'string' },
            rfid_code:            { type: 'string', nullable: true },
            vaccine_name:         { type: 'string', example: 'Bluetongue BTV' },
            vaccine_type:         { type: 'string', nullable: true, example: 'Vivant atténué' },
            manufacturer:         { type: 'string', nullable: true, example: 'MSD Animal Health' },
            batch_number:         { type: 'string', nullable: true },
            dose:                 { type: 'string', nullable: true, example: '2ml' },
            expiration_date:      { type: 'string', format: 'date', nullable: true },
            next_dose_date:       { type: 'string', format: 'date', nullable: true },
            administered_by:      { type: 'integer', nullable: true },
            administered_by_name: { type: 'string', nullable: true },
            created_at:           { type: 'string', format: 'date-time' },
          },
        },
        CreateVaccinationRequest: {
          type: 'object',
          required: ['healthRecordId', 'vaccineName'],
          properties: {
            healthRecordId:  { type: 'integer', example: 5 },
            vaccineName:     { type: 'string', example: 'Bluetongue BTV' },
            vaccineType:     { type: 'string', nullable: true, example: 'Vivant atténué' },
            manufacturer:    { type: 'string', nullable: true, example: 'MSD Animal Health' },
            batchNumber:     { type: 'string', nullable: true },
            dose:            { type: 'string', nullable: true, example: '2ml' },
            expirationDate:  { type: 'string', format: 'date', nullable: true },
            nextDoseDate:    { type: 'string', format: 'date', nullable: true },
          },
        },
        UpdateVaccinationRequest: {
          type: 'object',
          description: 'Tous les champs sont optionnels',
          properties: {
            vaccineName:    { type: 'string' },
            vaccineType:    { type: 'string' },
            manufacturer:   { type: 'string' },
            batchNumber:    { type: 'string' },
            dose:           { type: 'string' },
            expirationDate: { type: 'string', format: 'date' },
            nextDoseDate:   { type: 'string', format: 'date' },
          },
        },

        // ─── Subsidies ────────────────────────────────────────────────────────
        SubsidyResponse: {
          type: 'object',
          properties: {
            id:               { type: 'integer', example: 4 },
            animal_id:        { type: 'integer', nullable: true },
            species:          { type: 'string', nullable: true },
            rfid_code:        { type: 'string', nullable: true },
            amount:           { type: 'number', example: 15000, description: 'Montant en DZD' },
            subsidy_type:     { type: 'string', example: 'Aide Bio' },
            status:           { type: 'string', enum: ['Pending', 'Approved', 'Rejected', 'Paid'] },
            request_date:     { type: 'string', format: 'date-time' },
            approved_date:    { type: 'string', format: 'date-time', nullable: true },
            paid_date:        { type: 'string', format: 'date-time', nullable: true },
            approved_by:      { type: 'integer', nullable: true },
            approved_by_name: { type: 'string', nullable: true },
            notes:            { type: 'string', nullable: true },
            created_at:       { type: 'string', format: 'date-time' },
          },
        },
        CreateSubsidyRequest: {
          type: 'object',
          required: ['amount', 'subsidyType'],
          properties: {
            animalId:    { type: 'integer', nullable: true, example: 12 },
            amount:      { type: 'number', example: 15000, description: 'Montant en DZD — doit être > 0' },
            subsidyType: { type: 'string', example: 'Aide Bio', description: 'ex: Aide Bio, Bien-être animal, Modernisation' },
            notes:       { type: 'string', nullable: true },
          },
        },
        UpdateSubsidyStatusRequest: {
          type: 'object',
          required: ['status'],
          properties: {
            status: {
              type: 'string',
              enum: ['Pending', 'Approved', 'Rejected', 'Paid'],
              example: 'Approved',
              description: 'Approved auto-renseigne approved_date. Paid auto-renseigne paid_date.',
            },
          },
        },

        // ─── Scan Sessions ────────────────────────────────────────────────────
        ScanSessionResponse: {
          type: 'object',
          properties: {
            id:               { type: 'integer', example: 2 },
            controller_id:    { type: 'integer' },
            controller_name:  { type: 'string', example: 'Inspecteur Samir' },
            farm_id:          { type: 'integer' },
            farm_name:        { type: 'string', example: 'Ferme El Baraka' },
            session_date:     { type: 'string', format: 'date-time' },
            total_scanned:    { type: 'integer', example: 47 },
            total_registered: { type: 'integer', example: 50 },
            difference:       { type: 'integer', example: -3, description: 'Calculé automatiquement par MySQL (GENERATED)' },
            is_consistent:    { type: 'boolean', example: false },
            status:           { type: 'string', enum: ['Pending', 'Confirmed', 'Disputed'] },
            confirmed_at:     { type: 'string', format: 'date-time', nullable: true },
            notes:            { type: 'string', nullable: true },
            created_at:       { type: 'string', format: 'date-time' },
          },
        },
        ScanSessionDetailResponse: {
          allOf: [
            { '$ref': '#/components/schemas/ScanSessionResponse' },
            {
              type: 'object',
              properties: {
                scannedTags: {
                  type: 'array',
                  description: 'Tags RFID lus pendant cette session',
                  items: {
                    type: 'object',
                    properties: {
                      id:         { type: 'integer' },
                      tag_id:     { type: 'integer' },
                      rfid_code:  { type: 'string' },
                      tag_status: { type: 'string' },
                    },
                  },
                },
              },
            },
          ],
        },
        CreateScanSessionRequest: {
          type: 'object',
          required: ['farmId'],
          properties: {
            farmId:          { type: 'integer', example: 1 },
            totalScanned:    { type: 'integer', example: 47, description: 'Nombre d\'animaux détectés par le lecteur UHF' },
            totalRegistered: { type: 'integer', example: 50, description: 'Nombre d\'animaux enregistrés en BD pour cette ferme' },
            isConsistent:    { type: 'boolean', example: false },
            notes:           { type: 'string', nullable: true },
            scannedTagCodes: {
              type: 'array',
              items: { type: 'string' },
              example: ['DZ-0001', 'DZ-0002'],
              description: 'Optionnel — codes RFID des tags scannés pour liaison en BD',
            },
          },
        },

        // ─── RFID Tags ���───────────────────────────────────────────────────────
        RfidTagResponse: {
          type: 'object',
          properties: {
            id:         { type: 'integer', example: 8 },
            rfid_code:  { type: 'string', example: 'DZ-2026-0008' },
            tag_type:   { type: 'string', enum: ['UHF', 'NFC'] },
            tag_status: { type: 'string', enum: ['InStock', 'Assigned', 'Defective', 'Lost'] },
            animal_id:  { type: 'integer', nullable: true, description: 'Null si le tag n\'est pas assigné' },
            species:    { type: 'string', nullable: true },
            farm_name:  { type: 'string', nullable: true },
            created_at: { type: 'string', format: 'date-time' },
          },
        },
        CreateRfidTagRequest: {
          type: 'object',
          required: ['rfidCode'],
          properties: {
            rfidCode: { type: 'string', example: 'DZ-2026-0099' },
            tagType:  { type: 'string', enum: ['UHF', 'NFC'], default: 'UHF' },
          },
        },
        UpdateRfidTagRequest: {
          type: 'object',
          properties: {
            tagStatus: { type: 'string', enum: ['InStock', 'Assigned', 'Defective', 'Lost'] },
            tagType:   { type: 'string', enum: ['UHF', 'NFC'] },
          },
        },

        // ─── Inspection ───────────────────────────────────────────────────────
        InspectionResponse: {
          type: 'object',
          properties: {
            id:               { type: 'integer', example: 10 },
            inspector_id:     { type: 'integer' },
            inspector_name:   { type: 'string', example: 'Inspecteur Samir Hadj' },
            animal_id:        { type: 'integer', nullable: true },
            species:          { type: 'string', nullable: true },
            rfid_code:        { type: 'string', nullable: true },
            constat_type:     { type: 'string', example: 'General' },
            description:      { type: 'string' },
            result:           { type: 'string', enum: ['Compliant', 'Fraud', 'Suspicious', 'Pending'] },
            status:           { type: 'string', enum: ['Pending', 'UnderReview', 'Resolved', 'Rejected'] },
            scanned_count:    { type: 'integer', nullable: true },
            registered_count: { type: 'integer', nullable: true },
            difference:       { type: 'integer', nullable: true, description: 'GENERATED par MySQL' },
            geo_latitude:     { type: 'number', nullable: true },
            geo_longitude:    { type: 'number', nullable: true },
            resolved_at:      { type: 'string', format: 'date-time', nullable: true },
            resolved_by:      { type: 'integer', nullable: true },
            inspection_date:  { type: 'string', format: 'date-time' },
            created_at:       { type: 'string', format: 'date-time' },
          },
        },
        InspectionRequest: {
          type: 'object',
          required: ['description'],
          properties: {
            description:  { type: 'string', example: 'Suspicion de brucellose sur 3 animaux' },
            constatType:  { type: 'string', enum: ['General', 'Sanitaire', 'Fraude', 'Inventaire'], default: 'General' },
            result:       { type: 'string', enum: ['Compliant', 'Fraud', 'Suspicious', 'Pending'], default: 'Pending' },
            animalId:     { type: 'integer', nullable: true },
          },
        },
        UpdateInspectionStatusRequest: {
          type: 'object',
          properties: {
            status: { type: 'string', enum: ['Pending', 'UnderReview', 'Resolved', 'Rejected'] },
            result: { type: 'string', enum: ['Compliant', 'Fraud', 'Suspicious', 'Pending'] },
          },
        },
        VerifyScanRequest: {
          type: 'object',
          required: ['farmId', 'scannedTags'],
          properties: {
            farmId:      { type: 'integer', example: 1 },
            scannedTags: {
              type: 'array',
              items: { type: 'string' },
              example: ['DZ-0007', 'DZ-0008', 'DZ-0009'],
            },
          },
        },
        VerifyScanResponse: {
          type: 'object',
          properties: {
            farmName:        { type: 'string' },
            registeredCount: { type: 'integer' },
            scannedCount:    { type: 'integer' },
            difference:      { type: 'integer' },
            unknownTags:     { type: 'array', items: { type: 'string' } },
            missingTags:     { type: 'array', items: { type: 'string' } },
            isConsistent:    { type: 'boolean' },
          },
        },

        // ─── Animal Status History ──���─────────────────────────────────────────
        AnimalStatusHistoryResponse: {
          type: 'object',
          properties: {
            id:                 { type: 'integer', example: 1 },
            animal_id:          { type: 'integer', example: 12 },
            species:            { type: 'string', example: 'Ovin' },
            rfid_code:          { type: 'string', nullable: true },
            changed_by:         { type: 'integer', nullable: true },
            changed_by_name:    { type: 'string', nullable: true, example: 'Dr. Karim Madi' },
            old_life_status:    { type: 'string', nullable: true, example: 'Active' },
            new_life_status:    { type: 'string', nullable: true, example: 'Sold' },
            old_health_status:  { type: 'string', nullable: true },
            new_health_status:  { type: 'string', nullable: true },
            reason:             { type: 'string', nullable: true },
            changed_at:         { type: 'string', format: 'date-time' },
          },
        },

      },
    },
    security: [{ bearerAuth: [] }],
  },
  apis: ['./Routes/*.js'],
};

module.exports = swaggerJsdoc(options);

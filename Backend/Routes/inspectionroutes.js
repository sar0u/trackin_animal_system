const express = require('express');
const router = express.Router();
const inspectionController = require('../Controllers/inspectioncontroller');    
const auth = require('../middleware/auth');

/**
 * @swagger
 * tags:
 * name: Inspections
 * description: Opérations de contrôle effectuées par les inspecteurs
 */

/**
 * @swagger
 * /api/inspections:
 * post:
 * summary: Créer un rapport d'inspection (Fraude/Santé)
 * tags: [Inspections]
 * security:
 * - bearerAuth: []
 * requestBody:
 * required: true
 * content:
 * application/json:
 * schema:
 * type: object
 * properties:
 * rfid: { type: string }
 * result: { type: string, enum: [Healthy, Fraud, Sick] }
 * notes: { type: string }
 * latitude: { type: number }
 * longitude: { type: number }
 * responses:
 * 201:
 * description: Inspection enregistrée avec succès
 * 401:
 * description: Non autorisé (Token manquant ou invalide)
 */
router.post('/api/inspections', auth, inspectionController.createInspection);

module.exports = router;
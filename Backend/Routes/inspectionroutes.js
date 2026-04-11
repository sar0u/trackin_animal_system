const express = require('express');
const router = express.Router();
const inspectionController = require('../Controllers/inspectioncontroller');
const auth = require('../middleware/auth');


/**
 * @swagger
 * tags:
 *   name: Inspections
 *   description: Contrôle terrain et détection de fraude
 */

/**
 * @swagger
 * /api/inspections:
 *   get:
 *     tags: [Inspections]
 *     summary: Liste de toutes les inspections
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des inspections triées par date
 *   post:
 *     tags: [Inspections]
 *     summary: Créer un rapport d'inspection terrain
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [latitude, longitude, result]
 *             properties:
 *               animalId:
 *                 type: integer
 *               farmId:
 *                 type: integer
 *               latitude:
 *                 type: number
 *                 example: 36.7372
 *               longitude:
 *                 type: number
 *                 example: 3.0868
 *               locationDescription:
 *                 type: string
 *               result:
 *                 type: string
 *                 enum: [Compliant, NonCompliant, Suspicious]
 *               fraudType:
 *                 type: string
 *                 enum: [None, Duplicate, FakeAnimal, Inconsistency]
 *               notes:
 *                 type: string
 *     responses:
 *       201:
 *         description: Inspection enregistrée avec succès
 *       500:
 *         description: Erreur serveur
 */
router.get('/', auth, inspectionController.getAllInspections);
router.post('/', auth, inspectionController.createInspection);

module.exports = router;
const express = require('express');
const router  = express.Router();
const ctrl    = require('../Controllers/VetController');
const { authMiddleware, requireRole } = require('../middleware/Auth');

router.use(authMiddleware, requireRole('Veterinarian'));

/**
 * @swagger
 * tags:
 *   name: Veterinarian
 *   description: Endpoints réservés aux vétérinaires
 */

/**
 * @swagger
 * /api/vet/farms:
 *   get:
 *     summary: Lister toutes les fermes avec nombre d'animaux
 *     tags: [Veterinarian]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des fermes
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id:           { type: integer }
 *                   name:         { type: string }
 *                   location:     { type: string }
 *                   first_name:   { type: string }
 *                   last_name:    { type: string }
 *                   animal_count: { type: integer }
 */
router.get('/farms', ctrl.getAllFarms);

/**
 * @swagger
 * /api/vet/farm/{farmId}/animals:
 *   get:
 *     summary: Lister les animaux d'une ferme spécifique
 *     tags: [Veterinarian]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: farmId
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Liste des animaux de la ferme
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/AnimalResponse'
 *       404:
 *         description: Ferme non trouvée
 */
router.get('/farm/:farmId/animals', ctrl.getAnimalsByFarm);

/**
 * @swagger
 * /api/vet/scan/{rfidCode}:
 *   get:
 *     summary: Scanner un animal et obtenir sa fiche santé complète
 *     tags: [Veterinarian]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: rfidCode
 *         required: true
 *         schema:
 *           type: string
 *         example: DZ-0007
 *     responses:
 *       200:
 *         description: Fiche santé complète de l'animal
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 rfidCode:      { type: string }
 *                 species:       { type: string }
 *                 breed:         { type: string }
 *                 gender:        { type: string }
 *                 lifeStatus:    { type: string }
 *                 healthStatus:  { type: string }
 *                 farmName:      { type: string }
 *                 healthRecords:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:             { type: integer }
 *                       record_type:    { type: string }
 *                       diagnosis:      { type: string }
 *                       treatment_plan: { type: string }
 *                       visit_date:     { type: string, format: date-time }
 *                       first_name:     { type: string }
 *                       last_name:      { type: string }
 *       404:
 *         description: Animal non trouvé
 */
router.get('/scan/:rfidCode', ctrl.scanAnimal);

/**
 * @swagger
 * /api/vet/health-record:
 *   post:
 *     summary: Ajouter un dossier médical à un animal
 *     tags: [Veterinarian]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/HealthRecordRequest'
 *     responses:
 *       200:
 *         description: Dossier médical ajouté avec succès
 *       400:
 *         description: rfidCode et recordType obligatoires
 *       404:
 *         description: Animal non trouvé
 */
router.post('/health-record', ctrl.addHealthRecord);

module.exports = router;
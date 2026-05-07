const express = require('express');
const router  = express.Router();
const ctrl    = require('../Controllers/HealthRecordController');
const { authMiddleware, requireRole } = require('../middleware/Auth');

router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   name: HealthRecords
 *   description: Dossiers médicaux des animaux
 */

/**
 * @swagger
 * /api/health-records:
 *   get:
 *     summary: Lister tous les dossiers médicaux
 *     tags: [HealthRecords]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des dossiers médicaux avec infos animal et vétérinaire
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/HealthRecordResponse'
 *       500:
 *         description: Erreur serveur
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/', ctrl.getAll);

/**
 * @swagger
 * /api/health-records/animal/{animalId}:
 *   get:
 *     summary: Lister les dossiers médicaux d'un animal
 *     description: Retourne l'historique médical complet trié par date de visite DESC.
 *     tags: [HealthRecords]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: animalId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de l'animal
 *     responses:
 *       200:
 *         description: Historique médical de l'animal
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/HealthRecordResponse'
 *       404:
 *         description: Animal non trouvé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/animal/:animalId', ctrl.getByAnimal);

/**
 * @swagger
 * /api/health-records/{id}:
 *   get:
 *     summary: Détail d'un dossier médical
 *     tags: [HealthRecords]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Dossier médical avec infos animal et vétérinaire
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/HealthRecordResponse'
 *       404:
 *         description: Dossier médical non trouvé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/:id', ctrl.getById);

/**
 * @swagger
 * /api/health-records:
 *   post:
 *     summary: Créer un dossier médical
 *     description: |
 *       Crée un dossier médical lié à un animal par son ID.
 *       Le vétérinaire connecté est automatiquement enregistré comme auteur.
 *       Types acceptés : Vaccination, Treatment, Disease, Checkup, Surgery, LabTest, Injury.
 *     tags: [HealthRecords]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateHealthRecordRequest'
 *     responses:
 *       201:
 *         description: Dossier médical créé avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:  { type: string, example: 'Dossier médical créé avec succès' }
 *                 recordId: { type: integer, example: 5 }
 *       400:
 *         description: Champs obligatoires manquants ou recordType invalide
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Animal non trouvé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post('/', requireRole('Veterinarian', 'Administrator'), ctrl.create);

/**
 * @swagger
 * /api/health-records/{id}:
 *   put:
 *     summary: Modifier un dossier médical
 *     description: Tous les champs sont optionnels. Le champ isValidated permet au vétérinaire de valider le dossier.
 *     tags: [HealthRecords]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UpdateHealthRecordRequest'
 *     responses:
 *       200:
 *         description: Dossier médical modifié avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       404:
 *         description: Dossier médical non trouvé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.put('/:id', requireRole('Veterinarian', 'Administrator'), ctrl.update);

/**
 * @swagger
 * /api/health-records/{id}:
 *   delete:
 *     summary: Supprimer un dossier médical (Administrateur uniquement)
 *     tags: [HealthRecords]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Dossier médical supprimé avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       404:
 *         description: Dossier médical non trouvé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.delete('/:id', requireRole('Administrator'), ctrl.remove);

module.exports = router;

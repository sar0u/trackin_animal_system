const express = require('express');
const router  = express.Router();
const ctrl    = require('../Controllers/VaccinationController');
const { authMiddleware, requireRole } = require('../middleware/Auth');

router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   name: Vaccinations
 *   description: Enregistrements des vaccinations animales
 */

/**
 * @swagger
 * /api/vaccinations:
 *   get:
 *     summary: Lister toutes les vaccinations
 *     tags: [Vaccinations]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des vaccinations avec infos animal et vétérinaire
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/VaccinationResponse'
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
 * /api/vaccinations/record/{recordId}:
 *   get:
 *     summary: Lister les vaccinations d'un dossier médical
 *     description: Retourne toutes les vaccinations associées à un dossier de type Vaccination.
 *     tags: [Vaccinations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: recordId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID du dossier médical parent
 *     responses:
 *       200:
 *         description: Liste des vaccinations du dossier
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/VaccinationResponse'
 *       404:
 *         description: Dossier médical non trouvé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/record/:recordId', ctrl.getByRecord);

/**
 * @swagger
 * /api/vaccinations/{id}:
 *   get:
 *     summary: Détail d'une vaccination
 *     tags: [Vaccinations]
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
 *         description: Détail de la vaccination
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/VaccinationResponse'
 *       404:
 *         description: Vaccination non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/:id', ctrl.getById);

/**
 * @swagger
 * /api/vaccinations:
 *   post:
 *     summary: Enregistrer une vaccination
 *     description: |
 *       Lie une vaccination à un dossier médical existant (health_record_id).
 *       Le vétérinaire connecté est automatiquement enregistré comme administrateur du vaccin.
 *     tags: [Vaccinations]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateVaccinationRequest'
 *     responses:
 *       201:
 *         description: Vaccination enregistrée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:       { type: string, example: 'Vaccination enregistrée avec succès' }
 *                 vaccinationId: { type: integer, example: 3 }
 *       400:
 *         description: healthRecordId ou vaccineName manquant
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Dossier médical non trouvé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post('/', requireRole('Veterinarian', 'Administrator'), ctrl.create);

/**
 * @swagger
 * /api/vaccinations/{id}:
 *   put:
 *     summary: Modifier une vaccination
 *     description: Tous les champs sont optionnels — seuls ceux fournis seront mis à jour.
 *     tags: [Vaccinations]
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
 *             $ref: '#/components/schemas/UpdateVaccinationRequest'
 *     responses:
 *       200:
 *         description: Vaccination modifiée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       404:
 *         description: Vaccination non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.put('/:id', requireRole('Veterinarian', 'Administrator'), ctrl.update);

/**
 * @swagger
 * /api/vaccinations/{id}:
 *   delete:
 *     summary: Supprimer une vaccination (Administrateur uniquement)
 *     tags: [Vaccinations]
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
 *         description: Vaccination supprimée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       404:
 *         description: Vaccination non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.delete('/:id', requireRole('Administrator'), ctrl.remove);

module.exports = router;

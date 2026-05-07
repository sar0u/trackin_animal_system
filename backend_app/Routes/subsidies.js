const express = require('express');
const router  = express.Router();
const ctrl    = require('../Controllers/SubsidyController');
const { authMiddleware, requireRole } = require('../middleware/Auth');

router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   name: Subsidies
 *   description: Gestion des subventions et aides financières
 */

/**
 * @swagger
 * /api/subsidies:
 *   get:
 *     summary: Lister toutes les subventions
 *     tags: [Subsidies]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des subventions avec infos animal et approbateur
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/SubsidyResponse'
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
 * /api/subsidies/{id}:
 *   get:
 *     summary: Détail d'une subvention
 *     tags: [Subsidies]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la subvention
 *     responses:
 *       200:
 *         description: Détail de la subvention
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/SubsidyResponse'
 *       404:
 *         description: Subvention non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/:id', ctrl.getById);

/**
 * @swagger
 * /api/subsidies:
 *   post:
 *     summary: Créer une demande de subvention
 *     description: |
 *       Crée une subvention en statut Pending.
 *       Le montant doit être > 0 (en DZD).
 *       Le champ animalId est optionnel — la subvention peut être globale.
 *     tags: [Subsidies]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateSubsidyRequest'
 *     responses:
 *       201:
 *         description: Subvention créée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:   { type: string, example: 'Subvention créée avec succès' }
 *                 subsidyId: { type: integer, example: 4 }
 *       400:
 *         description: Champs obligatoires manquants ou montant invalide
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
router.post('/', requireRole('Inspector', 'Administrator'), ctrl.create);

/**
 * @swagger
 * /api/subsidies/{id}/status:
 *   put:
 *     summary: Changer le statut d'une subvention
 *     description: |
 *       Workflow de statut : Pending → Approved → Paid / Rejected
 *       - Passer à **Approved** renseigne automatiquement `approved_date` et `approved_by`
 *       - Passer à **Paid** renseigne automatiquement `paid_date`
 *     tags: [Subsidies]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UpdateSubsidyStatusRequest'
 *     responses:
 *       200:
 *         description: Statut mis à jour avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       400:
 *         description: Statut invalide
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Subvention non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.put('/:id/status', requireRole('Inspector', 'Administrator'), ctrl.updateStatus);

/**
 * @swagger
 * /api/subsidies/{id}:
 *   put:
 *     summary: Modifier une subvention en attente
 *     description: Seules les subventions avec status = 'Pending' peuvent être modifiées.
 *     tags: [Subsidies]
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
 *             type: object
 *             properties:
 *               amount:      { type: number, description: 'Montant en DZD' }
 *               subsidyType: { type: string }
 *               notes:       { type: string }
 *     responses:
 *       200:
 *         description: Subvention modifiée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       400:
 *         description: Subvention déjà traitée (non Pending)
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Subvention non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.put('/:id', requireRole('Inspector', 'Administrator'), ctrl.update);

/**
 * @swagger
 * /api/subsidies/{id}:
 *   delete:
 *     summary: Supprimer une subvention (Administrateur uniquement)
 *     tags: [Subsidies]
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
 *         description: Subvention supprimée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       404:
 *         description: Subvention non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.delete('/:id', requireRole('Administrator'), ctrl.remove);

module.exports = router;

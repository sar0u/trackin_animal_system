const express = require('express');
const router  = express.Router();
const ctrl    = require('../Controllers/MovementController');
const { authMiddleware, requireRole } = require('../middleware/Auth');

router.use(authMiddleware, requireRole('Farmer'));

/**
 * @swagger
 * tags:
 *   name: Movements
 *   description: Gestion des transferts d'animaux entre fermes
 */

/**
 * @swagger
 * /api/movements:
 *   get:
 *     summary: Lister tous les mouvements d'animaux
 *     tags: [Movements]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste complète des mouvements avec détails fermes et animal
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/MovementResponse'
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
 * /api/movements/{id}:
 *   get:
 *     summary: Détail d'un mouvement
 *     tags: [Movements]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID du mouvement
 *     responses:
 *       200:
 *         description: Détail du mouvement
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MovementResponse'
 *       404:
 *         description: Mouvement non trouvé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/:id', ctrl.getById);

/**
 * @swagger
 * /api/movements:
 *   post:
 *     summary: Créer un mouvement de transfert
 *     description: |
 *       Crée un mouvement en statut Pending. Le trigger MySQL valide automatiquement que :
 *       - l'animal est en statut Active
 *       - fromFarmId ≠ toFarmId
 *     tags: [Movements]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateMovementRequest'
 *     responses:
 *       201:
 *         description: Mouvement créé avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:    { type: string, example: 'Mouvement créé avec succès' }
 *                 movementId: { type: integer, example: 7 }
 *       400:
 *         description: Champs manquants, fermes identiques, ou animal non actif
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
router.post('/',ctrl.create);

/**
 * @swagger
 * /api/movements/{id}:
 *   put:
 *     summary: Modifier un mouvement en attente
 *     description: Seuls les mouvements avec approval_status = 'Pending' peuvent être modifiés.
 *     tags: [Movements]
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
 *               reason:   { type: string }
 *               moveDate: { type: string, format: date-time }
 *               notes:    { type: string }
 *     responses:
 *       200:
 *         description: Mouvement modifié avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       400:
 *         description: Mouvement déjà traité (Approved ou Rejected)
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Mouvement non trouvé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.put('/:id', ctrl.update);

/**
 * @swagger
 * /api/movements/{id}/approve:
 *   put:
 *     summary: Approuver ou rejeter un mouvement
 *     description: |
 *       Approuver un mouvement déclenche le trigger MySQL `after_movement_approved`
 *       qui met à jour automatiquement `animals.farm_id` vers la ferme de destination.
 *       Seuls les mouvements en statut Pending peuvent être traités.
 *     tags: [Movements]
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
 *             $ref: '#/components/schemas/ApproveMovementRequest'
 *     responses:
 *       200:
 *         description: Mouvement approuvé ou rejeté avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       400:
 *         description: Status invalide ou mouvement déjà traité
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Mouvement non trouvé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.put('/:id/approve', ctrl.approve);

/**
 * @swagger
 * /api/movements/{id}:
 *   delete:
 *     summary: Supprimer un mouvement (Administrateur uniquement)
 *     tags: [Movements]
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
 *         description: Mouvement supprimé avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       404:
 *         description: Mouvement non trouvé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.delete('/:id', requireRole('Administrator'), ctrl.remove);

module.exports = router;

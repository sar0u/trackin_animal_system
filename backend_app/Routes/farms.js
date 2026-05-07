const express = require('express');
const router  = express.Router();
const ctrl    = require('../Controllers/FarmController');
const { authMiddleware, requireRole } = require('../middleware/Auth');

router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   name: Farms
 *   description: Gestion des exploitations agricoles
 */

/**
 * @swagger
 * /api/farms:
 *   get:
 *     summary: Lister toutes les fermes
 *     description: Retourne toutes les fermes avec le nom du propriétaire et le nombre d'animaux.
 *     tags: [Farms]
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
 *                 $ref: '#/components/schemas/FarmResponse'
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
 * /api/farms/{id}:
 *   get:
 *     summary: Détail d'une ferme
 *     tags: [Farms]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la ferme
 *     responses:
 *       200:
 *         description: Détail de la ferme avec comptage d'animaux
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/FarmResponse'
 *       404:
 *         description: Ferme non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/:id', ctrl.getById);

/**
 * @swagger
 * /api/farms:
 *   post:
 *     summary: Créer une ferme
 *     description: |
 *       Le propriétaire (owner_id) est automatiquement le Farmer connecté.
 *       Un Farmer peut avoir plusieurs fermes via cette route (contrairement à l'auto-création à l'inscription).
 *     tags: [Farms]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateFarmRequest'
 *     responses:
 *       201:
 *         description: Ferme créée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string, example: 'Ferme créée avec succès' }
 *                 farmId:  { type: integer, example: 3 }
 *       400:
 *         description: Nom de ferme manquant
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post('/', requireRole('Farmer', 'Administrator'), ctrl.create);

/**
 * @swagger
 * /api/farms/{id}:
 *   put:
 *     summary: Modifier une ferme
 *     description: |
 *       Seul le propriétaire de la ferme ou un Administrateur peut la modifier.
 *       Le champ `isVerified` est réservé à l'Administrateur.
 *     tags: [Farms]
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
 *             $ref: '#/components/schemas/UpdateFarmRequest'
 *     responses:
 *       200:
 *         description: Ferme modifiée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       403:
 *         description: Accès refusé — vous ne possédez pas cette ferme
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Ferme non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.put('/:id', requireRole('Farmer', 'Administrator'), ctrl.update);

/**
 * @swagger
 * /api/farms/{id}:
 *   delete:
 *     summary: Supprimer une ferme (Administrateur uniquement)
 *     tags: [Farms]
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
 *         description: Ferme supprimée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       404:
 *         description: Ferme non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.delete('/:id', requireRole('Administrator'), ctrl.remove);

module.exports = router;

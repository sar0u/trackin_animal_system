const express = require('express');
const router  = express.Router();
const ctrl    = require('../Controllers/RfidTagController');
const { authMiddleware, requireRole } = require('../middleware/Auth');

router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   name: RfidTags
 *   description: Gestion du stock de tags RFID (UHF et NFC)
 */

/**
 * @swagger
 * /api/rfid-tags:
 *   get:
 *     summary: Lister tous les tags RFID
 *     description: Retourne tous les tags avec leur statut et l'animal assigné (si applicable).
 *     tags: [RfidTags]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des tags RFID
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/RfidTagResponse'
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
 * /api/rfid-tags/{id}:
 *   get:
 *     summary: Détail d'un tag RFID
 *     tags: [RfidTags]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID du tag RFID
 *     responses:
 *       200:
 *         description: Détail du tag avec animal assigné
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/RfidTagResponse'
 *       404:
 *         description: Tag RFID non trouvé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/:id', ctrl.getById);

/**
 * @swagger
 * /api/rfid-tags:
 *   post:
 *     summary: Créer un tag RFID (Administrateur uniquement)
 *     description: |
 *       Crée un nouveau tag en statut **InStock**.
 *       Le code RFID doit être unique.
 *       Type par défaut : UHF.
 *     tags: [RfidTags]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateRfidTagRequest'
 *     responses:
 *       201:
 *         description: Tag RFID créé avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string, example: 'Tag RFID créé avec succès' }
 *                 tagId:   { type: integer, example: 8 }
 *       400:
 *         description: rfidCode manquant ou tagType invalide
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       409:
 *         description: Ce code RFID existe déjà
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post('/', requireRole('Administrator'), ctrl.create);

/**
 * @swagger
 * /api/rfid-tags/{id}:
 *   put:
 *     summary: Modifier le statut ou le type d'un tag RFID
 *     description: |
 *       Permet de déclarer un tag comme **Defective** ou **Lost**, ou de modifier son type.
 *       Les transitions de statut liées aux animaux (InStock ↔ Assigned) sont gérées
 *       automatiquement par les triggers MySQL — ne pas forcer ces transitions manuellement.
 *     tags: [RfidTags]
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
 *             $ref: '#/components/schemas/UpdateRfidTagRequest'
 *     responses:
 *       200:
 *         description: Tag RFID modifié avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       400:
 *         description: Valeur de statut ou de type invalide
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Tag RFID non trouvé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.put('/:id', requireRole('Inspector', 'Administrator'), ctrl.update);

/**
 * @swagger
 * /api/rfid-tags/{id}:
 *   delete:
 *     summary: Supprimer un tag RFID (Administrateur uniquement)
 *     description: Impossible de supprimer un tag en statut **Assigned** (assigné à un animal actif).
 *     tags: [RfidTags]
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
 *         description: Tag RFID supprimé avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       400:
 *         description: Tag actuellement assigné à un animal — suppression impossible
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Tag RFID non trouvé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.delete('/:id', requireRole('Administrator'), ctrl.remove);

module.exports = router;

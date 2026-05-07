const express = require('express');
const router  = express.Router();
const ctrl    = require('../Controllers/ScanSessionController');
const { authMiddleware, requireRole } = require('../middleware/Auth');

router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   name: ScanSessions
 *   description: Sessions de scan UHF longue portée — inventaire terrain
 */

/**
 * @swagger
 * /api/scan-sessions:
 *   get:
 *     summary: Lister toutes les sessions de scan
 *     tags: [ScanSessions]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des sessions avec infos ferme et contrôleur
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/ScanSessionResponse'
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
 * /api/scan-sessions/{id}:
 *   get:
 *     summary: Détail d'une session de scan avec les tags lus
 *     description: Retourne la session et la liste complète des tags RFID scannés pendant celle-ci.
 *     tags: [ScanSessions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la session de scan
 *     responses:
 *       200:
 *         description: Session avec liste des tags scannés
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ScanSessionDetailResponse'
 *       404:
 *         description: Session non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/:id', ctrl.getById);

/**
 * @swagger
 * /api/scan-sessions:
 *   post:
 *     summary: Créer une session de scan UHF
 *     description: |
 *       Enregistre une session de scan de terrain.
 *       Le champ `scannedTagCodes` (optionnel) permet de lier les codes RFID scannés à la session
 *       via la table `scanned_tags`. Les codes qui n'existent pas en base sont ignorés.
 *       La colonne `difference` est calculée automatiquement par MySQL (GENERATED ALWAYS AS).
 *     tags: [ScanSessions]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateScanSessionRequest'
 *     responses:
 *       201:
 *         description: Session de scan créée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:   { type: string, example: 'Session de scan créée avec succès' }
 *                 sessionId: { type: integer, example: 2 }
 *       400:
 *         description: farmId manquant
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
router.post('/', requireRole('Inspector', 'Administrator'), ctrl.create);

/**
 * @swagger
 * /api/scan-sessions/{id}:
 *   put:
 *     summary: Mettre à jour une session de scan
 *     description: |
 *       Permet de confirmer (Confirmed) ou contester (Disputed) une session.
 *       Passer à **Confirmed** renseigne automatiquement `confirmed_at`.
 *     tags: [ScanSessions]
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
 *               status:       { type: string, enum: [Pending, Confirmed, Disputed] }
 *               notes:        { type: string }
 *               isConsistent: { type: boolean }
 *     responses:
 *       200:
 *         description: Session mise à jour avec succès
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
 *         description: Session non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.put('/:id', requireRole('Inspector', 'Administrator'), ctrl.update);

/**
 * @swagger
 * /api/scan-sessions/{id}:
 *   delete:
 *     summary: Supprimer une session de scan (Administrateur uniquement)
 *     tags: [ScanSessions]
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
 *         description: Session supprimée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       404:
 *         description: Session non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.delete('/:id', requireRole('Administrator'), ctrl.remove);

module.exports = router;

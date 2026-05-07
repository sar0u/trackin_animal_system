const express = require('express');
const router  = express.Router();
const ctrl    = require('../Controllers/InspectionController');
const { authMiddleware, requireRole } = require('../middleware/Auth');

router.use(authMiddleware, requireRole('Inspector'));

/**
 * @swagger
 * tags:
 *   name: Inspection
 *   description: Endpoints réservés aux inspecteurs — scan UHF et gestion des constats
 */

/**
 * @swagger
 * /api/inspection/verify-scan:
 *   post:
 *     summary: Vérifier les animaux scannés via UHF longue portée
 *     description: |
 *       L'inspecteur utilise un lecteur UHF longue portée pour détecter tous les tags
 *       dans un rayon de plusieurs mètres. Cette route compare les tags détectés avec
 *       les animaux enregistrés en base de données pour la ferme concernée.
 *       Retourne : nombre d'animaux détectés, tags inconnus (non déclarés), tags manquants.
 *     tags: [Inspection]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/VerifyScanRequest'
 *     responses:
 *       200:
 *         description: Rapport de vérification UHF
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/VerifyScanResponse'
 *       400:
 *         description: farmId ou scannedTags manquant
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
router.post('/verify-scan', ctrl.verifyScan);

/**
 * @swagger
 * /api/inspection/confirm:
 *   post:
 *     summary: Confirmer l'inventaire d'une ferme
 *     description: |
 *       Après vérification UHF, l'inspecteur confirme que le compte est correct.
 *       Crée automatiquement une inspection de type Inventaire avec statut Resolved.
 *     tags: [Inspection]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [farmId]
 *             properties:
 *               farmId:
 *                 type: integer
 *                 example: 1
 *     responses:
 *       200:
 *         description: Inventaire confirmé avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:      { type: string }
 *                 farmName:     { type: string }
 *                 animalCount:  { type: integer }
 *                 inspectionId: { type: integer }
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
router.post('/confirm', ctrl.confirmCheck);

/**
 * @swagger
 * /api/inspection/declare:
 *   post:
 *     summary: Déclarer un constat / inspection
 *     description: |
 *       Crée un constat officiel sur le terrain. Le statut initial est Pending.
 *       Peut être lié à un animal spécifique via animalId.
 *       Types disponibles : General, Sanitaire, Fraude, Inventaire.
 *     tags: [Inspection]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/InspectionRequest'
 *     responses:
 *       200:
 *         description: Inspection déclarée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:      { type: string }
 *                 inspectionId: { type: integer }
 *       400:
 *         description: Description manquante
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post('/declare', ctrl.declare);


/**
 * @swagger
 * /api/inspection/my:
 *   get:
 *     summary: Mes inspections (inspecteur connecté)
 *     tags: [Inspection]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des inspections de l'inspecteur connecté
 */
/**
 * @swagger
 * /api/inspection/my:
 *   get:
 *     summary: Mes inspections (inspecteur connecté)
 *     description: Retourne uniquement les inspections créées par l'inspecteur actuellement connecté, triées par date DESC.
 *     tags: [Inspection]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des inspections de l'inspecteur connecté
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/InspectionResponse'
 */
router.get('/my', ctrl.myInspections);

/**
 * @swagger
 * /api/inspection/animal/{animalId}:
 *   get:
 *     summary: Inspections liées à un animal
 *     description: Retourne l'historique de toutes les inspections ayant ciblé un animal spécifique, trié par date d'inspection DESC.
 *     tags: [Inspection]
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
 *         description: Liste des inspections de l'animal
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/InspectionResponse'
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
 * /api/inspection/list:
 *   get:
 *     summary: Lister toutes les inspections
 *     description: Retourne toutes les inspections du système avec le nom de l'inspecteur, triées par date de création DESC.
 *     tags: [Inspection]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste complète des inspections
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/InspectionResponse'
 */

/**
 * @swagger
 * /api/inspection/{id}:
 *   get:
 *     summary: Détail d'une inspection
 *     description: Retourne une inspection avec les informations de l'inspecteur et de l'animal ciblé.
 *     tags: [Inspection]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de l'inspection
 *     responses:
 *       200:
 *         description: Détail de l'inspection
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/InspectionResponse'
 *       404:
 *         description: Inspection non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/:id', ctrl.getById);

/**
 * @swagger
 * /api/inspection/{id}/status:
 *   put:
 *     summary: Mettre à jour le statut ou le résultat d'une inspection
 *     description: |
 *       Workflow statut : **Pending → UnderReview → Resolved / Rejected**
 *       Passer à **Resolved** renseigne automatiquement `resolved_at` et `resolved_by`.
 *       Le champ `result` peut être mis à jour indépendamment du statut.
 *     tags: [Inspection]
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
 *             $ref: '#/components/schemas/UpdateInspectionStatusRequest'
 *     responses:
 *       200:
 *         description: Statut mis à jour avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       400:
 *         description: Valeur de status ou result invalide
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Inspection non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.put('/:id/status', ctrl.updateStatus);

/**
 * @swagger
 * /api/inspection/{id}:
 *   delete:
 *     summary: Supprimer une inspection (Administrateur uniquement)
 *     description: La suppression est en cascade — les images associées sont également supprimées.
 *     tags: [Inspection]
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
 *         description: Inspection supprimée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MessageResponse'
 *       404:
 *         description: Inspection non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.delete('/:id', requireRole('Administrator'), ctrl.remove);

module.exports = router;
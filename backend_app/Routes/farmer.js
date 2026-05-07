const express = require('express');
const router  = express.Router();
const ctrl    = require('../Controllers/FarmerController');
const { authMiddleware, requireRole } = require('../middleware/Auth');

router.use(authMiddleware, requireRole('Farmer'));

/**
 * @swagger
 * tags:
 *   name: Farmer
 *   description: Endpoints réservés aux agriculteurs — un farmer gère une seule ferme
 */

/**
 * @swagger
 * /api/farmer/scan/{rfidCode}:
 *   get:
 *     summary: Scanner un animal via son tag RFID
 *     description: Retourne les informations complètes de l'animal. Vérifie que l'animal appartient bien à la ferme du farmer connecté.
 *     tags: [Farmer]
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
 *         description: Informations de l'animal
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/AnimalResponse'
 *       403:
 *         description: Cet animal n'appartient pas à votre ferme
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
router.get('/scan/:rfidCode', ctrl.scanAnimal);

/**
 * @swagger
 * /api/farmer/animals:
 *   get:
 *     summary: Lister tous les animaux de la ferme du farmer connecté
 *     tags: [Farmer]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des animaux de la ferme
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/AnimalResponse'
 */
router.get('/animals', ctrl.getMyAnimals);

/**
 * @swagger
 * /api/farmer/animals:
 *   post:
 *     summary: Ajouter un animal à la ferme
 *     description: |
 *       Crée un nouvel animal dans la ferme unique du farmer connecté.
 *       La ferme est déterminée automatiquement — il n'est pas nécessaire de fournir un farmId.
 *       Champs obligatoires : species.
 *       Champs optionnels : rfidCode, gender, birthDate, weight, notes.
 *       Si rfidCode est fourni, un tag RFID UHF est créé ou réutilisé automatiquement.
 *       Retourne l'id et le rfidCode de l'animal créé.
 *     tags: [Farmer]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateAnimalRequest'
 *     responses:
 *       201:
 *         description: Animal créé avec succès
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/CreateAnimalResponse'
 *       400:
 *         description: species manquant ou ferme introuvable
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post('/animals', ctrl.createAnimal);

/**
 * @swagger
 * /api/farmer/animals/{id}:
 *   put:
 *     summary: Modifier un animal existant
 *     description: Tous les champs sont optionnels — seuls ceux fournis seront mis à jour. L'animal doit appartenir à la ferme du farmer connecté.
 *     tags: [Farmer]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de l'animal à modifier
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UpdateAnimalRequest'
 *     responses:
 *       200:
 *         description: Animal modifié avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string }
 *       404:
 *         description: Animal non trouvé ou accès refusé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.put('/animals/:id', ctrl.updateAnimal);

/**
 * @swagger
 * /api/farmer/animals/{id}:
 *   delete:
 *     summary: Supprimer un animal
 *     description: L'animal doit appartenir à la ferme du farmer connecté.
 *     tags: [Farmer]
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
 *         description: Animal supprimé avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string }
 *       404:
 *         description: Animal non trouvé ou accès refusé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.delete('/animals/:id', ctrl.deleteAnimal);

module.exports = router;
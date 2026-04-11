const express = require('express');
const router = express.Router();
const animalController = require('../Controllers/animalcontroller');
const auth = require('../middleware/auth');
const db = require('../config/db');



/**
 * @swagger
 * tags:
 *   - name: Animals
 *     description: Gestion du cheptel
 *   - name: Santé
 *     description: Suivi sanitaire des animaux
 */

/**
 * @swagger
 * /api/animals:
 *   get:
 *     tags: [Animals]
 *     summary: Liste des animaux de l'éleveur connecté
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: species
 *         schema:
 *           type: string
 *         description: Filtrer par espèce (ex Mouton, Boeuf)
 *     responses:
 *       200:
 *         description: Liste des animaux
 *       401:
 *         description: Token manquant ou invalide
 */
router.get('/', auth, animalController.getAllAnimals);

/**
 * @swagger
 * /api/animals/register:
 *   post:
 *     tags: [Animals]
 *     summary: Enregistrer un nouvel animal (naissance ou acquisition)
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [rfid_tag_id, species, breed, gender, birth_date, origin_type, owner_id, farm_id]
 *             properties:
 *               rfid_tag_id:
 *                 type: integer
 *                 example: 5
 *               species:
 *                 type: string
 *                 example: Mouton
 *               breed:
 *                 type: string
 *                 example: Ouled Djellal
 *               gender:
 *                 type: string
 *                 enum: [Male, Female]
 *               birth_date:
 *                 type: string
 *                 format: date
 *                 example: "2024-03-15"
 *               weight:
 *                 type: number
 *                 example: 45.5
 *               origin_type:
 *                 type: string
 *                 enum: [Birth, Purchase]
 *               owner_id:
 *                 type: integer
 *                 example: 1
 *               farm_id:
 *                 type: integer
 *                 example: 2
 *     responses:
 *       201:
 *         description: Animal enregistré avec succès
 *       400:
 *         description: Erreur d'enregistrement
 */
router.post('/register', auth, animalController.registerNewanimal);

/**
 * @swagger
 * /api/animals/scan/{rfid}:
 *   get:
 *     tags: [Animals]
 *     summary: Récupérer un animal par scan RFID
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: rfid
 *         required: true
 *         schema:
 *           type: string
 *         description: Code RFID unique de l'animal
 *     responses:
 *       200:
 *         description: Données de l'animal trouvé
 *       404:
 *         description: Aucun animal trouvé pour ce tag
 */
router.get('/scan/:rfid', auth, animalController.getanimalByScan);

/**
 * @swagger
 * /api/animals/markets/verified:
 *   get:
 *     tags: [Animals]
 *     summary: Liste des marchés vérifiés (Aïd el-Adha)
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des marchés actifs et vérifiés
 */
router.get('/markets/verified', auth, animalController.getVerifiedMarkets);

/**
 * @swagger
 * /api/animals/health:
 *   post:
 *     tags: [Santé]
 *     summary: Ajouter un dossier médical (vétérinaire uniquement)
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [animalId, status, notes]
 *             properties:
 *               animalId:
 *                 type: integer
 *               status:
 *                 type: string
 *                 enum: [Healthy, Sick, UnderTreatment, Quarantined]
 *               notes:
 *                 type: string
 *     responses:
 *       200:
 *         description: Dossier médical mis à jour
 *       403:
 *         description: Réservé aux vétérinaires
 */
router.post('/health', auth, animalController.addHealthRecord);

/**
 * @swagger
 * /api/animals/{id}/vaccinations:
 *   get:
 *     tags: [Santé]
 *     summary: Vaccinations d'un animal
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
 *         description: Liste des vaccinations
 */
router.get('/:id/vaccinations', auth, async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM Vaccinations WHERE AnimalId = ?', [req.params.id]);
        res.json({ success: true, data: rows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

/**
 * @swagger
 * /api/animals/{id}/verify:
 *   patch:
 *     tags: [Animals]
 *     summary: Certifier un animal (admin ou vétérinaire uniquement)
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
 *         description: Animal certifié
 *       403:
 *         description: Non autorisé
 */
router.patch('/:id/verify', auth, animalController.verifyAnimal);

/**
 * @swagger
 * /api/animals/{id}/move:
 *   patch:
 *     tags: [Animals]
 *     summary: Déplacer un animal vers une nouvelle ferme
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
 *             type: object
 *             required: [newFarmId]
 *             properties:
 *               newFarmId:
 *                 type: integer
 *                 example: 3
 *     responses:
 *       200:
 *         description: Mouvement enregistré
 */
router.patch('/:id/move', auth, animalController.moveanimal);

/**
 * @swagger
 * /api/animals/{id}/health:
 *   get:
 *     tags: [Santé]
 *     summary: Historique de santé complet d'un animal
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
 *         description: Historique sanitaire
 */
router.get('/:id/health', auth, animalController.getHealthHistory);

/**
 * @swagger
 * /api/animals/{id}:
 *   delete:
 *     tags: [Animals]
 *     summary: Supprimer un animal (propriétaire uniquement)
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
 *         description: Animal supprimé
 *       404:
 *         description: Animal non trouvé ou non autorisé
 */
router.delete('/:id', auth, animalController.deleteAnimal);

/**
 * @swagger
 * /api/health-records/{recordId}:
 *   put:
 *     tags: [Santé]
 *     summary: Modifier un dossier médical existant (vétérinaire uniquement)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: recordId
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               status:
 *                 type: string
 *               notes:
 *                 type: string
 *     responses:
 *       200:
 *         description: Fiche médicale mise à jour
 *       403:
 *         description: Réservé aux vétérinaires
 */
router.put('/health-records/:recordId', auth, animalController.updateHealthRecord);

module.exports = router;
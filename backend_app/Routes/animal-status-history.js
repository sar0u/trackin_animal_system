const express = require('express');
const router  = express.Router();
const ctrl    = require('../Controllers/AnimalStatusHistoryController');
const { authMiddleware } = require('../middleware/Auth');

router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   name: AnimalStatusHistory
 *   description: Historique des changements de statut des animaux (lecture seule — généré automatiquement par triggers MySQL)
 */

/**
 * @swagger
 * /api/animal-status-history:
 *   get:
 *     summary: Lister tout l'historique de statut
 *     description: |
 *       Retourne tous les changements de `life_status` et `health_status` de tous les animaux,
 *       triés par date DESC.
 *       Ces entrées sont créées automatiquement par le trigger MySQL `after_animal_status_history`
 *       à chaque modification d'un statut animal — elles ne peuvent pas être créées manuellement.
 *     tags: [AnimalStatusHistory]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste complète de l'historique de statut
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/AnimalStatusHistoryResponse'
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
 * /api/animal-status-history/animal/{animalId}:
 *   get:
 *     summary: Historique de statut d'un animal spécifique
 *     description: |
 *       Retourne la chronologie complète des changements de statut pour un animal donné,
 *       triée par date DESC (le plus récent en premier).
 *       Inclut : life_status (Active → Sold, Dead…) et health_status (Healthy → UnderTreatment…).
 *     tags: [AnimalStatusHistory]
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
 *         description: Historique de statut de l'animal
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/AnimalStatusHistoryResponse'
 *       404:
 *         description: Animal non trouvé
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/animal/:animalId', ctrl.getByAnimal);

module.exports = router;

const express = require('express');
const router = express.Router();
const MetadataController = require('../Controllers/metadatacontroller');
const Metadata = require('../model/metadata');
const auth = require('../middleware/auth');



/**
 * @swagger
 * tags:
 *   name: Dashboard
 *   description: Statistiques globales et données utilitaires
 */

/**
 * @swagger
 * /api/dashboard/stats:
 *   get:
 *     tags: [Dashboard]
 *     summary: Statistiques globales du tableau de bord
 *     description: Retourne le total d'animaux vivants, les alertes sanitaires et les mouvements récents
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Statistiques récupérées avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     totalAnimals:
 *                       type: integer
 *                       example: 1250
 *                     healthAlerts:
 *                       type: integer
 *                       example: 12
 *                     recentMovements:
 *                       type: integer
 *                       example: 34
 *       401:
 *         description: Token invalide ou manquant
 */
router.get('/dashboard/stats', auth, MetadataController.getDashboardStats);

/**
 * @swagger
 * /api/metadata/options:
 *   get:
 *     tags: [Dashboard]
 *     summary: Options pour les formulaires (fermes, propriétaires, tags RFID disponibles)
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Données de référence pour les menus déroulants
 */
router.get('/metadata/options', auth, MetadataController.getFormOptions);

/**
 * @swagger
 * /api/reports/activity:
 *   get:
 *     tags: [Dashboard]
 *     summary: Rapport d'activité récente de l'éleveur connecté
 *     description: Retourne les 20 derniers événements (mouvements + santé)
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des activités récentes
 */
router.get('/reports/activity', auth, async (req, res) => {
    try {
        const report = await Metadata.getActivityReport(req.user.id);
        res.json({ success: true, data: report });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
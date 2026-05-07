const express = require('express');
const router  = express.Router({ mergeParams: true });
const ctrl    = require('../Controllers/InspectionImageController');
const upload  = require('../models/multerConfig');
const { authMiddleware, requireRole } = require('../middleware/Auth');

router.use(authMiddleware, requireRole('Inspector'));

/**
 * @swagger
 * tags:
 *   name: InspectionImages
 *   description: Gestion des images liées aux inspections
 */

/**
 * @swagger
 * /api/inspection/{inspectionId}/images:
 *   post:
 *     summary: Uploader entre 2 et 5 images pour une inspection
 *     description: |
 *       Formats acceptés : jpeg, png, webp. Taille max par fichier : 5MB.
 *       Le total d'images par inspection ne peut pas dépasser 5.
 *       Le paramètre imageType peut être Photo, Screenshot ou Document.
 *     tags: [InspectionImages]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: inspectionId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de l'inspection
 *       - in: query
 *         name: imageType
 *         schema:
 *           type: string
 *           enum: [Photo, Screenshot, Document]
 *           default: Photo
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               files:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *                 description: Entre 2 et 5 images (jpeg/png/webp, max 5MB chacune)
 *     responses:
 *       200:
 *         description: Images uploadées avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string }
 *                 count:   { type: integer }
 *                 images:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:        { type: integer }
 *                       imageUrl:  { type: string }
 *                       imageType: { type: string }
 *       400:
 *         description: Nombre d'images invalide, type non autorisé, ou quota dépassé
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
router.post('/', upload.array('files', 5), ctrl.uploadImages);

/**
 * @swagger
 * /api/inspection/{inspectionId}/images:
 *   get:
 *     summary: Récupérer toutes les images d'une inspection
 *     tags: [InspectionImages]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: inspectionId
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Liste des images triées par date d'ajout
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id:            { type: integer }
 *                   inspection_id: { type: integer }
 *                   image_url:     { type: string }
 *                   image_type:    { type: string }
 *                   created_at:    { type: string, format: date-time }
 *       404:
 *         description: Inspection non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/', ctrl.getImages);

/**
 * @swagger
 * /api/inspection/{inspectionId}/images/{imageId}:
 *   delete:
 *     summary: Supprimer une image d'inspection
 *     description: Supprime l'image de la base de données et le fichier du disque.
 *     tags: [InspectionImages]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: inspectionId
 *         required: true
 *         schema:
 *           type: integer
 *       - in: path
 *         name: imageId
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Image supprimée avec succès
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string }
 *       404:
 *         description: Image non trouvée
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.delete('/:imageId', ctrl.deleteImage);

module.exports = router;
const express = require('express');
const router  = express.Router();
const ctrl    = require('../Controllers/AuthController');

/**
 * @swagger
 * tags:
 *   name: Auth
 *   description: Authentification et gestion des comptes
 */

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Connexion utilisateur
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/LoginRequest'
 *     responses:
 *       200:
 *         description: Connexion réussie — retourne token + infos utilisateur
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/LoginResponse'
 *       401:
 *         description: Identifiant ou mot de passe incorrect
 *       403:
 *         description: Compte désactivé
 */
router.post('/login', ctrl.login);

/** 
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Inscription d'un nouvel utilisateur
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/RegisterRequest'
 *     responses:
 *       200:
 *         description: Compte créé avec succès
 *       400:
 *         description: Username ou email déjà pris / champs manquants
 */
router.post('/register', ctrl.register);

/**
 * @swagger
 * /api/auth/forgot-password:
 *   post:
 *     summary: Vérifier si un compte existe (username ou email)
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [identifier]
 *             properties:
 *               identifier:
 *                 type: string
 *                 example: ahmed123
 *     responses:
 *       200:
 *         description: Compte trouvé — retourne email masqué
 *       404:
 *         description: Aucun compte trouvé
 */
router.post('/forgot-password', ctrl.forgotPassword);

/**
 * @swagger
 * /api/auth/reset-password:
 *   post:
 *     summary: Réinitialiser le mot de passe
 *     tags: [Auth]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [identifier, newPassword]
 *             properties:
 *               identifier:
 *                 type: string
 *               newPassword:
 *                 type: string
 *                 minLength: 6
 *     responses:
 *       200:
 *         description: Mot de passe réinitialisé avec succès
 *       400:
 *         description: Mot de passe trop court
 *       404:
 *         description: Utilisateur non trouvé
 */
router.post('/reset-password', ctrl.resetPassword);

module.exports = router;
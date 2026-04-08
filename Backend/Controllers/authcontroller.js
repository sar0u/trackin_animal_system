// Controllers/authcontroller.js
const jwt = require('jsonwebtoken');
const User = require('../model/User'); 
const express = require('express');
const router = express.Router();

router.post('/login', async (req, res) => {
    const { email, password } = req.body;
    try {
        const user = await User.findByEmail(email);
        if (!user) return res.status(404).json({ message: "Utilisateur non trouvé" });

        const isMatch = await User.comparePassword(password, user.Password);
        if (!isMatch) return res.status(401).json({ message: "Mot de passe incorrect" });

        const token = jwt.sign(
            { id: user.Id, role: user.UserRole },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );

        res.json({ success: true, token, user: { name: user.FullOwnerName, role: user.UserRole } });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.post('/register', async (req, res) => {
    try {
        const userId = await User.create(req.body);
        res.status(201).json({ success: true, userId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
const bcrypt = require('bcrypt'); // Assure-toi d'avoir bcrypt pour le mot de passe

exports.updateProfile = async (req, res) => {
    try {
        const { name, email, phone } = req.body;
        const userId = req.user.id;

        const query = `UPDATE Users SET FullName = ?, Email = ?, PhoneNumber = ? WHERE Id = ?`;
        await db.execute(query, [name, email, phone, userId]);

        res.json({ success: true, message: "Profil mis à jour avec succès" });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.changePassword = async (req, res) => {
    try {
        const { oldPassword, newPassword } = req.body;
        const userId = req.user.id;

        // 1. Récupérer l'ancien mot de passe haché
        const [users] = await db.execute('SELECT PasswordHash FROM Users WHERE Id = ?', [userId]);
        const user = users[0];

        // 2. Vérifier si l'ancien mot de passe est correct
        const isMatch = await bcrypt.compare(oldPassword, user.PasswordHash);
        if (!isMatch) {
            return res.status(400).json({ success: false, message: "Ancien mot de passe incorrect" });
        }

        // 3. Hacher le nouveau et sauvegarder
        const salt = await bcrypt.genSalt(10);
        const newHash = await bcrypt.hash(newPassword, salt);
        
        await db.execute('UPDATE Users SET PasswordHash = ? WHERE Id = ?', [newHash, userId]);

        res.json({ success: true, message: "Mot de passe modifié" });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

module.exports = router;
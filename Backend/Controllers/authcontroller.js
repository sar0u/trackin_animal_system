const jwt = require('jsonwebtoken');
const User = require('../models/User'); 

const router = express.Router();

// Route pour enregistrer un utilisateur
router.post('/register', async (req, res) => {
    const { email, password, role } = req.body;

    // Vérifiez que le rôle est soit 'veterinaire' soit 'eleveur'
    if (role !== 'veterinaire' && role !== 'eleveur') {
        return res.status(400).json({ message: 'Rôle invalide. Utilisez "veterinaire" ou "eleveur".' });
    }

    try {
        const newUser = new User({ email, password, role });
        await newUser.save();
        res.status(201).json({ message: 'Utilisateur enregistré avec succès.' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur lors de l\'enregistrement de l\'utilisateur.', error });
    }
});

module.exports = router;
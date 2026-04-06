// server.js
require('dotenv').config({ path: './access.env' }); 
const express = require('express');
const cors = require('cors');

// Import des Contrôleurs
const animalController = require('./Controllers/animalcontroller');
const authRoutes = require('./Controllers/authcontroller');
const metadataController = require('./Controllers/metadatacontroller');

// Import du Middleware
const auth = require('./middleware/auth');

const app = express();
app.use(cors());
app.use(express.json());

// ROUTES D'AUTHENTIFICATION 
app.use('/api/auth', authRoutes);

// ROUTES ANIMAL
app.get('/api/scan/:rfid', auth, animalController.getanimalByScan);
app.post('/api/animals/register', auth, animalController.registerNewanimal);
app.get('/api/animals', auth, async (req, res) => {
    // Route pour la liste filtrée par proprio
    const Animal = require('./model/animal');
    try {
        const animals = await Animal.getAll(req.user.id, req.query.species);
        res.json({ success: true, data: animals });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
app.patch('/api/animals/:id/move', auth, animalController.moveanimal);

// ROUTES SANTÉ
app.get('/api/animals/:id/health', auth, animalController.getHealthHistory);
app.post('/api/animals/health', auth, animalController.addHealthRecord);
app.put('/api/health-records/:recordId', auth, animalController.updateHealthRecord);

// ROUTES DASHBOARD
app.get('/api/dashboard/stats', auth, metadataController.getDashboardStats);
app.get('/api/metadata/options', auth, metadataController.getFormOptions);
app.get('/api/farms', auth, async (req, res) => {
    const Metadata = require('./model/metadata');
    try {
        const farms = await Metadata.getUserFarms(req.user.id);
        res.json({ success: true, data: farms });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ROUTE RAPPORTS
app.get('/api/reports/activity', auth, async (req, res) => {
    const Metadata = require('./model/metadata');
    try {
        const report = await Metadata.getActivityReport(req.user.id);
        res.json({ success: true, data: report });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// aid l'adha option
app.get('/api/special/aid-adha', auth, animalController.getAidAnimals);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Serveur lancé sur le port ${PORT}`);
});
const express = require('express');
const cors = require('cors');
const animalController = require('./Controllers/animalcontroller');

const app = express();
app.use(cors());
app.use(express.json());

// route appelé par flutter
app.get('/api/scan/:rfid', animalController.getanimalByScan);

const PORT = 3000;
app.listen(PORT, () =>  console.log(`Serveur lancé sur le port ${PORT}`));
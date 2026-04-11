// server.js
require('dotenv').config({ path: './access.env' });
const express = require('express');
const cors = require('cors');
const swaggerJSDoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');


const app = express();
app.use(cors());
app.use(express.json());

// ─── Configuration Swagger ─────────────────────────────────────────────────
const options = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'API Animal Tracking System',
            version: '1.0.0',
            description: 'Système de suivi du cheptel et détection de fraude — HB Technologies',
        },
        servers: [{ url: 'http://localhost:3000' }],
        components: {
            securitySchemes: {
                bearerAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'JWT',
                },
            },
        },
    },
    apis: ['./Routes/*.js'], 
};

const swaggerSpec = swaggerJSDoc(options);

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// ─── Import des Routes ─────────────────────────────────────────────────────
const animalRoute     = require('./Routes/animalroute');
const authRoutes      = require('./Routes/authroutes');
const StatsRoute      = require('./Routes/statsroute');
const inspectionRoute = require('./Routes/inspectionroutes');

// ─── Montage des Routes ────────────────────────────────────────────────────
app.use('/api/auth',        authRoutes);
app.use('/api/animals',     animalRoute);
app.use('/api/inspections', inspectionRoute);
app.use('/api',             StatsRoute);

// ─── Démarrage ────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Serveur lancé sur le port ${PORT}`);
    console.log(` Swagger UI : http://localhost:${PORT}/api-docs`);
});
require('dotenv').config();
const express     = require('express');
const cors        = require('cors');
const path        = require('path');
const swaggerUi   = require('swagger-ui-express');
const swaggerSpec = require('./Config/Swagger');

const app = express();

// ─── Middlewares globaux ──────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ─── Swagger ──────────────────────────────────────────────────────────────────
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customSiteTitle: 'DZCheptel API Docs',
}));
app.use((req, res, next) => {
  console.log(`URL appelée : ${req.method} ${req.originalUrl}`);
  next();
});

// ─── Routes ──────────────────────────────────────────────────────────────────
app.use('/api/auth',                   require('./Routes/auth'));
app.use('/api/farmer',                 require('./Routes/farmer'));
app.use('/api/vet',                    require('./Routes/vet'));
app.use('/api/inspection',             require('./Routes/inspection'));
app.use('/api/inspection/:inspectionId/images', require('./Routes/inspectionimage'));
app.use('/api/movements',              require('./Routes/movements'));
app.use('/api/health-records',         require('./Routes/health-records'));
app.use('/api/vaccinations',           require('./Routes/vaccinations'));
app.use('/api/subsidies',              require('./Routes/subsidies'));
app.use('/api/scan-sessions',          require('./Routes/scan-sessions'));
app.use('/api/farms',                  require('./Routes/farms'));
app.use('/api/rfid-tags',              require('./Routes/rfid-tags'));
app.use('/api/animal-status-history',  require('./Routes/animal-status-history'));

// ─── Health check ─────────────────────────────────────────────────────────────
app.get('/health', (req, res) => res.json({ status: 'ok', timestamp: new Date() }));

// ─── 404 ──────────────────────────────────────────────────────────────────────
app.use((req, res) => res.status(404).json({ message: `Route non trouvée : ${req.path}` }));

// ─── Erreur globale ───────────────────────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ message: err.message || 'Erreur interne du serveur' });
});

module.exports = app;
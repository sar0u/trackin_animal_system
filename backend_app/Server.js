require('dotenv').config();
const app  = require('./App');
const PORT = process.env.PORT || 8000;

app.listen(PORT, () => {
  console.log(` Serveur démarré sur http://localhost:${PORT}`);
  console.log(` Swagger UI   → http://localhost:${PORT}/api-docs`);
}); 
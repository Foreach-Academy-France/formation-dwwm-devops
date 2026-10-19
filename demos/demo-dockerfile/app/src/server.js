// Mini API de démonstration : même forme que l'API TaskFlow (port 3000, /health, logs JSON)
const express = require('express');

const app = express();
const PORT = Number(process.env.PORT) || 3000;
const APP_VERSION = process.env.APP_VERSION || 'dev';

// Une ligne JSON par requête sur stdout (lisible avec `docker logs`)
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    console.log(JSON.stringify({ method: req.method, path: req.path, status: res.statusCode, ms: Date.now() - start }));
  });
  next();
});

app.get('/', (req, res) => {
  res.json({ message: 'Bonjour depuis un conteneur !' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', version: APP_VERSION });
});

const server = app.listen(PORT, () => {
  console.log(JSON.stringify({ msg: 'listening', port: PORT, version: APP_VERSION }));
});

// Arrêt propre : en PID 1 dans un conteneur, Node ignore SIGTERM s'il n'est pas géré
// (docker stop attendrait alors 10 s avant de tuer le processus)
process.on('SIGTERM', () => {
  console.log(JSON.stringify({ msg: 'SIGTERM reçu, arrêt propre' }));
  server.close(() => process.exit(0));
});

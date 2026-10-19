// Mini API TaskFlow — exercice « Dockerfile à corriger »
const express = require('express');

const PORT = Number(process.env.PORT) || 3000;
const APP_ENV = process.env.APP_ENV || 'local';
const APP_VERSION = process.env.APP_VERSION || 'dev';

const app = express();
app.use(express.json());

const tasks = [{ id: 1, title: 'Dockeriser TaskFlow', done: false }];

app.get('/health', (req, res) => {
  res.json({ status: 'ok', version: APP_VERSION, env: APP_ENV });
});

app.get('/api/tasks', (req, res) => {
  res.json(tasks);
});

const server = app.listen(PORT, () => {
  console.log(JSON.stringify({ msg: 'api démarrée', port: PORT, env: APP_ENV }));
});

// Arrêt propre sur « docker stop » (signal SIGTERM)
process.on('SIGTERM', () => {
  console.log(JSON.stringify({ msg: 'arrêt demandé (SIGTERM)' }));
  server.close(() => process.exit(0));
});

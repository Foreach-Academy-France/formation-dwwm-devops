// Compteur de visites dans Postgres : prouve que « web » joint « db » PAR SON NOM
// et que les données survivent à « docker compose down » grâce au volume.
const http = require('node:http');
const { Pool } = require('pg');

const PORT = Number(process.env.PORT) || 3000;
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

// Sans ce gestionnaire, une coupure de la base ferait PLANTER tout le processus Node
pool.on('error', (err) => console.error(JSON.stringify({ level: 'error', msg: `pool: ${err.message}` })));

async function migrate() {
  await pool.query('CREATE TABLE IF NOT EXISTS visits (id SERIAL PRIMARY KEY, at TIMESTAMPTZ DEFAULT now())');
}

function send(res, status, body) {
  res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(body));
}

const server = http.createServer(async (req, res) => {
  const start = Date.now();
  res.on('finish', () => {
    console.log(JSON.stringify({ method: req.method, path: req.url, status: res.statusCode, ms: Date.now() - start }));
  });
  try {
    if (req.url === '/health') {
      await pool.query('SELECT 1');
      return send(res, 200, { status: 'ok', db: 'up' });
    }
    if (req.url === '/') {
      await pool.query('INSERT INTO visits DEFAULT VALUES');
      const { rows } = await pool.query('SELECT count(*)::int AS total FROM visits');
      return send(res, 200, { message: 'Bonjour depuis Compose !', visites: rows[0].total });
    }
    return send(res, 404, { error: 'not found' });
  } catch (err) {
    console.error(JSON.stringify({ level: 'error', msg: err.message }));
    return send(res, 503, { status: 'error', db: 'down' });
  }
});

migrate()
  .then(() => server.listen(PORT, () => console.log(JSON.stringify({ msg: 'listening', port: PORT }))))
  .catch((err) => {
    console.error(JSON.stringify({ level: 'fatal', msg: err.message }));
    process.exit(1);
  });

process.on('SIGTERM', () => server.close(() => pool.end().then(() => process.exit(0))));

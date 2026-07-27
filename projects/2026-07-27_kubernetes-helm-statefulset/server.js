const express = require('express');
const pg = require('pg');
const redis = require('redis');

const app = express();
const PORT = process.env.PORT || 3000;

// Clients
const pgClient = new pg.Client({
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'app_db',
});

const redisClient = redis.createClient({
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379,
});

// Routes
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/ready', async (req, res) => {
  try {
    await pgClient.query('SELECT 1');
    redisClient.ping((err, reply) => {
      if (err) throw err;
      res.json({
        status: 'ready',
        db: 'connected',
        cache: 'connected',
        timestamp: new Date().toISOString()
      });
    });
  } catch (err) {
    res.status(503).json({ status: 'not ready', error: err.message });
  }
});

app.get('/api/data', async (req, res) => {
  try {
    const cacheKey = 'app:data';

    // Essayer le cache
    redisClient.get(cacheKey, async (err, cachedData) => {
      if (cachedData) {
        return res.json({
          source: 'cache',
          data: JSON.parse(cachedData)
        });
      }

      // Sinon, requête DB
      const result = await pgClient.query('SELECT version();');
      const data = {
        db_version: result.rows[0].version,
        timestamp: new Date().toISOString()
      };

      // Cache pour 60s
      redisClient.setex(cacheKey, 60, JSON.stringify(data), () => {});

      res.json({ source: 'database', data });
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/metrics', (req, res) => {
  res.setHeader('Content-Type', 'text/plain');
  res.send(`# HELP app_requests_total Total requests
# TYPE app_requests_total counter
app_requests_total 0

# HELP app_version Version of the app
# TYPE app_version gauge
app_version{version="1.0.0"} 1
`);
});

// Startup
(async () => {
  try {
    await pgClient.connect();
    console.log('✓ PostgreSQL connected');

    redisClient.on('connect', () => {
      console.log('✓ Redis connected');
    });
    redisClient.on('error', (err) => {
      console.error('Redis error:', err);
    });

    app.listen(PORT, () => {
      console.log(`App listening on port ${PORT}`);
    });
  } catch (err) {
    console.error('Connection error:', err);
    process.exit(1);
  }
})();

process.on('SIGTERM', async () => {
  console.log('SIGTERM received, graceful shutdown');
  await pgClient.end();
  redisClient.quit();
  process.exit(0);
});

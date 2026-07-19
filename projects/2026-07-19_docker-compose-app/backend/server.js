const express = require('express');
const { Client } = require('pg');
const redis = require('redis');
const client = require('prom-client');

const app = express();
const port = process.env.PORT || 3000;

// Metrics setup
const register = new client.Registry();
client.collectDefaultMetrics({ register });

const httpRequestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route'],
  registers: [register]
});

// Middleware
app.use(express.json());

app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestCounter.inc({
      method: req.method,
      route: req.path,
      status_code: res.statusCode
    });
    httpRequestDuration.observe({
      method: req.method,
      route: req.path
    }, duration);
  });
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Metrics endpoint
app.get('/metrics', (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(register.metrics());
});

// API endpoints
app.get('/api/users', async (req, res) => {
  try {
    const result = await queryDatabase('SELECT id, name, email FROM users LIMIT 10');
    res.json({ users: result.rows });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ error: 'Database query failed' });
  }
});

app.post('/api/users', async (req, res) => {
  const { name, email } = req.body;
  if (!name || !email) {
    return res.status(400).json({ error: 'Name and email are required' });
  }

  try {
    const result = await queryDatabase(
      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id, name, email',
      [name, email]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Insert error:', error);
    res.status(500).json({ error: 'Failed to create user' });
  }
});

app.get('/api/cache/:key', async (req, res) => {
  try {
    const value = await getCache(req.params.key);
    if (value) {
      res.json({ key: req.params.key, value });
    } else {
      res.status(404).json({ error: 'Key not found' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Cache error' });
  }
});

app.post('/api/cache/:key', async (req, res) => {
  const { value } = req.body;
  if (!value) {
    return res.status(400).json({ error: 'Value is required' });
  }

  try {
    await setCache(req.params.key, value);
    res.json({ key: req.params.key, value, status: 'cached' });
  } catch (error) {
    res.status(500).json({ error: 'Cache error' });
  }
});

// Database functions
let dbPool;
async function getDBPool() {
  if (!dbPool) {
    dbPool = new Client({
      connectionString: process.env.DATABASE_URL
    });
    await dbPool.connect();
    console.log('Connected to PostgreSQL');
  }
  return dbPool;
}

async function queryDatabase(query, params = []) {
  const connection = await getDBPool();
  return connection.query(query, params);
}

// Redis cache functions
let redisClient;
async function getRedisClient() {
  if (!redisClient) {
    redisClient = redis.createClient({
      url: process.env.REDIS_URL
    });
    redisClient.on('error', (err) => console.log('Redis Client Error', err));
    await redisClient.connect();
    console.log('Connected to Redis');
  }
  return redisClient;
}

async function getCache(key) {
  const cache = await getRedisClient();
  return cache.get(key);
}

async function setCache(key, value) {
  const cache = await getRedisClient();
  await cache.setEx(key, 3600, JSON.stringify(value));
}

// Error handling
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

// Start server
const server = app.listen(port, () => {
  console.log(`Backend API listening on port ${port}`);
  console.log(`Health check: http://localhost:${port}/health`);
  console.log(`Metrics: http://localhost:${port}/metrics`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

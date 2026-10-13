const express = require('express');
const app = express();

const serverName = process.env.SERVER_NAME || 'unknown';
const serverPort = parseInt(process.env.SERVER_PORT) || 3000;
const startTime = Date.now();

app.use(express.json());

// Middleware pour logger les requêtes
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path} from ${req.ip}`);
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', server: serverName, timestamp: new Date().toISOString() });
});

// Root endpoint
app.get('/', (req, res) => {
  const uptime = Math.floor((Date.now() - startTime) / 1000);
  res.json({
    message: 'Hello from load-balanced backend',
    server: serverName,
    port: serverPort,
    uptime: `${uptime}s`,
    timestamp: new Date().toISOString(),
    headers: req.headers,
  });
});

// API endpoint
app.get('/api/info', (req, res) => {
  const uptime = Math.floor((Date.now() - startTime) / 1000);
  res.json({
    server: serverName,
    port: serverPort,
    uptime: uptime,
    memory: process.memoryUsage(),
    timestamp: new Date().toISOString(),
  });
});

// API endpoint pour data
app.get('/api/data', (req, res) => {
  const data = {
    server: serverName,
    items: [
      { id: 1, name: `Item from ${serverName}`, timestamp: new Date().toISOString() },
      { id: 2, name: `Data processed on ${serverName}` },
      { id: 3, name: `Request handled by ${serverName}` },
    ],
  };
  res.json(data);
});

// POST endpoint pour démo
app.post('/api/echo', (req, res) => {
  res.json({
    server: serverName,
    received: req.body,
    timestamp: new Date().toISOString(),
  });
});

// Endpoint pour simuler du travail (pour tester les timeouts)
app.get('/api/slow', (req, res) => {
  const delay = parseInt(req.query.delay) || 2000;
  setTimeout(() => {
    res.json({
      server: serverName,
      delay: delay,
      message: `Processed after ${delay}ms`,
    });
  }, delay);
});

// Endpoint pour simuler une erreur
app.get('/api/error', (req, res) => {
  res.status(500).json({
    server: serverName,
    error: 'This is a simulated error',
    timestamp: new Date().toISOString(),
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not found',
    path: req.path,
    server: serverName,
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal server error',
    server: serverName,
    message: err.message,
  });
});

// Start server
app.listen(serverPort, '0.0.0.0', () => {
  console.log(`✅ ${serverName} server listening on port ${serverPort}`);
  console.log(`   Health check: http://localhost:${serverPort}/health`);
  console.log(`   Info: http://localhost:${serverPort}/api/info`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log(`⚠️  SIGTERM received, shutting down ${serverName} gracefully...`);
  process.exit(0);
});

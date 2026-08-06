const express = require('express');
const compression = require('compression');
const helmet = require('helmet');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Security middleware
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(express.json());

// Logging middleware
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    environment: NODE_ENV,
    uptime: process.uptime(),
  });
});

// Ready probe
app.get('/ready', (req, res) => {
  res.json({
    ready: true,
    service: 'docker-optimization-app',
  });
});

// Metrics endpoint
app.get('/metrics', (req, res) => {
  const memUsage = process.memoryUsage();
  res.json({
    memory: {
      heapUsed: Math.round(memUsage.heapUsed / 1024 / 1024) + ' MB',
      heapTotal: Math.round(memUsage.heapTotal / 1024 / 1024) + ' MB',
      rss: Math.round(memUsage.rss / 1024 / 1024) + ' MB',
    },
    uptime: process.uptime(),
    pid: process.pid,
  });
});

// API endpoint - System info
app.get('/api/system', (req, res) => {
  res.json({
    os: process.platform,
    nodeVersion: process.version,
    environment: NODE_ENV,
    timestamp: new Date().toISOString(),
  });
});

// API endpoint - Echo
app.post('/api/echo', (req, res) => {
  const { message } = req.body;
  res.json({
    received: message,
    echoed: message ? message.toUpperCase() : 'NO MESSAGE',
    timestamp: new Date().toISOString(),
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path,
    method: req.method,
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: NODE_ENV === 'development' ? err.message : 'Something went wrong',
  });
});

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`
╔════════════════════════════════════════════════════╗
║  🚀 Docker Optimization App Started                ║
╠════════════════════════════════════════════════════╣
║  Environment: ${NODE_ENV.padEnd(38)}║
║  Port: ${PORT.toString().padEnd(44)}║
║  PID: ${process.pid.toString().padEnd(45)}║
║  Memory: ${Math.round(process.memoryUsage().heapUsed / 1024 / 1024)}MB heap used                         ║
╠════════════════════════════════════════════════════╣
║  Available endpoints:                              ║
║  - GET  /health                                    ║
║  - GET  /ready                                     ║
║  - GET  /metrics                                   ║
║  - GET  /api/system                                ║
║  - POST /api/echo                                  ║
╚════════════════════════════════════════════════════╝
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received: shutting down gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('\nSIGINT received: shutting down...');
  process.exit(0);
});

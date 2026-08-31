#!/usr/bin/env node

/**
 * Multi-Environment Deployable Application
 *
 * This application demonstrates a production-ready Node.js app
 * that can be deployed to multiple environments (dev, staging, prod)
 * using GitHub Actions workflows.
 */

const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
require('dotenv').config();

// Initialize application
const app = express();
const PORT = process.env.PORT || 3000;
const ENV = process.env.NODE_ENV || 'development';
const VERSION = '1.0.0';

// Request counter for metrics
let requestCount = 0;
let errorCount = 0;
let lastDeployment = new Date().toISOString();

// Middleware
app.use(helmet()); // Security headers
app.use(cors());   // Cross-origin
app.use(express.json());

// Logging middleware
app.use((req, res, next) => {
  requestCount++;
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`${req.method} ${req.path} - ${res.statusCode} (${duration}ms)`);
  });

  next();
});

// ============================================================================
// ROUTES
// ============================================================================

/**
 * Health check endpoint
 * Used by load balancers and monitoring systems
 */
app.get('/health', (req, res) => {
  const uptime = process.uptime();
  const memoryUsage = process.memoryUsage();

  const health = {
    status: 'UP',
    timestamp: new Date().toISOString(),
    version: VERSION,
    environment: ENV,
    uptime: Math.round(uptime),
    memory: {
      heapUsed: Math.round(memoryUsage.heapUsed / 1024 / 1024) + 'MB',
      heapTotal: Math.round(memoryUsage.heapTotal / 1024 / 1024) + 'MB'
    }
  };

  res.status(200).json(health);
});

/**
 * Liveness probe
 * Kubernetes uses this to restart unhealthy pods
 */
app.get('/live', (req, res) => {
  res.status(200).json({ status: 'alive' });
});

/**
 * Readiness probe
 * Kubernetes uses this to add/remove pod from load balancer
 */
app.get('/ready', (req, res) => {
  // In real scenario, check database, cache, etc.
  res.status(200).json({ status: 'ready' });
});

/**
 * Metrics endpoint
 * Exposes application metrics for monitoring
 */
app.get('/metrics', (req, res) => {
  const uptime = process.uptime();
  const memoryUsage = process.memoryUsage();

  const metrics = {
    timestamp: new Date().toISOString(),
    version: VERSION,
    environment: ENV,
    uptime: uptime,
    requests: {
      total: requestCount,
      errors: errorCount,
      errorRate: requestCount > 0 ? ((errorCount / requestCount) * 100).toFixed(2) + '%' : '0%'
    },
    memory: {
      heapUsed: memoryUsage.heapUsed,
      heapTotal: memoryUsage.heapTotal,
      external: memoryUsage.external,
      rss: memoryUsage.rss
    },
    deployment: {
      version: VERSION,
      environment: ENV,
      lastDeployment: lastDeployment
    }
  };

  res.status(200).json(metrics);
});

/**
 * API endpoint - Get application info
 */
app.get('/api/info', (req, res) => {
  res.status(200).json({
    name: 'DevOps Multi-Environment App',
    version: VERSION,
    environment: ENV,
    description: 'Deployable application for GitHub Actions multi-environment pipeline',
    endpoints: {
      health: '/health',
      metrics: '/metrics',
      info: '/api/info',
      status: '/api/status'
    }
  });
});

/**
 * API endpoint - Get application status
 */
app.get('/api/status', (req, res) => {
  const uptime = process.uptime();
  const memoryUsage = process.memoryUsage();

  res.status(200).json({
    status: 'operational',
    timestamp: new Date().toISOString(),
    version: VERSION,
    environment: ENV,
    uptime: Math.round(uptime),
    requests: requestCount,
    errors: errorCount,
    memory: Math.round(memoryUsage.heapUsed / 1024 / 1024) + 'MB',
    lastDeployment: lastDeployment
  });
});

/**
 * API endpoint - Trigger version
 */
app.get('/api/version', (req, res) => {
  res.status(200).json({
    version: VERSION,
    environment: ENV,
    timestamp: lastDeployment
  });
});

/**
 * Test endpoint
 * Used for integration tests
 */
app.post('/api/test', (req, res) => {
  const { message } = req.body;

  if (!message) {
    errorCount++;
    return res.status(400).json({
      error: 'Message is required'
    });
  }

  res.status(200).json({
    success: true,
    message: `Received: ${message}`,
    timestamp: new Date().toISOString()
  });
});

/**
 * Root endpoint
 */
app.get('/', (req, res) => {
  res.status(200).json({
    message: 'Welcome to DevOps Multi-Environment App',
    version: VERSION,
    environment: ENV,
    deployedAt: lastDeployment,
    documentation: 'https://github.com/jaouadsiouahe1978/claude-devops-tools'
  });
});

/**
 * 404 handler
 */
app.use((req, res) => {
  errorCount++;
  res.status(404).json({
    error: 'Not Found',
    path: req.path,
    method: req.method
  });
});

/**
 * Error handler
 */
app.use((err, req, res, next) => {
  errorCount++;
  console.error('Error:', err);

  res.status(500).json({
    error: 'Internal Server Error',
    message: ENV === 'production' ? 'An error occurred' : err.message
  });
});

// ============================================================================
// SERVER START
// ============================================================================

const server = app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════════════════════╗
║   DevOps Multi-Environment Application                    ║
╠════════════════════════════════════════════════════════════╣
║ Version:    ${VERSION.padEnd(40)}║
║ Environment: ${ENV.padEnd(39)}║
║ Port:       ${PORT.toString().padEnd(40)}║
║ Time:       ${new Date().toISOString().padEnd(40)}║
╠════════════════════════════════════════════════════════════╣
║ Endpoints:                                                 ║
║  - Health:  GET /health                                    ║
║  - Metrics: GET /metrics                                   ║
║  - API:     GET /api/info, /api/status, /api/version      ║
║  - Docs:    https://github.com/.../README.md              ║
╚════════════════════════════════════════════════════════════╝
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

module.exports = app;

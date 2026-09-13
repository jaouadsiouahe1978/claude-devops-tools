#!/usr/bin/env node

/**
 * Simple Express app exposing Prometheus metrics
 *
 * Metrics exposed:
 * - app_requests_total: Counter of all HTTP requests
 * - app_request_duration_ms: Histogram of request duration
 * - app_memory_bytes: Gauge of memory usage
 * - app_active_connections: Gauge of active connections
 */

const express = require('express');
const client = require('prom-client');

// ============================================================================
// Initialize Prometheus Metrics
// ============================================================================

// Default metrics (CPU, memory, GC, etc.)
client.collectDefaultMetrics({ timeout: 5000 });

// Custom metrics

// Counter: Total number of requests
const requestCounter = new client.Counter({
  name: 'app_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'path', 'status'],
  registers: [client.register]
});

// Histogram: Request duration
const requestDuration = new client.Histogram({
  name: 'app_request_duration_ms',
  help: 'HTTP request duration in milliseconds',
  labelNames: ['method', 'path', 'status'],
  buckets: [10, 50, 100, 200, 500, 1000, 2000, 5000],
  registers: [client.register]
});

// Gauge: Memory usage
const memoryGauge = new client.Gauge({
  name: 'app_memory_bytes',
  help: 'Memory usage in bytes',
  registers: [client.register]
});

// Gauge: Active connections
const activeConnections = new client.Gauge({
  name: 'app_active_connections',
  help: 'Number of active HTTP connections',
  registers: [client.register]
});

// Counter: API errors
const errorCounter = new client.Counter({
  name: 'app_errors_total',
  help: 'Total number of errors',
  labelNames: ['type'],
  registers: [client.register]
});

// ============================================================================
// Express Setup
// ============================================================================

const app = express();
const PORT = process.env.PORT || 8080;

// Middleware to track memory and active connections
setInterval(() => {
  const mem = process.memoryUsage();
  memoryGauge.set(mem.heapUsed);
}, 5000);

// Middleware to track request metrics
app.use((req, res, next) => {
  activeConnections.inc();
  const startTime = Date.now();

  // Hook to capture response status
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    const status = res.statusCode;

    // Record metrics
    requestCounter.labels(req.method, req.path, status).inc();
    requestDuration.labels(req.method, req.path, status).observe(duration);

    activeConnections.dec();
  });

  next();
});

// ============================================================================
// Routes
// ============================================================================

/**
 * Health check endpoint
 */
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage()
  });
});

/**
 * API endpoint that does some work
 */
app.get('/api/data', (req, res) => {
  try {
    // Simulate some processing
    const delay = Math.random() * 100;
    setTimeout(() => {
      res.status(200).json({
        data: [
          { id: 1, value: Math.random() * 100, timestamp: new Date() },
          { id: 2, value: Math.random() * 100, timestamp: new Date() },
          { id: 3, value: Math.random() * 100, timestamp: new Date() }
        ],
        processingTime: delay
      });
    }, delay);
  } catch (error) {
    errorCounter.labels('api_error').inc();
    res.status(500).json({ error: error.message });
  }
});

/**
 * Prometheus metrics endpoint
 * This is what Prometheus scrapes
 */
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', client.register.contentType);
    res.end(await client.register.metrics());
  } catch (err) {
    res.status(500).end(err);
  }
});

/**
 * Stats endpoint showing current metrics
 */
app.get('/stats', (req, res) => {
  const mem = process.memoryUsage();
  res.json({
    uptime: process.uptime(),
    memory: {
      heapUsed: Math.round(mem.heapUsed / 1024 / 1024) + ' MB',
      heapTotal: Math.round(mem.heapTotal / 1024 / 1024) + ' MB',
      external: Math.round(mem.external / 1024 / 1024) + ' MB'
    },
    cpu: process.cpuUsage(),
    pid: process.pid
  });
});

/**
 * Root endpoint
 */
app.get('/', (req, res) => {
  res.json({
    message: 'DevOps Monitoring App',
    endpoints: {
      '/': 'This message',
      '/health': 'Health check',
      '/metrics': 'Prometheus metrics (scraped by Prometheus)',
      '/stats': 'Application statistics',
      '/api/data': 'API endpoint returning random data'
    },
    version: '1.0.0'
  });
});

/**
 * 404 handler
 */
app.use((req, res) => {
  errorCounter.labels('not_found').inc();
  res.status(404).json({ error: 'Not Found' });
});

/**
 * Error handler
 */
app.use((err, req, res, next) => {
  console.error(err);
  errorCounter.labels('unhandled_error').inc();
  res.status(500).json({ error: 'Internal Server Error' });
});

// ============================================================================
// Start Server
// ============================================================================

const server = app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════╗
║   🚀 DevOps Monitoring App Started         ║
╠════════════════════════════════════════════╣
║ Server:        http://localhost:${PORT}     ║
║ Health:        http://localhost:${PORT}/health
║ Metrics:       http://localhost:${PORT}/metrics
║ Stats:         http://localhost:${PORT}/stats
║ API:           http://localhost:${PORT}/api/data
╚════════════════════════════════════════════╝

Endpoints:
  GET  /              - API info
  GET  /health        - Health check
  GET  /stats         - App statistics
  GET  /api/data      - Sample API endpoint
  GET  /metrics       - Prometheus metrics (scraped)

Prometheus will scrape http://app:8080/metrics every 5 seconds
View metrics at: http://localhost:9090 (Prometheus)
Create dashboards at: http://localhost:3000 (Grafana)
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
  console.log('\nSIGINT received, shutting down gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

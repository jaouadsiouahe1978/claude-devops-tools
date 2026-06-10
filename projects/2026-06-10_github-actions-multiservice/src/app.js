/**
 * Simple Express.js web application
 */
const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;
const VERSION = '1.0.0';

app.use(express.json());

/**
 * Health check endpoint
 */
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    version: VERSION,
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString()
  });
});

/**
 * API ping endpoint
 */
app.get('/api/v1/ping', (req, res) => {
  res.json({
    message: 'pong',
    timestamp: new Date().toISOString()
  });
});

/**
 * API info endpoint
 */
app.get('/api/v1/info', (req, res) => {
  res.json({
    name: 'Multiservice Web App',
    version: VERSION,
    status: 'running',
    uptime: process.uptime()
  });
});

/**
 * Root endpoint
 */
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to Multiservice Web App',
    version: VERSION,
    endpoints: {
      health: '/health',
      ping: '/api/v1/ping',
      info: '/api/v1/info'
    }
  });
});

/**
 * 404 handler
 */
app.use((req, res) => {
  res.status(404).json({
    error: 'Not found',
    path: req.path
  });
});

/**
 * Error handler
 */
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Start server
if (require.main === module) {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`App running on port ${PORT}`);
  });
}

module.exports = app;

const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;
const ENV = process.env.NODE_ENV || 'development';

app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: ENV,
  });
});

// Version endpoint
app.get('/api/version', (req, res) => {
  res.json({
    version: '1.0.0',
    name: 'github-actions-cd-pipeline',
    buildTime: process.env.BUILD_TIME || 'unknown',
    commitSha: process.env.COMMIT_SHA || 'unknown',
  });
});

// Status endpoint
app.get('/api/status', (req, res) => {
  res.json({
    uptime: process.uptime(),
    environment: ENV,
    nodeVersion: process.version,
    timestamp: new Date().toISOString(),
  });
});

// Echo endpoint for testing
app.post('/api/echo', (req, res) => {
  res.json({
    echo: req.body,
    receivedAt: new Date().toISOString(),
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
app.use((err, req, res) => {
  console.error(err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: ENV === 'production' ? 'An error occurred' : err.message,
  });
});

const server = app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT} in ${ENV} mode`);
  console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
});

module.exports = app;

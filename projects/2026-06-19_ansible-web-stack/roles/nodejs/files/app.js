const express = require('express');
const os = require('os');
const app = express();

const port = process.env.PORT || 3000;
const env = process.env.NODE_ENV || 'development';

app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// Readiness check
app.get('/ready', (req, res) => {
  res.status(200).json({ ready: true });
});

// Main endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to Node.js application',
    hostname: os.hostname(),
    timestamp: new Date().toISOString(),
    environment: env,
    uptime: process.uptime(),
    nodeVersion: process.version,
    platform: process.platform,
  });
});

// API endpoint
app.get('/api/info', (req, res) => {
  res.json({
    app: 'DevOps Stack Demo',
    version: '1.0.0',
    features: [
      'Express.js backend',
      'Nginx reverse proxy',
      'PostgreSQL database',
      'Prometheus monitoring'
    ],
    author: 'Jaouad - DevOps Training',
    docs: 'https://github.com/jaouadsiouahe1978/claude-devops-tools'
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal Server Error' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not Found' });
});

const server = app.listen(port, () => {
  console.log(`Server running on port ${port}`);
  console.log(`Environment: ${env}`);
  console.log(`Hostname: ${os.hostname()}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

module.exports = app;

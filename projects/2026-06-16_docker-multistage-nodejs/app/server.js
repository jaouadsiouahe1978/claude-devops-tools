const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;
const ENV = process.env.NODE_ENV || 'production';

app.use(express.json());

// Route principale
app.get('/', (req, res) => {
  res.json({
    message: 'Hello from multi-stage Docker!',
    environment: ENV,
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    nodeVersion: process.version
  });
});

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

// Endpoint pour montrer les infos du conteneur
app.get('/info', (req, res) => {
  res.json({
    hostname: require('os').hostname(),
    platform: process.platform,
    arch: process.arch,
    memory: {
      heapUsed: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + 'MB',
      heapTotal: Math.round(process.memoryUsage().heapTotal / 1024 / 1024) + 'MB'
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path
  });
});

// Lancer le serveur
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Server running on http://0.0.0.0:${PORT}`);
  console.log(`📦 Environment: ${ENV}`);
  console.log(`🐳 Running in Docker: ${process.env.DOCKER_ENV === 'true' ? 'YES' : 'NO'}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('⚠️  SIGTERM received, shutting down gracefully...');
  server.close(() => {
    console.log('✅ Server stopped');
    process.exit(0);
  });
});

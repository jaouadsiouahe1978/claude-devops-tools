const express = require('express');
const app = express();
const PORT = 3000;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Status endpoint
app.get('/api/status', (req, res) => {
  res.json({
    service: 'DevOps App',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    port: PORT,
    message: 'Multi-stage Docker build optimization demo'
  });
});

// Welcome endpoint
app.get('/', (req, res) => {
  res.json({
    message: '🐳 Welcome to DevOps Docker Optimization Project!',
    endpoints: [
      '/',
      '/health',
      '/api/status'
    ]
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not Found' });
});

// Start server
app.listen(PORT, () => {
  console.log(`✅ App running on http://localhost:${PORT}`);
  console.log(`📊 Check /health and /api/status endpoints`);
});

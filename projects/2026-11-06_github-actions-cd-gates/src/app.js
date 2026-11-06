const express = require('express');
const prometheus = require('prom-client');

const app = express();
const port = process.env.PORT || 3000;

// Prometheus metrics
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

const httpRequestTotal = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

// Middleware
app.use(express.json());

app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
    httpRequestTotal
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .inc();
  });
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'production'
  });
});

// Ready check (for k8s)
app.get('/ready', (req, res) => {
  res.json({
    ready: true,
    timestamp: new Date().toISOString()
  });
});

// API endpoints
app.get('/api/info', (req, res) => {
  res.json({
    name: 'GitHub Actions CD Gates Demo',
    version: process.env.APP_VERSION || '1.0.0',
    environment: process.env.NODE_ENV || 'production',
    deployment: {
      strategy: 'Blue-Green',
      timestamp: process.env.DEPLOY_TIME || new Date().toISOString()
    }
  });
});

app.get('/api/metrics', (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(prometheus.register.metrics());
});

app.get('/api/config', (req, res) => {
  res.json({
    host: req.hostname,
    protocol: req.protocol,
    environment: process.env.NODE_ENV,
    deployment_id: process.env.GITHUB_RUN_ID,
    commit: process.env.GITHUB_SHA,
    branch: process.env.GITHUB_REF
  });
});

app.post('/api/simulate-error', (req, res) => {
  const { statusCode = 500, message = 'Simulated error' } = req.body;
  res.status(statusCode).json({
    error: message,
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>GitHub Actions CD Gates</title>
      <style>
        body { font-family: Arial; margin: 40px; }
        .status { color: green; }
        .endpoint { background: #f0f0f0; padding: 10px; margin: 10px 0; }
      </style>
    </head>
    <body>
      <h1>✅ GitHub Actions CD with Approval Gates</h1>
      <div class="status">
        <h2>Status: Healthy</h2>
        <p>Environment: ${process.env.NODE_ENV || 'production'}</p>
        <p>Uptime: ${Math.round(process.uptime())}s</p>
      </div>

      <h2>📊 Available Endpoints:</h2>
      <div class="endpoint">
        <strong>GET /health</strong>
        <p>Health check endpoint for load balancers</p>
      </div>
      <div class="endpoint">
        <strong>GET /ready</strong>
        <p>Readiness probe for Kubernetes</p>
      </div>
      <div class="endpoint">
        <strong>GET /api/info</strong>
        <p>Application information</p>
      </div>
      <div class="endpoint">
        <strong>GET /api/metrics</strong>
        <p>Prometheus metrics</p>
      </div>
      <div class="endpoint">
        <strong>GET /api/config</strong>
        <p>Deployment configuration</p>
      </div>
      <div class="endpoint">
        <strong>POST /api/simulate-error</strong>
        <p>Simulate error for testing</p>
      </div>

      <hr>
      <p><small>GitHub Actions CI/CD Pipeline Demo • Jaouad DevOps Training</small></p>
    </body>
    </html>
  `);
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Start server
const server = app.listen(port, () => {
  console.log(`
╔════════════════════════════════════════╗
║  GitHub Actions CD with Approval Gates ║
║  Server running on port ${port}        ║
║  Environment: ${process.env.NODE_ENV || 'production'}     ║
╚════════════════════════════════════════╝
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
  setTimeout(() => {
    console.error('Forcefully shutting down');
    process.exit(1);
  }, 30000);
});

module.exports = app;

// Application Node.js avec métriques Prometheus

const express = require('express');
const prometheus = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3000;

// ==============================================
// Configuration des métriques Prometheus
// ==============================================

// Counter - compte le nombre total de requêtes HTTP
const httpRequestsTotal = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Nombre total de requêtes HTTP',
  labelNames: ['method', 'route', 'status']
});

// Gauge - mesure actuelle (ex: nombre de connexions actives)
const activeConnections = new prometheus.Gauge({
  name: 'active_connections',
  help: 'Nombre de connexions actives',
  labelNames: ['type']
});

// Histogram - distribue les temps de réponse en buckets
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Durée des requêtes HTTP en secondes',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.1, 0.5, 1, 2, 5] // buckets en secondes
});

// Gauge - taille de la queue de traitement
const queueSize = new prometheus.Gauge({
  name: 'queue_size',
  help: 'Taille de la queue de traitement',
  labelNames: ['queue_name']
});

// Counter - nombre d'erreurs
const errorsTotal = new prometheus.Counter({
  name: 'errors_total',
  help: 'Nombre total d\'erreurs',
  labelNames: ['type', 'severity']
});

// ==============================================
// Middleware pour instrumenter les requêtes
// ==============================================

app.use((req, res, next) => {
  const start = Date.now();

  // Incrémenter les connexions actives
  activeConnections.inc();

  // Intercepter la réponse
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000; // convertir en secondes

    // Enregistrer les métriques
    httpRequestsTotal.labels(req.method, req.path, res.statusCode).inc();
    httpRequestDuration.labels(req.method, req.path, res.statusCode).observe(duration);

    // Décrémenter les connexions actives
    activeConnections.dec();

    console.log(`${req.method} ${req.path} - ${res.statusCode} - ${duration.toFixed(3)}s`);
  });

  next();
});

// ==============================================
// Routes de l'application
// ==============================================

// Route de santé (pour health checks)
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Endpoint des métriques Prometheus (obligatoire!)
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(await prometheus.register.metrics());
});

// Route API simple
app.get('/api/data', (req, res) => {
  // Simuler un délai aléatoire
  const delay = Math.random() * 1000;

  // 2% de chance d'erreur
  if (Math.random() < 0.02) {
    errorsTotal.labels('http_error', 'high').inc();
    return res.status(500).json({ error: 'Internal Server Error' });
  }

  // Simuler du travail
  setTimeout(() => {
    res.json({
      message: 'Données récupérées',
      timestamp: new Date().toISOString(),
      data: {
        temperature: 20 + Math.random() * 5,
        humidity: 40 + Math.random() * 20,
        pressure: 1013 + Math.random() * 10
      }
    });
  }, delay);
});

// Route pour simuler du travail en arrière-plan
app.get('/api/process', (req, res) => {
  queueSize.labels('background').set(Math.floor(Math.random() * 100));

  setTimeout(() => {
    queueSize.labels('background').set(0);
    res.json({ status: 'processing complete' });
  }, 500);
});

// Route pour simuler des erreurs
app.get('/api/error', (req, res) => {
  errorsTotal.labels('test_error', 'medium').inc();
  res.status(400).json({ error: 'Bad Request' });
});

// Route racine
app.get('/', (req, res) => {
  res.json({
    application: 'Prometheus Monitoring App',
    version: '1.0.0',
    endpoints: [
      'GET /health - Health check',
      'GET /metrics - Prometheus metrics',
      'GET /api/data - Simulated data endpoint',
      'GET /api/process - Simulated processing',
      'GET /api/error - Simulated error'
    ],
    uptime: process.uptime()
  });
});

// ==============================================
// Démarrage du serveur
// ==============================================

app.listen(PORT, () => {
  console.log(`✓ Application démarrée sur http://localhost:${PORT}`);
  console.log(`✓ Métriques disponibles sur http://localhost:${PORT}/metrics`);
  console.log(`✓ En attente de scraping par Prometheus...`);

  // Initialiser certaines métriques
  activeConnections.set(0);
  queueSize.labels('background').set(0);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('Arrêt du serveur...');
  process.exit(0);
});

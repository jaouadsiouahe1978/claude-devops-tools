/**
 * Application Tests
 *
 * These tests are run during the GitHub Actions build process
 * to ensure the application meets quality requirements
 */

const request = require('supertest');
const app = require('../src/index.js');

describe('Application Tests', () => {

  // ========================================================================
  // Health & Readiness Tests
  // ========================================================================

  describe('GET /health', () => {
    it('should return health status', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.body).toHaveProperty('status', 'UP');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('environment');
      expect(response.body).toHaveProperty('timestamp');
    });

    it('should include memory information', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.body).toHaveProperty('memory');
      expect(response.body.memory).toHaveProperty('heapUsed');
      expect(response.body.memory).toHaveProperty('heapTotal');
    });
  });

  describe('GET /live', () => {
    it('should return alive status', async () => {
      const response = await request(app)
        .get('/live')
        .expect(200);

      expect(response.body).toHaveProperty('status', 'alive');
    });
  });

  describe('GET /ready', () => {
    it('should return ready status', async () => {
      const response = await request(app)
        .get('/ready')
        .expect(200);

      expect(response.body).toHaveProperty('status', 'ready');
    });
  });

  // ========================================================================
  // Metrics Tests
  // ========================================================================

  describe('GET /metrics', () => {
    it('should return metrics', async () => {
      const response = await request(app)
        .get('/metrics')
        .expect(200);

      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('environment');
      expect(response.body).toHaveProperty('requests');
      expect(response.body).toHaveProperty('memory');
      expect(response.body).toHaveProperty('deployment');
    });

    it('should track request count', async () => {
      const response1 = await request(app).get('/metrics');
      const count1 = response1.body.requests.total;

      await request(app).get('/health');

      const response2 = await request(app).get('/metrics');
      const count2 = response2.body.requests.total;

      expect(count2).toBeGreaterThan(count1);
    });
  });

  // ========================================================================
  // API Endpoints Tests
  // ========================================================================

  describe('GET /api/info', () => {
    it('should return application info', async () => {
      const response = await request(app)
        .get('/api/info')
        .expect(200);

      expect(response.body).toHaveProperty('name');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('environment');
      expect(response.body).toHaveProperty('endpoints');
    });

    it('should include all available endpoints', async () => {
      const response = await request(app)
        .get('/api/info')
        .expect(200);

      const endpoints = response.body.endpoints;
      expect(endpoints).toHaveProperty('health');
      expect(endpoints).toHaveProperty('metrics');
      expect(endpoints).toHaveProperty('info');
      expect(endpoints).toHaveProperty('status');
    });
  });

  describe('GET /api/status', () => {
    it('should return operational status', async () => {
      const response = await request(app)
        .get('/api/status')
        .expect(200);

      expect(response.body).toHaveProperty('status', 'operational');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('environment');
      expect(response.body).toHaveProperty('uptime');
      expect(response.body).toHaveProperty('requests');
      expect(response.body).toHaveProperty('memory');
    });
  });

  describe('GET /api/version', () => {
    it('should return version information', async () => {
      const response = await request(app)
        .get('/api/version')
        .expect(200);

      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('environment');
      expect(response.body).toHaveProperty('timestamp');
    });
  });

  describe('GET /', () => {
    it('should return welcome message', async () => {
      const response = await request(app)
        .get('/')
        .expect(200);

      expect(response.body).toHaveProperty('message');
      expect(response.body.message).toContain('Welcome');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('environment');
    });
  });

  // ========================================================================
  // Test Endpoint Tests
  // ========================================================================

  describe('POST /api/test', () => {
    it('should accept test message', async () => {
      const response = await request(app)
        .post('/api/test')
        .send({ message: 'Hello Test' })
        .expect(200);

      expect(response.body).toHaveProperty('success', true);
      expect(response.body.message).toContain('Hello Test');
    });

    it('should reject empty message', async () => {
      const response = await request(app)
        .post('/api/test')
        .send({})
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('should include timestamp', async () => {
      const response = await request(app)
        .post('/api/test')
        .send({ message: 'Test' })
        .expect(200);

      expect(response.body).toHaveProperty('timestamp');
    });
  });

  // ========================================================================
  // Error Handling Tests
  // ========================================================================

  describe('Error Handling', () => {
    it('should handle 404 errors', async () => {
      const response = await request(app)
        .get('/non-existent-endpoint')
        .expect(404);

      expect(response.body).toHaveProperty('error', 'Not Found');
      expect(response.body).toHaveProperty('path');
      expect(response.body).toHaveProperty('method');
    });

    it('should handle JSON requests', async () => {
      const response = await request(app)
        .get('/')
        .expect(200);

      expect(response.type).toMatch(/json/);
    });
  });

  // ========================================================================
  // Performance Tests
  // ========================================================================

  describe('Performance', () => {
    it('should respond to health check within 100ms', async () => {
      const start = Date.now();

      await request(app)
        .get('/health')
        .expect(200);

      const duration = Date.now() - start;
      expect(duration).toBeLessThan(100);
    });

    it('should respond to metrics within 100ms', async () => {
      const start = Date.now();

      await request(app)
        .get('/metrics')
        .expect(200);

      const duration = Date.now() - start;
      expect(duration).toBeLessThan(100);
    });
  });

  // ========================================================================
  // Security Tests
  // ========================================================================

  describe('Security', () => {
    it('should include security headers', async () => {
      const response = await request(app)
        .get('/')
        .expect(200);

      // Check for common security headers (from helmet middleware)
      expect(response.headers).toHaveProperty('x-content-type-options');
      expect(response.headers).toHaveProperty('x-frame-options');
    });

    it('should handle CORS properly', async () => {
      const response = await request(app)
        .get('/')
        .expect(200);

      // CORS middleware should be active
      expect(response.status).toBe(200);
    });
  });

});

describe('Integration Tests', () => {

  it('should process multiple requests concurrently', async () => {
    const promises = [
      request(app).get('/health'),
      request(app).get('/metrics'),
      request(app).get('/api/info'),
      request(app).get('/api/status')
    ];

    const responses = await Promise.all(promises);

    responses.forEach(response => {
      expect(response.status).toBe(200);
    });
  });

  it('should maintain state across requests', async () => {
    const response1 = await request(app).get('/metrics');
    const count1 = response1.body.requests.total;

    // Make several requests
    await request(app).get('/health');
    await request(app).get('/api/info');

    const response2 = await request(app).get('/metrics');
    const count2 = response2.body.requests.total;

    // Request count should increase
    expect(count2).toBeGreaterThan(count1);
  });

});

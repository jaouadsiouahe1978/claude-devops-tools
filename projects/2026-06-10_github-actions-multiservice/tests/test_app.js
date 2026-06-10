/**
 * Tests for Express.js application
 */
const request = require('supertest');
const app = require('../src/app');

describe('Express App Tests', () => {
  describe('GET /health', () => {
    it('should return 200 with health status', async () => {
      const res = await request(app).get('/health');
      expect(res.statusCode).toBe(200);
      expect(res.body.status).toBe('healthy');
      expect(res.body).toHaveProperty('version');
      expect(res.body).toHaveProperty('environment');
    });
  });

  describe('GET /api/v1/ping', () => {
    it('should return 200 with pong message', async () => {
      const res = await request(app).get('/api/v1/ping');
      expect(res.statusCode).toBe(200);
      expect(res.body.message).toBe('pong');
      expect(res.body).toHaveProperty('timestamp');
    });
  });

  describe('GET /api/v1/info', () => {
    it('should return 200 with app info', async () => {
      const res = await request(app).get('/api/v1/info');
      expect(res.statusCode).toBe(200);
      expect(res.body.name).toBe('Multiservice Web App');
      expect(res.body.status).toBe('running');
      expect(res.body).toHaveProperty('version');
      expect(res.body).toHaveProperty('uptime');
    });
  });

  describe('GET /', () => {
    it('should return 200 with welcome message', async () => {
      const res = await request(app).get('/');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('message');
      expect(res.body).toHaveProperty('endpoints');
    });
  });

  describe('GET /nonexistent', () => {
    it('should return 404 for unknown routes', async () => {
      const res = await request(app).get('/nonexistent');
      expect(res.statusCode).toBe(404);
      expect(res.body).toHaveProperty('error');
    });
  });

  describe('Response Content-Type', () => {
    it('should return JSON responses', async () => {
      const res = await request(app).get('/health');
      expect(res.type).toBe('application/json');
    });
  });
});

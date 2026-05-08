const request = require('supertest');
const app = require('../src/index');

describe('API Endpoints', () => {
  test('GET / returns 200 with app info', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('message', 'Prod-Ready Application is running!');
  });

  test('GET /health returns healthy status', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('status', 'healthy');
    expect(res.body).toHaveProperty('timestamp');
  });

  test('GET /api/info returns app metadata', async () => {
    const res = await request(app).get('/api/info');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('app', 'Prod-Ready-Application');
  });
});
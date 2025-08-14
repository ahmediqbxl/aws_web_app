const request = require('supertest');
const app = require('../src/app');

describe('DevOps WebApp API', () => {
  describe('GET /', () => {
    it('should return welcome message', async () => {
      const response = await request(app).get('/');
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('message');
      expect(response.body.message).toContain('Welcome to DevOps Web Application');
    });

    it('should return version and environment info', async () => {
      const response = await request(app).get('/');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('environment');
      expect(response.body).toHaveProperty('endpoints');
    });
  });

  describe('GET /health', () => {
    it('should return healthy status', async () => {
      const response = await request(app).get('/health');
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('status');
      expect(response.body.status).toBe('healthy');
    });

    it('should return system metrics', async () => {
      const response = await request(app).get('/health');
      expect(response.body).toHaveProperty('uptime');
      expect(response.body).toHaveProperty('memory');
      expect(response.body).toHaveProperty('cpu');
    });
  });

  describe('GET /ready', () => {
    it('should return ready status', async () => {
      const response = await request(app).get('/ready');
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('status');
      expect(response.body.status).toBe('ready');
    });

    it('should return readiness checks', async () => {
      const response = await request(app).get('/ready');
      expect(response.body).toHaveProperty('checks');
      expect(response.body.checks).toHaveProperty('database');
      expect(response.body.checks).toHaveProperty('redis');
      expect(response.body.checks).toHaveProperty('external_api');
    });
  });

  describe('GET /metrics', () => {
    it('should return system metrics', async () => {
      const response = await request(app).get('/metrics');
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('process');
      expect(response.body).toHaveProperty('system');
    });

    it('should return process information', async () => {
      const response = await request(app).get('/metrics');
      expect(response.body.process).toHaveProperty('uptime');
      expect(response.body.process).toHaveProperty('memory');
      expect(response.body.process).toHaveProperty('cpu');
      expect(response.body.process).toHaveProperty('pid');
      expect(response.body.process).toHaveProperty('version');
      expect(response.body.process).toHaveProperty('platform');
    });
  });

  describe('GET /api/status', () => {
    it('should return operational status', async () => {
      const response = await request(app).get('/api/status');
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('status');
      expect(response.body.status).toBe('operational');
      expect(response.body).toHaveProperty('service');
      expect(response.body.service).toBe('devops-webapp');
    });
  });

  describe('POST /api/data', () => {
    it('should process valid data successfully', async () => {
      const testData = {
        name: 'John Doe',
        email: 'john.doe@example.com',
        message: 'This is a test message for the DevOps web application.'
      };

      const response = await request(app)
        .post('/api/data')
        .send(testData)
        .expect(201);

      expect(response.body).toHaveProperty('status');
      expect(response.body.status).toBe('success');
      expect(response.body).toHaveProperty('data');
      expect(response.body.data).toHaveProperty('id');
      expect(response.body.data).toHaveProperty('processed');
      expect(response.body.data.processed).toBe(true);
    });

    it('should validate name length', async () => {
      const testData = {
        name: 'Jo', // Too short
        email: 'john.doe@example.com',
        message: 'This is a test message.'
      };

      const response = await request(app)
        .post('/api/data')
        .send(testData)
        .expect(400);

      expect(response.body).toHaveProperty('status');
      expect(response.body.status).toBe('error');
      expect(response.body).toHaveProperty('errors');
    });

    it('should validate email format', async () => {
      const testData = {
        name: 'John Doe',
        email: 'invalid-email', // Invalid email
        message: 'This is a test message.'
      };

      const response = await request(app)
        .post('/api/data')
        .send(testData)
        .expect(400);

      expect(response.body).toHaveProperty('status');
      expect(response.body.status).toBe('error');
    });

    it('should validate message length', async () => {
      const testData = {
        name: 'John Doe',
        email: 'john.doe@example.com',
        message: 'Short' // Too short
      };

      const response = await request(app)
        .post('/api/data')
        .send(testData)
        .expect(400);

      expect(response.body).toHaveProperty('status');
      expect(response.body.status).toBe('error');
    });
  });

  describe('404 Handler', () => {
    it('should return 404 for unknown routes', async () => {
      const response = await request(app).get('/unknown-route');
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('status');
      expect(response.body.status).toBe('error');
      expect(response.body).toHaveProperty('message');
      expect(response.body.message).toBe('Endpoint not found');
    });
  });

  describe('Security Headers', () => {
    it('should include security headers', async () => {
      const response = await request(app).get('/');
      expect(response.headers).toHaveProperty('x-frame-options');
      expect(response.headers).toHaveProperty('x-content-type-options');
      expect(response.headers).toHaveProperty('x-xss-protection');
    });
  });

  describe('Rate Limiting', () => {
    it('should handle rate limiting', async () => {
      // Make multiple requests to trigger rate limiting
      const requests = Array(105).fill().map(() => 
        request(app).get('/')
      );
      
      const responses = await Promise.all(requests);
      const tooManyRequests = responses.filter(r => r.status === 429);
      
      // Should have some rate limited responses
      expect(tooManyRequests.length).toBeGreaterThan(0);
    });
  });
});

describe('Application Startup', () => {
  it('should start without errors', () => {
    expect(() => {
      require('../src/app');
    }).not.toThrow();
  });
});

describe('Environment Variables', () => {
  it('should use default port when PORT not set', () => {
    const originalPort = process.env.PORT;
    delete process.env.PORT;
    
    // Re-require app to test default port
    jest.resetModules();
    const app = require('../src/app');
    
    // Restore original PORT
    if (originalPort) {
      process.env.PORT = originalPort;
    }
    
    expect(app).toBeDefined();
  });
}); 
import request from 'supertest';
import { Express } from 'express';
import { createTestApp } from '../helpers/testApp';
import { performance } from 'perf_hooks';

describe('Performance Load Tests', () => {
  let app: Express;
  let authToken: string;

  beforeAll(async () => {
    app = await createTestApp();
    
    // Create test user and get auth token
    const userData = {
      username: 'loadtest',
      email: 'load@example.com',
      password: 'password123',
      fullName: 'Load Test User',
      role: 'farmer'
    };

    const response = await request(app)
      .post('/api/auth/register')
      .send(userData);
    
    authToken = response.body.token;
  });

  describe('API Response Times', () => {
    it('should handle authentication within 200ms', async () => {
      const start = performance.now();
      
      await request(app)
        .post('/api/auth/login')
        .send({
          email: 'load@example.com',
          password: 'password123'
        })
        .expect(200);
      
      const duration = performance.now() - start;
      expect(duration).toBeLessThan(200);
    });

    it('should handle sensor data processing within 100ms', async () => {
      const sensorData = {
        sensorId: 'LOAD_TEST_001',
        type: 'temperature',
        location: { latitude: 40.7128, longitude: -74.0060 },
        thresholds: { min: 10, max: 35 }
      };

      // First create a sensor
      await request(app)
        .post('/api/sensors')
        .set('Authorization', `Bearer ${authToken}`)
        .send(sensorData);

      const readingData = {
        sensorId: 'LOAD_TEST_001',
        data: { temperature: 25, humidity: 60 },
        timestamp: new Date(),
        location: { latitude: 40.7128, longitude: -74.0060 }
      };

      const start = performance.now();
      
      await request(app)
        .post('/api/sensors/readings')
        .set('Authorization', `Bearer ${authToken}`)
        .send(readingData);
      
      const duration = performance.now() - start;
      expect(duration).toBeLessThan(100);
    });
  });

  describe('Concurrent Request Handling', () => {
    it('should handle 50 concurrent authentication requests', async () => {
      const start = performance.now();
      
      const promises = Array.from({ length: 50 }, () =>
        request(app)
          .get('/api/auth/profile')
          .set('Authorization', `Bearer ${authToken}`)
      );

      const responses = await Promise.all(promises);
      const duration = performance.now() - start;

      // All requests should succeed
      responses.forEach(response => {
        expect(response.status).toBe(200);
      });

      // Should complete within 2 seconds
      expect(duration).toBeLessThan(2000);
    });

    it('should handle bulk sensor readings efficiently', async () => {
      const sensorData = {
        sensorId: 'BULK_TEST_001',
        type: 'temperature',
        location: { latitude: 40.7128, longitude: -74.0060 },
        thresholds: { min: 10, max: 35 }
      };

      await request(app)
        .post('/api/sensors')
        .set('Authorization', `Bearer ${authToken}`)
        .send(sensorData);

      const readings = Array.from({ length: 100 }, (_, i) => ({
        sensorId: 'BULK_TEST_001',
        data: { temperature: 20 + (i % 15), humidity: 50 + (i % 30) },
        timestamp: new Date(Date.now() + i * 1000),
        location: { latitude: 40.7128, longitude: -74.0060 }
      }));

      const start = performance.now();
      
      const promises = readings.map(reading =>
        request(app)
          .post('/api/sensors/readings')
          .set('Authorization', `Bearer ${authToken}`)
          .send(reading)
      );

      await Promise.all(promises);
      const duration = performance.now() - start;

      // Should process 100 readings within 5 seconds
      expect(duration).toBeLessThan(5000);
    });
  });

  describe('Memory Usage Tests', () => {
    it('should not have memory leaks during repeated operations', async () => {
      const initialMemory = process.memoryUsage().heapUsed;
      
      // Perform 1000 operations
      for (let i = 0; i < 1000; i++) {
        await request(app)
          .get('/health')
          .expect(200);
      }

      // Force garbage collection if available
      if (global.gc) {
        global.gc();
      }

      const finalMemory = process.memoryUsage().heapUsed;
      const memoryIncrease = finalMemory - initialMemory;
      
      // Memory increase should be reasonable (less than 50MB)
      expect(memoryIncrease).toBeLessThan(50 * 1024 * 1024);
    });
  });

  describe('Database Query Performance', () => {
    it('should retrieve user profile efficiently', async () => {
      const start = performance.now();
      
      await request(app)
        .get('/api/auth/profile')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);
      
      const duration = performance.now() - start;
      expect(duration).toBeLessThan(50);
    });

    it('should handle complex analytics queries within time limit', async () => {
      const start = performance.now();
      
      await request(app)
        .get('/api/analytics/dashboard')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);
      
      const duration = performance.now() - start;
      expect(duration).toBeLessThan(1000); // 1 second for complex queries
    });
  });

  describe('Stress Testing', () => {
    it('should maintain performance under high load', async () => {
      const concurrentUsers = 20;
      const requestsPerUser = 10;
      
      const start = performance.now();
      
      const userPromises = Array.from({ length: concurrentUsers }, async () => {
        const requests = Array.from({ length: requestsPerUser }, () =>
          request(app)
            .get('/health')
            .expect(200)
        );
        return Promise.all(requests);
      });

      await Promise.all(userPromises);
      const duration = performance.now() - start;

      // Should handle 200 requests (20 users × 10 requests) within 3 seconds
      expect(duration).toBeLessThan(3000);
    });
  });
});

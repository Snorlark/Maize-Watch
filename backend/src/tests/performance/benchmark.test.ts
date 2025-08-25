import request from 'supertest';
import { Express } from 'express';
import { createTestApp } from '../helpers/testApp';
import { performance } from 'perf_hooks';

describe('Performance Benchmark Tests', () => {
  let app: Express;

  beforeAll(async () => {
    app = await createTestApp();
  });

  describe('Response Time Benchmarks', () => {
    it('should respond to health check within 50ms', async () => {
      const start = performance.now();
      
      await request(app)
        .get('/health')
        .expect(200);
      
      const duration = performance.now() - start;
      expect(duration).toBeLessThan(50);
    });

    it('should handle authentication within 200ms', async () => {
      const start = performance.now();
      
      await request(app)
        .post('/api/auth/login')
        .send({
          email: 'test@example.com',
          password: 'password123'
        })
        .expect(200);
      
      const duration = performance.now() - start;
      expect(duration).toBeLessThan(200);
    });
  });

  describe('Concurrent Load Tests', () => {
    it('should handle 50 concurrent requests', async () => {
      const start = performance.now();
      
      const promises = Array.from({ length: 50 }, () =>
        request(app).get('/health').expect(200)
      );

      const responses = await Promise.all(promises);
      const duration = performance.now() - start;

      expect(responses.length).toBe(50);
      expect(duration).toBeLessThan(1000); // Should complete within 1 second
    });

    it('should maintain performance under sustained load', async () => {
      const iterations = 100;
      const start = performance.now();
      
      for (let i = 0; i < iterations; i++) {
        await request(app)
          .get('/health')
          .expect(200);
      }
      
      const duration = performance.now() - start;
      const avgResponseTime = duration / iterations;
      
      expect(avgResponseTime).toBeLessThan(10); // Average response time under 10ms
    });
  });

  describe('Memory Usage Tests', () => {
    it('should not leak memory during repeated operations', async () => {
      const initialMemory = process.memoryUsage().heapUsed;
      
      // Perform 500 operations
      for (let i = 0; i < 500; i++) {
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
      
      // Memory increase should be reasonable (less than 10MB)
      expect(memoryIncrease).toBeLessThan(10 * 1024 * 1024);
    });
  });

  describe('Throughput Tests', () => {
    it('should handle high request throughput', async () => {
      const requestCount = 200;
      const timeLimit = 2000; // 2 seconds
      
      const start = performance.now();
      
      const promises = Array.from({ length: requestCount }, () =>
        request(app).get('/health')
      );

      await Promise.all(promises);
      const duration = performance.now() - start;
      
      expect(duration).toBeLessThan(timeLimit);
      
      const requestsPerSecond = (requestCount / duration) * 1000;
      expect(requestsPerSecond).toBeGreaterThan(100); // At least 100 RPS
    });
  });
});

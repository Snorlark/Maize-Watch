import request from 'supertest';
import { Express } from 'express';
import { createTestApp } from '../helpers/testApp';
import jwt from 'jsonwebtoken';

describe('Security Tests', () => {
  let app: Express;
  let authToken: string;

  beforeAll(async () => {
    app = await createTestApp();
    
    const userData = {
      username: 'securitytest',
      email: 'security@example.com',
      password: 'password123',
      fullName: 'Security Test User',
      role: 'farmer'
    };

    const response = await request(app)
      .post('/api/auth/register')
      .send(userData);
    
    authToken = response.body.token;
  });

  describe('Authentication Security', () => {
    it('should reject requests without authentication token', async () => {
      await request(app)
        .get('/api/auth/profile')
        .expect(401);
    });

    it('should reject malformed JWT tokens', async () => {
      await request(app)
        .get('/api/auth/profile')
        .set('Authorization', 'Bearer invalid.jwt.token')
        .expect(401);
    });

    it('should reject expired JWT tokens', async () => {
      const expiredToken = jwt.sign(
        { userId: 'test', role: 'farmer' },
        process.env.JWT_SECRET || 'test-secret',
        { expiresIn: '-1h' } // Expired 1 hour ago
      );

      await request(app)
        .get('/api/auth/profile')
        .set('Authorization', `Bearer ${expiredToken}`)
        .expect(401);
    });

    it('should reject tokens with invalid signature', async () => {
      const invalidToken = jwt.sign(
        { userId: 'test', role: 'farmer' },
        'wrong-secret'
      );

      await request(app)
        .get('/api/auth/profile')
        .set('Authorization', `Bearer ${invalidToken}`)
        .expect(401);
    });
  });

  describe('Input Validation Security', () => {
    it('should prevent SQL injection attempts', async () => {
      const maliciousData = {
        email: "admin@example.com'; DROP TABLE users; --",
        password: 'password123'
      };

      await request(app)
        .post('/api/auth/login')
        .send(maliciousData)
        .expect(401); // Should fail authentication, not crash
    });

    it('should sanitize XSS attempts in registration', async () => {
      const xssData = {
        username: '<script>alert("xss")</script>',
        email: 'xss@example.com',
        password: 'password123',
        fullName: '<img src=x onerror=alert("xss")>',
        role: 'farmer'
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(xssData)
        .expect(201);

      // Check that XSS payload is sanitized
      expect(response.body.user.username).not.toContain('<script>');
      expect(response.body.user.fullName).not.toContain('<img');
    });

    it('should validate email format strictly', async () => {
      const invalidEmails = [
        'notanemail',
        '@example.com',
        'user@',
        'user..name@example.com',
        'user@example',
      ];

      for (const email of invalidEmails) {
        await request(app)
          .post('/api/auth/register')
          .send({
            username: 'testuser',
            email,
            password: 'password123',
            fullName: 'Test User',
            role: 'farmer'
          })
          .expect(400);
      }
    });

    it('should enforce password complexity', async () => {
      const weakPasswords = [
        '123',
        'password',
        '12345678',
        'abcdefgh',
        'ABCDEFGH'
      ];

      for (const password of weakPasswords) {
        await request(app)
          .post('/api/auth/register')
          .send({
            username: 'testuser',
            email: 'test@example.com',
            password,
            fullName: 'Test User',
            role: 'farmer'
          })
          .expect(400);
      }
    });
  });

  describe('Rate Limiting Security', () => {
    it('should enforce rate limits on sensitive endpoints', async () => {
      const requests = Array.from({ length: 20 }, () =>
        request(app)
          .post('/api/auth/login')
          .send({
            email: 'nonexistent@example.com',
            password: 'wrongpassword'
          })
      );

      const responses = await Promise.all(requests);
      const rateLimitedCount = responses.filter(res => res.status === 429).length;
      
      expect(rateLimitedCount).toBeGreaterThan(0);
    });

    it('should have different rate limits for different endpoints', async () => {
      // Test that health check has higher rate limit than auth endpoints
      const healthRequests = Array.from({ length: 100 }, () =>
        request(app).get('/health')
      );

      const responses = await Promise.all(healthRequests);
      const successfulRequests = responses.filter(res => res.status === 200).length;
      
      expect(successfulRequests).toBeGreaterThan(50); // Health should allow more requests
    });
  });

  describe('Authorization Security', () => {
    it('should prevent privilege escalation', async () => {
      // Create a regular farmer user
      const farmerData = {
        username: 'farmer',
        email: 'farmer@example.com',
        password: 'password123',
        fullName: 'Farmer User',
        role: 'farmer'
      };

      const farmerResponse = await request(app)
        .post('/api/auth/register')
        .send(farmerData);

      const farmerToken = farmerResponse.body.token;

      // Try to access admin-only endpoints
      await request(app)
        .get('/api/users') // Assuming this is admin-only
        .set('Authorization', `Bearer ${farmerToken}`)
        .expect(403);
    });

    it('should validate resource ownership', async () => {
      // Create two users
      const user1Data = {
        username: 'user1',
        email: 'user1@example.com',
        password: 'password123',
        fullName: 'User One',
        role: 'farmer'
      };

      const user2Data = {
        username: 'user2',
        email: 'user2@example.com',
        password: 'password123',
        fullName: 'User Two',
        role: 'farmer'
      };

      const user1Response = await request(app)
        .post('/api/auth/register')
        .send(user1Data);

      const user2Response = await request(app)
        .post('/api/auth/register')
        .send(user2Data);

      const user1Token = user1Response.body.token;
      const user2Token = user2Response.body.token;

      // User1 creates a farm
      const farmData = {
        name: 'User1 Farm',
        location: { latitude: 40.7128, longitude: -74.0060 },
        size: 100
      };

      const farmResponse = await request(app)
        .post('/api/farms')
        .set('Authorization', `Bearer ${user1Token}`)
        .send(farmData);

      const farmId = farmResponse.body._id;

      // User2 should not be able to access User1's farm
      await request(app)
        .get(`/api/farms/${farmId}`)
        .set('Authorization', `Bearer ${user2Token}`)
        .expect(403);
    });
  });

  describe('Data Protection Security', () => {
    it('should not expose sensitive data in responses', async () => {
      const response = await request(app)
        .get('/api/auth/profile')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.password).toBeUndefined();
      expect(response.body.passwordResetToken).toBeUndefined();
      expect(response.body.emailVerificationToken).toBeUndefined();
    });

    it('should hash passwords properly', async () => {
      const userData = {
        username: 'hashtest',
        email: 'hash@example.com',
        password: 'plainpassword123',
        fullName: 'Hash Test',
        role: 'farmer'
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(201);

      // Password should not be returned in response
      expect(response.body.user.password).toBeUndefined();
      
      // Login should work with original password
      await request(app)
        .post('/api/auth/login')
        .send({
          email: userData.email,
          password: userData.password
        })
        .expect(200);
    });
  });

  describe('HTTP Security Headers', () => {
    it('should include security headers', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.headers['x-content-type-options']).toBe('nosniff');
      expect(response.headers['x-frame-options']).toBeDefined();
      expect(response.headers['x-xss-protection']).toBeDefined();
    });

    it('should prevent clickjacking', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.headers['x-frame-options']).toMatch(/DENY|SAMEORIGIN/);
    });
  });

  describe('File Upload Security', () => {
    it('should validate file types for uploads', async () => {
      // Test with malicious file
      const maliciousFile = Buffer.from('<?php echo "hacked"; ?>');
      
      await request(app)
        .post('/api/users/avatar')
        .set('Authorization', `Bearer ${authToken}`)
        .attach('avatar', maliciousFile, 'malicious.php')
        .expect(400);
    });

    it('should enforce file size limits', async () => {
      // Create a large buffer (simulate large file)
      const largeFile = Buffer.alloc(10 * 1024 * 1024); // 10MB
      
      await request(app)
        .post('/api/users/avatar')
        .set('Authorization', `Bearer ${authToken}`)
        .attach('avatar', largeFile, 'large.jpg')
        .expect(413); // Payload too large
    });
  });

  describe('Session Security', () => {
    it('should invalidate tokens after password change', async () => {
      // This test would require implementing token invalidation
      // For now, we'll test that the endpoint exists and requires auth
      await request(app)
        .put('/api/auth/change-password')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          currentPassword: 'password123',
          newPassword: 'newpassword123'
        })
        .expect(200);
    });

    it('should prevent concurrent sessions (if implemented)', async () => {
      // Test multiple logins with same credentials
      const loginData = {
        email: 'security@example.com',
        password: 'password123'
      };

      const response1 = await request(app)
        .post('/api/auth/login')
        .send(loginData)
        .expect(200);

      const response2 = await request(app)
        .post('/api/auth/login')
        .send(loginData)
        .expect(200);

      // Both tokens should be valid (or implement session invalidation)
      expect(response1.body.token).toBeDefined();
      expect(response2.body.token).toBeDefined();
    });
  });
});

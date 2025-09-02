import request from 'supertest';
import { Express } from 'express';
import { IUser } from '../../models/User';
import { createTestApp } from '../helpers/testApp';

describe('Auth Integration Tests', () => {
  let app: Express;

  beforeAll(async () => {
    app = await createTestApp();
  });

  describe('POST /api/auth/register', () => {
    it('should register a new user successfully', async () => {
      const userData = {
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Test User',
        role: 'farmer'
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(201);

      expect(response.body).toHaveProperty('user');
      expect(response.body).toHaveProperty('token');
      expect(response.body.user.email).toBe(userData.email);
      expect(response.body.user.password).toBeUndefined();
    });

    it('should reject duplicate email registration', async () => {
      const userData = {
        username: 'testuser1',
        email: 'duplicate@example.com',
        password: 'password123',
        fullName: 'Test User 1',
        role: 'farmer'
      };

      // First registration
      await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(201);

      // Duplicate registration
      const duplicateData = { ...userData, username: 'testuser2' };
      await request(app)
        .post('/api/auth/register')
        .send(duplicateData)
        .expect(400);
    });

    it('should validate required fields', async () => {
      const invalidData = {
        username: 'testuser',
        // Missing email, password, fullName, role
      };

      await request(app)
        .post('/api/auth/register')
        .send(invalidData)
        .expect(400);
    });
  });

  describe('POST /api/auth/login', () => {
    beforeEach(async () => {
      // Create a test user
      const userData = {
        username: 'logintest',
        email: 'login@example.com',
        password: 'password123',
        fullName: 'Login Test',
        role: 'farmer'
      };

      await request(app)
        .post('/api/auth/register')
        .send(userData);
    });

    it('should login with valid credentials', async () => {
      const loginData = {
        email: 'login@example.com',
        password: 'password123'
      };

      const response = await request(app)
        .post('/api/auth/login')
        .send(loginData)
        .expect(200);

      expect(response.body).toHaveProperty('user');
      expect(response.body).toHaveProperty('token');
      expect(response.body.user.email).toBe(loginData.email);
    });

    it('should reject invalid credentials', async () => {
      const loginData = {
        email: 'login@example.com',
        password: 'wrongpassword'
      };

      await request(app)
        .post('/api/auth/login')
        .send(loginData)
        .expect(401);
    });

    it('should reject non-existent user', async () => {
      const loginData = {
        email: 'nonexistent@example.com',
        password: 'password123'
      };

      await request(app)
        .post('/api/auth/login')
        .send(loginData)
        .expect(401);
    });
  });

  describe('POST /api/auth/forgot-password', () => {
    beforeEach(async () => {
      const userData = {
        username: 'forgottest',
        email: 'forgot@example.com',
        password: 'password123',
        fullName: 'Forgot Test',
        role: 'farmer'
      };

      await request(app)
        .post('/api/auth/register')
        .send(userData);
    });

    it('should send password reset email for valid user', async () => {
      const response = await request(app)
        .post('/api/auth/forgot-password')
        .send({ email: 'forgot@example.com' })
        .expect(200);

      expect(response.body).toHaveProperty('message');
    });

    it('should handle non-existent email gracefully', async () => {
      await request(app)
        .post('/api/auth/forgot-password')
        .send({ email: 'nonexistent@example.com' })
        .expect(404);
    });
  });

  describe('Authentication Middleware Tests', () => {
    let authToken: string;

    beforeEach(async () => {
      const userData = {
        username: 'authtest',
        email: 'auth@example.com',
        password: 'password123',
        fullName: 'Auth Test',
        role: 'farmer'
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(userData);

      authToken = response.body.token;
    });

    it('should allow access with valid token', async () => {
      await request(app)
        .get('/api/auth/profile')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);
    });

    it('should reject access without token', async () => {
      await request(app)
        .get('/api/auth/profile')
        .expect(401);
    });

    it('should reject access with invalid token', async () => {
      await request(app)
        .get('/api/auth/profile')
        .set('Authorization', 'Bearer invalid-token')
        .expect(401);
    });
  });

  describe('Rate Limiting Tests', () => {
    it('should enforce rate limits on login attempts', async () => {
      const loginData = {
        email: 'ratelimit@example.com',
        password: 'wrongpassword'
      };

      // Make multiple failed login attempts
      const promises = Array.from({ length: 10 }, () =>
        request(app)
          .post('/api/auth/login')
          .send(loginData)
      );

      const responses = await Promise.all(promises);
      
      // Some requests should be rate limited
      const rateLimitedResponses = responses.filter(res => res.status === 429);
      expect(rateLimitedResponses.length).toBeGreaterThan(0);
    });
  });
});

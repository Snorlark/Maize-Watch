import request from 'supertest';
import { Express } from 'express';
import { createTestApp } from '../helpers/testApp';

describe('Sensors Integration Tests', () => {
  let app: Express;
  let authToken: string;
  let farmId: string;

  beforeAll(async () => {
    app = await createTestApp();
    
    // Create test user
    const userData = {
      username: 'sensortest',
      email: 'sensor@example.com',
      password: 'password123',
      fullName: 'Sensor Test User',
      role: 'farmer'
    };

    const userResponse = await request(app)
      .post('/api/auth/register')
      .send(userData);
    
    authToken = userResponse.body.token;

    // Create test farm
    const farmData = {
      name: 'Test Farm',
      location: { latitude: 40.7128, longitude: -74.0060 },
      size: 100,
      cropType: 'corn'
    };

    const farmResponse = await request(app)
      .post('/api/farms')
      .set('Authorization', `Bearer ${authToken}`)
      .send(farmData);
    
    farmId = farmResponse.body._id;
  });

  describe('POST /api/sensors', () => {
    it('should create a new sensor successfully', async () => {
      const sensorData = {
        sensorId: 'TEMP_001',
        type: 'temperature',
        farm: farmId,
        location: { latitude: 40.7128, longitude: -74.0060 },
        thresholds: { min: 10, max: 35 }
      };

      const response = await request(app)
        .post('/api/sensors')
        .set('Authorization', `Bearer ${authToken}`)
        .send(sensorData)
        .expect(201);

      expect(response.body.sensorId).toBe(sensorData.sensorId);
      expect(response.body.type).toBe(sensorData.type);
      expect(response.body.farm).toBe(farmId);
    });

    it('should reject duplicate sensor IDs', async () => {
      const sensorData = {
        sensorId: 'DUPLICATE_001',
        type: 'humidity',
        farm: farmId,
        location: { latitude: 40.7128, longitude: -74.0060 },
        thresholds: { min: 30, max: 80 }
      };

      // First creation
      await request(app)
        .post('/api/sensors')
        .set('Authorization', `Bearer ${authToken}`)
        .send(sensorData)
        .expect(201);

      // Duplicate creation
      await request(app)
        .post('/api/sensors')
        .set('Authorization', `Bearer ${authToken}`)
        .send(sensorData)
        .expect(400);
    });
  });

  describe('POST /api/sensors/readings', () => {
    beforeEach(async () => {
      const sensorData = {
        sensorId: 'READING_TEST_001',
        type: 'temperature',
        farm: farmId,
        location: { latitude: 40.7128, longitude: -74.0060 },
        thresholds: { min: 10, max: 35 }
      };

      await request(app)
        .post('/api/sensors')
        .set('Authorization', `Bearer ${authToken}`)
        .send(sensorData);
    });

    it('should process sensor reading successfully', async () => {
      const readingData = {
        sensorId: 'READING_TEST_001',
        data: { temperature: 25, humidity: 60 },
        timestamp: new Date(),
        location: { latitude: 40.7128, longitude: -74.0060 }
      };

      const response = await request(app)
        .post('/api/sensors/readings')
        .set('Authorization', `Bearer ${authToken}`)
        .send(readingData)
        .expect(201);

      expect(response.body.sensorId).toBe(readingData.sensorId);
      expect(response.body.data.temperature).toBe(25);
    });

    it('should trigger alerts for threshold violations', async () => {
      const alertData = {
        sensorId: 'READING_TEST_001',
        data: { temperature: 45, humidity: 60 }, // Above threshold
        timestamp: new Date(),
        location: { latitude: 40.7128, longitude: -74.0060 }
      };

      const response = await request(app)
        .post('/api/sensors/readings')
        .set('Authorization', `Bearer ${authToken}`)
        .send(alertData)
        .expect(201);

      expect(response.body.alerts).toBeDefined();
      expect(response.body.alerts.length).toBeGreaterThan(0);
    });
  });

  describe('GET /api/sensors', () => {
    it('should retrieve user sensors', async () => {
      const response = await request(app)
        .get('/api/sensors')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThan(0);
    });

    it('should filter sensors by farm', async () => {
      const response = await request(app)
        .get(`/api/sensors?farm=${farmId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
      response.body.forEach((sensor: any) => {
        expect(sensor.farm).toBe(farmId);
      });
    });
  });

  describe('GET /api/sensors/:sensorId/readings', () => {
    beforeEach(async () => {
      const sensorData = {
        sensorId: 'HISTORY_TEST_001',
        type: 'temperature',
        farm: farmId,
        location: { latitude: 40.7128, longitude: -74.0060 },
        thresholds: { min: 10, max: 35 }
      };

      await request(app)
        .post('/api/sensors')
        .set('Authorization', `Bearer ${authToken}`)
        .send(sensorData);

      // Add some readings
      const readings = [
        { temperature: 20, humidity: 50 },
        { temperature: 25, humidity: 55 },
        { temperature: 30, humidity: 60 }
      ];

      for (const data of readings) {
        await request(app)
          .post('/api/sensors/readings')
          .set('Authorization', `Bearer ${authToken}`)
          .send({
            sensorId: 'HISTORY_TEST_001',
            data,
            timestamp: new Date(),
            location: { latitude: 40.7128, longitude: -74.0060 }
          });
      }
    });

    it('should retrieve sensor reading history', async () => {
      const response = await request(app)
        .get('/api/sensors/HISTORY_TEST_001/readings')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBe(3);
    });

    it('should filter readings by date range', async () => {
      const startDate = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
      const endDate = new Date().toISOString();

      const response = await request(app)
        .get(`/api/sensors/HISTORY_TEST_001/readings?startDate=${startDate}&endDate=${endDate}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
    });
  });
});

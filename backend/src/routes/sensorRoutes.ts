import { Router } from 'express';
import {
  createSensor,
  getSensorsByFarm,
  getSensorById,
  updateSensor,
  deleteSensor,
  recordReading,
  getSensorReadings,
  getHistoricalReadings,
  syncFromThingSpeak,
  calibrateSensor,
  getSensorsNeedingMaintenance,
  getSensorStats,
  getLatestReadingsByFarm,
  getLatestSensorReading,
  getLast24HourReadings,
  getThingSpeakLiveData,
  getThingSpeakHistoricalData
} from '../controllers/sensorController';
import { authenticate, authorize } from '../middleware/auth';
import {
  validateSensorCreation,
  validateSensorReading,
  validateObjectId,
  validatePagination,
  validateDateRange
} from '../middleware/validation';
import { USER_ROLES } from '../utils/constants';

const router = Router();

// Test endpoints (no auth required) - MUST BE BEFORE authenticate middleware
// Simple test endpoint (no auth, no ThingSpeak)
router.get('/test-simple', (req, res) => {
  res.json({
    success: true,
    message: 'Simple sensor test endpoint working',
    timestamp: new Date().toISOString(),
    mockData: {
      temperature: 26.8,
      humidity: 65.3,
      soilMoisture: 78,
      soilPh: 6.5,
      lightIntensity: 420
    }
  });
});

// Test ThingSpeak connectivity (no auth required for debugging)
router.get('/test-thingspeak-noauth', async (req, res) => {
  try {
    console.log('🔍 Testing ThingSpeak without auth...');
    res.json({
      success: true,
      message: 'ThingSpeak test endpoint reached',
      timestamp: new Date().toISOString(),
      env_check: {
        hasApiKey: !!process.env.THINGSPEAK_API_KEY,
        hasChannelId: !!process.env.THINGSPEAK_CHANNEL_ID,
        hasReadKey: !!process.env.THINGSPEAK_READ_API_KEY,
        hasWriteKey: !!process.env.THINGSPEAK_WRITE_API_KEY
      }
    });
  } catch (error: any) {
    console.error('ThingSpeak test failed:', error);
    res.status(500).json({
      success: false,
      error: error.message,
      message: 'ThingSpeak test failed',
      timestamp: new Date().toISOString()
    });
  }
});

// Seed sample sensor data (no auth for testing)
router.post('/seed-sample-data', async (req, res) => {
  try {
    const SensorReading = (await import('../models/SensorReading')).default;
    const Farm = (await import('../models/Farm')).default;
    const Sensor = (await import('../models/Sensor')).default;
    
    console.log('🌱 Seeding sample sensor data...');
    
    // Find or create a test farm
    let testFarm = await Farm.findOne({ fieldName: 'Test Farm' });
    if (!testFarm) {
      testFarm = await Farm.create({
        fieldName: 'Test Farm',
        location: 'Test Location, Manila',
        soilType: 'Loamy',
        plantingDate: new Date(),
        growthStage: 'Vegetative',
        userId: '000000000000000000000000' // Dummy user ID
      });
    }
    
    // Find or create a test sensor
    let testSensor = await Sensor.findOne({ name: 'Test Sensor' });
    if (!testSensor) {
      testSensor = await Sensor.create({
        sensorId: 'TEST_SENSOR_001',
        name: 'Test Sensor',
        type: 'Multi_Sensor',
        farm: testFarm._id,
        location: {
          coordinates: [121.0244, 14.5547],
          description: 'Test sensor location'
        },
        specifications: {
          model: 'Test Model',
          manufacturer: 'Test Manufacturer'
        }
      });
    }
    
    // Create sample sensor readings
    const sampleReadings = [];
    for (let i = 0; i < 5; i++) {
      const reading = await SensorReading.create({
        sensor: testSensor._id,
        farm: testFarm._id,
        timestamp: new Date(Date.now() - i * 60000), // Every minute going back
        data: {
          temperature: 25 + Math.random() * 10,
          humidity: 60 + Math.random() * 20,
          soilMoisture: 70 + Math.random() * 15,
          pH: 6.0 + Math.random() * 1.5,
          lightIntensity: 400 + Math.random() * 200
        },
        metadata: {
          source: 'simulation',
          quality: 'good',
          processed: true
        }
      });
      sampleReadings.push(reading);
    }
    
    res.json({
      success: true,
      message: 'Sample sensor data seeded successfully',
      data: {
        farm: testFarm,
        sensor: testSensor,
        readingsCount: sampleReadings.length,
        latestReading: sampleReadings[0]
      }
    });
  } catch (error: any) {
    console.error('Error seeding sample data:', error);
    res.status(500).json({
      success: false,
      error: error.message,
      message: 'Failed to seed sample data'
    });
  }
});

// All routes below require authentication
router.use(authenticate);

// Get sensors needing maintenance (Admin only)
router.get('/maintenance', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), getSensorsNeedingMaintenance);

// Get sensor statistics (Admin only)
router.get('/stats', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), getSensorStats);

// Create sensor
router.post('/', validateSensorCreation, createSensor);

// Get sensor by ID
router.get('/:id', validateObjectId, getSensorById);

// Update sensor
router.put('/:id', validateObjectId, updateSensor);

// Delete sensor
router.delete('/:id', validateObjectId, deleteSensor);

// Record sensor reading
router.post('/:id/readings', validateObjectId, validateSensorReading, recordReading);

// Get sensor readings
router.get('/:id/readings', validateObjectId, validatePagination, validateDateRange, getSensorReadings);

// Historical readings for current user (by date range across their farms)
router.get('/historical', validateDateRange, getHistoricalReadings);

router.post('/:id/sync', validateObjectId, syncFromThingSpeak);

// Calibrate sensor
router.post('/:id/calibrate', validateObjectId, calibrateSensor);

// Get latest readings for farm (mobile compatibility)
router.get('/farms/:farmId/readings/latest', validateObjectId('farmId'), getLatestReadingsByFarm);

// Web admin compatibility - expected by LiveData.tsx
router.get('/farm/:id/latest', validateObjectId('id'), getLatestReadingsByFarm);

// General latest sensor data (not farm-specific) - now uses real data
router.get('/latest', getLatestSensorReading);

// Latest sensor data without ThingSpeak (for debugging)
router.get('/latest-no-thingspeak', async (req, res) => {
  try {
    console.log('🔍 Testing /latest without ThingSpeak...');
    
    // Return mock data immediately without ThingSpeak
    const mockData = {
      _id: 'mock-reading-' + Date.now(),
      timestamp: new Date().toISOString(),
      temperature: 26.8,
      humidity: 65.3,
      soilMoisture: 78,
      soilPh: 6.5,
      lightIntensity: 420
    };

    res.json({
      success: true,
      data: mockData,
      source: 'mock-no-thingspeak'
    });
  } catch (error: any) {
    console.error('Error in latest-no-thingspeak:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Last 24 hours data for dashboard - now returns proper array format
router.get('/last24h', getLast24HourReadings);

// NEW: Direct ThingSpeak endpoints for LiveData components
router.get('/thingspeak/live', getThingSpeakLiveData);
router.get('/thingspeak/historical', getThingSpeakHistoricalData);

// Test ThingSpeak connectivity (with auth)
router.get('/test-thingspeak', async (req, res) => {
  try {
    const { getThingSpeakService } = await import('../config/thingspeak');
    const thingSpeakService = getThingSpeakService();
    
    console.log('Testing ThingSpeak connectivity...');
    const startTime = Date.now();
    
    const data = await thingSpeakService.readLatestData();
    const endTime = Date.now();
    
    res.json({
      success: true,
      data: data,
      responseTime: `${endTime - startTime}ms`,
      timestamp: new Date().toISOString(),
      message: data ? 'ThingSpeak connection successful' : 'ThingSpeak returned no data'
    });
  } catch (error: any) {
    console.error('ThingSpeak test failed:', error);
    res.status(500).json({
      success: false,
      error: error.message,
      message: 'ThingSpeak connection failed',
      timestamp: new Date().toISOString()
    });
  }
});

// Backward-compat path expected by mobile client
router.get('/readings/latest/:farmId', validateObjectId('farmId'), getLatestReadingsByFarm);

export default router;
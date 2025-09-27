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
  getLatestReadingsByFarm
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

// All routes require authentication
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

// General latest sensor data (not farm-specific)
router.get('/latest', async (req, res) => {
  try {
    // Return general sensor data for fallback
    res.json({
      success: true,
      data: {
        _id: 'general-sensor-' + Date.now(),
        timestamp: new Date().toISOString(),
        temperature: 26.8,
        humidity: 65.3,
        soilMoisture: 78,
        soilPh: 6.5,
        lightIntensity: 420
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching general sensor data'
    });
  }
});

// Last 24 hours data for dashboard
router.get('/last24h', async (req, res) => {
  try {
    // For now, return the same as latest reading
    // TODO: Implement proper 24h aggregation
    res.json({
      success: true,
      data: {
        temperature: 25.5,
        humidity: 60.2,
        soilMoisture: 75,
        soilPh: 6.8,
        lightIntensity: 450,
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching 24h data'
    });
  }
});

// Backward-compat path expected by mobile client
router.get('/readings/latest/:farmId', validateObjectId('farmId'), getLatestReadingsByFarm);

export default router;
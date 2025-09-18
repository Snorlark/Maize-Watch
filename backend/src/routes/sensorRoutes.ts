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
  getSensorStats
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

// Sync from ThingSpeak
router.post('/:id/sync', validateObjectId, syncFromThingSpeak);

// Calibrate sensor
router.post('/:id/calibrate', validateObjectId, calibrateSensor);

export default router;

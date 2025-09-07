import { Router } from 'express';
import {
  createSensor,
  getSensorsByFarm,
  getSensorById,
  updateSensor,
  deleteSensor,
  recordReading,
  getSensorReadings,
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

// Sync from ThingSpeak
router.post('/:id/sync', validateObjectId, syncFromThingSpeak);

// Calibrate sensor
router.post('/:id/calibrate', validateObjectId, calibrateSensor);

// Get latest readings for farm (mobile compatibility)
router.get('/farms/:farmId/readings/latest', validateObjectId('farmId'), getLatestReadingsByFarm);

// Backward-compat path expected by mobile client
router.get('/readings/latest/:farmId', validateObjectId('farmId'), getLatestReadingsByFarm);

export default router;

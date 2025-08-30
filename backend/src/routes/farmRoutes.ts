import { Router } from 'express';
import {
  createFarm,
  createSimpleFarm,
  getFarms,
  getFarmById,
  updateFarm,
  deleteFarm,
  getFarmAnalytics,
  updateFarmStatus,
  addFarmImages,
  linkDeviceToFarm,
  unlinkDeviceFromFarm,
  getFarmByDeviceId,
  getFarmsByLocation,
  getFarmStats,
  getHarvestPredictions
} from '../controllers/farmController';
import { authenticate, authorize } from '../middleware/auth';
import {
  validateFarmCreation,
  validateObjectId,
  validatePagination,
  validateDateRange
} from '../middleware/validation';
import { USER_ROLES } from '../utils/constants';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Get farms by location (Admin only)
router.get('/location', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), getFarmsByLocation);

// Get farm by device ID
router.get('/device/:deviceId', validateObjectId, getFarmByDeviceId);

// Get farm statistics (Admin only)
router.get('/stats', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), getFarmStats);

// Create farm (simplified for corn-only system)
router.post('/', validateFarmCreation, createSimpleFarm);

// Get farms (with pagination)
router.get('/', validatePagination, getFarms);

// Get farm by ID
router.get('/:id', validateObjectId, getFarmById);

// Update farm
router.put('/:id', validateObjectId, updateFarm);

// Delete farm
router.delete('/:id', validateObjectId, deleteFarm);

// Get farm analytics
router.get('/:id/analytics', validateObjectId, validateDateRange, getFarmAnalytics);

// Update farm status
router.patch('/:id/status', validateObjectId, updateFarmStatus);

// Add farm images
router.post('/:id/images', validateObjectId, addFarmImages);

// Link device to farm
router.post('/:id/link-device', validateObjectId, linkDeviceToFarm);

// Unlink device from farm
router.delete('/:id/unlink-device', validateObjectId, unlinkDeviceFromFarm);

// Get harvest predictions
router.get('/:id/predictions', validateObjectId, getHarvestPredictions);

export default router;

import { Router } from 'express';
import {
  createFarm,
  getFarms,
  getFarmById,
  updateFarm,
  deleteFarm,
  getFarmAnalytics,
  updateFarmStatus,
  addFarmImages,
  updateWeatherData,
  updateSoilData,
  getFarmsNearby,
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

// Get farms nearby (Admin only)
router.get('/nearby', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), getFarmsNearby);

// Get farm statistics (Admin only)
router.get('/stats', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), getFarmStats);

// Create farm
router.post('/', validateFarmCreation, createFarm);

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

// Update weather data
router.put('/:id/weather', validateObjectId, updateWeatherData);

// Update soil data
router.put('/:id/soil', validateObjectId, updateSoilData);

// Get harvest predictions
router.get('/:id/predictions', validateObjectId, getHarvestPredictions);

export default router;

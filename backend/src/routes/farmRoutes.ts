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
  getHarvestPredictions,
  getTotalFarms   // 👈 make sure this is exported in farmController.ts
} from '../controllers/farmController';

import { authenticate, authorize, requireRegionalAdmin } from '../middleware/auth';
import {
  validateFarmCreation,
  validateObjectId,
  validatePagination,
  validateDateRange
} from '../middleware/validation';
import { USER_ROLES } from '../utils/constants';

const router = Router();
// Get total farm count
router.get("/total", getTotalFarms);  // 👈 now properly wired

// All routes require authentication
router.use(authenticate);

// Get farms by location (Admin only)
router.get('/location', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), getFarmsByLocation);

// Get farm by device ID
router.get('/device/:deviceId', validateObjectId, getFarmByDeviceId);

// Get farm statistics (Admin only)
router.get('/stats', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), getFarmStats);

// Create farm
router.post('/', validateFarmCreation, createSimpleFarm);

// Get farms (with pagination) - Regional Admin and above
router.get('/', requireRegionalAdmin, validatePagination, getFarms);

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
// import { Router } from 'express';
// import {
//   createFarm,
//   createSimpleFarm,
//   getFarms,
//   getFarmById,
//   updateFarm,
//   deleteFarm,
//   getFarmAnalytics,
//   updateFarmStatus,
//   addFarmImages,
//   linkDeviceToFarm,
//   unlinkDeviceFromFarm,
//   getFarmByDeviceId,
//   getFarmsByLocation,
//   getFarmStats,
//   getHarvestPredictions
// } from '../controllers/farmController';
// import { authenticate, authorize } from '../middleware/auth';
// import {
//   validateFarmCreation,
//   validateObjectId,
//   validatePagination,
//   validateDateRange
// } from '../middleware/validation';
// import { USER_ROLES } from '../utils/constants';
// import * as farmController from "../controllers/farmController"; 
// import Farm from '../models/Farm';

// const router = Router();

// // All routes require authentication
// router.use(authenticate);

// // Get farms by location (Admin only)
// router.get('/location', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), getFarmsByLocation);

// // Get farm by device ID
// router.get('/device/:deviceId', validateObjectId, getFarmByDeviceId);

// // Get farm statistics (Admin only)
// router.get('/stats', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), getFarmStats);

// // Create farm (simplified for corn-only system)
// router.post('/', validateFarmCreation, createSimpleFarm);

// // Get farms (with pagination)
// router.get('/', validatePagination, getFarms);

// // Add this route
// // router.get("/count", getTotalFarms);


// // // Get total farm count
// // router.get('/count', async (req, res) => {
// //   try {
// //     const total = await Farm.countDocuments();
// //     res.json({ total });
// //   } catch (error) {
// //     res.status(500).json({ message: "Error fetching total farms", error });
// //   }
// // });

// router.get("/total", farmController.getTotalFarms);


// // Get farm by ID
// router.get('/:id', validateObjectId, getFarmById);

// // Update farm
// router.put('/:id', validateObjectId, updateFarm);

// // Delete farm
// router.delete('/:id', validateObjectId, deleteFarm);

// // Get farm analytics
// router.get('/:id/analytics', validateObjectId, validateDateRange, getFarmAnalytics);

// // Update farm status
// router.patch('/:id/status', validateObjectId, updateFarmStatus);

// // Add farm images
// router.post('/:id/images', validateObjectId, addFarmImages);

// // Link device to farm
// router.post('/:id/link-device', validateObjectId, linkDeviceToFarm);

// // Unlink device from farm
// router.delete('/:id/unlink-device', validateObjectId, unlinkDeviceFromFarm);

// // Get harvest predictions
// router.get('/:id/predictions', validateObjectId, getHarvestPredictions);



// router.use(authenticate);

// export default router;

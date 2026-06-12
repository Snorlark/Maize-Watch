import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import {
  getSettings,
  updateSettings,
  updateNotificationSettings,
  updateLanguage,
  updateTheme,
  updateSyncSettings,
  updateDataCollection,
  updateAnalytics,
  getSensorStatus,
} from '../controllers/settingsController';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Settings routes
router.get('/', getSettings);
router.put('/', updateSettings);

// Specific setting updates
router.patch('/notifications', updateNotificationSettings);
router.patch('/language', updateLanguage);
router.patch('/theme', updateTheme);
router.patch('/sync', updateSyncSettings);
router.patch('/data-collection', updateDataCollection);
router.patch('/analytics', updateAnalytics);

// Sensor status
router.get('/sensors/status', getSensorStatus);

export default router;

import { Router } from 'express';
import {
  getAggregatedData,
  generateFarmReport,
  analyzeTrends,
  analyzeCorrelations,
  generatePredictiveModel,
  detectAnomalies,
  getYieldOptimizationInsights,
  exportData,
  getDashboardData,
  compareFarms
} from '../controllers/analyticsController';
import { authenticate, authorize } from '../middleware/auth';
import {
  validateObjectId,
  validateDateRange
} from '../middleware/validation';
import { USER_ROLES } from '../utils/constants';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Get dashboard data (Admin gets all, users get their own)
router.get('/dashboard', getDashboardData);

// Compare farms
router.get('/compare', compareFarms);

// Get aggregated data
router.get('/data', getAggregatedData);

// Farm-specific analytics routes
router.get('/farms/:farmId/report', validateObjectId('farmId'), generateFarmReport);
router.get('/farms/:farmId/trends', validateObjectId('farmId'), validateDateRange, analyzeTrends);
router.get('/farms/:farmId/correlations', validateObjectId('farmId'), validateDateRange, analyzeCorrelations);
router.post('/farms/:farmId/predict', validateObjectId('farmId'), generatePredictiveModel);
router.get('/farms/:farmId/anomalies', validateObjectId('farmId'), detectAnomalies);
router.get('/farms/:farmId/optimization', validateObjectId('farmId'), getYieldOptimizationInsights);
router.get('/farms/:farmId/export', validateObjectId('farmId'), validateDateRange, exportData);

export default router;

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
  compareFarms,
  runCornAnalytics,
  getDailyRecommendations,
  getCompleteAnalytics,
  getGrowthStageAnalysis,
  getRiskAssessment,
  getAnalyticsHealth,
  getCropStatus,
  getCropAnalytics,
  getWeeklyData,
  getCurrentWeatherForecast,
  getWeatherForecast,
  createTestSensorData,
  forceSyncThingSpeakData
} from '../controllers/analyticsController';
import { authenticate, authorize } from '../middleware/auth';
import {
  validateObjectId,
  validateDateRange
} from '../middleware/validation';
import { USER_ROLES } from '../utils/constants';

const router = Router();

// Public test endpoints (for development only)
router.get('/test/weekly-data/:farmId', validateObjectId('farmId'), getWeeklyData);
router.get('/test/crop/:farmId', validateObjectId('farmId'), getCropAnalytics);

// All other routes require authentication
router.use(authenticate);

// Get dashboard data (Admin gets all, users get their own)
router.get('/dashboard', getDashboardData);

// Compare farms
router.get('/compare', compareFarms);

// Get aggregated data
router.get('/data', getAggregatedData);

// System health check (Admin only)
router.get('/health', authorize(USER_ROLES.ADMIN), getAnalyticsHealth);

// Farm-specific analytics routes
router.get('/farms/:farmId/report', validateObjectId('farmId'), generateFarmReport);
router.get('/farms/:farmId/trends', validateObjectId('farmId'), validateDateRange, analyzeTrends);
router.get('/farms/:farmId/correlations', validateObjectId('farmId'), validateDateRange, analyzeCorrelations);
router.post('/farms/:farmId/predict', validateObjectId('farmId'), generatePredictiveModel);
router.get('/farms/:farmId/anomalies', validateObjectId('farmId'), detectAnomalies);
router.get('/farms/:farmId/optimization', validateObjectId('farmId'), getYieldOptimizationInsights);
router.get('/farms/:farmId/export', validateObjectId('farmId'), validateDateRange, exportData);

// Python Analytics v2 Integration Routes
router.post('/farms/:farmId/corn-analytics', validateObjectId('farmId'), runCornAnalytics);
router.get('/farms/:farmId/recommendations', validateObjectId('farmId'), getDailyRecommendations);
router.get('/farms/:farmId/complete', validateObjectId('farmId'), getCompleteAnalytics);
router.get('/farms/:farmId/growth-stage', validateObjectId('farmId'), getGrowthStageAnalysis);
router.get('/farms/:farmId/risk-assessment', validateObjectId('farmId'), getRiskAssessment);

// Minimal mobile endpoints
router.get('/crop-status/:farmId', validateObjectId('farmId'), getCropStatus);
router.get('/crop/:farmId', validateObjectId('farmId'), getCropAnalytics);
router.get('/farms/:farmId/weekly-data', validateObjectId('farmId'), getWeeklyData);

// Weather analytics endpoints
router.get('/weather/current/:farmId', validateObjectId('farmId'), getCurrentWeatherForecast);
router.get('/weather/forecast/:farmId', validateObjectId('farmId'), getWeatherForecast);

// Test data endpoint for development
router.post('/test-data', createTestSensorData);

// Force sync ThingSpeak data endpoint
router.post('/farms/:farmId/sync', validateObjectId('farmId'), forceSyncThingSpeakData);

export default router;

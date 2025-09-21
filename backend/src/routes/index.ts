import { Router } from 'express';
import authRoutes from './authRoute';
import userRoutes from './userRoutes';
import farmRoutes from './farmRoutes';
import sensorRoutes from './sensorRoutes';
import analyticsRoutes from './analyticsRoutes';
import historicalDataRouter from './historical_data.routes';  // ✅ import here
import { AppError } from '../middleware/errorHandler';
import { HTTP_STATUS } from '../utils/constants';

const router = Router();

// Health check endpoint
router.get('/health', (req, res) => {
  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Maize-Watch API is running',
    timestamp: new Date().toISOString(),
    version: process.env.API_VERSION || '1.0.0'
  });
});

// ✅ MOVED TEST ROUTE BEFORE 404 HANDLER
router.get('/test', (req, res) => {
  res.json({ 
    message: 'Routes working!', 
    timestamp: new Date().toISOString(),
    availableRoutes: [
      'GET /api/health',
      'GET /api/test', 
      'GET /api/historical-data',
      'GET /api/historical-data/debug',
      'GET /api/sensors/readings'
    ]
  });
});

// API routes
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/farms', farmRoutes);
router.use('/sensors', sensorRoutes);
router.use('/analytics', analyticsRoutes);
router.use('/historical-data', historicalDataRouter); // ✅ add this


// Farm-specific sensor routes
router.use('/farms/:farmId/sensors', (req, res, next) => {
  req.params.farmId = req.params.farmId;
  next();
}, sensorRoutes);

// Farm-specific reading routes
router.use('/farms/:farmId/readings', (req, res, next) => {
  req.params.farmId = req.params.farmId;
  next();
}, sensorRoutes);

// ✅ 404 handler MUST BE LAST - it catches all unmatched routes
router.use('*', (req, res, next) => {
  console.log(`[404] Route not found: ${req.method} ${req.originalUrl}`);
  next(new AppError(`Route ${req.originalUrl} not found`, HTTP_STATUS.NOT_FOUND));
});

export default router;
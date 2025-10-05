import { Router } from 'express';
import authRoutes from './authRoute';
import userRoutes from './userRoutes';
import farmRoutes from './farmRoutes';
import sensorRoutes from './sensorRoutes';
import analyticsRoutes from './analyticsRoutes';
import historicalDataRouter from './historical_data.routes';  // ✅ import here
import activityLogRoutes from './activityLog.route';  // ✅ import activity logs
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
      'GET /api/security-headers-test',
      'GET /api/historical-data',
      'GET /api/historical-data/debug',
      'GET /api/sensors/readings'
    ]
  });
});

// Security headers test endpoint
router.get('/security-headers-test', (req, res) => {
  // Get all response headers that will be sent
  const headers = res.getHeaders();
  
  res.status(200).json({
    success: true,
    message: 'Security headers test endpoint',
    timestamp: new Date().toISOString(),
    protocol: req.protocol,
    isSecure: req.secure,
    forwardedProto: req.get('x-forwarded-proto'),
    headers: {
      'content-security-policy': res.getHeader('content-security-policy'),
      'x-frame-options': res.getHeader('x-frame-options'),
      'referrer-policy': res.getHeader('referrer-policy'),
      'permissions-policy': res.getHeader('permissions-policy'),
      'strict-transport-security': res.getHeader('strict-transport-security'),
      'x-content-type-options': res.getHeader('x-content-type-options'),
      'x-dns-prefetch-control': res.getHeader('x-dns-prefetch-control'),
      'x-download-options': res.getHeader('x-download-options'),
      'x-permitted-cross-domain-policies': res.getHeader('x-permitted-cross-domain-policies')
    },
    allHeaders: headers
  });
});

// API routes
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/farms', farmRoutes);
router.use('/sensors', sensorRoutes);
router.use('/analytics', analyticsRoutes);
router.use('/historical-data', historicalDataRouter); // ✅ add this
router.use('/activity-logs', activityLogRoutes); // ✅ add activity logs


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
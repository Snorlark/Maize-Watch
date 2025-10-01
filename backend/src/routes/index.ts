import { Router } from 'express';
import authRoutes from './authRoute';
import userRoutes from './userRoutes';
import farmRoutes from './farmRoutes';
import fieldRoutes from './fieldRoutes';
import sensorRoutes from './sensorRoutes';
import analyticsRoutes from './analyticsRoutes';
import prescriptionRoutes from './prescriptionRoutes';
import settingsRoutes from './settingsRoutes';
import prototypeRoutes from './prototypeRoutes';
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

// API routes
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/farms', farmRoutes);
router.use('/fields', fieldRoutes);
router.use('/sensors', sensorRoutes);
router.use('/analytics', analyticsRoutes);
router.use('/prescriptions', prescriptionRoutes);
router.use('/settings', settingsRoutes);
router.use('/prototypes', prototypeRoutes);

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

// 404 handler for undefined routes
router.use('*', (req, res, next) => {
  next(new AppError(`Route ${req.originalUrl} not found`, HTTP_STATUS.NOT_FOUND));
});

export default router;

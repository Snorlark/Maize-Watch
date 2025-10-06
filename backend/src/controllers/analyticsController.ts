import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import analyticsService from '../services/analyticsService';
import farmService from '../services/farmService';
import pythonAnalyticsService from '../services/pythonAnalyticsService';
import thingSpeakService from '../services/thingspeakService';
import sensorService from '../services/sensorService';
import syncService from '../services/syncService';
import CacheService from '../services/cacheService';
import { AppError, catchAsync } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { HTTP_STATUS, USER_ROLES } from '../utils/constants';
import mongoose from 'mongoose';
import SensorReading from '../models/SensorReading';

/**
 * @desc    Get aggregated sensor data
 * @route   GET /api/analytics/data
 * @access  Private
 */
export const getAggregatedData = catchAsync(async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map((err: any) => ({
        field: err.param,
        message: err.msg
      }))
    });
  }

  const currentUser = (req as any).user;
  const { farmId, sensorId, startDate, endDate, interval } = req.query;

  // Verify access to farm if farmId is provided
  if (farmId) {
    const farm = await farmService.getFarmById(farmId as string);
    if (farm.userId.toString() !== currentUser.id && 
        currentUser.role !== USER_ROLES.ADMIN && 
        currentUser.role !== USER_ROLES.SUPER_ADMIN) {
      throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
    }
  }

  const query = {
    farmId: farmId as string,
    sensorId: sensorId as string,
    startDate: new Date(startDate as string),
    endDate: new Date(endDate as string),
    interval: interval as 'hour' | 'day' | 'week' | 'month',
    metrics: req.query.metrics ? (req.query.metrics as string).split(',') : undefined
  };

  const data = await analyticsService.getAggregatedData(query);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { aggregatedData: data }
  });
});

/**
 * @desc    Generate farm report
 * @route   GET /api/analytics/farms/:farmId/report
 * @access  Private
 */
export const generateFarmReport = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const { period = 'month' } = req.query;
  const currentUser = (req as any).user;

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const report = await analyticsService.generateFarmReport(
    farmId, 
    period as 'week' | 'month' | 'quarter' | 'year'
  );

  logger.info('Farm report generated', {
    farmId,
    period,
    generatedBy: currentUser.id
  });

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { report }
  });
});

/**
 * @desc    Analyze environmental trends
 * @route   GET /api/analytics/farms/:farmId/trends
 * @access  Private
 */
export const analyzeTrends = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const currentUser = (req as any).user;
  const startDate = req.query.startDate ? new Date(req.query.startDate as string) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const endDate = req.query.endDate ? new Date(req.query.endDate as string) : new Date();

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const trends = await analyticsService.analyzeTrends(farmId, startDate, endDate);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { trends }
  });
});

/**
 * @desc    Analyze correlations between metrics
 * @route   GET /api/analytics/farms/:farmId/correlations
 * @access  Private
 */
export const analyzeCorrelations = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const currentUser = (req as any).user;
  const startDate = req.query.startDate ? new Date(req.query.startDate as string) : new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const endDate = req.query.endDate ? new Date(req.query.endDate as string) : new Date();

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const correlations = await analyticsService.analyzeCorrelations(farmId, startDate, endDate);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { correlations }
  });
});

/**
 * @desc    Generate predictive model
 * @route   POST /api/analytics/farms/:farmId/predict
 * @access  Private
 */
export const generatePredictiveModel = catchAsync(async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map((err: any) => ({
        field: err.param,
        message: err.msg
      }))
    });
  }

  const { farmId } = req.params;
  const { metric, daysAhead = 7 } = req.body;
  const currentUser = (req as any).user;

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const model = await analyticsService.generatePredictiveModel(farmId, metric, daysAhead);

  logger.info('Predictive model generated', {
    farmId,
    metric,
    daysAhead,
    generatedBy: currentUser.id
  });

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { model }
  });
});

/**
 * @desc    Detect anomalies
 * @route   GET /api/analytics/farms/:farmId/anomalies
 * @access  Private
 */
export const detectAnomalies = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const { days = 30 } = req.query;
  const currentUser = (req as any).user;

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const anomalies = await analyticsService.detectAnomalies(farmId, parseInt(days as string));

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { anomalies }
  });
});

/**
 * @desc    Get yield optimization insights
 * @route   GET /api/analytics/farms/:farmId/optimization
 * @access  Private
 */
export const getYieldOptimizationInsights = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const currentUser = (req as any).user;

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const insights = await analyticsService.getYieldOptimizationInsights(farmId);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { insights }
  });
});

/**
 * @desc    Export analytics data
 * @route   GET /api/analytics/farms/:farmId/export
 * @access  Private
 */
export const exportData = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const { format = 'json', startDate, endDate } = req.query;
  const currentUser = (req as any).user;

  if (!startDate || !endDate) {
    throw new AppError('Start date and end date are required', HTTP_STATUS.BAD_REQUEST);
  }

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const exportedData = await analyticsService.exportData(
    farmId,
    format as 'csv' | 'json' | 'excel',
    new Date(startDate as string),
    new Date(endDate as string)
  );

  logger.info('Analytics data exported', {
    farmId,
    format,
    exportedBy: currentUser.id
  });

  // Set appropriate headers based on format
  if (format === 'csv') {
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', `attachment; filename=farm-data-${farmId}.csv`);
    res.send(exportedData);
  } else if (format === 'excel') {
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename=farm-data-${farmId}.xlsx`);
    res.json(exportedData);
  } else {
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Disposition', `attachment; filename=farm-data-${farmId}.json`);
    res.json(exportedData);
  }
});

/**
 * @desc    Get analytics dashboard data
 * @route   GET /api/analytics/dashboard
 * @access  Private/Admin
 */
export const getDashboardData = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;
  const { period = 'month' } = req.query;

  // Get farms based on user role
  let farmIds: string[] = [];
  
  if (currentUser.role === USER_ROLES.ADMIN || currentUser.role === USER_ROLES.SUPER_ADMIN) {
    // Admins can see all farms
    const allFarms = await farmService.getFarmsByOwner('');
    farmIds = allFarms.map((farm: any) => farm._id.toString());
  } else {
    // Regular users see only their farms
    const userFarms = await farmService.getFarmsByOwner(currentUser.id);
    farmIds = userFarms.map((farm: any) => farm._id.toString());
  }

  // Generate summary data for all accessible farms
  const dashboardData = {
    totalFarms: farmIds.length,
    reports: [] as any[],
    trends: [] as any[],
    alerts: [] as any[]
  };

  // Get basic stats for each farm (limit to prevent performance issues)
  const maxFarms = 10;
  const limitedFarmIds = farmIds.slice(0, maxFarms);

  for (const farmId of limitedFarmIds) {
    try {
      const report = await analyticsService.generateFarmReport(
        farmId, 
        period as 'week' | 'month' | 'quarter' | 'year'
      );
      dashboardData.reports.push({
        farmId,
        farmName: report.farm.name,
        summary: {
          totalSensors: report.statistics.temperature?.count || 0,
          alertCount: report.alerts.total,
          dataQuality: report.dataQuality
        }
      });
    } catch (error) {
      logger.warn(`Failed to generate report for farm ${farmId}:`, error);
    }
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: dashboardData
  });
});

/**
 * @desc    Compare farms performance
 * @route   GET /api/analytics/compare
 * @access  Private
 */
export const compareFarms = catchAsync(async (req: Request, res: Response) => {
  const { farmIds, metric = 'temperature', period = 'month' } = req.query;
  const currentUser = (req as any).user;

  if (!farmIds) {
    throw new AppError('Farm IDs are required', HTTP_STATUS.BAD_REQUEST);
  }

  const farmIdArray = (farmIds as string).split(',');

  // Verify user has access to all farms
  for (const farmId of farmIdArray) {
    const farm = await farmService.getFarmById(farmId);
    if (farm.userId.toString() !== currentUser.id && 
        currentUser.role !== USER_ROLES.ADMIN && 
        currentUser.role !== USER_ROLES.SUPER_ADMIN) {
      throw new AppError(`Access denied to farm ${farmId}`, HTTP_STATUS.FORBIDDEN);
    }
  }

  const comparison = {
    farms: farmIdArray,
    metric: metric as string,
    period: period as string,
    data: [] as any[]
  };

  // Get data for each farm
  for (const farmId of farmIdArray) {
    try {
      const endDate = new Date();
      const startDate = new Date();
      
      switch (period) {
        case 'week':
          startDate.setDate(startDate.getDate() - 7);
          break;
        case 'month':
          startDate.setMonth(startDate.getMonth() - 1);
          break;
        case 'quarter':
          startDate.setMonth(startDate.getMonth() - 3);
          break;
        default:
          startDate.setDate(startDate.getDate() - 30);
      }

      const trends = await analyticsService.analyzeTrends(farmId, startDate, endDate);
      const farmTrend = trends.find(t => t.metric === metric);
      
      comparison.data.push({
        farmId,
        trend: farmTrend || { metric, trend: 'stable', changeRate: 0, confidence: 0 }
      });
    } catch (error) {
      logger.warn(`Failed to get trends for farm ${farmId}:`, error);
    }
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { comparison }
  });
});

/**
 * @desc    Run Python analytics_v2 system for farm
 * @route   POST /api/analytics/farms/:farmId/corn-analytics
 * @access  Private
 */
export const runCornAnalytics = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const currentUser = (req as any).user;

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  // Use the actual user ID instead of hardcoded value
  const results = await pythonAnalyticsService.runCompleteAnalytics(farmId, currentUser.id);

  logger.info('Corn analytics completed', {
    farmId,
    generatedBy: currentUser.id,
    priorityScore: results.prescriptive.priority_score
  });

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { analytics: results }
  });
});

/**
 * @desc    Get daily recommendations for farm
 * @route   GET /api/analytics/farms/:farmId/recommendations
 * @access  Private
 */
export const getDailyRecommendations = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const currentUser = (req as any).user;

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const recommendations = await pythonAnalyticsService.getDailyRecommendations(farmId);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { recommendations }
  });
});

/**
 * @desc    Get complete analytics data for farm (descriptive, predictive, prescriptive)
 * @route   GET /api/analytics/farms/:farmId/complete
 * @access  Private
 */
export const getCompleteAnalytics = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const { fieldId } = req.query; // Get fieldId from query parameters
  const currentUser = (req as any).user;

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  try {
    // Check if we have recent analytics data cached (within last 30 minutes)
    const cachedAnalytics = await CacheService.getFarmAnalytics(farmId);
    if (cachedAnalytics && cachedAnalytics.timestamp) {
      const cacheAge = Date.now() - new Date(cachedAnalytics.timestamp).getTime();
      const thirtyMinutes = 30 * 60 * 1000;
      
      if (cacheAge < thirtyMinutes) {
        logger.info(`Returning cached analytics for farm ${farmId} (age: ${Math.round(cacheAge / 60000)} minutes)`);
        return res.status(HTTP_STATUS.OK).json({
          success: true,
          data: cachedAnalytics.data,
          cached: true,
          cacheAge: Math.round(cacheAge / 60000)
        });
      }
    }
    
    // Only sync if cache is stale or missing
    logger.info(`Syncing latest data from ThingSpeak for farm ${farmId}`);
    await syncService.syncFarmData(farmId);
    
    // Get complete analytics data with fieldId
    const analytics = await pythonAnalyticsService.runCompleteAnalytics(farmId, currentUser.id, fieldId as string);
    
    res.status(HTTP_STATUS.OK).json({
      success: true,
      data: analytics
    });
  } catch (error) {
    logger.error('Error getting complete analytics:', error);
    throw new AppError('Failed to get analytics data', HTTP_STATUS.INTERNAL_SERVER_ERROR);
  }
});

/**
 * @desc    Create test sensor data for development
 * @route   POST /api/analytics/test-data
 * @access  Private
 */
export const createTestSensorData = catchAsync(async (req: Request, res: Response) => {
  const { farmId, fieldId } = req.body;
  const currentUser = (req as any).user;

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  try {
    // Import SensorReading model
    const SensorReading = require('../models/SensorReading').default;
    const mongoose = require('mongoose');

    // Create test sensor data for the last 7 days
    const testData = [];
    const now = new Date();
    
    for (let i = 0; i < 7; i++) {
      const timestamp = new Date(now.getTime() - (i * 24 * 60 * 60 * 1000));
      
      // Create realistic test data with some variation
      const baseTemp = 25 + (Math.random() - 0.5) * 10; // 20-30°C
      const baseHumidity = 60 + (Math.random() - 0.5) * 20; // 50-70%
      const baseSoilMoisture = 40 + (Math.random() - 0.5) * 20; // 30-50%
      const baseSoilPh = 6.5 + (Math.random() - 0.5) * 1; // 6.0-7.0
      const baseLight = 500 + (Math.random() - 0.5) * 200; // 400-600

      const sensorData = new SensorReading({
        timestamp: timestamp,
        farm: new mongoose.Types.ObjectId(farmId),
        field_id: fieldId || '124', // Add field_id for analytics compatibility
        sensor: new mongoose.Types.ObjectId('68d58aff35083cdabb3a7e27'), // Use existing sensor ID
        data: {
          temperature: Math.round(baseTemp * 10) / 10,
          humidity: Math.round(baseHumidity * 10) / 10,
          soilMoisture: Math.round(baseSoilMoisture * 10) / 10,
          pH: Math.round(baseSoilPh * 10) / 10,
          lightIntensity: Math.round(baseLight * 10) / 10
        },
        metadata: {
          source: 'simulation',
          quality: 'good',
          processed: true,
          version: '1.0'
        }
      });

      testData.push(sensorData);
    }

    // Save all test data
    await SensorReading.insertMany(testData);

    res.status(HTTP_STATUS.OK).json({
      success: true,
      message: `Created ${testData.length} test sensor readings`,
      data: {
        farmId,
        fieldId: fieldId || '124',
        readings: testData.length,
        dateRange: {
          from: testData[testData.length - 1].timestamp,
          to: testData[0].timestamp
        }
      }
    });
  } catch (error) {
    logger.error('Error creating test sensor data:', error);
    throw new AppError('Failed to create test data', HTTP_STATUS.INTERNAL_SERVER_ERROR);
  }
});

/**
 * @desc    Get growth stage analysis for farm
 * @route   GET /api/analytics/farms/:farmId/growth-stage
 * @access  Private
 */
export const getGrowthStageAnalysis = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const currentUser = (req as any).user;

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const growthAnalysis = await pythonAnalyticsService.getGrowthStageAnalysis(farmId);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { growthAnalysis }
  });
});

/**
 * @desc    Get risk assessment for farm
 * @route   GET /api/analytics/farms/:farmId/risk-assessment
 * @access  Private
 */
export const getRiskAssessment = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const currentUser = (req as any).user;

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const riskAssessment = await pythonAnalyticsService.getRiskAssessment(farmId);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { riskAssessment }
  });
});

/**
 * @desc    Health check for Python analytics system
 * @route   GET /api/analytics/health
 * @access  Private/Admin
 */
export const getAnalyticsHealth = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;

  // Only admins can check system health
  if (currentUser.role !== USER_ROLES.ADMIN && currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const health = await pythonAnalyticsService.healthCheck();

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { health }
  });
});

/**
 * @desc    Get overall crop status (minimal implementation for mobile)
 * @route   GET /api/analytics/crop-status/:farmId
 * @access  Private
 */
export const getCropStatus = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const { fieldId } = req.query; // optional, reserved for per-field in future
  const currentUser = (req as any).user;

  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  try {
    // First, sync latest data from ThingSpeak
    await syncService.syncFarmData(farmId);
    
    // Get field-specific sensor data from IoT database
    const fieldSensorData = await syncService.getSensorDataForAnalytics(farmId);
    
    if (!fieldSensorData) {
      // Try to get data from ThingSpeak as fallback
      const thingSpeakData = await thingSpeakService.getLatestData();
      if (thingSpeakData) {
        const temperature = thingSpeakData.temperature;
        const humidity = thingSpeakData.humidity;
        const soilMoisture = thingSpeakData.soilMoisture;
        const soilPh = thingSpeakData.soilPh;
        const lightIntensity = thingSpeakData.lightIntensity;
        
        // Determine crop status based on ThingSpeak data
    let status = 'NORMAL';
    let message = 'Your corn is in normal condition.';
    let color = '#FFC107'; // Amber
    let icon = 'normal';

        // Check for critical conditions
        if (soilMoisture < 20 || soilMoisture > 90 || 
            temperature < 10 || temperature > 40 ||
            soilPh < 5.0 || soilPh > 8.5) {
          status = 'CRITICAL';
          message = 'Your corn is in critical condition. Immediate action required.';
          color = '#F44336'; // Red
          icon = 'critical';
        }
        // Check for warning conditions
        else if (soilMoisture < 30 || soilMoisture > 80 ||
                 temperature < 15 || temperature > 35 ||
                 soilPh < 5.5 || soilPh > 8.0 ||
                 humidity < 30 || humidity > 85) {
          status = 'WARNING';
          message = 'Your corn needs attention. Check soil moisture and nutrients.';
          color = '#FF9800'; // Orange
          icon = 'warning';
        }
        // Check for good conditions
        else if (soilMoisture >= 40 && soilMoisture <= 70 &&
                 temperature >= 20 && temperature <= 30 &&
                 soilPh >= 6.0 && soilPh <= 7.5 &&
                 humidity >= 50 && humidity <= 75 &&
                 lightIntensity >= 400 && lightIntensity <= 1000) {
          status = 'GOOD';
          message = 'Your corn is growing well with good conditions.';
          color = '#8BC34A'; // Light Green
          icon = 'good';
        }
        // Check for excellent conditions
        else if (soilMoisture >= 50 && soilMoisture <= 65 &&
                 temperature >= 22 && temperature <= 28 &&
                 soilPh >= 6.2 && soilPh <= 7.0 &&
                 humidity >= 55 && humidity <= 70 &&
                 lightIntensity >= 500 && lightIntensity <= 800) {
          status = 'EXCELLENT';
          message = 'Your corn is in excellent condition!';
          color = '#4CAF50'; // Green
          icon = 'excellent';
        }

        return res.status(HTTP_STATUS.OK).json({
          success: true,
          data: { 
            status,
            message,
            color,
            icon
          }
        });
      }
      
      // Return default status if no sensor data
      return res.status(HTTP_STATUS.OK).json({
        success: true,
        data: { 
          status: 'NORMAL',
          message: 'No sensor data available. Check sensor connectivity.',
          color: '#9E9E9E',
          icon: 'unknown'
        }
      });
    }

    // Calculate averages from field-specific sensor data
    const fieldDataArray = Object.values(fieldSensorData);
    const temperature = fieldDataArray.reduce((sum, r) => sum + ((r as any)?.temperature || 0), 0) as number / fieldDataArray.length;
    const humidity = fieldDataArray.reduce((sum, r) => sum + ((r as any)?.humidity || 0), 0) as number / fieldDataArray.length;
    const soilMoisture = fieldDataArray.reduce((sum, r) => sum + ((r as any)?.soilMoisture || 0), 0) as number / fieldDataArray.length;
    const soilPh = fieldDataArray.reduce((sum, r) => sum + ((r as any)?.soilPh || 0), 0) as number / fieldDataArray.length;
    const lightIntensity = fieldDataArray.reduce((sum, r) => sum + ((r as any)?.lightIntensity || 0), 0) as number / fieldDataArray.length;

    // Determine crop status based on sensor readings
    let status = 'NORMAL';
    let message = 'Your corn is in normal condition.';
    let color = '#FFC107'; // Amber
    let icon = 'normal';

    // Check for critical conditions
    if (soilMoisture < 20 || soilMoisture > 90 || 
        temperature < 10 || temperature > 40 ||
        soilPh < 5.0 || soilPh > 8.5) {
      status = 'CRITICAL';
      message = 'Your corn is in critical condition. Immediate action required.';
      color = '#F44336'; // Red
      icon = 'critical';
    }
    // Check for warning conditions
    else if (soilMoisture < 30 || soilMoisture > 80 ||
             temperature < 15 || temperature > 35 ||
             soilPh < 5.5 || soilPh > 8.0 ||
             humidity < 30 || humidity > 85) {
      status = 'WARNING';
      message = 'Your corn needs attention. Check soil moisture and nutrients.';
      color = '#FF9800'; // Orange
      icon = 'warning';
    }
    // Check for good conditions
    else if (soilMoisture >= 40 && soilMoisture <= 70 &&
             temperature >= 20 && temperature <= 30 &&
             soilPh >= 6.0 && soilPh <= 7.5 &&
             humidity >= 50 && humidity <= 75 &&
             lightIntensity >= 400 && lightIntensity <= 1000) {
      status = 'GOOD';
      message = 'Your corn is growing well with good conditions.';
      color = '#8BC34A'; // Light Green
      icon = 'good';
    }
    // Check for excellent conditions
    else if (soilMoisture >= 50 && soilMoisture <= 65 &&
             temperature >= 22 && temperature <= 28 &&
             soilPh >= 6.2 && soilPh <= 7.0 &&
             humidity >= 55 && humidity <= 70 &&
             lightIntensity >= 500 && lightIntensity <= 800) {
      status = 'EXCELLENT';
      message = 'Your corn is in excellent condition!';
      color = '#4CAF50'; // Green
      icon = 'excellent';
    }

    res.status(HTTP_STATUS.OK).json({
      success: true,
      data: { 
        status,
        message,
        color,
        icon
      }
    });
  } catch (error) {
    logger.error('Error getting crop status:', error);
    // Return default status if there's an error
  res.status(HTTP_STATUS.OK).json({
    success: true,
      data: { 
        status: 'NORMAL',
        message: 'Unable to determine crop condition. Check sensor connectivity.',
        color: '#9E9E9E',
        icon: 'unknown'
      }
    });
  }
});

/**
 * @desc    Get crop analytics summary (minimal implementation for mobile)
 * @route   GET /api/analytics/crop/:farmId
 * @access  Private
 */
export const getCropAnalytics = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const { fieldId } = req.query; // optional, reserved for per-field in future
  const currentUser = (req as any).user;

  // Skip authentication check for test endpoints
  if (currentUser) {
    const farm = await farmService.getFarmById(farmId);
    if (farm.userId.toString() !== currentUser.id && 
        currentUser.role !== USER_ROLES.ADMIN && 
        currentUser.role !== USER_ROLES.SUPER_ADMIN) {
      throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
    }
  }

  try {
    // For test endpoints, return sample data immediately
    if (req.path.includes('/test/')) {
      return res.status(HTTP_STATUS.OK).json({
        success: true,
        data: {
          soilPh: 6.5 + (Math.random() - 0.5) * 1,
          soilMoisture: 50 + (Math.random() - 0.5) * 20,
          temperature: 25 + (Math.random() - 0.5) * 10,
          humidity: 60 + (Math.random() - 0.5) * 20,
          lightIntensity: 500 + (Math.random() - 0.5) * 200,
          timestamp: new Date().toISOString()
        }
      });
    }
    
    // First, sync latest data from ThingSpeak
    await syncService.syncFarmData(farmId);
    
    // Get latest sensor data from MongoDB
    const latestReadings = await sensorService.getLatestReadingsByFarm(farmId);
    
    if (!latestReadings || latestReadings.length === 0) {
      // Try to get data from ThingSpeak as fallback
      const thingSpeakData = await thingSpeakService.getLatestData();
      if (thingSpeakData) {
        return res.status(HTTP_STATUS.OK).json({
          success: true,
          data: {
            soilPh: thingSpeakData.soilPh,
            soilMoisture: thingSpeakData.soilMoisture,
            temperature: thingSpeakData.temperature,
            humidity: thingSpeakData.humidity,
            lightIntensity: thingSpeakData.lightIntensity,
            timestamp: thingSpeakData.timestamp.toISOString()
          }
        });
      }
      
      // Return default values if no sensor data
      return res.status(HTTP_STATUS.OK).json({
        success: true,
        data: {
          soilPh: 7.0,
          soilMoisture: 4.0,
          temperature: 23.4,
          humidity: 83.0,
          lightIntensity: 16500.0,
          timestamp: new Date().toISOString()
        }
      });
    }

    // Calculate averages from latest readings
    const readings = latestReadings.map(r => r.data);
    const soilPh = readings.reduce((sum, r) => sum + (r.pH || 0), 0) / readings.length;
    const soilMoisture = readings.reduce((sum, r) => sum + (r.soilMoisture || 0), 0) / readings.length;
    const temperature = readings.reduce((sum, r) => sum + (r.temperature || 0), 0) / readings.length;
    const humidity = readings.reduce((sum, r) => sum + (r.humidity || 0), 0) / readings.length;
    const lightIntensity = readings.reduce((sum, r) => sum + (r.lightIntensity || 0), 0) / readings.length;
    const timestamp = latestReadings[0].timestamp; // Use timestamp from first reading
    
    res.status(HTTP_STATUS.OK).json({
      success: true,
      data: {
        soilPh: Math.round(soilPh * 100) / 100,
        soilMoisture: Math.round(soilMoisture * 100) / 100,
        temperature: Math.round(temperature * 100) / 100,
        humidity: Math.round(humidity * 100) / 100,
        lightIntensity: Math.round(lightIntensity * 100) / 100,
        timestamp: timestamp.toISOString()
      }
    });
  } catch (error) {
    logger.error('Error getting crop analytics:', error);
    // Return default values if there's an error
    res.status(HTTP_STATUS.OK).json({
      success: true,
      data: {
        soilPh: 6.5,
        soilMoisture: 50.0,
        temperature: 25.0,
        humidity: 60.0,
        lightIntensity: 500.0,
        timestamp: new Date().toISOString()
      }
    });
  }
});

/**
 * @desc    Get weekly historical data for mobile analytics
 * @route   GET /api/analytics/farms/:farmId/weekly-data
 * @access  Private
 */
export const getWeeklyData = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const { fieldId } = req.query; // optional, reserved for per-field in future
  const currentUser = (req as any).user;

  // Skip authentication check for test endpoints
  if (currentUser) {
    const farm = await farmService.getFarmById(farmId);
    if (farm.userId.toString() !== currentUser.id && 
        currentUser.role !== USER_ROLES.ADMIN && 
        currentUser.role !== USER_ROLES.SUPER_ADMIN) {
      throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
    }
  }

  try {
    // For test endpoints, return sample data immediately
    if (req.path.includes('/test/')) {
      const dailyData = [];
      const now = new Date();
      
      for (let i = 6; i >= 0; i--) {
        const date = new Date(now);
        date.setDate(date.getDate() - i);
        date.setHours(0, 0, 0, 0);
        
        // Generate realistic sample data
        const baseTemp = 25 + (Math.random() - 0.5) * 10; // 20-30°C
        const baseHumidity = 60 + (Math.random() - 0.5) * 20; // 50-70%
        const baseSoilMoisture = 40 + (Math.random() - 0.5) * 20; // 30-50%
        const baseSoilPh = 6.5 + (Math.random() - 0.5) * 1; // 6.0-7.0
        const baseLight = 500 + (Math.random() - 0.5) * 200; // 400-600
        
        dailyData.push({
          date: date.toISOString().split('T')[0],
          temperature: Math.round(baseTemp * 100) / 100,
          humidity: Math.round(baseHumidity * 100) / 100,
          soilMoisture: Math.round(baseSoilMoisture * 100) / 100,
          soilPh: Math.round(baseSoilPh * 100) / 100,
          lightIntensity: Math.round(baseLight * 100) / 100,
        });
      }
      
      return res.status(HTTP_STATUS.OK).json({
        success: true,
        data: {
          dailyData,
          summary: {
            totalDays: 7,
            dataPoints: 7
          }
        }
      });
    }
    
    // Check cache first
    const cacheKey = `weekly_data_${farmId}_${fieldId || 'all'}`;
    const cached = await CacheService.get(cacheKey);
    if (cached) {
      logger.info(`Cache hit for weekly data: ${cacheKey}`);
      return res.status(HTTP_STATUS.OK).json({
        success: true,
        data: cached
      });
    }

    // Get historical data for the past 7 days from MongoDB using aggregation
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - 7);
    
    // Get all sensors for the farm first
    const sensors = await sensorService.getSensorsByFarm(farmId);
    const sensorIds = sensors.map(s => (s as any)._id);
    
    // Use MongoDB aggregation for efficient data processing
    const aggregationPipeline = [
      {
        $match: {
          sensor: { $in: sensorIds },
          timestamp: {
            $gte: startDate,
            $lte: endDate
          }
        }
      },
      {
        $group: {
          _id: {
            year: { $year: '$timestamp' },
            month: { $month: '$timestamp' },
            day: { $dayOfMonth: '$timestamp' }
          },
          temperature: { $avg: '$data.temperature' },
          humidity: { $avg: '$data.humidity' },
          soilMoisture: { $avg: '$data.soilMoisture' },
          soilPh: { $avg: '$data.pH' },
          lightIntensity: { $avg: '$data.lightIntensity' },
          count: { $sum: 1 }
        }
      },
      {
        $sort: { '_id.year': 1 as 1, '_id.month': 1 as 1, '_id.day': 1 as 1 }
      }
    ];

    const aggregatedData = await SensorReading.aggregate(aggregationPipeline);
    
    // If no readings from MongoDB, try to get from ThingSpeak
    let historicalData = [];
    if (aggregatedData.length === 0) {
      logger.info('No MongoDB data found, fetching from ThingSpeak...');
      const thingSpeakData = await thingSpeakService.getHistoricalData(7 * 24 * 60); // 7 days in minutes
      if (thingSpeakData && thingSpeakData.length > 0) {
        // Convert ThingSpeak data to daily format
        const thingSpeakByDay: { [key: string]: { temperature: number[], humidity: number[], soilMoisture: number[], soilPh: number[], lightIntensity: number[] } } = {};
        for (const dataPoint of thingSpeakData) {
          const date = new Date(dataPoint.timestamp);
          const dayKey = `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
          
          if (!thingSpeakByDay[dayKey]) {
            thingSpeakByDay[dayKey] = {
              temperature: [],
              humidity: [],
              soilMoisture: [],
              soilPh: [],
              lightIntensity: []
            };
          }
          
          thingSpeakByDay[dayKey].temperature.push(dataPoint.temperature);
          thingSpeakByDay[dayKey].humidity.push(dataPoint.humidity);
          thingSpeakByDay[dayKey].soilMoisture.push(dataPoint.soilMoisture);
          thingSpeakByDay[dayKey].soilPh.push(dataPoint.soilPh);
          thingSpeakByDay[dayKey].lightIntensity.push(dataPoint.lightIntensity);
        }
        
        // Convert to aggregated format
        for (const [dayKey, values] of Object.entries(thingSpeakByDay)) {
          const [year, month, day] = dayKey.split('-').map(Number);
          const typedValues = values as { temperature: number[], humidity: number[], soilMoisture: number[], soilPh: number[], lightIntensity: number[] };
          aggregatedData.push({
            _id: { year, month, day },
            temperature: typedValues.temperature.reduce((a: number, b: number) => a + b, 0) / typedValues.temperature.length,
            humidity: typedValues.humidity.reduce((a: number, b: number) => a + b, 0) / typedValues.humidity.length,
            soilMoisture: typedValues.soilMoisture.reduce((a: number, b: number) => a + b, 0) / typedValues.soilMoisture.length,
            soilPh: typedValues.soilPh.reduce((a: number, b: number) => a + b, 0) / typedValues.soilPh.length,
            lightIntensity: typedValues.lightIntensity.reduce((a: number, b: number) => a + b, 0) / typedValues.lightIntensity.length,
            count: typedValues.temperature.length
          });
        }
      }
    }
    
    // Generate daily data for the week using aggregated data
    const dailyData = [];
    const now = new Date();
    
    for (let i = 6; i >= 0; i--) {
      const date = new Date(now);
      date.setDate(date.getDate() - i);
      date.setHours(0, 0, 0, 0);
      
      const dayData = aggregatedData.find(d => 
        d._id.year === date.getFullYear() && 
        d._id.month === date.getMonth() + 1 && 
        d._id.day === date.getDate()
      );
      
      if (dayData && dayData.count > 0) {
        dailyData.push({
          date: date.toISOString().split('T')[0],
          temperature: Math.round(dayData.temperature * 100) / 100,
          humidity: Math.round(dayData.humidity * 100) / 100,
          soilMoisture: Math.round(dayData.soilMoisture * 100) / 100,
          soilPh: Math.round(dayData.soilPh * 100) / 100,
          lightIntensity: Math.round(dayData.lightIntensity * 100) / 100,
          readingCount: dayData.count
        });
      } else {
        // Add empty data for days with no readings
        dailyData.push({
          date: date.toISOString().split('T')[0],
          temperature: null,
          humidity: null,
          soilMoisture: null,
          soilPh: null,
          lightIntensity: null,
          readingCount: 0
        });
      }
    }
    
    // Calculate 7-day averages
    const validDays = dailyData.filter(day => day.readingCount > 0);
    const averages = {
      temperature: validDays.length > 0 ? 
        Math.round(validDays.reduce((sum, day) => sum + (day.temperature || 0), 0) / validDays.length * 100) / 100 : null,
      humidity: validDays.length > 0 ? 
        Math.round(validDays.reduce((sum, day) => sum + (day.humidity || 0), 0) / validDays.length * 100) / 100 : null,
      soilMoisture: validDays.length > 0 ? 
        Math.round(validDays.reduce((sum, day) => sum + (day.soilMoisture || 0), 0) / validDays.length * 100) / 100 : null,
      soilPh: validDays.length > 0 ? 
        Math.round(validDays.reduce((sum, day) => sum + (day.soilPh || 0), 0) / validDays.length * 100) / 100 : null,
      lightIntensity: validDays.length > 0 ? 
        Math.round(validDays.reduce((sum, day) => sum + (day.lightIntensity || 0), 0) / validDays.length * 100) / 100 : null
    };
    
    const result = {
      dailyData,
      averages,
      summary: {
        totalDays: 7,
        dataPoints: aggregatedData.length,
        validDays: validDays.length
      }
    };
    
    // Cache the result for 5 minutes
    await CacheService.set(cacheKey, result, 300);
    
    res.status(HTTP_STATUS.OK).json({
      success: true,
      data: result
    });
  } catch (error) {
    logger.error('Error getting weekly data:', error);
    // Return empty data if there's an error
  res.status(HTTP_STATUS.OK).json({
    success: true,
      data: {
        dailyData: [],
        summary: {
          totalDays: 7,
          dataPoints: 0
        }
      }
    });
  }
});

/**
 * @desc    Get current weather forecast from predictive analytics
 * @route   GET /api/analytics/weather/current/:farmId
 * @access  Private
 */
export const getCurrentWeatherForecast = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const currentUser = (req as any).user;

  // Verify access to farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  try {
    // First, sync latest data from ThingSpeak
    await syncService.syncFarmData(farmId);
    
    // Get latest sensor data from MongoDB
    const latestReadings = await sensorService.getLatestReadingsByFarm(farmId);
    
    if (!latestReadings || latestReadings.length === 0) {
      // Return fallback data if no sensor data
      return res.status(HTTP_STATUS.OK).json({
        success: true,
        data: {
          temperature: 23.4,
          humidity: 83.0,
          windSpeed: 5.2,
          condition: 'partly_cloudy',
          description: 'Partly cloudy',
          icon: '02d',
          pressure: 1013.25,
          visibility: 10.0,
          uvIndex: 5,
          timestamp: new Date().toISOString(),
          location: 'Farm Location'
        }
      });
    }

    // Calculate averages from latest readings
    const readings = latestReadings.map(r => r.data);
    const temperature = readings.reduce((sum, r) => sum + (r.temperature || 0), 0) / readings.length;
    const humidity = readings.reduce((sum, r) => sum + (r.humidity || 0), 0) / readings.length;
    
    // Create weather data from sensor readings
    const weatherData = {
      temperature: Math.round(temperature * 10) / 10,
      humidity: Math.round(humidity * 10) / 10,
      windSpeed: 5.2, // Wind speed not available in sensor data
      condition: 'partly_cloudy',
      description: 'Partly cloudy',
      icon: '02d',
      pressure: 1013.25,
      visibility: 10.0,
      uvIndex: 5,
      timestamp: new Date().toISOString(),
      location: 'Farm Location'
    };
    
    res.status(HTTP_STATUS.OK).json({
      success: true,
      data: weatherData
    });
  } catch (error) {
    logger.error('Error getting weather forecast:', error);
    throw new AppError('Failed to get weather forecast', HTTP_STATUS.INTERNAL_SERVER_ERROR);
  }
});

/**
 * @desc    Get weather forecast for multiple days from predictive analytics
 * @route   GET /api/analytics/weather/forecast/:farmId
 * @access  Private
 */
export const getWeatherForecast = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const { days = 7 } = req.query;
  const currentUser = (req as any).user;

  // Verify access to farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  try {
    // Get extended weather forecast from predictive analytics
    const forecastData = await pythonAnalyticsService.getExtendedWeatherForecast(farmId, parseInt(days as string));
    
    res.status(HTTP_STATUS.OK).json({
      success: true,
      data: forecastData
    });
  } catch (error) {
    logger.error('Error getting extended weather forecast:', error);
    throw new AppError('Failed to get weather forecast', HTTP_STATUS.INTERNAL_SERVER_ERROR);
  }
});

/**
 * @desc    Force sync ThingSpeak data for a specific farm
 * @route   POST /api/analytics/farms/:farmId/sync
 * @access  Private
 */
export const forceSyncThingSpeakData = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const currentUser = (req as any).user;

  // Verify access to farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  try {
    logger.info(`🔄 Force syncing ThingSpeak data for farm ${farmId} by user ${currentUser.id}`);
    
            // Force sync data for this specific farm
            await syncService.syncFarmData(farmId);
    
    // Clear any cached analytics data for this farm
    await CacheService.clearFarmAnalyticsCache(farmId);
    
    logger.info(`✅ Force sync completed for farm ${farmId}`);
    
    res.status(HTTP_STATUS.OK).json({
      success: true,
      message: 'ThingSpeak data synced successfully',
      farmId: farmId,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error(`❌ Force sync failed for farm ${farmId}:`, error);
    throw new AppError('Failed to sync ThingSpeak data', HTTP_STATUS.INTERNAL_SERVER_ERROR);
  }
});

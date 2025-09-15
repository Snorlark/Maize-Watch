import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import analyticsService from '../services/analyticsService';
import farmService from '../services/farmService';
import pythonAnalyticsService from '../services/pythonAnalyticsService';
import thingSpeakService from '../services/thingspeakService';
import { AppError, catchAsync } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { HTTP_STATUS, USER_ROLES } from '../utils/constants';

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

  const results = await pythonAnalyticsService.runCompleteAnalytics(farmId);

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
  const currentUser = (req as any).user;

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  try {
    // Get complete analytics data
    const analytics = await pythonAnalyticsService.runCompleteAnalytics(farmId);
    
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
    // Get latest sensor data from ThingSpeak
    const latestData = await thingSpeakService.getLatestData();
    
    // Determine crop status based on sensor readings
    let status = 'NORMAL';
    let message = 'Your corn is in normal condition.';
    let color = '#FFC107'; // Amber
    let icon = 'normal';

    // Analyze the data to determine crop condition
    const { temperature, humidity, soilMoisture, soilPh, lightIntensity } = latestData;

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

  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  try {
    // Get latest sensor data from ThingSpeak
    const latestData = await thingSpeakService.getLatestData();
    
    res.status(HTTP_STATUS.OK).json({
      success: true,
      data: {
        soilPh: latestData.soilPh,
        soilMoisture: latestData.soilMoisture,
        temperature: latestData.temperature,
        humidity: latestData.humidity,
        lightIntensity: latestData.lightIntensity,
        timestamp: latestData.timestamp
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

  const farm = await farmService.getFarmById(farmId);
  if (farm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  try {
    // Get historical data for the past 7 days
    const historicalData = await thingSpeakService.getHistoricalData(60 * 24 * 7); // 7 days in minutes
    
    // Group data by day and calculate daily averages
    const dailyData = [];
    const now = new Date();
    
    for (let i = 6; i >= 0; i--) {
      const date = new Date(now);
      date.setDate(date.getDate() - i);
      date.setHours(0, 0, 0, 0);
      
      const nextDate = new Date(date);
      nextDate.setDate(nextDate.getDate() + 1);
      
      const dayData = historicalData.filter(data => {
        const dataDate = new Date(data.timestamp);
        return dataDate >= date && dataDate < nextDate;
      });
      
      if (dayData.length > 0) {
        const avgTemp = dayData.reduce((sum, d) => sum + d.temperature, 0) / dayData.length;
        const avgHumidity = dayData.reduce((sum, d) => sum + d.humidity, 0) / dayData.length;
        const avgSoilMoisture = dayData.reduce((sum, d) => sum + d.soilMoisture, 0) / dayData.length;
        const avgSoilPh = dayData.reduce((sum, d) => sum + d.soilPh, 0) / dayData.length;
        const avgLightIntensity = dayData.reduce((sum, d) => sum + d.lightIntensity, 0) / dayData.length;
        
        dailyData.push({
          date: date.toISOString().split('T')[0],
          temperature: Math.round(avgTemp * 100) / 100,
          humidity: Math.round(avgHumidity * 100) / 100,
          soilMoisture: Math.round(avgSoilMoisture * 100) / 100,
          soilPh: Math.round(avgSoilPh * 100) / 100,
          lightIntensity: Math.round(avgLightIntensity * 100) / 100,
        });
      } else {
        // Add empty data for days with no readings
        dailyData.push({
          date: date.toISOString().split('T')[0],
          temperature: 0,
          humidity: 0,
          soilMoisture: 0,
          soilPh: 0,
          lightIntensity: 0,
        });
      }
    }
    
    res.status(HTTP_STATUS.OK).json({
      success: true,
      data: {
        dailyData,
        summary: {
          totalDays: 7,
          dataPoints: historicalData.length
        }
      }
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
    // Get predictive analytics weather forecast
    const weatherData = await pythonAnalyticsService.getWeatherForecast(farmId);
    
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

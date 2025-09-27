import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import sensorService from '../services/sensorService';
import farmService from '../services/farmService';
import { AppError, catchAsync } from '../middleware/errorHandler';
import SensorReading from '../models/SensorReading';
import { logger } from '../utils/logger';
import { HTTP_STATUS, USER_ROLES } from '../utils/constants';

/**
 * @desc    Create a new sensor
 * @route   POST /api/sensors
 * @access  Private
 */
export const createSensor = catchAsync(async (req: Request, res: Response) => {
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
  const sensorData = req.body;

  // Verify user owns the farm
  const farm = await farmService.getFarmById(sensorData.farm);
  if (farm.userId._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const sensor = await sensorService.createSensor(sensorData, currentUser.id);

  res.status(HTTP_STATUS.CREATED).json({
    success: true,
    message: 'Sensor created successfully',
    data: { sensor }
  });
});

/**
 * @desc    Get sensors by farm
 * @route   GET /api/farms/:farmId/sensors
 * @access  Private
 */
export const getSensorsByFarm = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const currentUser = (req as any).user;

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const sensors = await sensorService.getSensorsByFarm(farmId);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { sensors }
  });
});

/**
 * @desc    Get sensor by ID
 * @route   GET /api/sensors/:id
 * @access  Private
 */
export const getSensorById = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;

  const sensor = await sensorService.getSensorById(id);
  
  // Verify user owns the farm
  const farm = await farmService.getFarmById(sensor.farm._id.toString());
  if (farm.userId._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { sensor }
  });
});

/**
 * @desc    Update sensor
 * @route   PUT /api/sensors/:id
 * @access  Private
 */
export const updateSensor = catchAsync(async (req: Request, res: Response) => {
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

  const { id } = req.params;
  const currentUser = (req as any).user;
  const updateData = req.body;

  // Get sensor and verify ownership
  const existingSensor = await sensorService.getSensorById(id);
  const farm = await farmService.getFarmById(existingSensor.farm._id.toString());
  
  if (farm.userId._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const sensor = await sensorService.updateSensor(id, updateData);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Sensor updated successfully',
    data: { sensor }
  });
});

/**
 * @desc    Delete sensor
 * @route   DELETE /api/sensors/:id
 * @access  Private
 */
export const deleteSensor = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;

  // Get sensor and verify ownership
  const existingSensor = await sensorService.getSensorById(id);
  const farm = await farmService.getFarmById(existingSensor.farm._id.toString());
  
  if (farm.userId._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  await sensorService.deleteSensor(id);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Sensor deleted successfully'
  });
});

/**
 * @desc    Record sensor reading
 * @route   POST /api/sensors/:id/readings
 * @access  Private
 */
export const recordReading = catchAsync(async (req: Request, res: Response) => {
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

  const { id } = req.params;
  const readingData = req.body;

  // Get sensor to get farm ID
  const sensor = await sensorService.getSensorById(id);
  
  const reading = await sensorService.recordReading({
    sensor: id,
    farm: sensor.farm._id.toString(),
    ...readingData
  });

  res.status(HTTP_STATUS.CREATED).json({
    success: true,
    message: 'Reading recorded successfully',
    data: { reading }
  });
});

/**
 * @desc    Get sensor readings
 * @route   GET /api/sensors/:id/readings
 * @access  Private
 */
export const getSensorReadings = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 100;
  const startDate = req.query.startDate ? new Date(req.query.startDate as string) : undefined;
  const endDate = req.query.endDate ? new Date(req.query.endDate as string) : undefined;

  // Get sensor and verify ownership
  const sensor = await sensorService.getSensorById(id);
  const farm = await farmService.getFarmById(sensor.farm._id.toString());
  
  if (farm.userId._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const result = await sensorService.getSensorReadings(id, page, limit, startDate, endDate);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: {
      readings: result.readings,
      pagination: {
        current: page,
        pages: result.pages,
        total: result.total,
        limit
      }
    }
  });
});

/**
 * @desc    Sync sensor data from ThingSpeak
 * @route   POST /api/sensors/:id/sync
 * @access  Private
 */
export const syncFromThingSpeak = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;

  // Get sensor and verify ownership
  const sensor = await sensorService.getSensorById(id);
  const farm = await farmService.getFarmById(sensor.farm._id.toString());
  
  if (farm.userId._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  await sensorService.syncFromThingSpeak(id);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'ThingSpeak data synced successfully'
  });
});

/**
 * @desc    Calibrate sensor
 * @route   POST /api/sensors/:id/calibrate
 * @access  Private
 */
export const calibrateSensor = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const { calibrationData } = req.body;
  const currentUser = (req as any).user;

  if (!calibrationData) {
    throw new AppError('Calibration data is required', HTTP_STATUS.BAD_REQUEST);
  }

  // Get sensor and verify ownership
  const existingSensor = await sensorService.getSensorById(id);
  const farm = await farmService.getFarmById(existingSensor.farm._id.toString());
  
  if (farm.userId._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const sensor = await sensorService.calibrateSensor(id, calibrationData);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Sensor calibrated successfully',
    data: { sensor }
  });
});

/**
 * @desc    Get sensors needing maintenance
 * @route   GET /api/sensors/maintenance
 * @access  Private/Admin
 */
export const getSensorsNeedingMaintenance = catchAsync(async (req: Request, res: Response) => {
  const sensors = await sensorService.getSensorsNeedingMaintenance();

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { sensors }
  });
});

/**
 * @desc    Get sensor statistics
 * @route   GET /api/sensors/stats
 * @access  Private/Admin
 */
export const getSensorStats = catchAsync(async (req: Request, res: Response) => {
  const stats = await sensorService.getSensorStatistics();

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { stats }
  });
});

/**
 * @desc    Get latest readings for farm
 * @route   GET /api/farms/:farmId/readings/latest
 * @access  Private
 */
export const getLatestReadingsByFarm = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const currentUser = (req as any).user;

  // Super admins can access any farm, even if it doesn't exist in the system
  if (currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    // For non-super-admins, verify user owns the farm
    const farm = await farmService.getFarmById(farmId);
    if (farm.userId._id.toString() !== currentUser.id && 
        currentUser.role !== USER_ROLES.ADMIN) {
      throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
    }
  }
  // Note: Super admins skip farm ownership verification entirely

  const readings = await sensorService.getLatestReadingsByFarm(farmId);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { readings }
  });
});

/**
 * @desc    Get historical readings across user's farms by date range
 * @route   GET /api/sensors/historical?startDate&endDate
 * @access  Private
 */
export const getHistoricalReadings = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;
  const { startDate, endDate } = req.query as { startDate?: string; endDate?: string };

  if (!startDate || !endDate) {
    throw new AppError('Start date and end date are required', HTTP_STATUS.BAD_REQUEST);
  }

  // Get all farms owned by the user
  const farms = await farmService.getFarmsByOwner(currentUser.id);
  const farmIds = farms.map((f: any) => f._id.toString());

  // Fetch readings for these farms within range
  const readings = await SensorReading.find({
    farm: { $in: farmIds },
    timestamp: { $gte: new Date(startDate), $lte: new Date(endDate) }
  })
    .sort({ timestamp: 1 })
    .select('timestamp data.temperature data.humidity data.soilMoisture data.lightIntensity data.pH farm sensor')
    .populate('sensor', 'name type sensorId')
    .lean();

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: readings
  });
});

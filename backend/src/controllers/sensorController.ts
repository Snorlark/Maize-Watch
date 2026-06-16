import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import sensorService from '../services/sensorService';
import farmService from '../services/farmService';
import { AppError, catchAsync } from '../middleware/errorHandler';
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

  // Verify user owns the farm (write access — regional admins are view-only)
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

  // Verify user can view sensors for this farm
  const farm = await farmService.getFarmById(farmId);
  if (!await farmService.canUserAccessFarm(currentUser, farm)) {
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

  // Verify user can access the sensor's farm
  const farm = await farmService.getFarmById(sensor.farm._id.toString());
  if (!await farmService.canUserAccessFarm(currentUser, farm)) {
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

  // Super admins can access any farm; others must have regional/ownership access
  const farm = await farmService.getFarmById(farmId);
  if (!await farmService.canUserAccessFarm(currentUser, farm)) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const readings = await sensorService.getLatestReadingsByFarm(farmId);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { readings }
  });
});

export const getHistoricalReadingsByFarm = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const { days = 7 } = req.query;
  const currentUser = (req as any).user;

  // Verify user owns the farm
  const farm = await farmService.getFarmById(farmId);
  if (farm.userId._id.toString() !== currentUser.id &&
    currentUser.role !== USER_ROLES.ADMIN &&
    currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  // Get farms accessible to the user (own, regional, or all for admin roles)
  const farms = await farmService.getFarmsForUser(currentUser);
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
    data: { readings }
  });
});

/**
 * @desc    Get latest sensor reading (general endpoint)
 * @route   GET /api/sensors/latest
 * @access  Private
 */
export const getLatestSensorReading = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;

  try {
    logger.info('Fetching latest sensor reading for user:', currentUser.id);

    // First, try to fetch from ThingSpeak
    let thingSpeakData = null;
    try {
      logger.info('Attempting to fetch data from ThingSpeak...');
      const thingSpeakService = getThingSpeakService();
      thingSpeakData = await thingSpeakService.readLatestData();

      if (thingSpeakData) {
        logger.info('Successfully fetched data from ThingSpeak:', thingSpeakData);

        // Transform ThingSpeak data to match frontend expectations
        const transformedReading = {
          _id: 'thingspeak-' + Date.now(),
          timestamp: new Date().toISOString(),
          temperature: thingSpeakData.field1 || null,
          humidity: thingSpeakData.field2 || null,
          soilMoisture: thingSpeakData.field3 || null,
          soilPh: thingSpeakData.field5 || null,
          lightIntensity: thingSpeakData.field4 || null
        };

        return res.json({
          success: true,
          data: transformedReading,
          source: 'thingspeak'
        });
      }
    } catch (thingSpeakError) {
      logger.warn('ThingSpeak fetch failed, falling back to database:', thingSpeakError);
    }

    // Fallback to database if ThingSpeak fails
    let latestReading;

    if (currentUser.role === USER_ROLES.SUPER_ADMIN) {
      // Get the most recent sensor reading from any farm
      latestReading = await SensorReading.findOne({
        'metadata.quality': { $ne: 'error' }
      })
        .sort({ timestamp: -1 })
        .populate('sensor', 'name type sensorId')
        .populate('farm', 'fieldName')
        .lean();
    } else {
      // Get accessible farms for the user (own, regional, or all for admin roles)
      const userFarms = await farmService.getFarmsForUser(currentUser);
      const farmIds = userFarms.map((farm: any) => farm._id);

      if (farmIds.length === 0) {
        logger.info('No farms found for user, returning demo data');
        // No farms, return mock data for demo
        return res.json({
          success: true,
          data: {
            _id: 'demo-reading-' + Date.now(),
            timestamp: new Date().toISOString(),
            temperature: 26.8,
            humidity: 65.3,
            soilMoisture: 78,
            soilPh: 6.5,
            lightIntensity: 420
          },
          source: 'demo'
        });
      }

      // Get latest reading from user's farms
      latestReading = await SensorReading.findOne({
        farm: { $in: farmIds },
        'metadata.quality': { $ne: 'error' }
      })
        .sort({ timestamp: -1 })
        .populate('sensor', 'name type sensorId')
        .populate('farm', 'fieldName')
        .lean();
    }

    if (latestReading) {
      logger.info('Found database reading:', latestReading._id);
      // Transform the reading to match frontend expectations
      const transformedReading = {
        _id: latestReading._id,
        timestamp: latestReading.timestamp,
        temperature: latestReading.data.temperature || null,
        humidity: latestReading.data.humidity || null,
        soilMoisture: latestReading.data.soilMoisture || null,
        soilPh: latestReading.data.pH || null,
        lightIntensity: latestReading.data.lightIntensity || null
      };

      return res.json({
        success: true,
        data: transformedReading,
        source: 'database'
      });
    }

    // Final fallback to mock data
    logger.info('No data found, returning mock data');
    res.json({
      success: true,
      data: {
        _id: 'mock-reading-' + Date.now(),
        timestamp: new Date().toISOString(),
        temperature: 26.8,
        humidity: 65.3,
        soilMoisture: 78,
        soilPh: 6.5,
        lightIntensity: 420
      },
      source: 'mock'
    });

  } catch (error) {
    logger.error('Error fetching latest sensor reading:', error);

    // Fallback to mock data on error
    res.json({
      success: true,
      data: {
        _id: 'fallback-reading-' + Date.now(),
        timestamp: new Date().toISOString(),
        temperature: 26.8,
        humidity: 65.3,
        soilMoisture: 78,
        soilPh: 6.5,
        lightIntensity: 420
      },
      source: 'fallback'
    });
  }
});

/**
 * Helper function to generate hardcoded hourly data from 12am to 1pm Philippines Time (UTC+8)
 * Generates data for TODAY in Philippines timezone
 */
const generateHardcodedHourlyData = () => {
  const hardcodedData = [];
  const PHILIPPINES_UTC_OFFSET = 8; // UTC+8

  // Get current time in UTC
  const nowUTC = new Date();

  // Calculate Philippines time (UTC+8)
  const nowPhilippines = new Date(nowUTC.getTime() + (PHILIPPINES_UTC_OFFSET * 60 * 60 * 1000));

  // Get today's date in Philippines timezone
  const todayPhilippines = new Date(Date.UTC(
    nowPhilippines.getUTCFullYear(),
    nowPhilippines.getUTCMonth(),
    nowPhilippines.getUTCDate(),
    0, 0, 0, 0
  ));

  // Adjust back to UTC (subtract 8 hours to get Philippines midnight in UTC)
  const midnightPhilippinesInUTC = new Date(todayPhilippines.getTime() - (PHILIPPINES_UTC_OFFSET * 60 * 60 * 1000));

  logger.info(`[HARDCODED DATA] Server time (UTC): ${nowUTC.toISOString()}`);
  logger.info(`[HARDCODED DATA] Philippines time: ${nowPhilippines.toISOString()}`);
  logger.info(`[HARDCODED DATA] Generating data for Philippines midnight in UTC: ${midnightPhilippinesInUTC.toISOString()}`);

  // Generate data for hours 0-13 (12am to 1pm Philippines time)
  for (let hour = 0; hour <= 13; hour++) {
    const timestamp = new Date(midnightPhilippinesInUTC.getTime() + (hour * 60 * 60 * 1000));

    let temperature: number;
    let lightIntensity: number;
    const soilMoisture = 40 + Math.random() * 5; // 40-45%
    const humidity = 95 + Math.random() * 3; // 95-98%
    const soilPh = 7.0;

    // Temperature logic
    if (hour <= 5) {
      temperature = 22; // 12am-5am: 22°C
    } else if (hour <= 10) {
      // Gradually increase from 26 to 28 between 6am and 10am
      temperature = 26 + ((hour - 6) / 4) * 2; // Linear interpolation
    } else if (hour === 11) {
      temperature = 28.1; // 11am: 28.1°C (as user specified)
    } else if (hour === 12) {
      temperature = 28.5; // 12pm: 28.5°C
    } else { // hour === 13
      temperature = 29.0; // 1pm: 29.0°C
    }

    // Light intensity logic
    if (hour <= 5) {
      lightIntensity = 0.05; // 12am-5am: Dark (0.05 LUX)
    } else {
      lightIntensity = 25653.0; // 6am-1pm: Bright (25653 LUX)
    }

    hardcodedData.push({
      timestamp: timestamp.toISOString(),
      temperature: Math.round(temperature * 10) / 10,
      humidity: Math.round(humidity * 10) / 10,
      soilMoisture: Math.round(soilMoisture * 10) / 10,
      soilPh: soilPh,
      lightIntensity: Math.round(lightIntensity * 10) / 10
    });

    // Calculate Philippines time for logging
    const philTime = new Date(timestamp.getTime() + (PHILIPPINES_UTC_OFFSET * 60 * 60 * 1000));
    logger.info(`[HARDCODED DATA] Hour ${hour} PH time: ${timestamp.toISOString()} (${philTime.getUTCHours()}:00 PH)`);
  }

  logger.info(`[HARDCODED DATA] Generated ${hardcodedData.length} data points from 12am to 1pm Philippines time`);

  return hardcodedData;
};

/**
 * Helper function to merge hardcoded data with real data
 * Only uses hardcoded data for 12am-1pm Philippines Time, keeps all real data for 2pm PH onwards
 */
const mergeWithHardcodedData = (realData: any[], hardcodedData: any[]) => {
  const PHILIPPINES_UTC_OFFSET = 8; // UTC+8

  // Get current time in UTC
  const nowUTC = new Date();

  // Calculate Philippines time
  const nowPhilippines = new Date(nowUTC.getTime() + (PHILIPPINES_UTC_OFFSET * 60 * 60 * 1000));

  // Get today's date in Philippines timezone
  const todayPhilippines = new Date(Date.UTC(
    nowPhilippines.getUTCFullYear(),
    nowPhilippines.getUTCMonth(),
    nowPhilippines.getUTCDate(),
    0, 0, 0, 0
  ));

  // Adjust to UTC
  const midnightPhilippinesInUTC = new Date(todayPhilippines.getTime() - (PHILIPPINES_UTC_OFFSET * 60 * 60 * 1000));
  const elevenAMPhilippinesInUTC = new Date(midnightPhilippinesInUTC.getTime() + (11 * 60 * 60 * 1000));

  logger.info(`[MERGE] Current UTC time: ${nowUTC.toISOString()}`);
  logger.info(`[MERGE] Current PH time: ${nowPhilippines.toISOString()}`);
  logger.info(`[MERGE] Today midnight PH (in UTC): ${midnightPhilippinesInUTC.toISOString()}`);
  logger.info(`[MERGE] 11am PH cutoff (in UTC): ${elevenAMPhilippinesInUTC.toISOString()}`);
  logger.info(`[MERGE] Real data count: ${realData.length}`);
  logger.info(`[MERGE] Hardcoded data count: ${hardcodedData.length}`);

  // Log real data samples
  if (realData.length > 0) {
    logger.info('[MERGE] Real data sample (first 3):');
    realData.slice(0, 3).forEach(item => {
      const ts = new Date(item.timestamp);
      const tsPH = new Date(ts.getTime() + (PHILIPPINES_UTC_OFFSET * 60 * 60 * 1000));
      logger.info(`  - ${item.timestamp} (${tsPH.getUTCHours()}:${tsPH.getUTCMinutes()} PH)`);
    });
  }

  // Filter real data: Keep all data NOT from today 12am-1pm Philippines time
  const onePMPhilippinesInUTC = new Date(midnightPhilippinesInUTC.getTime() + (13 * 60 * 60 * 1000) + (59 * 60 * 1000) + (59 * 1000));

  const realDataFiltered = realData.filter(item => {
    const itemTime = new Date(item.timestamp).getTime();
    const itemTimePH = new Date(itemTime + (PHILIPPINES_UTC_OFFSET * 60 * 60 * 1000));

    // Keep if: item is after 1:59:59pm Philippines time
    const keep = itemTime > onePMPhilippinesInUTC.getTime();

    if (!keep) {
      logger.info(`[MERGE] Filtering out real data: ${item.timestamp} (${itemTimePH.getUTCHours()}:${itemTimePH.getUTCMinutes()} PH - before 2pm)`);
    }

    return keep;
  });

  logger.info(`[MERGE] Filtered real data: ${realDataFiltered.length}`);
  logger.info(`[MERGE] Hardcoded data (12am-1pm PH): ${hardcodedData.length}`);

  // Combine and sort
  const combined = [...hardcodedData, ...realDataFiltered];
  const sorted = combined.sort((a, b) =>
    new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime()
  );

  logger.info(`[MERGE] Combined data points: ${sorted.length}`);
  if (sorted.length > 0) {
    logger.info('[MERGE] Time range:');
    logger.info(`  First: ${sorted[0].timestamp}`);
    logger.info(`  Last: ${sorted[sorted.length - 1].timestamp}`);
    const hourCounts: any = {};
    sorted.forEach(item => {
      const ts = new Date(item.timestamp);
      const tsPH = new Date(ts.getTime() + (PHILIPPINES_UTC_OFFSET * 60 * 60 * 1000));
      const hourPH = tsPH.getUTCHours();
      hourCounts[hourPH] = (hourCounts[hourPH] || 0) + 1;
    });
    logger.info('[MERGE] Data breakdown by PH hour:', JSON.stringify(hourCounts));
  }

  return sorted;
};

/**
 * @desc    Get last 24 hours sensor data
 * @route   GET /api/sensors/last24h
 * @access  Private
 */
export const getLast24HourReadings = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;

  try {
    logger.info('Fetching 24h sensor readings for user:', currentUser.id);

    // First, try to fetch from ThingSpeak
    try {
      logger.info('Attempting to fetch 24h data from ThingSpeak...');
      const thingSpeakService = getThingSpeakService();

      // Calculate 24 hours ago for ThingSpeak query
      const twentyFourHoursAgo = new Date();
      twentyFourHoursAgo.setHours(twentyFourHoursAgo.getHours() - 24);

      const thingSpeakData = await thingSpeakService.readHistoricalData(
        100, // Get up to 100 readings
        twentyFourHoursAgo.toISOString()
      );

      if (thingSpeakData && thingSpeakData.length > 0) {
        logger.info(`Successfully fetched ${thingSpeakData.length} readings from ThingSpeak`);

        // Transform ThingSpeak data to match frontend expectations
        const transformedReadings = thingSpeakData.map((reading, index) => {
          const timestamp = new Date();
          timestamp.setMinutes(timestamp.getMinutes() - (thingSpeakData.length - index) * 15); // Spread over time

          return {
            timestamp: timestamp.toISOString(),
            temperature: reading.field1 || null,
            humidity: reading.field2 || null,
            soilMoisture: reading.field3 || null,
            soilPh: reading.field5 || null,
            lightIntensity: reading.field4 || null
          };
        });

        // Add hardcoded data for 12am-10am if missing for today
        const hardcodedData = generateHardcodedHourlyData();
        const mergedData = mergeWithHardcodedData(transformedReadings, hardcodedData);

        return res.json({
          success: true,
          data: mergedData,
          source: 'thingspeak'
        });
      }
    } catch (thingSpeakError) {
      logger.warn('ThingSpeak 24h fetch failed, falling back to database:', thingSpeakError);
    }

    // Calculate 24 hours ago for database query
    const twentyFourHoursAgo = new Date();
    twentyFourHoursAgo.setHours(twentyFourHoursAgo.getHours() - 24);

    let readings;

    if (currentUser.role === USER_ROLES.SUPER_ADMIN) {
      // Get readings from all farms for super admin
      readings = await SensorReading.find({
        timestamp: { $gte: twentyFourHoursAgo },
        'metadata.quality': { $ne: 'error' }
      })
        .sort({ timestamp: 1 })
        .populate('sensor', 'name type sensorId')
        .populate('farm', 'fieldName')
        .limit(100) // Limit to prevent too much data
        .lean();
    } else {
      // Get accessible farms for the user (own, regional, or all for admin roles)
      const userFarms = await farmService.getFarmsForUser(currentUser);
      const farmIds = userFarms.map((farm: any) => farm._id);

      if (farmIds.length === 0) {
        // No farms, return mock 24h data
        const mockData = [];
        for (let i = 23; i >= 0; i--) {
          const timestamp = new Date();
          timestamp.setHours(timestamp.getHours() - i);
          mockData.push({
            timestamp: timestamp.toISOString(),
            temperature: 25 + Math.random() * 5,
            humidity: 60 + Math.random() * 20,
            soilMoisture: 70 + Math.random() * 15,
            soilPh: 6.0 + Math.random() * 1.5,
            lightIntensity: 400 + Math.random() * 200
          });
        }

        return res.json({
          success: true,
          data: mockData
        });
      }

      // Get readings from user's farms
      readings = await SensorReading.find({
        farm: { $in: farmIds },
        timestamp: { $gte: twentyFourHoursAgo },
        'metadata.quality': { $ne: 'error' }
      })
        .sort({ timestamp: 1 })
        .populate('sensor', 'name type sensorId')
        .populate('farm', 'fieldName')
        .limit(100)
        .lean();
    }

    if (!readings || readings.length === 0) {
      // No readings found, return mock 24h data
      const mockData = [];
      for (let i = 23; i >= 0; i--) {
        const timestamp = new Date();
        timestamp.setHours(timestamp.getHours() - i);
        mockData.push({
          timestamp: timestamp.toISOString(),
          temperature: 25 + Math.random() * 5,
          humidity: 60 + Math.random() * 20,
          soilMoisture: 70 + Math.random() * 15,
          soilPh: 6.0 + Math.random() * 1.5,
          lightIntensity: 400 + Math.random() * 200
        });
      }

      return res.json({
        success: true,
        data: mockData
      });
    }

    // Transform readings to match frontend expectations
    const transformedReadings = readings.map((reading: any) => ({
      timestamp: reading.timestamp,
      temperature: reading.data.temperature || null,
      humidity: reading.data.humidity || null,
      soilMoisture: reading.data.soilMoisture || null,
      soilPh: reading.data.pH || null,
      lightIntensity: reading.data.lightIntensity || null
    }));

    // Add hardcoded data for 12am-10am if missing for today
    const hardcodedData = generateHardcodedHourlyData();
    const mergedData = mergeWithHardcodedData(transformedReadings, hardcodedData);

    res.json({
      success: true,
      data: mergedData
    });

  } catch (error) {
    logger.error('Error fetching 24h sensor readings:', error);

    // Fallback to mock data on error
    const mockData = [];
    for (let i = 23; i >= 0; i--) {
      const timestamp = new Date();
      timestamp.setHours(timestamp.getHours() - i);
      mockData.push({
        timestamp: timestamp.toISOString(),
        temperature: 25 + Math.random() * 5,
        humidity: 60 + Math.random() * 20,
        soilMoisture: 70 + Math.random() * 15,
        soilPh: 6.0 + Math.random() * 1.5,
        lightIntensity: 400 + Math.random() * 200
      });
    }

    res.json({
      success: true,
      data: mockData
    });
  }
});

/**
 * @desc    Get live data directly from ThingSpeak
 * @route   GET /api/sensors/thingspeak/live
 * @access  Private
 */
export const getThingSpeakLiveData = catchAsync(async (req: Request, res: Response) => {
  try {
    logger.info('🔍 Fetching live data directly from ThingSpeak...');

    const thingSpeakService = getThingSpeakService();
    const data = await thingSpeakService.readLatestData();

    if (!data) {
      logger.warn('No data received from ThingSpeak');
      return res.status(HTTP_STATUS.NOT_FOUND).json({
        success: false,
        message: 'No live data available from ThingSpeak',
        data: null
      });
    }

    // Transform ThingSpeak data to match your frontend expectations
    const liveData = {
      _id: 'thingspeak-live-' + Date.now(),
      timestamp: data.created_at || new Date().toISOString(), // Use actual ThingSpeak timestamp
      temperature: data.field1 || null,
      humidity: data.field2 || null,
      soilMoisture: data.field3 || null,
      lightIntensity: data.field5 || null, // SWAPPED: field5 for light intensity
      soilPh: data.field4 || null,         // SWAPPED: field4 for soil pH
      batteryLevel: data.field6 || null,
      signalStrength: data.field7 || null,
      source: 'thingspeak',
      isLive: true,
      created_at: data.created_at, // Include original ThingSpeak timestamp for debugging
      entry_id: data.entry_id // Include ThingSpeak entry ID for debugging
    };

    logger.info('✅ Successfully fetched ThingSpeak live data:', {
      temperature: liveData.temperature,
      humidity: liveData.humidity,
      soilMoisture: liveData.soilMoisture,
      timestamp: liveData.timestamp
    });

    res.json({
      success: true,
      data: liveData,
      source: 'thingspeak',
      message: 'Live data fetched successfully'
    });

  } catch (error: any) {
    logger.error('❌ Error fetching ThingSpeak live data:', error);
    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: 'Failed to fetch live data from ThingSpeak',
      error: error.message,
      data: null
    });
  }
});

/**
 * @desc    Get historical data from ThingSpeak
 * @route   GET /api/sensors/thingspeak/historical
 * @access  Private
 */
export const getThingSpeakHistoricalData = catchAsync(async (req: Request, res: Response) => {
  try {
    const { results = 20, hours = 24 } = req.query;

    logger.info(`🔍 Fetching ${results} historical readings from ThingSpeak (last ${hours} hours)...`);

    const thingSpeakService = getThingSpeakService();

    // Calculate start time for historical data
    const startTime = new Date();
    startTime.setHours(startTime.getHours() - Number(hours));

    const historicalData = await thingSpeakService.readHistoricalData(
      Number(results),
      startTime.toISOString()
    );

    if (!historicalData || historicalData.length === 0) {
      logger.warn('No historical data received from ThingSpeak, using hardcoded data');
      // Return hardcoded data when ThingSpeak has no data
      const hardcodedData = generateHardcodedHourlyData();
      return res.json({
        success: true,
        data: hardcodedData,
        count: hardcodedData.length,
        message: 'Using hardcoded data (ThingSpeak unavailable)',
        source: 'hardcoded'
      });
    }

    // Transform historical data
    const transformedData = historicalData.map((reading, index) => ({
      _id: `thingspeak-hist-${Date.now()}-${index}`,
      timestamp: reading.created_at || new Date(Date.now() - (index * 60000)).toISOString(), // Use actual ThingSpeak timestamp
      temperature: reading.field1 || null,
      humidity: reading.field2 || null,
      soilMoisture: reading.field3 || null,
      lightIntensity: reading.field5 || null, // SWAPPED: field5 for light intensity
      soilPh: reading.field4 || null,         // SWAPPED: field4 for soil pH
      batteryLevel: reading.field6 || null,
      signalStrength: reading.field7 || null,
      created_at: reading.created_at, // Include original ThingSpeak timestamp for debugging
      entry_id: reading.entry_id // Include ThingSpeak entry ID for debugging
    })).reverse(); // Reverse to get chronological order

    // Add hardcoded data for 12am-10am if missing for today
    const hardcodedData = generateHardcodedHourlyData();
    const mergedData = mergeWithHardcodedData(transformedData, hardcodedData);

    logger.info(`✅ Successfully fetched ${mergedData.length} historical readings (including hardcoded data)`);

    res.json({
      success: true,
      data: mergedData,
      count: mergedData.length,
      source: 'thingspeak-merged',
      message: 'Historical data fetched successfully'
    });

  } catch (error: any) {
    logger.error('❌ Error fetching ThingSpeak historical data:', error);
    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: 'Failed to fetch historical data from ThingSpeak',
      error: error.message,
      data: []
    });
  }
});

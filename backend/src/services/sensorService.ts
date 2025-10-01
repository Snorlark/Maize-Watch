import mongoose from 'mongoose';
import Sensor, { ISensor } from '../models/Sensor';
import SensorReading, { ISensorReading } from '../models/SensorReading';
import Farm from '../models/Farm';
import { AppError } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { getThingSpeakService, SensorData } from '../config/thingspeak';
import getIotSensorReadingModel from '../models/IotSensorReading';
import { DEFAULT_THRESHOLDS, ALERT_SEVERITY } from '../utils/constants';
import CacheService from './cacheService';
import farmService from './farmService';
// Lazy import to prevent startup connection
const getEmailService = () => import('../utils/emailService').then(m => m.default);

interface SensorCreationData {
  sensorId: string;
  name: string;
  type: 'DHT11' | 'Soil_Moisture' | 'LDR' | 'pH_Sensor' | 'Multi_Sensor';
  farm: string;
  location: {
    coordinates: [number, number];
    description?: string;
  };
  specifications: {
    model: string;
    manufacturer?: string;
    accuracy?: string;
    range?: string;
    powerRequirement?: string;
  };
  thingspeakConfig?: {
    channelId?: string;
    writeApiKey?: string;
    fieldMapping?: any;
  };
}

interface SensorReadingData {
  sensor: string;
  farm: string;
  timestamp?: Date;
  data: SensorData;
  metadata?: {
    source?: 'thingspeak' | 'direct' | 'manual' | 'simulation';
    quality?: 'good' | 'fair' | 'poor' | 'error';
  };
}

class SensorService {
  /**
   * Create a new sensor
   */
  async createSensor(sensorData: SensorCreationData, userId: string): Promise<ISensor> {
    try {
      // Verify farm exists and user has access
      const farm = await Farm.findById(sensorData.farm);
      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      // Check if sensor ID already exists
      const existingSensor = await Sensor.findOne({ sensorId: sensorData.sensorId });
      if (existingSensor) {
        throw new AppError('Sensor ID already exists', 409);
      }

      // Set default alert thresholds based on sensor type
      const defaultThresholds = this.getDefaultThresholds(sensorData.type);

      const sensor = new Sensor({
        ...sensorData,
        alerts: {
          enabled: true,
          thresholds: defaultThresholds,
        },
      });

      await sensor.save();

      // Note: Simplified farm model doesn't track sensors array
      // Sensor is linked to farm via sensor.farm field

      logger.info(`Sensor created: ${sensor.sensorId}`, {
        sensorId: sensor.sensorId,
        farmId: farm._id,
        userId,
      });

      return sensor;
    } catch (error) {
      logger.error('Error creating sensor:', error);
      throw error;
    }
  }

  /**
   * Get sensors by farm
   */
  async getSensorsByFarm(farmId: string): Promise<ISensor[]> {
    try {
      const sensors = await Sensor.find({ farm: farmId, isActive: true })
        .populate('farm', 'name owner')
        .sort({ createdAt: -1 });

      return sensors;
    } catch (error) {
      logger.error('Error fetching sensors by farm:', error);
      throw error;
    }
  }

  /**
   * Get sensor by ID
   */
  async getSensorById(sensorId: string): Promise<ISensor> {
    try {
      const sensor = await Sensor.findById(sensorId).populate('farm', 'name owner');
      if (!sensor) {
        throw new AppError('Sensor not found', 404);
      }

      return sensor;
    } catch (error) {
      logger.error('Error fetching sensor:', error);
      throw error;
    }
  }

  /**
   * Update sensor
   */
  async updateSensor(sensorId: string, updateData: Partial<ISensor>): Promise<ISensor> {
    try {
      const sensor = await Sensor.findByIdAndUpdate(
        sensorId,
        { ...updateData, updatedAt: new Date() },
        { new: true, runValidators: true }
      ).populate('farm', 'name owner');

      if (!sensor) {
        throw new AppError('Sensor not found', 404);
      }

      logger.info(`Sensor updated: ${sensor.sensorId}`);
      return sensor;
    } catch (error) {
      logger.error('Error updating sensor:', error);
      throw error;
    }
  }

  /**
   * Delete sensor
   */
  async deleteSensor(sensorId: string): Promise<void> {
    try {
      const sensor = await Sensor.findById(sensorId);
      if (!sensor) {
        throw new AppError('Sensor not found', 404);
      }

      // Remove sensor from farm
      await Farm.findByIdAndUpdate(sensor.farm, {
        $pull: { sensors: sensor._id },
      });

      // Soft delete sensor
      sensor.isActive = false;
      await sensor.save();

      logger.info(`Sensor deleted: ${sensor.sensorId}`);
    } catch (error) {
      logger.error('Error deleting sensor:', error);
      throw error;
    }
  }

  /**
   * Record sensor reading
   */
  async recordReading(readingData: SensorReadingData): Promise<ISensorReading> {
    try {
      const sensor = await Sensor.findById(readingData.sensor).populate('farm');
      if (!sensor) {
        throw new AppError('Sensor not found', 404);
      }

      // Create sensor reading
      const reading = new SensorReading({
        ...readingData,
        timestamp: readingData.timestamp || new Date(),
        metadata: {
          source: 'direct',
          quality: 'good',
          processed: false,
          ...readingData.metadata,
        },
      });

      // Assess data quality
      const qualityAssessment = reading.assessDataQuality();
      reading.metadata.quality = qualityAssessment.quality;

      // Check alert thresholds
      const alerts = sensor.checkAlertThresholds(readingData.data);
      if (alerts.length > 0) {
        reading.alerts = alerts.map(alert => ({
          type: alert.type,
          severity: this.determineSeverity(alert.type, alert.value, alert.threshold),
          message: `${alert.type}: ${alert.value} (threshold: ${alert.threshold})`,
          acknowledged: false,
        }));

        // Send alert notifications
        await this.sendAlertNotifications(sensor, alerts);
      }

      await reading.save();

      // Update sensor last reading
      await sensor.updateLastReading(
        readingData.data.field6, // Battery Level
        readingData.data.field7  // Signal Strength
      );

      logger.info(`Sensor reading recorded: ${sensor.sensorId}`, {
        sensorId: sensor.sensorId,
        timestamp: reading.timestamp,
        quality: reading.metadata.quality,
        alertCount: reading.alerts?.length || 0,
      });

      // Record the reading
      const newReading = await this.recordReading({
        sensor: sensor.sensorId,
        farm: sensor.farm.toString(),
        data: readingData.data,
        metadata: {
          source: 'direct',
          quality: 'good'
        }
      });

      // Cache the latest reading
      await CacheService.cacheSensorLatest(sensor.sensorId, newReading);

      // Invalidate related cache
      await CacheService.invalidateSensorCache(sensor.sensorId);

      return newReading;
    } catch (error) {
      logger.error('Error recording sensor reading:', error);
      throw error;
    }
  }

  /**
   * Get sensor readings with pagination and caching
   */
  async getSensorReadings(
    sensorId: string,
    page: number = 1,
    limit: number = 100,
    startDate?: Date,
    endDate?: Date
  ): Promise<{ readings: ISensorReading[]; total: number; pages: number }> {
    try {
      const sensor = await Sensor.findById(sensorId);
      if (!sensor) {
        throw new AppError('Sensor not found', 404);
      }

      // Try cache first (only for first page without date filters)
      if (page === 1 && !startDate && !endDate) {
        const cached = await CacheService.getSensorReadings(sensorId, page);
        if (cached) {
          logger.debug(`Cache hit for sensor readings: ${sensorId}, page: ${page}`);
          return cached;
        }
      }

      const skip = (page - 1) * limit;
      
      // Build query
      const query: any = { sensor: sensorId };
      if (startDate || endDate) {
        query.timestamp = {};
        if (startDate) query.timestamp.$gte = startDate;
        if (endDate) query.timestamp.$lte = endDate;
      }

      // Get readings and total count
      const [readings, total] = await Promise.all([
        SensorReading.find(query)
          .sort({ timestamp: -1 })
          .skip(skip)
          .limit(limit)
          .populate('sensor', 'name type')
          .populate('farm', 'name'),
        SensorReading.countDocuments(query)
      ]);

      const result = {
        readings,
        total,
        pages: Math.ceil(total / limit)
      };

      // Cache first page without date filters
      if (page === 1 && !startDate && !endDate) {
        await CacheService.cacheSensorReadings(sensorId, page, result);
      }

      return result;
    } catch (error) {
      logger.error('Error getting sensor readings:', error);
      throw error instanceof AppError ? error : new AppError('Failed to get sensor readings', 500);
    }
  }

  /**
   * Get latest readings for all sensors in a farm with caching
   */
  async getLatestReadingsByFarm(farmId: string): Promise<ISensorReading[]> {
    try {
      // Get the farm to find its registered prototypes
      const farm = await farmService.getFarmById(farmId);
      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      // Get all prototypes registered by this farm's user
      const Prototype = require('../models/Prototype').default;
      const prototypes = await Prototype.find({ registeredBy: farm.userId });
      
      if (!prototypes || prototypes.length === 0) {
        logger.warn(`No prototypes found for farm ${farmId}`);
        return [];
      }

      // Get latest readings for each prototype from IoT database
      const allReadings: ISensorReading[] = [];

      for (const prototype of prototypes) {
        // Connect to IoT database directly
        const iotConnection = mongoose.createConnection(process.env.MONGODB_IOT_URI || 'mongodb://localhost:27017/iot_data');
        const iotSensorReadingSchema = new mongoose.Schema({
          prototype_id: String,
          timestamp: Date,
          temperature: Number,
          humidity: Number,
          soilMoisture: Number,
          soilPh: Number,
          lightIntensity: Number,
          metadata: Object
        }, { collection: 'sensor_readings' });
        
        const IotSensorReading = iotConnection.model('IotSensorReading', iotSensorReadingSchema);
        
        const readings = await IotSensorReading.find({ prototype_id: prototype.prototype_id })
          .sort({ timestamp: -1 })
          .limit(1);
        
        if (readings && readings.length > 0) {
          const reading = readings[0];
          allReadings.push({
            sensor: undefined as any,
            farm: farmId as any,
            timestamp: reading.timestamp,
            data: {
              temperature: reading.temperature,
              humidity: reading.humidity,
              soilMoisture: reading.soilMoisture,
              lightIntensity: reading.lightIntensity,
              pH: reading.soilPh,
            },
            metadata: reading.metadata || { source: 'thingspeak', quality: 'good', processed: false },
            createdAt: reading.timestamp,
            updatedAt: reading.timestamp,
          } as any);
        }
        
        // Close the connection
        await iotConnection.close();
      }

      if (allReadings.length > 0) {
        return allReadings;
      }

      // Fallback to primary DB if no IoT readings found
      const cached = await CacheService.getFarmSensors(farmId);
      if (cached) {
        logger.debug(`Cache hit for farm sensors: ${farmId}`);
        return cached;
      }

      const sensorReadings = await SensorReading.getLatestByFarm(farmId);
      await CacheService.cacheFarmSensors(farmId, sensorReadings);
      return sensorReadings;
    } catch (error) {
      logger.error('Error getting latest readings by farm:', error);
      throw error instanceof AppError ? error : new AppError('Failed to get latest readings', 500);
    }
  }

  /**
   * Sync data from ThingSpeak
   */
  async syncFromThingSpeak(sensorId: string): Promise<void> {
    try {
      const sensor = await Sensor.findById(sensorId);
      if (!sensor) {
        throw new AppError('Sensor not found', 404);
      }

      if (!sensor.thingspeakConfig?.channelId) {
        throw new AppError('ThingSpeak configuration not found for sensor', 400);
      }

      // Check cache first
      const cached = await CacheService.getThingSpeakData(sensor.thingspeakConfig.channelId);
      if (cached) {
        logger.debug(`Cache hit for ThingSpeak data: ${sensor.thingspeakConfig.channelId}`);
        return;
      }

      // Get latest data from ThingSpeak
      const thingSpeakService = getThingSpeakService();
      const data = await thingSpeakService.readLatestData();
      if (!data) {
        logger.warn(`No data received from ThingSpeak for sensor ${sensorId}`);
        return;
      }

      // Cache the ThingSpeak data
      await CacheService.cacheThingSpeakData(sensor.thingspeakConfig.channelId, data);

      // Record the reading
      await this.recordReading({
        sensor: sensorId,
        farm: sensor.farm.toString(),
        data,
        metadata: {
          source: 'thingspeak',
          quality: 'good'
        }
      });

      logger.info(`ThingSpeak data synced for sensor ${sensorId}`);
    } catch (error) {
      logger.error('Error syncing from ThingSpeak:', error);
      throw error instanceof AppError ? error : new AppError('Failed to sync from ThingSpeak', 500);
    }
  }

  /**
   * Get sensors needing maintenance
   */
  async getSensorsNeedingMaintenance(): Promise<ISensor[]> {
    try {
      const sensors = await Sensor.findNeedingMaintenance();
      return sensors;
    } catch (error) {
      logger.error('Error fetching sensors needing maintenance:', error);
      throw error;
    }
  }

  /**
   * Calibrate sensor
   */
  async calibrateSensor(sensorId: string, calibrationData: any): Promise<ISensor> {
    try {
      const sensor = await Sensor.findById(sensorId);
      if (!sensor) {
        throw new AppError('Sensor not found', 404);
      }

      sensor.calibration = {
        lastCalibrated: new Date(),
        calibrationData,
        nextCalibrationDue: undefined,
      };

      // Schedule next calibration (90 days from now)
      await sensor.scheduleCalibration(90);

      logger.info(`Sensor calibrated: ${sensor.sensorId}`);
      return sensor;
    } catch (error) {
      logger.error('Error calibrating sensor:', error);
      throw error;
    }
  }

  /**
   * Get sensor statistics
   */
  async getSensorStatistics(): Promise<any> {
    try {
      const stats = await Sensor.getStatistics();
      return stats;
    } catch (error) {
      logger.error('Error fetching sensor statistics:', error);
      throw error;
    }
  }

  /**
   * Private helper methods
   */
  private getDefaultThresholds(sensorType: string): any {
    const baseThresholds = {
      temperature: DEFAULT_THRESHOLDS.TEMPERATURE,
      humidity: DEFAULT_THRESHOLDS.HUMIDITY,
      batteryLevel: DEFAULT_THRESHOLDS.BATTERY_LEVEL,
    };

    switch (sensorType) {
      case 'Soil_Moisture':
        return {
          ...baseThresholds,
          soilMoisture: DEFAULT_THRESHOLDS.SOIL_MOISTURE,
        };
      case 'pH_Sensor':
        return {
          ...baseThresholds,
          pH: DEFAULT_THRESHOLDS.PH,
        };
      case 'Multi_Sensor':
        return {
          ...baseThresholds,
          soilMoisture: DEFAULT_THRESHOLDS.SOIL_MOISTURE,
          pH: DEFAULT_THRESHOLDS.PH,
        };
      default:
        return baseThresholds;
    }
  }

  private determineSeverity(alertType: string, value: number, threshold: number): 'low' | 'medium' | 'high' | 'critical' {
    const difference = Math.abs(value - threshold);
    const percentageDiff = (difference / threshold) * 100;

    if (percentageDiff > 50) return ALERT_SEVERITY.CRITICAL;
    if (percentageDiff > 30) return ALERT_SEVERITY.HIGH;
    if (percentageDiff > 15) return ALERT_SEVERITY.MEDIUM;
    return ALERT_SEVERITY.LOW;
  }

  private async sendAlertNotifications(sensor: ISensor, alerts: any[]): Promise<void> {
    try {
      const farm = await Farm.findById(sensor.farm).populate('owner');
      if (!farm || !farm.userId) return;

      const user = farm.userId as any;
      
      for (const alert of alerts) {
        const emailService = await getEmailService();
        await emailService.sendAlertNotification(
          user.email,
          user.fullName,
          farm.farmName,
          alert.type,
          `${alert.type}: ${alert.value} (threshold: ${alert.threshold})`,
          this.determineSeverity(alert.type, alert.value, alert.threshold)
        );
      }
    } catch (error) {
      logger.error('Error sending alert notifications:', error);
      // Don't throw error to avoid breaking the main flow
    }
  }
}

function normalizeSoilMoisture(value: number): number {
  if (value <= 100) return value;
  if (value <= 1023) return ((1023 - value) / 1023) * 100;
  if (value <= 4095) return ((4095 - value) / 4095) * 100;
  if (value <= 65535) return ((65535 - value) / 65535) * 100;
  return Math.max(0, Math.min(100, (value / Math.max(value, 1000)) * 100));
}

export default new SensorService();

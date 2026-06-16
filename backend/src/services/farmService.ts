import Farm, { IFarm } from '../models/Farm';
import Field from '../models/Field';
import { AppError } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { USER_ROLES } from '../utils/constants';
import User from '../models/User';
import Sensor from '../models/Sensor';
import SensorReading from '../models/SensorReading';
import { HTTP_STATUS } from '../utils/constants';

interface FarmCreationData {
  userId: string;
  farmName: string;
  location: string;
  fields?: Array<{
    fieldName: string;
    plantingDate: Date;
    growthStage?: 'VE' | 'V3' | 'V8' | 'VT' | 'R1' | 'R6';
    sensors: Array<{
      deviceID: string;
      sensorName: string;
      description: string;
      soilType: 'loamy' | 'sandy' | 'clay' | 'silty';
      readings: {
        soilMoisture?: number;
        temperature?: number;
        humidity?: number;
        lightIntensity?: number;
        soilPh?: number;
      };
    }>;
  }>;
  // Legacy support for old interface
  owner?: string;
  description?: string;
}

interface FarmAnalytics {
  totalSensors: number;
  activeSensors: number;
  latestReadings: any[];
  averageConditions: {
    temperature?: number;
    humidity?: number;
    soilMoisture?: number;
    pH?: number;
    lightLevel?: number;
  };
  alerts: {
    total: number;
    critical: number;
    warning: number;
    info: number;
    bySeverity: {
      [key: string]: number;
    };
  };
  dataQuality: {
    completeness: number;
    accuracy: number;
    timeliness: number;
  };
  trends: {
    temperature: 'increasing' | 'decreasing' | 'stable';
    humidity: 'increasing' | 'decreasing' | 'stable';
    soilMoisture: 'increasing' | 'decreasing' | 'stable';
  };
}

class FarmService {
  /**
   * Create a new farm
   */
  async createFarm(farmData: FarmCreationData): Promise<IFarm> {
    try {
      logger.info('🏗️ FarmService.createFarm called', {
        farmData: JSON.stringify(farmData, null, 2)
      });

      // Handle legacy owner field
      const userId = farmData.userId || farmData.owner;

      if (!userId) {
        logger.error('🚨 User ID is missing from farm data', { farmData });
        throw new AppError('User ID is required', HTTP_STATUS.BAD_REQUEST);
      }

      logger.info('🔍 Checking if user exists', { userId });

      // Check if user exists
      const user = await User.findById(userId);
      if (!user) {
        logger.error('🚨 User not found', { userId });
        throw new AppError('User not found', HTTP_STATUS.NOT_FOUND);
      }

      logger.info('✅ User found', {
        userId,
        userFullName: user.fullName,
        userEmail: user.email
      });

      // Check if user already has a farm (users can only have one farm with multiple fields)
      const existingFarm = await Farm.findOne({ userId });

      if (existingFarm) {
        logger.info('🔄 User already has a farm, adding fields to existing farm', {
          existingFarmId: existingFarm._id,
          existingFarmName: existingFarm.farmName,
          newFieldsCount: farmData.fields?.length || 0
        });

        // Add new fields to existing farm
        if (farmData.fields && farmData.fields.length > 0) {
          // Ensure growthStage is set for each field
          const fieldsToAdd = farmData.fields.map(field => ({
            ...field,
            growthStage: field.growthStage || 'VE' as const
          }));
          existingFarm.fields.push(...fieldsToAdd);
          await existingFarm.save();

          logger.info('✅ Fields added to existing farm successfully', {
            farmId: existingFarm._id,
            totalFieldsCount: existingFarm.fields.length,
            addedFieldsCount: farmData.fields.length
          });

          return existingFarm;
        } else {
          logger.info('ℹ️ No new fields to add to existing farm', {
            farmId: existingFarm._id,
            existingFieldsCount: existingFarm.fields.length
          });

          return existingFarm;
        }
      }

      logger.info('🔍 Validating fields data', {
        fieldsCount: farmData.fields?.length || 0,
        fields: farmData.fields ? JSON.stringify(farmData.fields, null, 2) : 'No fields'
      });

      // Validate fields structure if provided
      if (farmData.fields && farmData.fields.length > 0) {
        for (let i = 0; i < farmData.fields.length; i++) {
          const field = farmData.fields[i];
          logger.info(`🔍 Validating field ${i + 1}`, {
            fieldName: field.fieldName,
            plantingDate: field.plantingDate,
            growthStage: field.growthStage,
            sensorsCount: field.sensors?.length || 0
          });

          if (!field.fieldName) {
            logger.error('🚨 Field name is required', { fieldIndex: i, field });
            throw new AppError(`Field ${i + 1}: fieldName is required`, HTTP_STATUS.BAD_REQUEST);
          }

          if (!field.plantingDate) {
            logger.error('🚨 Planting date is required', { fieldIndex: i, field });
            throw new AppError(`Field ${i + 1}: plantingDate is required`, HTTP_STATUS.BAD_REQUEST);
          }

          // Validate sensors if provided
          if (field.sensors && field.sensors.length > 0) {
            for (let j = 0; j < field.sensors.length; j++) {
              const sensor = field.sensors[j];
              logger.info(`🔍 Validating sensor ${j + 1} in field ${i + 1}`, {
                deviceID: sensor.deviceID,
                sensorName: sensor.sensorName,
                soilType: sensor.soilType
              });

              if (!sensor.deviceID) {
                logger.error('🚨 Sensor deviceID is required', { fieldIndex: i, sensorIndex: j, sensor });
                throw new AppError(`Field ${i + 1}, Sensor ${j + 1}: deviceID is required`, HTTP_STATUS.BAD_REQUEST);
              }
            }
          }
        }
      }

      logger.info('🏗️ Creating farm document', {
        userId,
        farmName: farmData.farmName,
        fieldsCount: farmData.fields?.length || 0
      });

      const farm = new Farm({
        userId,
        farmName: farmData.farmName,
        location: farmData.location,
        fields: farmData.fields || []
      });

      logger.info('💾 Saving farm to database');
      await farm.save();

      logger.info('✅ Farm created successfully with new structure', {
        farmId: farm._id,
        userId,
        farmName: farm.farmName,
        fieldsCount: farm.fields?.length || 0,
        savedFarm: JSON.stringify(farm.toObject(), null, 2)
      });

      return farm;
    } catch (error) {
      logger.error('🚨 Error creating farm', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
        farmData: JSON.stringify(farmData, null, 2)
      });
      throw error;
    }
  }

  /**
   * Get farm by ID with embedded fields
   * @param farmId - Farm ID
   * @returns Promise<IFarm>
   */
  async getFarmById(farmId: string): Promise<IFarm> {
    try {
      const farm = await Farm.findById(farmId);

      if (!farm) {
        throw new AppError('Farm not found', HTTP_STATUS.NOT_FOUND);
      }

      return farm;
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      logger.error('Error fetching farm by ID', { error: error instanceof Error ? error.message : 'Unknown error', farmId });
      throw new AppError('Failed to fetch farm', HTTP_STATUS.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * Get farms by owner/user ID with embedded fields
   * @param userId - User ID (optional for admin)
   * @returns Promise<IFarm[]>
   */
  /**
   * Build a MongoDB query matching users in an assigned region.
   */
  buildRegionUserQuery(assignedRegion: string): Record<string, unknown> {
    return {
      $or: [
        { 'address.region': assignedRegion },
        { address: { $regex: assignedRegion.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), $options: 'i' } }
      ]
    };
  }

  /**
   * Check whether a user record belongs to the given region.
   */
  isUserInRegion(user: { address?: { region?: string } | string }, assignedRegion: string): boolean {
    if (user.address && typeof user.address === 'object' && user.address.region === assignedRegion) {
      return true;
    }
    const addressStr = typeof user.address === 'string' ? user.address : '';
    const regex = new RegExp(assignedRegion.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
    return regex.test(addressStr);
  }

  /**
   * Determine if the current user can access a farm (read).
   */
  async canUserAccessFarm(currentUser: { id: string; role: string; assignedRegion?: string }, farm: IFarm): Promise<boolean> {
    const farmUserId = (farm.userId as { _id?: { toString(): string } })?._id
      ? (farm.userId as { _id: { toString(): string } })._id.toString()
      : farm.userId.toString();

    if (farmUserId === currentUser.id) return true;
    if (currentUser.role === USER_ROLES.SUPER_ADMIN || currentUser.role === USER_ROLES.ADMIN) return true;

    if (currentUser.role === USER_ROLES.REGIONAL_ADMIN && currentUser.assignedRegion) {
      const owner = await User.findById(farmUserId).select('address').lean();
      if (!owner) return false;
      return this.isUserInRegion(owner, currentUser.assignedRegion);
    }

    return false;
  }

  /**
   * Get farms accessible to the current user based on role.
   */
  async getFarmsForUser(currentUser: { id: string; role: string; assignedRegion?: string }): Promise<IFarm[]> {
    if (currentUser.role === USER_ROLES.SUPER_ADMIN || currentUser.role === USER_ROLES.ADMIN) {
      return this.getFarmsByOwner(undefined);
    }
    if (currentUser.role === USER_ROLES.REGIONAL_ADMIN && currentUser.assignedRegion) {
      return this.getFarmsByOwner(undefined, currentUser.assignedRegion);
    }
    return this.getFarmsByOwner(currentUser.id);
  }

  async getFarmsByOwner(ownerId?: string, regionalFilter?: string): Promise<IFarm[]> {
    try {
      let query: Record<string, unknown> = {};

      if (ownerId !== undefined) {
        query.userId = ownerId;
      }

      // Regional admins see farms owned by users in their assigned region
      if (regionalFilter) {
        const usersInRegion = await User.find(this.buildRegionUserQuery(regionalFilter)).select('_id');
        const userIds = usersInRegion.map((u) => u._id);
        query.userId = { $in: userIds };
      }

      const farms = await Farm.find(query);

      if (ownerId === undefined && !regionalFilter) {
        logger.info(`Fetching all farms for super_admin: ${farms.length} farms found`);
      } else if (regionalFilter) {
        logger.info(`Fetching farms for region ${regionalFilter}: ${farms.length} farms found`);
      } else {
        logger.info(`Fetching farms for user ${ownerId}: ${farms.length} farms found`);
      }

      return farms;
    } catch (error) {
      logger.error('Error fetching farms by owner', { error: error instanceof Error ? error.message : 'Unknown error', userId });
      throw new AppError('Failed to fetch farms', HTTP_STATUS.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * Update farm with embedded fields support
   * @param farmId - Farm ID
   * @param updateData - Update data
   * @returns Promise<IFarm>
   */
  async updateFarm(farmId: string, updateData: Partial<FarmCreationData>): Promise<IFarm> {
    try {
      const farm = await Farm.findByIdAndUpdate(
        farmId,
        { $set: updateData },
        { new: true, runValidators: true }
      ).populate('userId', 'fullName email username');

      if (!farm) {
        throw new AppError('Farm not found', HTTP_STATUS.NOT_FOUND);
      }

      logger.info('Farm updated successfully', {
        farmId: farm._id,
        updatedFields: Object.keys(updateData)
      });

      return farm;
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      logger.error('Error updating farm', { error: error instanceof Error ? error.message : 'Unknown error', farmId, updateData });
      throw new AppError('Failed to update farm', HTTP_STATUS.INTERNAL_SERVER_ERROR);
    }
  }

  /**
   * Delete farm
   */
  async deleteFarm(farmId: string): Promise<void> {
    try {
      const farm = await Farm.findByIdAndDelete(farmId);
      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      logger.info(`Farm deleted: ${farm.farmName}`, {
        farmId: farm._id
      });
    } catch (error) {
      logger.error('Error deleting farm:', error);
      throw error;
    }
  }

  /**
   * Get farm analytics with simplified implementation
   */
  async getFarmAnalytics(farmId: string, days: number = 7): Promise<FarmAnalytics> {
    try {
      const farm = await Farm.findById(farmId);
      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      // Get all fields for the farm and their sensors
      const fields = await Field.find({ farmId });
      const fieldIds = fields.map(f => f._id);
      const sensors = await Sensor.find({ field: { $in: fieldIds } });
      const sensorIds = sensors.map(s => s._id);

      // Get recent readings
      const readings = await SensorReading.find({
        sensor: { $in: sensorIds },
        timestamp: { $gte: startDate }
      }).populate('sensor', 'name type status');

      // Calculate analytics
      const analytics: FarmAnalytics = {
        totalSensors: sensors.length,
        activeSensors: sensors.filter(s => s.status === 'active').length,
        latestReadings: [],
        averageConditions: {},
        alerts: {
          total: 0,
          critical: 0,
          warning: 0,
          info: 0,
          bySeverity: {}
        },
        dataQuality: {
          completeness: 85,
          accuracy: 90,
          timeliness: 95
        },
        trends: {
          temperature: 'stable',
          humidity: 'stable',
          soilMoisture: 'stable'
        }
      };

      // Calculate average conditions
      if (readings.length > 0) {
        const conditions = {
          temperature: [] as number[],
          humidity: [] as number[],
          soilMoisture: [] as number[],
          pH: [] as number[]
        };

        readings.forEach(reading => {
          if (reading.data.temperature !== undefined) conditions.temperature.push(reading.data.temperature);
          if (reading.data.humidity !== undefined) conditions.humidity.push(reading.data.humidity);
          if (reading.data.soilMoisture !== undefined) conditions.soilMoisture.push(reading.data.soilMoisture);
          if (reading.data.pH !== undefined) conditions.pH.push(reading.data.pH);
        });

        // Calculate averages
        if (conditions.temperature.length > 0) {
          analytics.averageConditions.temperature =
            conditions.temperature.reduce((a, b) => a + b, 0) / conditions.temperature.length;
        }
        if (conditions.humidity.length > 0) {
          analytics.averageConditions.humidity =
            conditions.humidity.reduce((a, b) => a + b, 0) / conditions.humidity.length;
        }
        if (conditions.soilMoisture.length > 0) {
          analytics.averageConditions.soilMoisture =
            conditions.soilMoisture.reduce((a, b) => a + b, 0) / conditions.soilMoisture.length;
        }
        if (conditions.pH.length > 0) {
          analytics.averageConditions.pH =
            conditions.pH.reduce((a, b) => a + b, 0) / conditions.pH.length;
        }

        // Get latest readings (one per sensor)
        const latestReadingsMap = new Map();
        readings
          .sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime())
          .forEach(reading => {
            const sensorId = reading.sensor._id.toString();
            if (!latestReadingsMap.has(sensorId)) {
              latestReadingsMap.set(sensorId, reading);
            }
          });

        analytics.latestReadings = Array.from(latestReadingsMap.values());
      }

      return analytics;
    } catch (error) {
      logger.error('Error getting farm analytics:', error);
      throw error;
    }
  }

  /**
   * Get farms by location (simplified location-based query)
   */
  async getFarmsByLocation(
    region?: string,
    province?: string,
    municipality?: string
  ): Promise<IFarm[]> {
    try {
      const query: any = {};

      if (region || province || municipality) {
        const locationParts = [];
        if (municipality) locationParts.push(municipality);
        if (province) locationParts.push(province);
        if (region) locationParts.push(region);

        query.location = { $regex: locationParts.join('|'), $options: 'i' };
      }

      const farms = await Farm.find(query);
      return farms;
    } catch (error) {
      logger.error('Error fetching farms by location:', error);
      throw error;
    }
  }

  /**
   * Get farm statistics
   */
  async getFarmStatistics(): Promise<any> {
    try {
      const stats = {
        totalFarms: await Farm.countDocuments(),
        activeFarms: await Farm.countDocuments({ growthStage: { $ne: 'Harvested' } }),
        totalSensors: await Sensor.countDocuments(),
        activeSensors: await Sensor.countDocuments({ status: 'active' })
      };
      return stats;
    } catch (error) {
      logger.error('Error fetching farm statistics:', error);
      throw error;
    }
  }

  /**
   * Update farm status
   */
  async updateFarmStatus(farmId: string, status: string): Promise<IFarm> {
    try {
      const validStatuses = ['active', 'inactive', 'archived'];
      if (!validStatuses.includes(status)) {
        throw new AppError('Invalid farm status', 400);
      }

      const farm = await Farm.findByIdAndUpdate(
        farmId,
        { status: status, updatedAt: new Date() },
        { new: true }
      );

      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      logger.info(`Farm status updated: ${farm.farmName} -> ${status}`, {
        farmId: farm._id,
        status,
        location: farm.location
      });

      return farm;
    } catch (error) {
      logger.error('Error updating farm status:', error);
      throw error;
    }
  }

  /**
   * Link device to farm
   */
  async linkDeviceToFarm(farmId: string, deviceId: string, macAddress?: string): Promise<IFarm> {
    try {
      // Check if device is already linked to another farm
      const existingFarm = await Farm.findOne({
        deviceId,
        _id: { $ne: farmId }
      });

      if (existingFarm) {
        throw new AppError(`Device already linked to farm ${farmId}`, 400);
      }

      const farm = await Farm.findByIdAndUpdate(
        farmId,
        {
          deviceId,
          deviceMacAddress: macAddress,
          deviceRegisteredAt: new Date(),
          updatedAt: new Date()
        },
        { new: true }
      );

      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      logger.info(`Device linked to farm: ${farm.farmName}`, {
        farmId: farm._id,
        deviceId,
        macAddress
      });

      return farm;
    } catch (error) {
      logger.error('Error linking device to farm:', error);
      throw error;
    }
  }

  /**
   * Unlink device from farm
   */
  async unlinkDeviceFromFarm(farmId: string): Promise<IFarm> {
    try {
      const farm = await Farm.findByIdAndUpdate(
        farmId,
        {
          $unset: {
            deviceId: 1,
            deviceMacAddress: 1,
            deviceRegisteredAt: 1
          },
          updatedAt: new Date()
        },
        { new: true }
      );

      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      logger.info(`Device unlinked from farm: ${farm.farmName}`, {
        farmId: farm._id
      });

      return farm;
    } catch (error) {
      logger.error('Error unlinking device from farm:', error);
      throw error;
    }
  }

  /**
   * Get farm by device ID
   */
  async getFarmByDeviceId(deviceId: string): Promise<IFarm | null> {
    try {
      const farm = await Farm.findOne({ deviceId });
      return farm;
    } catch (error) {
      logger.error('Error fetching farm by device ID:', error);
      throw error;
    }
  }

  /**
   * Get harvest predictions for corn
   */
  async getHarvestPredictions(farmId: string): Promise<any> {
    try {
      const farm = await Farm.findById(farmId);
      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      // Simplified corn harvest prediction
      const predictions = {
        cropType: 'Corn',
        estimatedYield: this.calculateEstimatedYield(farm),
        harvestReadiness: this.calculateHarvestReadiness(farm),
        riskFactors: this.identifyRiskFactors(farm),
        recommendations: this.generateRecommendations(farm)
      };

      return predictions;
    } catch (error) {
      logger.error('Error getting harvest predictions:', error);
      throw error;
    }
  }

  private calculateEstimatedYield(farm: IFarm): any {
    // Simplified yield calculation for farm-level aggregation
    const baseYield = 8.5; // Average corn yield

    return {
      estimated: baseYield.toFixed(2),
      unit: 'tons/hectare',
      confidence: 'medium'
    };
  }

  private calculateHarvestReadiness(farm: IFarm): any {
    // Simplified harvest readiness for farm-level aggregation
    return {
      percentage: 50,
      status: 'not_ready',
      estimatedDays: 60
    };
  }

  private identifyRiskFactors(farm: IFarm): string[] {
    const risks: string[] = [];

    // Basic risk assessment for farm-level aggregation
    risks.push('Weather variability');

    return risks;
  }

  private generateRecommendations(farm: IFarm): string[] {
    const recommendations: string[] = [];

    // Basic recommendations for farm-level management
    recommendations.push('Monitor field conditions regularly');
    recommendations.push('Maintain proper irrigation schedules');
    recommendations.push('Check sensor data for anomalies');

    return recommendations;
  }
}

export default new FarmService();

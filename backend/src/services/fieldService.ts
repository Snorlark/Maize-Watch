import Field, { IField } from '../models/Field';
import Farm from '../models/Farm';
import { AppError } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import User from '../models/User';
import Sensor from '../models/Sensor';
import SensorReading from '../models/SensorReading';

interface FieldCreationData {
  farmId: string;
  fieldName: string;
  soilType: string;
  plantingDate: Date;
  growthStage?: string;
  devices?: Array<{
    sensorId: string;
    name: string;
    deviceMacAddress?: string;
    status?: 'active' | 'inactive' | 'maintenance';
    location?: {
      coordinates: [number, number];
      description?: string;
    };
  }>;
}

interface FieldAnalytics {
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

class FieldService {
  /**
   * Create a new field
   */
  async createField(fieldData: FieldCreationData): Promise<IField> {
    try {
      // Verify farm exists
      const farm = await Farm.findById(fieldData.farmId);
      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      // Create field with devices array
      const field = new Field({
        ...fieldData,
        devices: fieldData.devices || []
      });
      await field.save();

      // Add field to farm's fields array
      await farm.addField(field._id as string);

      logger.info(`Field created: ${field.fieldName}`, {
        fieldId: field._id,
        farmId: field.farmId,
        soilType: field.soilType,
        devicesCount: field.devices.length
      });

      return field;
    } catch (error) {
      logger.error('Error creating field:', error);
      throw error;
    }
  }

  /**
   * Get field by ID
   */
  async getFieldById(fieldId: string): Promise<IField> {
    try {
      const field = await Field.findById(fieldId);
      if (!field) {
        throw new AppError('Field not found', 404);
      }
      return field;
    } catch (error) {
      logger.error('Error fetching field:', error);
      throw error;
    }
  }

  /**
   * Get fields by farm ID
   */
  async getFieldsByFarmId(farmId: string): Promise<IField[]> {
    try {
      const fields = await Field.find({ farmId });
      return fields;
    } catch (error) {
      logger.error('Error fetching fields by farm:', error);
      throw error;
    }
  }

  /**
   * Update field
   */
  async updateField(fieldId: string, updateData: Partial<IField>): Promise<IField> {
    try {
      const field = await Field.findByIdAndUpdate(
        fieldId,
        { ...updateData, updatedAt: new Date() },
        { new: true }
      );

      if (!field) {
        throw new AppError('Field not found', 404);
      }

      logger.info(`Field updated: ${field.fieldName}`, {
        fieldId: field._id,
        farmId: field.farmId
      });

      return field;
    } catch (error) {
      logger.error('Error updating field:', error);
      throw error;
    }
  }

  /**
   * Delete field
   */
  async deleteField(fieldId: string): Promise<void> {
    try {
      const field = await Field.findById(fieldId);
      if (!field) {
        throw new AppError('Field not found', 404);
      }

      // Remove field from farm's fields array
      const farm = await Farm.findById(field.farmId);
      if (farm) {
        // For now, we'll handle field removal manually
        // This will be updated when we implement proper Farm -> Field relationship methods
        logger.info(`Field removed from farm: ${field.fieldName}`, {
          fieldId: field._id,
          farmId: field.farmId
        });
      }

      await Field.findByIdAndDelete(fieldId);

      logger.info(`Field deleted: ${field.fieldName}`, {
        fieldId: field._id,
        farmId: field.farmId
      });
    } catch (error) {
      logger.error('Error deleting field:', error);
      throw error;
    }
  }

  /**
   * Get field analytics
   */
  async getFieldAnalytics(fieldId: string, days: number = 7): Promise<FieldAnalytics> {
    try {
      const field = await Field.findById(fieldId);
      if (!field) {
        throw new AppError('Field not found', 404);
      }

      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      // Get all sensors for the field
      const sensors = await Sensor.find({ field: fieldId });
      const sensorIds = sensors.map(s => s._id);

      // Get recent readings
      const readings = await SensorReading.find({
        sensor: { $in: sensorIds },
        timestamp: { $gte: startDate }
      }).populate('sensor', 'name type status');

      // Calculate analytics
      const analytics: FieldAnalytics = {
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
      logger.error('Error getting field analytics:', error);
      throw error;
    }
  }

  /**
   * Add device to field
   */
  async addDeviceToField(fieldId: string, deviceData: any): Promise<IField> {
    try {
      const field = await Field.findById(fieldId);
      if (!field) {
        throw new AppError('Field not found', 404);
      }

      await field.addDevice(deviceData);

      logger.info(`Device added to field: ${field.fieldName}`, {
        fieldId: field._id,
        deviceId: deviceData.sensorId
      });

      return field;
    } catch (error) {
      logger.error('Error adding device to field:', error);
      throw error;
    }
  }

  /**
   * Remove device from field
   */
  async removeDeviceFromField(fieldId: string, deviceId: string): Promise<IField> {
    try {
      const field = await Field.findById(fieldId);
      if (!field) {
        throw new AppError('Field not found', 404);
      }

      await field.removeDevice(deviceId);

      logger.info(`Device removed from field: ${field.fieldName}`, {
        fieldId: field._id,
        deviceId
      });

      return field;
    } catch (error) {
      logger.error('Error removing device from field:', error);
      throw error;
    }
  }

  /**
   * Get harvest predictions for field
   */
  async getHarvestPredictions(fieldId: string): Promise<any> {
    try {
      const field = await Field.findById(fieldId);
      if (!field) {
        throw new AppError('Field not found', 404);
      }

      // Simplified corn harvest prediction
      const predictions = {
        cropType: 'Corn',
        estimatedYield: this.calculateEstimatedYield(field),
        harvestReadiness: this.calculateHarvestReadiness(field),
        riskFactors: this.identifyRiskFactors(field),
        recommendations: this.generateRecommendations(field)
      };

      return predictions;
    } catch (error) {
      logger.error('Error getting harvest predictions:', error);
      throw error;
    }
  }

  private calculateEstimatedYield(field: IField): any {
    // Simplified yield calculation based on growth stage and planting date
    const daysFromPlanting = Math.floor(
      (new Date().getTime() - field.plantingDate.getTime()) / (1000 * 60 * 60 * 24)
    );
    
    // Basic corn yield estimation (tons per hectare)
    const baseYield = 8.5; // Average corn yield
    const yieldFactor = Math.min(daysFromPlanting / 120, 1); // 120 days to maturity
    
    return {
      estimated: (baseYield * yieldFactor).toFixed(2),
      unit: 'tons/hectare',
      confidence: 'medium'
    };
  }

  private calculateHarvestReadiness(field: IField): any {
    const daysFromPlanting = Math.floor(
      (new Date().getTime() - field.plantingDate.getTime()) / (1000 * 60 * 60 * 24)
    );
    
    // Corn typically ready for harvest at 100-120 days
    const readinessPercentage = Math.min((daysFromPlanting / 110) * 100, 100);
    
    return {
      percentage: Math.round(readinessPercentage),
      status: readinessPercentage >= 95 ? 'ready' : readinessPercentage >= 80 ? 'almost_ready' : 'not_ready',
      estimatedDays: Math.max(110 - daysFromPlanting, 0)
    };
  }

  private identifyRiskFactors(field: IField): string[] {
    const risks: string[] = [];
    
    // Basic risk assessment based on growth stage and timing
    const daysFromPlanting = Math.floor(
      (new Date().getTime() - field.plantingDate.getTime()) / (1000 * 60 * 60 * 24)
    );
    
    if (daysFromPlanting > 130) {
      risks.push('Overmaturity risk');
    }
    
    if (field.growthStage === 'VE' && daysFromPlanting > 14) {
      risks.push('Slow emergence');
    }
    
    return risks;
  }

  private generateRecommendations(field: IField): string[] {
    const recommendations: string[] = [];
    
    const daysFromPlanting = Math.floor(
      (new Date().getTime() - field.plantingDate.getTime()) / (1000 * 60 * 60 * 24)
    );
    
    if (daysFromPlanting >= 100) {
      recommendations.push('Monitor for harvest readiness');
      recommendations.push('Check moisture content regularly');
    } else if (daysFromPlanting >= 60) {
      recommendations.push('Apply side-dress nitrogen if needed');
      recommendations.push('Monitor for pest activity');
    } else {
      recommendations.push('Ensure adequate soil moisture');
      recommendations.push('Monitor for early pest issues');
    }
    
    return recommendations;
  }
}

export default new FieldService();

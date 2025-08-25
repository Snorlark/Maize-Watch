import Farm, { IFarm } from '../models/Farm';
import Sensor from '../models/Sensor';
import SensorReading from '../models/SensorReading';
import User from '../models/User';
import { AppError } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { FARM_STATUS } from '../utils/constants';

interface FarmCreationData {
  name: string;
  description?: string;
  owner: string;
  location: {
    coordinates: [number, number];
    address: {
      region: string;
      province: string;
      municipality: string;
      barangay: string;
      zipCode?: string;
    };
  };
  area: {
    size: number;
    unit: 'hectares' | 'square_meters' | 'acres';
  };
  cropType: string;
  plantingDate?: Date;
  expectedHarvestDate?: Date;
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
  };
  alerts: {
    total: number;
    unacknowledged: number;
    bySeverity: Record<string, number>;
  };
  dataQuality: {
    good: number;
    fair: number;
    poor: number;
    error: number;
  };
}

class FarmService {
  /**
   * Create a new farm
   */
  async createFarm(farmData: FarmCreationData): Promise<IFarm> {
    try {
      // Verify owner exists
      const owner = await User.findById(farmData.owner);
      if (!owner) {
        throw new AppError('Owner not found', 404);
      }

      const farm = new Farm(farmData);
      await farm.save();

      logger.info(`Farm created: ${farm.name}`, {
        farmId: farm._id,
        ownerId: owner._id,
        location: farm.location.coordinates,
      });

      return farm;
    } catch (error) {
      logger.error('Error creating farm:', error);
      throw error;
    }
  }

  /**
   * Get farms by owner
   */
  async getFarmsByOwner(ownerId: string, page: number = 1, limit: number = 10): Promise<{
    farms: IFarm[];
    total: number;
    pages: number;
  }> {
    try {
      const skip = (page - 1) * limit;

      const [farms, total] = await Promise.all([
        Farm.find({ owner: ownerId, isActive: true })
          .populate('owner', 'username fullName email')
          .populate('sensors', 'name sensorId type status')
          .sort({ createdAt: -1 })
          .skip(skip)
          .limit(limit),
        Farm.countDocuments({ owner: ownerId, isActive: true }),
      ]);

      return {
        farms,
        total,
        pages: Math.ceil(total / limit),
      };
    } catch (error) {
      logger.error('Error fetching farms by owner:', error);
      throw error;
    }
  }

  /**
   * Get farm by ID
   */
  async getFarmById(farmId: string): Promise<IFarm> {
    try {
      const farm = await Farm.findById(farmId)
        .populate('owner', 'username fullName email contactNumber')
        .populate('sensors', 'name sensorId type status lastReading');

      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      return farm;
    } catch (error) {
      logger.error('Error fetching farm:', error);
      throw error;
    }
  }

  /**
   * Update farm
   */
  async updateFarm(farmId: string, updateData: Partial<IFarm>): Promise<IFarm> {
    try {
      const farm = await Farm.findByIdAndUpdate(
        farmId,
        { ...updateData, updatedAt: new Date() },
        { new: true, runValidators: true }
      ).populate('owner', 'username fullName email')
       .populate('sensors', 'name sensorId type status');

      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      logger.info(`Farm updated: ${farm.name}`, { farmId: farm._id });
      return farm;
    } catch (error) {
      logger.error('Error updating farm:', error);
      throw error;
    }
  }

  /**
   * Delete farm (soft delete)
   */
  async deleteFarm(farmId: string): Promise<void> {
    try {
      const farm = await Farm.findById(farmId);
      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      // Deactivate all sensors in the farm
      await Sensor.updateMany(
        { farm: farmId },
        { isActive: false, status: 'inactive' }
      );

      // Soft delete farm
      farm.isActive = false;
      await farm.save();

      logger.info(`Farm deleted: ${farm.name}`, { farmId: farm._id });
    } catch (error) {
      logger.error('Error deleting farm:', error);
      throw error;
    }
  }

  /**
   * Get farm analytics
   */
  async getFarmAnalytics(farmId: string, days: number = 7): Promise<FarmAnalytics> {
    try {
      const farm = await Farm.findById(farmId);
      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      // Get sensors
      const sensors = await Sensor.find({ farm: farmId, isActive: true });
      const activeSensors = sensors.filter(s => s.status === 'active');

      // Get latest readings
      const latestReadings = await SensorReading.getLatestByFarm(farmId);

      // Get readings for the period
      const readings = await SensorReading.find({
        farm: farmId,
        timestamp: { $gte: startDate },
        'metadata.quality': { $ne: 'error' }
      });

      // Calculate averages
      const averageConditions = this.calculateAverageConditions(readings);

      // Count alerts
      const alertStats = this.calculateAlertStatistics(readings);

      // Data quality stats
      const dataQualityStats = this.calculateDataQuality(readings);

      return {
        totalSensors: sensors.length,
        activeSensors: activeSensors.length,
        latestReadings,
        averageConditions,
        alerts: alertStats,
        dataQuality: dataQualityStats,
      };
    } catch (error) {
      logger.error('Error fetching farm analytics:', error);
      throw error;
    }
  }

  /**
   * Get farms near location
   */
  async getFarmsNearLocation(
    longitude: number,
    latitude: number,
    maxDistance: number = 10000
  ): Promise<IFarm[]> {
    try {
      const farms = await Farm.findNearby(longitude, latitude, maxDistance);
      return farms;
    } catch (error) {
      logger.error('Error fetching farms near location:', error);
      throw error;
    }
  }

  /**
   * Get farm statistics
   */
  async getFarmStatistics(): Promise<any> {
    try {
      const stats = await Farm.getStatistics();
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
      if (!Object.values(FARM_STATUS).includes(status as any)) {
        throw new AppError('Invalid farm status', 400);
      }

      const farm = await Farm.findByIdAndUpdate(
        farmId,
        { status, updatedAt: new Date() },
        { new: true }
      );

      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      logger.info(`Farm status updated: ${farm.name} -> ${status}`, {
        farmId: farm._id,
        status,
      });

      return farm;
    } catch (error) {
      logger.error('Error updating farm status:', error);
      throw error;
    }
  }

  /**
   * Add images to farm
   */
  async addFarmImages(farmId: string, imageUrls: string[]): Promise<IFarm> {
    try {
      const farm = await Farm.findById(farmId);
      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      farm.images.push(...imageUrls);
      await farm.save();

      logger.info(`Images added to farm: ${farm.name}`, {
        farmId: farm._id,
        imageCount: imageUrls.length,
      });

      return farm;
    } catch (error) {
      logger.error('Error adding farm images:', error);
      throw error;
    }
  }

  /**
   * Update farm weather data
   */
  async updateWeatherData(farmId: string, weatherData: any): Promise<IFarm> {
    try {
      const farm = await Farm.findById(farmId);
      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      await farm.updateWeatherData(weatherData);

      logger.info(`Weather data updated for farm: ${farm.name}`, {
        farmId: farm._id,
      });

      return farm;
    } catch (error) {
      logger.error('Error updating weather data:', error);
      throw error;
    }
  }

  /**
   * Update farm soil data
   */
  async updateSoilData(farmId: string, soilData: any): Promise<IFarm> {
    try {
      const farm = await Farm.findById(farmId) as IFarm;
      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      await farm.updateSoilData(soilData);

      logger.info(`Soil data updated for farm: ${farm.name}`, {
        farmId: farm._id,
      });

      return farm;
    } catch (error) {
      logger.error('Error updating soil data:', error);
      throw error;
    }
  }

  /**
   * Get farm harvest predictions
   */
  async getHarvestPredictions(farmId: string): Promise<any> {
    try {
      const farm = await Farm.findById(farmId);
      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      // Get recent sensor data for predictions
      const recentReadings = await SensorReading.find({
        farm: farmId,
        timestamp: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) }, // Last 30 days
        'metadata.quality': { $in: ['good', 'fair'] }
      }).sort({ timestamp: -1 }).limit(1000);

      // Calculate prediction metrics
      const predictions = {
        estimatedYield: this.calculateYieldPrediction(farm, recentReadings),
        harvestReadiness: this.calculateHarvestReadiness(farm, recentReadings),
        riskFactors: this.identifyRiskFactors(recentReadings),
        recommendations: this.generateRecommendations(farm, recentReadings),
      };

      return predictions;
    } catch (error) {
      logger.error('Error getting harvest predictions:', error);
      throw error;
    }
  }

  /**
   * Private helper methods
   */
  private calculateAverageConditions(readings: any[]): any {
    if (readings.length === 0) return {};

    const totals = readings.reduce((acc, reading) => {
      if (reading.data.temperature) acc.temperature += reading.data.temperature;
      if (reading.data.humidity) acc.humidity += reading.data.humidity;
      if (reading.data.soilMoisture) acc.soilMoisture += reading.data.soilMoisture;
      if (reading.data.pH) acc.pH += reading.data.pH;
      return acc;
    }, { temperature: 0, humidity: 0, soilMoisture: 0, pH: 0 });

    const counts = readings.reduce((acc, reading) => {
      if (reading.data.temperature) acc.temperature++;
      if (reading.data.humidity) acc.humidity++;
      if (reading.data.soilMoisture) acc.soilMoisture++;
      if (reading.data.pH) acc.pH++;
      return acc;
    }, { temperature: 0, humidity: 0, soilMoisture: 0, pH: 0 });

    return {
      temperature: counts.temperature ? totals.temperature / counts.temperature : undefined,
      humidity: counts.humidity ? totals.humidity / counts.humidity : undefined,
      soilMoisture: counts.soilMoisture ? totals.soilMoisture / counts.soilMoisture : undefined,
      pH: counts.pH ? totals.pH / counts.pH : undefined,
    };
  }

  private calculateAlertStatistics(readings: any[]): any {
    const alerts = readings.flatMap(r => r.alerts || []);
    const unacknowledged = alerts.filter(a => !a.acknowledged);
    
    const bySeverity = alerts.reduce((acc, alert) => {
      acc[alert.severity] = (acc[alert.severity] || 0) + 1;
      return acc;
    }, {});

    return {
      total: alerts.length,
      unacknowledged: unacknowledged.length,
      bySeverity,
    };
  }

  private calculateDataQuality(readings: any[]): any {
    const qualityCounts = readings.reduce((acc, reading) => {
      const quality = reading.metadata?.quality || 'unknown';
      acc[quality] = (acc[quality] || 0) + 1;
      return acc;
    }, {});

    return {
      good: qualityCounts.good || 0,
      fair: qualityCounts.fair || 0,
      poor: qualityCounts.poor || 0,
      error: qualityCounts.error || 0,
    };
  }

  private calculateYieldPrediction(farm: any, readings: any[]): any {
    // Simplified yield prediction based on environmental conditions
    const avgConditions = this.calculateAverageConditions(readings);
    
    let yieldScore = 100; // Start with 100%
    
    // Adjust based on temperature (optimal range: 20-30°C for corn)
    if (avgConditions.temperature) {
      if (avgConditions.temperature < 15 || avgConditions.temperature > 35) {
        yieldScore -= 20;
      } else if (avgConditions.temperature < 20 || avgConditions.temperature > 30) {
        yieldScore -= 10;
      }
    }
    
    // Adjust based on soil moisture (optimal: 50-70%)
    if (avgConditions.soilMoisture) {
      if (avgConditions.soilMoisture < 30 || avgConditions.soilMoisture > 80) {
        yieldScore -= 15;
      } else if (avgConditions.soilMoisture < 40 || avgConditions.soilMoisture > 75) {
        yieldScore -= 8;
      }
    }

    return {
      estimatedYieldPercentage: Math.max(yieldScore, 0),
      confidence: readings.length > 100 ? 'high' : readings.length > 50 ? 'medium' : 'low',
    };
  }

  private calculateHarvestReadiness(farm: any, readings: any[]): any {
    if (!farm.plantingDate || !farm.expectedHarvestDate) {
      return { readiness: 'unknown', daysRemaining: null };
    }

    const now = new Date();
    const daysRemaining = Math.ceil((farm.expectedHarvestDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
    
    let readiness = 'not_ready';
    if (daysRemaining <= 0) readiness = 'ready';
    else if (daysRemaining <= 7) readiness = 'almost_ready';
    else if (daysRemaining <= 30) readiness = 'approaching';

    return {
      readiness,
      daysRemaining: Math.max(daysRemaining, 0),
      plantingAge: farm.ageInDays,
    };
  }

  private identifyRiskFactors(readings: any[]): string[] {
    const risks = [];
    const avgConditions = this.calculateAverageConditions(readings);

    if (avgConditions.temperature && avgConditions.temperature > 35) {
      risks.push('High temperature stress');
    }
    if (avgConditions.soilMoisture && avgConditions.soilMoisture < 30) {
      risks.push('Low soil moisture - drought risk');
    }
    if (avgConditions.pH && (avgConditions.pH < 5.5 || avgConditions.pH > 8.0)) {
      risks.push('Suboptimal soil pH levels');
    }

    return risks;
  }

  private generateRecommendations(farm: any, readings: any[]): string[] {
    const recommendations = [];
    const avgConditions = this.calculateAverageConditions(readings);

    if (avgConditions.soilMoisture && avgConditions.soilMoisture < 40) {
      recommendations.push('Increase irrigation frequency');
    }
    if (avgConditions.pH && avgConditions.pH < 6.0) {
      recommendations.push('Consider lime application to raise soil pH');
    }
    if (avgConditions.temperature && avgConditions.temperature > 32) {
      recommendations.push('Provide shade or increase irrigation during hot periods');
    }

    return recommendations;
  }
}

export default new FarmService();

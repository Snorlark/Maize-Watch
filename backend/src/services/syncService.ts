import thingSpeakService from './thingspeakService';
import sensorService from './sensorService';
import farmService from './farmService';
import { logger } from '../utils/logger';
import mongoose from 'mongoose';

class SyncService {
  /**
   * Sync ThingSpeak data to MongoDB for all farms
   */
  async syncAllFarmsData(): Promise<void> {
    try {
      logger.info('Starting sync of ThingSpeak data for all farms...');
      
      // Get all farms
      const farms = await farmService.getFarmsByOwner('');
      
      for (const farm of farms) {
        try {
          await this.syncFarmData((farm as any)._id.toString());
        } catch (error) {
          logger.error(`Failed to sync data for farm ${farm.farmName}:`, error);
        }
      }
      
      logger.info('Sync completed for all farms');
    } catch (error) {
      logger.error('Error syncing all farms data:', error);
      throw error;
    }
  }

  /**
   * Sync ThingSpeak data to MongoDB for a specific farm
   */
  async syncFarmData(farmId: string): Promise<void> {
    try {
      const farm = await farmService.getFarmById(farmId);
      if (!farm) {
        throw new Error(`Farm ${farmId} not found`);
      }

      // Get latest data from ThingSpeak
      const thingSpeakData = await thingSpeakService.getLatestData();
      
      if (!thingSpeakData) {
        logger.warn(`No ThingSpeak data available for farm ${farmId}`);
        return;
      }

      // Update sensor readings for each field's sensors
      let totalSensors = 0;
      for (const field of farm.fields) {
        for (const sensor of field.sensors) {
          totalSensors++;
          
          // Update the sensor readings in the Farm model
          sensor.readings = {
            soilMoisture: thingSpeakData.soilMoisture,
            temperature: thingSpeakData.temperature,
            humidity: thingSpeakData.humidity,
            lightIntensity: thingSpeakData.lightIntensity,
            soilPh: thingSpeakData.soilPh
          };
        }
      }

      // Save the updated farm
      await farm.save();

      // Also record readings in the SensorReading collection for analytics
      for (const field of farm.fields) {
        for (const sensor of field.sensors) {
          try {
            // Create a sensor reading directly in the SensorReading collection
            const SensorReading = require('../models/SensorReading').default;
            const sensorReading = new SensorReading({
              sensor: new mongoose.Types.ObjectId(), // Generate a new ObjectId for the sensor
              farm: new mongoose.Types.ObjectId(farmId),
              timestamp: new Date(),
                data: {
                  temperature: thingSpeakData.temperature,
                  humidity: thingSpeakData.humidity,
                  soilMoisture: thingSpeakData.soilMoisture,
                  pH: Math.min(Math.max(thingSpeakData.soilPh, 0), 14), // Clamp pH between 0-14
                  lightIntensity: thingSpeakData.lightIntensity,
                  batteryLevel: 0, // Battery level
                  signalStrength: 0, // Signal strength
                },
              metadata: {
                source: 'thingspeak',
                quality: 'good',
                processed: false,
                anomaly: false,
                calibrated: true
              }
            });
            
            await sensorReading.save();
            logger.info(`Recorded sensor reading for device ${sensor.deviceID} in field ${field.fieldName}`);
          } catch (error) {
            logger.warn(`Could not record reading for sensor ${sensor.deviceID}:`, error);
          }
        }
      }

      logger.info(`Successfully synced ThingSpeak data for farm ${farm.farmName} (${totalSensors} sensors updated)`);
    } catch (error) {
      logger.error(`Error syncing farm data for ${farmId}:`, error);
      throw error;
    }
  }

  /**
   * Sync historical data from ThingSpeak
   */
  async syncHistoricalData(farmId: string, days: number = 7): Promise<void> {
    try {
      const farm = await farmService.getFarmById(farmId);
      if (!farm) {
        throw new Error(`Farm ${farmId} not found`);
      }

      // Get historical data from ThingSpeak
      const historicalData = await thingSpeakService.getHistoricalData(days * 24 * 60); // Convert days to minutes
      
      if (!historicalData || historicalData.length === 0) {
        logger.warn(`No historical data available for farm ${farmId}`);
        return;
      }

      // Save historical data for each field's sensors
      let totalDataPoints = 0;
      for (const field of farm.fields) {
        for (const sensor of field.sensors) {
          for (const dataPoint of historicalData) {
            try {
              // Create a sensor reading directly in the SensorReading collection
              const SensorReading = require('../models/SensorReading').default;
              const sensorReading = new SensorReading({
                sensor: new mongoose.Types.ObjectId(), // Generate a new ObjectId for the sensor
                farm: new mongoose.Types.ObjectId(farmId),
                timestamp: dataPoint.timestamp,
                data: {
                  temperature: dataPoint.temperature,
                  humidity: dataPoint.humidity,
                  soilMoisture: dataPoint.soilMoisture,
                  pH: Math.min(Math.max(dataPoint.soilPh, 0), 14), // Clamp pH between 0-14
                  lightIntensity: dataPoint.lightIntensity,
                  batteryLevel: 0, // Battery level
                  signalStrength: 0, // Signal strength
                },
                metadata: {
                  source: 'thingspeak',
                  quality: 'good',
                  processed: false,
                  anomaly: false,
                  calibrated: true
                }
              });
              
              await sensorReading.save();
              totalDataPoints++;
            } catch (error) {
              logger.warn(`Could not record historical reading for sensor ${sensor.deviceID}:`, error);
            }
          }
        }
      }

      logger.info(`Successfully synced ${totalDataPoints} historical data points for farm ${farm.farmName}`);
    } catch (error) {
      logger.error(`Error syncing historical data for ${farmId}:`, error);
      throw error;
    }
  }

  /**
   * Get sensor data for analytics
   */
  async getSensorDataForAnalytics(farmId: string, fieldId?: string): Promise<any> {
    try {
      const farm = await farmService.getFarmById(farmId);
      if (!farm) {
        throw new Error(`Farm ${farmId} not found`);
      }

      // Get latest sensor readings
      const latestReadings = await sensorService.getLatestReadingsByFarm(farmId);
      
      if (!latestReadings || latestReadings.length === 0) {
        // Fallback to ThingSpeak data
        const thingSpeakData = await thingSpeakService.getLatestData();
        if (thingSpeakData) {
          return {
            temperature: thingSpeakData.temperature,
            humidity: thingSpeakData.humidity,
            soilMoisture: thingSpeakData.soilMoisture,
            soilPh: thingSpeakData.soilPh,
            lightIntensity: thingSpeakData.lightIntensity,
            timestamp: thingSpeakData.timestamp
          };
        }
        return null;
      }

      // Calculate averages from latest readings
      const readings = latestReadings.map(r => r.data);
      return {
        temperature: readings.reduce((sum, r) => sum + (r.temperature || 0), 0) / readings.length,
        humidity: readings.reduce((sum, r) => sum + (r.humidity || 0), 0) / readings.length,
        soilMoisture: readings.reduce((sum, r) => sum + (r.soilMoisture || 0), 0) / readings.length,
        soilPh: readings.reduce((sum, r) => sum + (r.pH || 0), 0) / readings.length,
        lightIntensity: readings.reduce((sum, r) => sum + (r.lightIntensity || 0), 0) / readings.length,
        timestamp: latestReadings[0].timestamp
      };
    } catch (error) {
      logger.error(`Error getting sensor data for analytics ${farmId}:`, error);
      throw error;
    }
  }
}

export default new SyncService();

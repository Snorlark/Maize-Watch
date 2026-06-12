import thingSpeakService from './thingspeakService';
import sensorService from './sensorService';
import farmService from './farmService';
import { logger } from '../utils/logger';
import mongoose from 'mongoose';

export class SyncService {
  /**
   * Sync ThingSpeak data to MongoDB for all farms
   */
  async syncAllFarmsData(): Promise<void> {
    try {
      logger.debug('Starting sync of ThingSpeak data for all farms...');
      
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
      logger.debug(`Starting sync for farm ${farmId}`);
      const farm = await farmService.getFarmById(farmId);
      if (!farm) {
        throw new Error(`Farm ${farmId} not found`);
      }

      logger.debug(`Found farm: ${farm.farmName} for user: ${farm.userId}`);

      // Get prototype data for this farm
      const Prototype = require('../models/Prototype').default;
      const prototypes = await Prototype.find({ registeredBy: farm.userId });
      logger.debug(`Found ${prototypes.length} prototypes for user ${farm.userId}`);

      if (!prototypes || prototypes.length === 0) {
        logger.debug(`No prototypes found for farm ${farmId}`);
        return;
      }

      // Update sensor readings for each field's sensors using prototype data
      let totalSensors = 0;
      for (const field of farm.fields) {
        for (const sensor of field.sensors) {
          totalSensors++;

          logger.debug(`Processing sensor: ${sensor.deviceID}, prototypeId: ${sensor.prototypeId}`);
          logger.debug(`Available prototypes: ${prototypes.map((p: any) => p.prototype_id).join(', ')}`);

          // Find the prototype for this sensor (assuming sensor has prototypeId)
          const prototype = prototypes.find((p: any) => p.prototype_id === sensor.prototypeId);
          if (!prototype) {
            logger.debug(`No prototype found for sensor ${(sensor as any)._id} with prototypeId ${sensor.prototypeId}`);
            continue;
          }

          // Get data from the specific prototype's channel
          logger.debug(`Fetching data for prototype ${prototype.prototype_id} with channel ${prototype.channel_id}`);
          const thingSpeakData = await thingSpeakService.getLatestData(prototype.channel_id, prototype.api_key);
          logger.debug(`Received ThingSpeak data: ${JSON.stringify(thingSpeakData)}`);
          
          if (!thingSpeakData) {
            logger.warn(`No ThingSpeak data available for prototype ${prototype.prototype_id} (channel ${prototype.channel_id})`);
            continue;
          }
          
          // Update the sensor readings in the Farm model
          sensor.readings = {
            soilMoisture: thingSpeakData.soilMoisture,
            temperature: thingSpeakData.temperature,
            humidity: thingSpeakData.humidity,
            lightIntensity: thingSpeakData.lightIntensity,
            soilPh: thingSpeakData.soilPh
          };

          // Record reading in SensorReading collection for analytics
          // Use the embedded sensor's _id directly — sensors are embedded in Farm, not a separate Sensor model
          try {
            const SensorReading = require('../models/SensorReading').default;
            const sensorReading = new SensorReading({
              sensor: (sensor as any)._id,
              farm: farm._id,
              field_id: field.fieldName,
              timestamp: new Date(),
              data: {
                temperature: thingSpeakData.temperature,
                humidity: thingSpeakData.humidity,
                soilMoisture: thingSpeakData.soilMoisture,
                pH: thingSpeakData.soilPh,
                lightIntensity: thingSpeakData.lightIntensity
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
            logger.debug(`Recorded sensor reading for prototype ${prototype.prototype_id} in field ${field.fieldName}`);
          } catch (error) {
            logger.warn(`Could not record reading for prototype ${prototype.prototype_id}:`, error);
          }
        }
      }

      // Save the updated farm
      await farm.save();

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
   * Get sensor data for analytics - returns field-specific data instead of averages
   */
  async getSensorDataForAnalytics(farmId: string, fieldId?: string): Promise<any> {
    try {
      const farm = await farmService.getFarmById(farmId);
      if (!farm) {
        throw new Error(`Farm ${farmId} not found`);
      }

      // Get all prototypes registered by this farm's user
      const Prototype = require('../models/Prototype').default;
      const prototypes = await Prototype.find({ registeredBy: farm.userId });
      
      if (!prototypes || prototypes.length === 0) {
        logger.warn(`No prototypes found for farm ${farmId}`);
        return null;
      }

      // Get field-specific sensor data from IoT database
      const fieldData: { [fieldName: string]: any } = {};
      
      for (const field of farm.fields) {
        for (const sensor of field.sensors) {
          if (sensor.prototypeId) {
            // Find the prototype for this sensor
            const prototype = prototypes.find((p: any) => p.prototype_id === sensor.prototypeId);
            if (prototype) {
              // Connect to IoT database to get the latest reading for this prototype
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
                fieldData[field.fieldName] = {
                  temperature: reading.temperature,
                  humidity: reading.humidity,
                  soilMoisture: reading.soilMoisture,
                  soilPh: reading.soilPh,
                  lightIntensity: reading.lightIntensity,
                  timestamp: reading.timestamp
                };
                logger.info(`Field ${field.fieldName} data: temp=${reading.temperature}°C, humidity=${reading.humidity}%, soilMoisture=${reading.soilMoisture}%, soilPh=${reading.soilPh}, lightIntensity=${reading.lightIntensity} lux`);
              }
              
              await iotConnection.close();
            }
          }
        }
      }

      // If specific field requested, return that field's data
      if (fieldId && fieldData[fieldId]) {
        return fieldData[fieldId];
      }

      // Return all field data
      return fieldData;
    } catch (error) {
      logger.error(`Error getting sensor data for analytics ${farmId}:`, error);
      throw error;
    }
  }
}

export default new SyncService();

import axios from 'axios';
import mongoose from 'mongoose';
import { logger } from '../utils/logger';

// ThingSpeak configuration
const THINGSPEAK_CHANNEL_ID = process.env.THINGSPEAK_CHANNEL_ID;
const THINGSPEAK_READ_API_KEY = process.env.THINGSPEAK_READ_API_KEY;
const THINGSPEAK_WRITE_API_KEY = process.env.THINGSPEAK_WRITE_API_KEY;

// Create connection to IOT database
const iotConnection = mongoose.createConnection(process.env.MONGODB_IOT_URI || 'mongodb://localhost:27017/iot_data');

// Define the sensor data schema
const sensorDataSchema = new mongoose.Schema({
  timestamp: { type: Date, required: true, index: true },
  farm: { type: mongoose.Schema.Types.ObjectId, required: true, ref: 'Farm' },
  field_id: { type: String, required: true },
  data: {
    temperature: { type: Number, required: true },
    humidity: { type: Number, required: true },
    soilMoisture: { type: Number, required: true },
    soilPh: { type: Number, required: true },
    lightIntensity: { type: Number, required: true }
  }
});

// Create the model with the correct collection name
const SensorData = iotConnection.model('SensorData', sensorDataSchema, 'sensor_readings');

class ThingSpeakService {
  private channelId: string;
  private writeApiKey: string;
  private readApiKey: string;
  private baseUrl: string;

  constructor() {
    this.channelId = THINGSPEAK_CHANNEL_ID!;
    this.writeApiKey = THINGSPEAK_WRITE_API_KEY!;
    this.readApiKey = THINGSPEAK_READ_API_KEY!;
    this.baseUrl = 'https://api.thingspeak.com';
    
    logger.info(`ThingSpeak service initialized with channel ID: ${this.channelId}`);
  }

  /**
   * Fetches the latest data entry from a specific ThingSpeak channel
   */
  async fetchLatestDataFromThingSpeakChannel(channelId: string) {
    try {
      logger.info(`Fetching latest data from ThingSpeak channel ${channelId}...`);
      
      const response = await axios.get(`${this.baseUrl}/channels/${channelId}/feeds.json`, {
        params: {
          api_key: this.readApiKey,
          results: 1
        },
        timeout: 10000
      });

      if (response.data && response.data.feeds && response.data.feeds.length > 0) {
        const latestFeed = response.data.feeds[0];
        
        // Parse all values with fallbacks for missing data
        const temperature = this.parseFieldValue(latestFeed.field1);
        const humidity = this.parseFieldValue(latestFeed.field2);
        const rawSoilMoisture = this.parseFieldValue(latestFeed.field3);
        const soil_moisture = this.convertSoilMoistureToPercentage(rawSoilMoisture);
        const soil_ph = this.parseFieldValue(latestFeed.field4);
        const light_intensity = this.parseFieldValue(latestFeed.field5);
        
        return {
          timestamp: new Date(latestFeed.created_at),
          temperature,
          humidity,
          soilMoisture: soil_moisture,
          soilPh: soil_ph,
          lightIntensity: light_intensity
        };
      }
      
      return null;
    } catch (error: any) {
      logger.error(`Error fetching data from ThingSpeak channel ${channelId}:`, error.message);
      throw error;
    }
  }

  /**
   * Fetches the latest data entry from ThingSpeak using feeds.json (private channel)
   */
  async fetchLatestDataFromThingSpeak() {
    try {
      logger.info('Fetching latest data from ThingSpeak...');
      
      const response = await axios.get(`${this.baseUrl}/channels/${this.channelId}/feeds.json`, {
        params: {
          api_key: this.readApiKey,
          results: 1
        },
        timeout: 10000
      });
      
      const latestData = response.data?.feeds && response.data.feeds.length > 0
        ? response.data.feeds[0]
        : null;
      
      if (!latestData || !this.isValidFeed(latestData)) {
        logger.warn('No valid data received from ThingSpeak');
        return null;
      }
      
      logger.info('Successfully fetched latest data from ThingSpeak');
      return latestData;
    } catch (error: any) {
      const status = error?.response?.status;
      const data = error?.response?.data;
      logger.error('Error fetching latest data from ThingSpeak:', {
        message: error.message,
        status,
        data
      });
      // Do not hard-fail on fetch errors; return null so callers can fallback to MongoDB data
      return null;
    }
  }

  /**
   * Fetch channel info to discover creation date and last entry
   */
  private async fetchChannelInfo() {
    try {
      const response = await axios.get(`${this.baseUrl}/channels/${this.channelId}.json`, {
        params: {
          api_key: this.readApiKey
        },
        timeout: 10000
      });
      return response.data?.channel;
    } catch (error: any) {
      logger.warn('Failed to fetch channel info from ThingSpeak', { message: error.message });
      return null;
    }
  }

  /**
   * Fetch feeds within a date range (inclusive). Uses private READ api_key.
   */
  private async fetchFeedsRange(startISO: string, endISO: string) {
    try {
      const response = await axios.get(`${this.baseUrl}/channels/${this.channelId}/feeds.json`, {
        params: {
          api_key: this.readApiKey,
          start: startISO,
          end: endISO,
          timezone: 'Asia/Manila'
        },
        timeout: 15000
      });
      return Array.isArray(response.data?.feeds) ? response.data.feeds : [];
    } catch (error: any) {
      logger.warn('Failed to fetch feeds for range', { message: error.message, startISO, endISO });
      return [];
    }
  }

  /**
   * Backfill all data from channel creation to latest entry by chunking dates
   */
  private async backfillAllDataFromThingSpeak() {
    let savedCount = 0;

    // Try to get channel created_at; if it fails, fall back to rolling windows
    const channel = await this.fetchChannelInfo();
    let startDate: Date | null = null;
    if (channel?.created_at) {
      startDate = new Date(channel.created_at);
    }

    const endDate = new Date();
    const chunkMs = 7 * 24 * 60 * 60 * 1000; // 7-day chunks

    if (startDate) {
      // Known start → iterate forward to now
      for (let windowStart = startDate.getTime(); windowStart < endDate.getTime(); windowStart += chunkMs) {
        const windowEnd = Math.min(windowStart + chunkMs - 1, endDate.getTime());
        const startISO = new Date(windowStart).toISOString();
        const endISO = new Date(windowEnd).toISOString();

        const feeds = await this.fetchFeedsRange(startISO, endISO);
        savedCount += await this.saveFeeds(feeds);
      }
    } else {
      // Unknown start → roll back in windows until no new data found for 3 consecutive windows or 5 years
      let windowEnd = endDate.getTime();
      let noNewDataWindows = 0;
      const fiveYearsMs = 5 * 365 * 24 * 60 * 60 * 1000;
      const lowerBound = endDate.getTime() - fiveYearsMs;

      while (windowEnd > lowerBound && noNewDataWindows < 3) {
        const windowStart = windowEnd - chunkMs + 1;
        const startISO = new Date(windowStart).toISOString();
        const endISO = new Date(windowEnd).toISOString();

        const feeds = await this.fetchFeedsRange(startISO, endISO);
        const before = savedCount;
        savedCount += await this.saveFeeds(feeds);
        noNewDataWindows = (savedCount === before) ? noNewDataWindows + 1 : 0;
        windowEnd = windowStart - 1;
      }
    }

    logger.info(`Backfill completed. Saved ${savedCount} new records from ThingSpeak.`);
    return savedCount;
  }

  private async saveFeeds(feeds: any[]): Promise<number> {
    if (!feeds || feeds.length === 0) return 0;
    let saved = 0;
    for (const feed of feeds) {
      if (!this.isValidFeed(feed)) continue;
      const feedTimestamp = new Date(feed.created_at);
      const manilaTimestamp = new Date(feedTimestamp.getTime() + (8 * 60 * 60 * 1000));

      const existingData = await SensorData.findOne({ timestamp: manilaTimestamp });
      if (existingData) continue;

      const temperature = this.parseFieldValue(feed.field1);
      const humidity = this.parseFieldValue(feed.field2);
      const rawSoilMoisture = this.parseFieldValue(feed.field3);
      const soil_moisture = this.convertSoilMoistureToPercentage(rawSoilMoisture);
      const soil_ph = this.parseFieldValue(feed.field4);
      const light_intensity = this.parseFieldValue(feed.field5);

      const sensorData = new SensorData({
        timestamp: manilaTimestamp,
        farm: new mongoose.Types.ObjectId('68d58aff35083cdabb3a7e26'), // Use actual farm ID
        field_id: '124', // Use actual field ID
        data: { 
          temperature, 
          humidity, 
          soilMoisture: soil_moisture, 
          soilPh: soil_ph, 
          lightIntensity: light_intensity 
        }
      });
      await sensorData.save();
      saved += 1;
    }
    return saved;
  }

  /**
   * Public backfill method to populate MongoDB from channel creation to latest
   */
  async backfillAll() {
    try {
      const saved = await this.backfillAllDataFromThingSpeak();
      return saved;
    } catch (error: any) {
      logger.error('Backfill failed', { message: error.message });
      throw error;
    }
  }

  /**
   * Syncs the latest data from ThingSpeak to MongoDB
   */
  async syncLatestDataFromThingSpeak() {
    try {
      logger.info('Starting ThingSpeak latest data sync...');
      
      const latestData = await this.fetchLatestDataFromThingSpeak();
      
      if (!latestData) {
        logger.warn('No latest data available from ThingSpeak');
        return false;
      }
      
      // Check if this data point already exists in our database by timestamp
      const feedTimestamp = new Date(latestData.created_at);
      const manilaTimestamp = new Date(feedTimestamp.getTime() + (8 * 60 * 60 * 1000));
      
      const existingData = await SensorData.findOne({
        timestamp: manilaTimestamp
      });
      
      if (existingData) {
        logger.info('Latest data already exists in MongoDB for timestamp:', manilaTimestamp);
        return false;
      }
      
      // Parse all values with fallbacks for missing data
      const temperature = this.parseFieldValue(latestData.field1);
      const humidity = this.parseFieldValue(latestData.field2);
      const rawSoilMoisture = this.parseFieldValue(latestData.field3);
      const soil_moisture = this.convertSoilMoistureToPercentage(rawSoilMoisture);
      const soil_ph = this.parseFieldValue(latestData.field4);
      const light_intensity = this.parseFieldValue(latestData.field5);
      
      // Save new data to MongoDB with Manila time
      const sensorData = new SensorData({
        timestamp: manilaTimestamp,
        farm: new mongoose.Types.ObjectId('68d58aff35083cdabb3a7e26'), // Use actual farm ID
        field_id: '124', // Use actual field ID
        data: {
          temperature,
          humidity,
          soilMoisture: soil_moisture,
          soilPh: soil_ph,
          lightIntensity: light_intensity
        }
      });

      await sensorData.save();
      
      logger.info('Latest data saved to MongoDB:', {
        timestamp: sensorData.timestamp,
        temperature: sensorData.data?.temperature,
        humidity: sensorData.data?.humidity,
        soilMoisture: sensorData.data?.soilMoisture,
        soilPh: sensorData.data?.soilPh,
        lightIntensity: sensorData.data?.lightIntensity
      });
      
      return true;
    } catch (error: any) {
      const status = error?.response?.status;
      const data = error?.response?.data;
      logger.error('Error syncing latest data from ThingSpeak:', {
        message: error.message,
        status,
        data
      });
      // Do not throw so consumers can still read existing MongoDB data
      return false;
    }
  }

  /**
   * Gets the latest sensor data from MongoDB
   */
  async getLatestData(channelId?: string) {
    try {
      // If a specific channel ID is provided, try to get data from that channel
      if (channelId) {
        try {
          const channelData = await this.fetchLatestDataFromThingSpeakChannel(channelId);
          if (channelData) {
            return channelData;
          }
        } catch (error) {
          logger.warn(`Failed to fetch data from channel ${channelId}:`, error);
        }
      }
      
      // Try to sync latest data, but ignore failures
      try {
        await this.syncLatestDataFromThingSpeak();
      } catch (_) {}
      
      // Then get the latest data from MongoDB
      const mongoData = await SensorData.findOne().sort({ timestamp: -1 });
      
      if (!mongoData) {
        throw new Error('No sensor data available in database');
      }

      return {
        timestamp: mongoData.timestamp,
        temperature: mongoData.data?.temperature || 0,
        humidity: mongoData.data?.humidity || 0,
        soilMoisture: mongoData.data?.soilMoisture || 0,
        soilPh: mongoData.data?.soilPh || 0,
        lightIntensity: mongoData.data?.lightIntensity || 0
      };
    } catch (error: any) {
      logger.error('Error fetching latest data:', error.message);
      throw error;
    }
  }

  /**
   * Gets historical data for a specified time range
   */
  async getHistoricalData(minutes = 60, channelId?: string, startDate = null, endDate = null) {
    try {
      // If a specific channel ID is provided, try to get data from that channel
      if (channelId) {
        try {
          const channelData = await this.fetchHistoricalDataFromThingSpeakChannel(channelId, minutes, startDate, endDate);
          if (channelData && channelData.length > 0) {
            return channelData;
          }
        } catch (error) {
          logger.warn(`Failed to fetch historical data from channel ${channelId}:`, error);
        }
      }
      
      // Try to sync or backfill if needed, but ignore failures
      try {
        const count = await SensorData.estimatedDocumentCount();
        if (count === 0) {
          await this.backfillAllDataFromThingSpeak();
        } else {
          await this.syncLatestDataFromThingSpeak();
        }
      } catch (_) {}
      
      let query = {};
      
      if (startDate && endDate) {
        query = {
          timestamp: {
            $gte: new Date(startDate),
            $lte: new Date(endDate)
          }
        };
      } else {
        const validMinutes = isNaN(minutes) || minutes <= 0 ? 60 : minutes;
        query = {
          timestamp: {
            $gte: new Date(Date.now() - validMinutes * 60 * 1000)
          }
        };
      }

      const mongoData = await SensorData.find(query).sort({ timestamp: 1 });

      if (!mongoData || mongoData.length === 0) {
        logger.info('No historical data found for the specified range');
        return [];
      }

      return mongoData.map(data => ({
        timestamp: data.timestamp,
        temperature: data.data?.temperature || 0,
        humidity: data.data?.humidity || 0,
        soilMoisture: data.data?.soilMoisture || 0,
        soilPh: data.data?.soilPh || 0,
        lightIntensity: data.data?.lightIntensity || 0
      }));
    } catch (error: any) {
      logger.error('Error fetching historical data:', error.message);
      throw error;
    }
  }

  /**
   * Fetches historical data from a specific ThingSpeak channel
   */
  async fetchHistoricalDataFromThingSpeakChannel(channelId: string, minutes = 60, startDate = null, endDate = null) {
    try {
      logger.info(`Fetching historical data from ThingSpeak channel ${channelId}...`);
      
      let params: any = {
        api_key: this.readApiKey,
        results: 8000 // Maximum results per request
      };
      
      if (startDate && endDate) {
        params.start = new Date(startDate).toISOString();
        params.end = new Date(endDate).toISOString();
      } else {
        const validMinutes = isNaN(minutes) || minutes <= 0 ? 60 : minutes;
        const startTime = new Date(Date.now() - validMinutes * 60 * 1000);
        params.start = startTime.toISOString();
      }
      
      const response = await axios.get(`${this.baseUrl}/channels/${channelId}/feeds.json`, {
        params,
        timeout: 15000
      });

      if (response.data && response.data.feeds && response.data.feeds.length > 0) {
        return response.data.feeds.map((feed: any) => {
          // Parse all values with fallbacks for missing data
          const temperature = this.parseFieldValue(feed.field1);
          const humidity = this.parseFieldValue(feed.field2);
          const rawSoilMoisture = this.parseFieldValue(feed.field3);
          const soil_moisture = this.convertSoilMoistureToPercentage(rawSoilMoisture);
          const soil_ph = this.parseFieldValue(feed.field4);
          const light_intensity = this.parseFieldValue(feed.field5);
          
          return {
            timestamp: new Date(feed.created_at),
            temperature,
            humidity,
            soilMoisture: soil_moisture,
            soilPh: soil_ph,
            lightIntensity: light_intensity
          };
        });
      }
      
      return [];
    } catch (error: any) {
      logger.error(`Error fetching historical data from ThingSpeak channel ${channelId}:`, error.message);
      throw error;
    }
  }

  /**
   * Helper method to validate a ThingSpeak feed
   */
  private isValidFeed(feed: any) {
    return feed && 
           feed.created_at && 
           (feed.field1 !== undefined || 
            feed.field2 !== undefined || 
            feed.field3 !== undefined || 
            feed.field4 !== undefined || 
            feed.field5 !== undefined);
  }
  
  /**
   * Helper method to safely parse field values
   */
  private parseFieldValue(value: any) {
    if (value === undefined || value === null || value === '') {
      return 0;
    }
    
    const parsed = parseFloat(value);
    return isNaN(parsed) ? 0 : parsed;
  }

  /**
   * Converts raw soil moisture sensor values to percentage
   */
  private convertSoilMoistureToPercentage(rawValue: number) {
    if (rawValue === undefined || rawValue === null || isNaN(rawValue)) {
      return 0;
    }

    if (rawValue >= 0 && rawValue <= 100) {
      return rawValue;
    }

    let percentage;
    
    if (rawValue >= 0 && rawValue <= 1023) {
      percentage = ((1023 - rawValue) / 1023) * 100;
    } else if (rawValue >= 0 && rawValue <= 4095) {
      percentage = ((4095 - rawValue) / 4095) * 100;
    } else if (rawValue >= 0 && rawValue <= 65535) {
      percentage = ((65535 - rawValue) / 65535) * 100;
    } else {
      const maxReasonableValue = Math.max(rawValue, 1000);
      percentage = (rawValue / maxReasonableValue) * 100;
    }
    
    return Math.max(0, Math.min(100, percentage));
  }
}

export default new ThingSpeakService();

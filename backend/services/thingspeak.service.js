import axios from 'axios';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import cron from 'node-cron'; // Added cron for scheduling

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, '../../.env') });
// Verify we have the required environment variables
const MONGODB_IOT_URI = process.env.MONGODB_IOT_URI;
const THINGSPEAK_CHANNEL_ID = process.env.THINGSPEAK_CHANNEL_ID || '2965485';
const THINGSPEAK_READ_API_KEY = process.env.THINGSPEAK_READ_API_KEY || 'EQ3MYH5XBDSB6K2A';
const THINGSPEAK_WRITE_API_KEY = process.env.THINGSPEAK_WRITE_API_KEY || '9T78QG1NCJMGHFH3';
// Added configuration for automatic fetching
const FETCH_INTERVAL_SECONDS = process.env.FETCH_INTERVAL_SECONDS || 15;

if (!MONGODB_IOT_URI) {
  console.error('Missing MONGODB_IOT_URI environment variable');
  process.exit(1);
}

// Create connection to IOT database
const iotConnection = mongoose.createConnection(MONGODB_IOT_URI);

// Define the sensor data schema
const sensorDataSchema = new mongoose.Schema({
  timestamp: { type: Date, required: true, index: true },
  field_id: { type: String, required: true },
  measurements: {
    temperature: { type: Number, required: true },
    humidity: { type: Number, required: true },
    soil_moisture: { type: Number, required: true },
    soil_ph: { type: Number, required: true },
    light_intensity: { type: Number, required: true }
  }
});

// Create the model with the correct collection name
const SensorData = iotConnection.model('SensorData', sensorDataSchema, 'sensor_readings');

class ThingSpeakService {
  constructor() {
    this.channelId = THINGSPEAK_CHANNEL_ID;
    this.writeApiKey = THINGSPEAK_WRITE_API_KEY;
    this.readApiKey = THINGSPEAK_READ_API_KEY;
    this.baseUrl = 'https://api.thingspeak.com';
    
    console.log(`ThingSpeak service initialized with channel ID: ${this.channelId}`);
    
    // Initialize automatic fetching if enabled
    this.initializeAutoFetch();
  }

  /**
   * Initialize automatic data fetching
   */
  initializeAutoFetch() {
    console.log(`Setting up automatic ThingSpeak data fetch every ${FETCH_INTERVAL_SECONDS} seconds`);
    
    // Fetch immediately on startup
    this.syncLatestDataFromThingSpeak().then(result => {
      if (result) {
        console.log(`[${new Date().toISOString()}] Initial data fetch: Successfully saved new data to MongoDB`);
      } else {
        console.log(`[${new Date().toISOString()}] Initial data fetch: No new data to save`);
      }
    }).catch(error => {
      console.error(`[${new Date().toISOString()}] Error in initial data fetch:`, error.message);
    });
    
    // Schedule regular fetching using cron (every 15 seconds)
    cron.schedule(`*/15 * * * * *`, async () => {
      try {
        console.log(`[${new Date().toISOString()}] Running scheduled data fetch...`);
        const result = await this.syncLatestDataFromThingSpeak();
        
        if (result) {
          console.log(`[${new Date().toISOString()}] Successfully saved new data to MongoDB`);
        } else {
          console.log(`[${new Date().toISOString()}] No new data to save`);
        }
      } catch (error) {
        console.error(`[${new Date().toISOString()}] Error in scheduled data fetch:`, error.message);
      }
    });
  }

  /**
   * Fetches the latest data entry from ThingSpeak
   * @returns {Promise<Object|null>} The latest data entry or null if none found
   */
  async fetchLatestDataFromThingSpeak() {
    try {
      console.log('Fetching latest data from ThingSpeak...');
      
      // Get only the latest entry from ThingSpeak
      const response = await axios.get(`${this.baseUrl}/channels/${this.channelId}/feeds/last.json`, {
        params: {
          api_key: this.readApiKey
        },
        timeout: 10000 // Add timeout to prevent hanging requests
      });
      
      const latestData = response.data;
      
      if (!latestData || !this.isValidFeed(latestData)) {
        console.warn('No valid data received from ThingSpeak');
        return null;
      }
      
      console.log('Successfully fetched latest data from ThingSpeak');
      return latestData;
    } catch (error) {
      console.error('Error fetching latest data from ThingSpeak:', error.message);
      throw new Error(`Failed to fetch latest data from ThingSpeak: ${error.message}`);
    }
  }

  /**
   * Syncs the latest data from ThingSpeak to MongoDB
   * @returns {Promise<boolean>} Whether new data was saved
   */
  async syncLatestDataFromThingSpeak() {
    try {
      console.log('Starting ThingSpeak latest data sync...');
      
      // Fetch only the latest data entry
      const latestData = await this.fetchLatestDataFromThingSpeak();
      
      if (!latestData) {
        console.warn('No latest data available from ThingSpeak');
        return false;
      }
      
      // Check if this data point already exists in our database by timestamp
      const feedTimestamp = new Date(latestData.created_at);
      
      // Convert Zulu time to Asia/Manila time (UTC+8)
      const manilaTimestamp = new Date(feedTimestamp.getTime() + (8 * 60 * 60 * 1000));
      
      const existingData = await SensorData.findOne({
        timestamp: manilaTimestamp
      });
      
      if (existingData) {
        console.log('Latest data already exists in MongoDB for timestamp:', manilaTimestamp);
        return false;
      }
      
      // Parse all values with fallbacks for missing data
      const temperature = this.parseFieldValue(latestData.field1);
      const humidity = this.parseFieldValue(latestData.field2);
      const soil_moisture = this.parseFieldValue(latestData.field3);
      const soil_ph = this.parseFieldValue(latestData.field4);
      const light_intensity = this.parseFieldValue(latestData.field5);
      
      // Save new data to MongoDB with Manila time
      const sensorData = new SensorData({
        timestamp: manilaTimestamp,
        field_id: 'maize_field_1',
        measurements: {
          temperature,
          humidity,
          soil_moisture,
          soil_ph,
          light_intensity
        }
      });

      try {
        await sensorData.save();
        
        console.log('Latest data saved to MongoDB:', {
          timestamp: sensorData.timestamp,
          temperature: sensorData.measurements.temperature,
          humidity: sensorData.measurements.humidity,
          soil_moisture: sensorData.measurements.soil_moisture,
          soil_ph: sensorData.measurements.soil_ph,
          light_intensity: sensorData.measurements.light_intensity
        });
        
        return true;
      } catch (saveError) {
        console.error('Error saving latest sensor data:', saveError);
        return false;
      }
    } catch (error) {
      console.error('Error syncing latest data from ThingSpeak:', error.message);
      throw new Error(`Failed to sync latest data from ThingSpeak: ${error.message}`);
    }
  }
  
  /**
   * Syncs data from ThingSpeak to MongoDB (Legacy method - now ensures latest data is fetched first)
   * @returns {Promise<number>} Number of new records saved
   */
  async syncDataFromThingSpeak() {
    try {
      console.log('Starting ThingSpeak data sync...');
      
      // First, always ensure we have the latest data
      await this.syncLatestDataFromThingSpeak();
      
      // Then get additional historical data if needed
      const response = await axios.get(`${this.baseUrl}/channels/${this.channelId}/feeds.json`, {
        params: {
          api_key: this.readApiKey,
          results: 10  // Get the last 10 entries to ensure we have complete data
        },
        timeout: 10000 // Add timeout to prevent hanging requests
      });
      
      const thingSpeakData = response.data;
      
      if (!thingSpeakData || !thingSpeakData.feeds || thingSpeakData.feeds.length === 0) {
        console.warn('No data received from ThingSpeak');
        return 0;
      }
      
      console.log(`Received ${thingSpeakData.feeds.length} records from ThingSpeak`);
      
      // Process the feeds (newest last to maintain chronological order)
      const feeds = thingSpeakData.feeds;
      let savedCount = 0;
      
      for (const feed of feeds) {
        // More robust validation of feed data
        if (!this.isValidFeed(feed)) {
          console.log('Skipping incomplete feed:', feed);
          continue;
        }
        
        // Check if this data point already exists in our database by timestamp
        const feedTimestamp = new Date(feed.created_at);
        const existingData = await SensorData.findOne({
          timestamp: feedTimestamp
        });
        
        if (existingData) {
          // console.log('Data already exists for timestamp:', feedTimestamp);
          continue;
        }
        
        // Parse all values with fallbacks for missing data
        const temperature = this.parseFieldValue(feed.field1);
        const humidity = this.parseFieldValue(feed.field2);
        const soil_moisture = this.parseFieldValue(feed.field3);
        const soil_ph = this.parseFieldValue(feed.field4);
        const light_intensity = this.parseFieldValue(feed.field5);
        
        // Save new data to MongoDB
        const sensorData = new SensorData({
          timestamp: feedTimestamp,
          field_id: 'maize_field_1',
          measurements: {
            temperature,
            humidity,
            soil_moisture,
            soil_ph,
            light_intensity
          }
        });

        try {
          await sensorData.save();
          savedCount++;
          
          console.log('Data saved to MongoDB:', {
            timestamp: sensorData.timestamp,
            temperature: sensorData.measurements.temperature,
            humidity: sensorData.measurements.humidity,
            soil_moisture: sensorData.measurements.soil_moisture,
            soil_ph: sensorData.measurements.soil_ph,
            light_intensity: sensorData.measurements.light_intensity
          });
        } catch (saveError) {
          console.error('Error saving sensor data:', saveError);
        }
      }
      
      console.log(`ThingSpeak sync complete. Saved ${savedCount} new data points.`);
      return savedCount;
    } catch (error) {
      console.error('Error syncing data from ThingSpeak:', error.message);
      throw new Error(`Failed to sync data from ThingSpeak: ${error.message}`);
    }
  }

  /**
   * Helper method to validate a ThingSpeak feed
   */
  isValidFeed(feed) {
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
  parseFieldValue(value) {
    if (value === undefined || value === null || value === '') {
      return 0; // Default value for missing data
    }
    
    const parsed = parseFloat(value);
    return isNaN(parsed) ? 0 : parsed;
  }

  /**
   * Gets the latest sensor data from MongoDB
   */
  async getLatestData() {
    try {
      // Always fetch and sync the latest data from ThingSpeak first
      await this.syncLatestDataFromThingSpeak();
      
      // Then get the latest data from MongoDB
      const mongoData = await SensorData.findOne().sort({ timestamp: -1 });
      
      if (!mongoData) {
        throw new Error('No sensor data available in database');
      }

      return {
        timestamp: mongoData.timestamp,
        temperature: mongoData.measurements.temperature,
        humidity: mongoData.measurements.humidity,
        soilMoisture: mongoData.measurements.soil_moisture,
        soilPh: mongoData.measurements.soil_ph,
        lightIntensity: mongoData.measurements.light_intensity
      };
    } catch (error) {
      console.error('Error fetching latest data:', error.message);
      throw error;
    }
  }

  /**
   * Gets historical data for a specified time range
   */
  async getHistoricalData(minutes = 60) {
    try {
      // Always sync latest data first
      await this.syncLatestDataFromThingSpeak();
      
      // Ensure minutes is a valid number
      const validMinutes = isNaN(minutes) || minutes <= 0 ? 60 : minutes;
      
      // Get data from MongoDB
      const mongoData = await SensorData.find({
        timestamp: {
          $gte: new Date(Date.now() - validMinutes * 60 * 1000)
        }
      }).sort({ timestamp: 1 }); // Sort by ascending time for charts

      if (!mongoData || mongoData.length === 0) {
        console.log(`No historical data found for the past ${validMinutes} minutes`);
        return [];
      }

      return mongoData.map(data => ({
        timestamp: data.timestamp,
        temperature: data.measurements.temperature,
        humidity: data.measurements.humidity,
        soilMoisture: data.measurements.soil_moisture,
        soilPh: data.measurements.soil_ph,
        lightIntensity: data.measurements.light_intensity
      }));
    } catch (error) {
      console.error('Error fetching historical data:', error.message);
      throw error;
    }
  }
  
  /**
   * Method to fetch data for a specific field from ThingSpeak
   */ 
  async fetchFieldData(fieldNumber, results = 10) {
    try {
      if (isNaN(fieldNumber) || fieldNumber < 1 || fieldNumber > 8) {
        throw new Error(`Invalid field number: ${fieldNumber}. Must be between 1 and 8.`);
      }
      
      // Always get the latest entry first
      await this.syncLatestDataFromThingSpeak();
      
      const response = await axios.get(`${this.baseUrl}/channels/${this.channelId}/fields/${fieldNumber}.json`, {
        params: {
          api_key: this.readApiKey,
          results: Math.min(Math.max(1, results), 8000) // Limit between 1 and 8000 (ThingSpeak max)
        },
        timeout: 10000 // Add timeout
      });
      
      if (!response.data || !response.data.feeds) {
        throw new Error(`Invalid data received from ThingSpeak for field ${fieldNumber}`);
      }
      
      return response.data.feeds;
    } catch (error) {
      console.error(`Error fetching field ${fieldNumber} data:`, error.message);
      throw error;
    }
  }
  
  /**
   * Method to fetch specific field data directly from ThingSpeak
   */
  async getThingSpeakFieldData(fieldNumber, results = 10) {
    try {
      // Always ensure we have the latest data first
      await this.syncLatestDataFromThingSpeak();
      
      const feeds = await this.fetchFieldData(fieldNumber, results);
      return feeds.map(feed => {
        const fieldKey = `field${fieldNumber}`;
        return {
          timestamp: new Date(feed.created_at),
          value: this.parseFieldValue(feed[fieldKey])
        };
      });
    } catch (error) {
      console.error(`Error processing field ${fieldNumber} data:`, error.message);
      throw error;
    }
  }
}

// Create and export the service instance
const thingSpeakService = new ThingSpeakService();
export default thingSpeakService;

// Add a mechanism to handle process termination gracefully
process.on('SIGINT', () => {
  console.log('ThingSpeak service shutting down...');
  process.exit(0);
});

// Keep the process running if this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  console.log('ThingSpeak service running in standalone mode...');
  console.log(`Automatic data fetch scheduled every ${FETCH_INTERVAL_SECONDS} seconds`);
}
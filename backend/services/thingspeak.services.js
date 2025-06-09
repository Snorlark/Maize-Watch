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
      const rawSoilMoisture = this.parseFieldValue(latestData.field3);
      const soil_moisture = this.convertSoilMoistureToPercentage(rawSoilMoisture);
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
        const rawSoilMoisture = this.parseFieldValue(feed.field3);
        const soil_moisture = this.convertSoilMoistureToPercentage(rawSoilMoisture);
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
   * Converts raw soil moisture sensor values to percentage
   * Most soil moisture sensors output raw analog values (0-1023 for 10-bit ADC)
   * that need to be converted to percentage (0-100%)
   * @param {number} rawValue - Raw sensor value
   * @returns {number} Percentage value (0-100)
   */
  convertSoilMoistureToPercentage(rawValue) {
    if (rawValue === undefined || rawValue === null || isNaN(rawValue)) {
      return 0;
    }

    // If the value is already in percentage range (0-100), return as is
    if (rawValue >= 0 && rawValue <= 100) {
      return rawValue;
    }

    // Convert raw analog values to percentage
    // Most common ranges:
    // - 10-bit ADC: 0-1023 (dry=1023, wet=0)
    // - 12-bit ADC: 0-4095 (dry=4095, wet=0)
    // - 16-bit ADC: 0-65535 (dry=65535, wet=0)
    
    let percentage;
    
    if (rawValue >= 0 && rawValue <= 1023) {
      // 10-bit ADC range (0-1023)
      // Invert the value since dry soil = high value, wet soil = low value
      percentage = ((1023 - rawValue) / 1023) * 100;
    } else if (rawValue >= 0 && rawValue <= 4095) {
      // 12-bit ADC range (0-4095)
      percentage = ((4095 - rawValue) / 4095) * 100;
    } else if (rawValue >= 0 && rawValue <= 65535) {
      // 16-bit ADC range (0-65535)
      percentage = ((65535 - rawValue) / 65535) * 100;
    } else {
      // For other ranges, assume it's already in a reasonable range and normalize
      // Find the maximum value in a reasonable range and normalize
      const maxReasonableValue = Math.max(rawValue, 1000);
      percentage = (rawValue / maxReasonableValue) * 100;
    }
    
    // Clamp to 0-100 range
    return Math.max(0, Math.min(100, percentage));
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
  async getHistoricalData(minutes = 60, startDate = null, endDate = null) {
    try {
      // Always sync latest data first
      await this.syncLatestDataFromThingSpeak();
      
      let query = {};
      
      if (startDate && endDate) {
        // Use specific date range
        query = {
          timestamp: {
            $gte: new Date(startDate),
            $lte: new Date(endDate)
          }
        };
        console.log('Querying with specific date range:', {
          startDate: new Date(startDate).toISOString(),
          endDate: new Date(endDate).toISOString()
        });
      } else {
        // Use relative time window
        const validMinutes = isNaN(minutes) || minutes <= 0 ? 60 : minutes;
        query = {
          timestamp: {
            $gte: new Date(Date.now() - validMinutes * 60 * 1000)
          }
        };
        console.log('Querying with relative time window:', {
          minutes: validMinutes,
          from: new Date(Date.now() - validMinutes * 60 * 1000).toISOString()
        });
      }

      // Get data from MongoDB
      const mongoData = await SensorData.find(query).sort({ timestamp: 1 }); // Sort by ascending time for charts

      console.log(`Found ${mongoData.length} records in the specified range`);

      if (!mongoData || mongoData.length === 0) {
        console.log('No historical data found for the specified range');
        return [];
      }

      // Log sample data points for debugging
      if (mongoData.length > 0) {
        console.log('Sample data points:', {
          first: {
            timestamp: mongoData[0].timestamp,
            humidity: mongoData[0].measurements.humidity
          },
          last: {
            timestamp: mongoData[mongoData.length - 1].timestamp,
            humidity: mongoData[mongoData.length - 1].measurements.humidity
          }
        });
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

  /**
   * Gets weekly overview data for a calendar week (Sunday to Saturday)
   * @param {Date} startDate - Optional start date to calculate week from
   * @param {Date} endDate - Optional end date to calculate week from
   * @returns {Promise<Object>} Weekly data with daily averages and summary
   */
  async getWeeklyOverviewData(startDate = null, endDate = null) {
    try {
      console.log('Getting weekly overview data...');
      console.log('Input dates:', {
        startDate: startDate?.toISOString(),
        endDate: endDate?.toISOString()
      });
      
      // Always sync latest data first
      await this.syncLatestDataFromThingSpeak();
      
      let queryStartDate, queryEndDate;
      
      if (startDate && endDate) {
        // Use provided date range - ensure these align to calendar week boundaries
        queryStartDate = new Date(startDate);
        queryEndDate = new Date(endDate);
        
        // Ensure we're working with calendar week boundaries (Sunday to Saturday)
        queryStartDate = this.getStartOfWeek(queryStartDate);
        queryEndDate = this.getEndOfWeek(queryStartDate);
        
        console.log('Adjusted date range:', {
          originalStart: startDate.toISOString(),
          originalEnd: endDate.toISOString(),
          adjustedStart: queryStartDate.toISOString(),
          adjustedEnd: queryEndDate.toISOString(),
          startDay: queryStartDate.getDay(),
          endDay: queryEndDate.getDay()
        });
      } else {
        // Default to current calendar week
        const now = new Date();
        queryStartDate = this.getStartOfWeek(now);
        queryEndDate = this.getEndOfWeek(queryStartDate);
        
        console.log('Using default date range (current week):', {
          now: now.toISOString(),
          startDate: queryStartDate.toISOString(),
          endDate: queryEndDate.toISOString(),
          startDay: queryStartDate.getDay(),
          endDay: queryEndDate.getDay()
        });
      }

      console.log('Querying MongoDB for data from ${queryStartDate.toISOString()} to ${queryEndDate.toISOString()}');
      
      // Query MongoDB for the specified date range
      const data = await SensorData.find({
        timestamp: { 
          $gte: queryStartDate,
          $lte: queryEndDate
        }
      }).sort({ timestamp: 1 });

      console.log(`Found ${data.length} records in the specified date range`);
      
      if (data.length > 0) {
        console.log('Sample data points:', {
          first: {
            timestamp: data[0].timestamp,
            humidity: data[0].measurements.humidity
          },
          last: {
            timestamp: data[data.length - 1].timestamp,
            humidity: data[data.length - 1].measurements.humidity
          }
        });
      }

      if (!data || data.length === 0) {
        console.log('No weekly data found for the specified range');
        return {
          data: [],
          summary: {
            totalRecords: 0,
            dateRange: {
              start: queryStartDate.toISOString(),
              end: queryEndDate.toISOString()
            }
          }
        };
      }

      // Group data by calendar day within the week (Sunday = 0, Saturday = 6)
      const weeklyData = new Map();
      
      // Initialize all 7 days of the week with empty arrays
      for (let i = 0; i < 7; i++) {
        const dayDate = new Date(queryStartDate);
        dayDate.setDate(queryStartDate.getDate() + i);
        const dayKey = this.formatDateKey(dayDate);
        weeklyData.set(dayKey, {
          dayOfWeek: i, // 0 = Sunday, 6 = Saturday
          date: dayDate.toISOString().split('T')[0],
          dayName: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][i],
          data: []
        });
      }

      // Process and group the sensor data by day
      data.forEach(record => {
        const recordDate = new Date(record.timestamp);
        const dayKey = this.formatDateKey(recordDate);
        
        if (weeklyData.has(dayKey)) {
          // Ensure soil_ph is properly handled (convert to number if it's a string)
          const soilPh = typeof record.measurements.soil_ph === 'string' 
            ? parseFloat(record.measurements.soil_ph) 
            : record.measurements.soil_ph;

          // Ensure light_intensity is properly handled
          const lightIntensity = typeof record.measurements.light_intensity === 'string'
            ? parseFloat(record.measurements.light_intensity)
            : record.measurements.light_intensity;

          weeklyData.get(dayKey).data.push({
            timestamp: record.timestamp,
            measurements: {
              temperature: record.measurements.temperature,
              humidity: record.measurements.humidity,
              soil_moisture: record.measurements.soil_moisture,
              soil_ph: soilPh || null, // Use null instead of 0 for missing soil pH
              light_intensity: lightIntensity || 0
            }
          });
        }
      });

      // Convert Map to array and calculate daily averages
      const processedWeeklyData = Array.from(weeklyData.values()).map(day => {
        if (day.data.length === 0) {
          // Return null values for days with no data
          return {
            dayOfWeek: day.dayOfWeek,
            date: day.date,
            dayName: day.dayName,
            timestamp: new Date(day.date + 'T12:00:00.000Z').toISOString(), // Use noon as default time
            hasData: false,
            dataPoints: 0,
            measurements: {
              temperature: null,
              humidity: null,
              soil_moisture: null,
              soil_ph: null,
              light_intensity: null
            }
          };
        }

        // Calculate daily averages with special handling for soil pH
        const totals = day.data.reduce((acc, reading) => {
          acc.temperature += reading.measurements.temperature || 0;
          acc.humidity += reading.measurements.humidity || 0;
          acc.soil_moisture += reading.measurements.soil_moisture || 0;
          
          // Special handling for soil pH - only include non-zero values
          if (reading.measurements.soil_ph && reading.measurements.soil_ph !== 0) {
            acc.soil_ph += reading.measurements.soil_ph;
            acc.soil_ph_count++;
          }
          
          acc.light_intensity += reading.measurements.light_intensity || 0;
          acc.count++;
          return acc;
        }, {
          temperature: 0,
          humidity: 0,
          soil_moisture: 0,
          soil_ph: 0,
          soil_ph_count: 0,
          light_intensity: 0,
          count: 0
        });

        // Use the most recent timestamp for the day
        const latestReading = day.data[day.data.length - 1];

        return {
          dayOfWeek: day.dayOfWeek,
          date: day.date,
          dayName: day.dayName,
          timestamp: latestReading.timestamp,
          hasData: true,
          dataPoints: day.data.length,
          measurements: {
            temperature: parseFloat((totals.temperature / totals.count).toFixed(2)),
            humidity: parseFloat((totals.humidity / totals.count).toFixed(2)),
            soil_moisture: parseFloat((totals.soil_moisture / totals.count).toFixed(2)),
            soil_ph: totals.soil_ph_count > 0 ? parseFloat((totals.soil_ph / totals.soil_ph_count).toFixed(2)) : null,
            light_intensity: parseFloat((totals.light_intensity / totals.count).toFixed(2))
          }
        };
      });

      // Calculate weekly statistics
      const weeklyStats = this.calculateWeeklyStats(processedWeeklyData);

      console.log(`Processed weekly data: ${processedWeeklyData.length} days, ${data.length} total readings`);

      return {
        data: processedWeeklyData,
        summary: {
          totalRecords: data.length,
          dateRange: {
            start: queryStartDate.toISOString(),
            end: queryEndDate.toISOString()
          },
          weeklyStats: weeklyStats
        }
      };

    } catch (error) {
      console.error('Error getting weekly overview data:', error);
      throw new Error(`Failed to get weekly overview data: ${error.message}`);
    }
  }

  /**
   * Helper method to get the start of calendar week (Sunday)
   */
  getStartOfWeek(date) {
    const d = new Date(date);
    // Convert to Sunday = 0, Monday = 1, ..., Saturday = 6
    const day = d.getDay(); // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
    const diff = day; // Days from Sunday
    d.setDate(d.getDate() - diff);
    d.setHours(0, 0, 0, 0);
    return d;
  }

  /**
   * Helper method to get the end of calendar week (Saturday at 23:59:59)
   */
  getEndOfWeek(startOfWeek) {
    const d = new Date(startOfWeek);
    d.setDate(d.getDate() + 6); // Add 6 days to get to Saturday
    d.setHours(23, 59, 59, 999);
    return d;
  }

  /**
   * Helper method to format date as YYYY-MM-DD for consistent keys
   */
  formatDateKey(date) {
    const d = new Date(date);
    return d.toISOString().split('T')[0];
  }

  /**
   * Helper method to calculate weekly statistics
   */
  calculateWeeklyStats(weeklyData) {
    const dataWithValues = weeklyData.filter(day => day.hasData);
    
    if (dataWithValues.length === 0) {
      return {
        temperature: { min: null, max: null, avg: null },
        humidity: { min: null, max: null, avg: null },
        soil_moisture: { min: null, max: null, avg: null },
        soil_ph: { min: null, max: null, avg: null },
        light_intensity: { min: null, max: null, avg: null },
        daysWithData: 0,
        totalDays: 7
      };
    }

    const parameters = ['temperature', 'humidity', 'soil_moisture', 'soil_ph', 'light_intensity'];
    const stats = {};

    parameters.forEach(param => {
      const values = dataWithValues
        .map(day => day.measurements[param])
        .filter(val => val !== null && !isNaN(val));
      
      if (values.length > 0) {
        stats[param] = {
          min: Math.min(...values),
          max: Math.max(...values),
          avg: parseFloat((values.reduce((sum, val) => sum + val, 0) / values.length).toFixed(2))
        };
      } else {
        stats[param] = { min: null, max: null, avg: null };
      }
    });

    stats.daysWithData = dataWithValues.length;
    stats.totalDays = 7;

    return stats;
  }

  /**
   * Helper method to get current calendar week start (for frontend compatibility)
   */
  getCurrentWeekStart() {
    const now = new Date();
    return this.getStartOfWeek(now);
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
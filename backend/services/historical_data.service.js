import { MongoClient } from 'mongodb';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

class HistoricalDataService {
  constructor() {
    this.iotDbUri = process.env.MONGODB_IOT_URI;
    this.historyDbUri = process.env.MONGODB_HISTORY_URI;
    this.client = null;
    this.iotDb = null;
    this.historyDb = null;
  }

  async connect() {
    if (!this.client) {
      this.client = new MongoClient(this.iotDbUri);
      await this.client.connect();
      this.iotDb = this.client.db();

      // Connect to historical database
      this.historyClient = new MongoClient(this.historyDbUri);
      await this.historyClient.connect();
      this.historyDb = this.historyClient.db();
    }
  }

  async disconnect() {
    if (this.client) {
      await this.client.close();
      this.client = null;
      this.iotDb = null;
    }
    if (this.historyClient) {
      await this.historyClient.close();
      this.historyClient = null;
      this.historyDb = null;
    }
  }

  async calculateDailyAverage() {
    try {
      await this.connect();

      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);

      const data = await this.iotDb.collection('sensor_data')
        .find({
          timestamp: {
            $gte: today,
            $lt: tomorrow
          }
        }).toArray();

      if (data.length === 0) return null;

      const averages = {
        temperature: 0,
        humidity: 0,
        soilMoisture: 0,
        soilPh: 0,
        lightIntensity: 0
      };

      data.forEach(record => {
        averages.temperature += record.temperature || 0;
        averages.humidity += record.humidity || 0;
        averages.soilMoisture += record.soilMoisture || 0;
        averages.soilPh += record.soilPh || 0;
        averages.lightIntensity += record.lightIntensity || 0;
      });

      const count = data.length;
      Object.keys(averages).forEach(key => {
        averages[key] = averages[key] / count;
      });

      // Store in historical database
      await this.historyDb.collection('daily_averages').insertOne({
        date: today,
        averages,
        count
      });

      return averages;
    } catch (error) {
      console.error('Error calculating daily average:', error);
      throw error;
    }
  }

  async calculateWeeklyAverage() {
    try {
      await this.connect();

      const today = new Date();
      const startOfWeek = new Date(today);
      startOfWeek.setDate(today.getDate() - today.getDay()); // Start from Sunday
      startOfWeek.setHours(0, 0, 0, 0);

      const endOfWeek = new Date(startOfWeek);
      endOfWeek.setDate(endOfWeek.getDate() + 7);

      const data = await this.iotDb.collection('sensor_data')
        .find({
          timestamp: {
            $gte: startOfWeek,
            $lt: endOfWeek
          }
        }).toArray();

      if (data.length === 0) return null;

      const averages = {
        temperature: 0,
        humidity: 0,
        soilMoisture: 0,
        soilPh: 0,
        lightIntensity: 0
      };

      data.forEach(record => {
        averages.temperature += record.temperature || 0;
        averages.humidity += record.humidity || 0;
        averages.soilMoisture += record.soilMoisture || 0;
        averages.soilPh += record.soilPh || 0;
        averages.lightIntensity += record.lightIntensity || 0;
      });

      const count = data.length;
      Object.keys(averages).forEach(key => {
        averages[key] = averages[key] / count;
      });

      // Store in historical database
      await this.historyDb.collection('weekly_averages').insertOne({
        weekStart: startOfWeek,
        weekEnd: endOfWeek,
        averages,
        count
      });

      return averages;
    } catch (error) {
      console.error('Error calculating weekly average:', error);
      throw error;
    }
  }

  async calculateMonthlyAverage() {
    try {
      await this.connect();

      const today = new Date();
      const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
      const endOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0);

      const data = await this.iotDb.collection('sensor_data')
        .find({
          timestamp: {
            $gte: startOfMonth,
            $lt: endOfMonth
          }
        }).toArray();

      if (data.length === 0) return null;

      const averages = {
        temperature: 0,
        humidity: 0,
        soilMoisture: 0,
        soilPh: 0,
        lightIntensity: 0
      };

      data.forEach(record => {
        averages.temperature += record.temperature || 0;
        averages.humidity += record.humidity || 0;
        averages.soilMoisture += record.soilMoisture || 0;
        averages.soilPh += record.soilPh || 0;
        averages.lightIntensity += record.lightIntensity || 0;
      });

      const count = data.length;
      Object.keys(averages).forEach(key => {
        averages[key] = averages[key] / count;
      });

      // Store in historical database
      await this.historyDb.collection('monthly_averages').insertOne({
        monthStart: startOfMonth,
        monthEnd: endOfMonth,
        averages,
        count
      });

      return averages;
    } catch (error) {
      console.error('Error calculating monthly average:', error);
      throw error;
    }
  }

  async getHistoricalData(period, limit = 7) {
    try {
      await this.connect();
      console.log(`[getHistoricalData] period: ${period}, limit: ${limit}`);

      let collection;
      let sortField;

      switch (period) {
        case 'daily':
          collection = 'daily_averages';
          sortField = 'date';
          break;
        case 'weekly':
          collection = 'weekly_averages';
          sortField = 'weekStart';
          break;
        case 'monthly':
          collection = 'monthly_averages';
          sortField = 'monthStart';
          break;
        default:
          throw new Error('Invalid period specified');
      }

      console.log(`[getHistoricalData] Using collection: ${collection}, sortField: ${sortField}`);

      const data = await this.historyDb.collection(collection)
        .find()
        .sort({ [sortField]: -1 })
        .limit(limit)
        .toArray();

      console.log(`[getHistoricalData] Retrieved ${data.length} records`);

      return data;
    } catch (error) {
      console.error('Error fetching historical data:', error);
      throw error;
    }
  }
}

export default new HistoricalDataService(); 
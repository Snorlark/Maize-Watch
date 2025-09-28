import axios, { AxiosInstance, AxiosResponse } from 'axios';
import { logger } from '../utils/logger';

interface ThingSpeakConfig {
  baseUrl: string;
  apiKey: string;
  channelId: string;
  readApiKey: string;
  writeApiKey: string;
  timeout: number;
}

interface SensorData {
  field1?: number; // Temperature
  field2?: number; // Humidity
  field3?: number; // Soil Moisture
  field4?: number; // Light Intensity
  field5?: number; // Soil pH
  field6?: number; // Battery Level
  field7?: number; // Signal Strength
  field8?: number; // Custom Field
}

interface ThingSpeakResponse {
  channel_id: number;
  feeds: Array<{
    created_at: string;
    entry_id: number;
    field1?: string;
    field2?: string;
    field3?: string;
    field4?: string;
    field5?: string;
    field6?: string;
    field7?: string;
    field8?: string;
  }>;
}

const getThingSpeakConfig = (): ThingSpeakConfig => {
  const apiKey = process.env.THINGSPEAK_API_KEY;
  const channelId = process.env.THINGSPEAK_CHANNEL_ID;
  const readApiKey = process.env.THINGSPEAK_READ_API_KEY;
  const writeApiKey = process.env.THINGSPEAK_WRITE_API_KEY;

  if (!apiKey || !channelId || !readApiKey || !writeApiKey) {
    throw new Error('ThingSpeak configuration is incomplete. Please check environment variables.');
  }

  return {
    baseUrl: 'https://api.thingspeak.com',
    apiKey,
    channelId,
    readApiKey,
    writeApiKey,
    timeout: 5000, // Reduced timeout to 5 seconds
  };
};

class ThingSpeakService {
  private config: ThingSpeakConfig;
  private axiosInstance: AxiosInstance;

  constructor() {
    this.config = getThingSpeakConfig();
    this.axiosInstance = axios.create({
      baseURL: this.config.baseUrl,
      timeout: this.config.timeout,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Request interceptor for logging
    this.axiosInstance.interceptors.request.use(
      (config) => {
        logger.debug(`ThingSpeak API Request: ${config.method?.toUpperCase()} ${config.url}`);
        return config;
      },
      (error) => {
        logger.error('ThingSpeak API Request Error:', error);
        return Promise.reject(error);
      }
    );

    // Response interceptor for logging
    this.axiosInstance.interceptors.response.use(
      (response) => {
        logger.debug(`ThingSpeak API Response: ${response.status} ${response.statusText}`);
        return response;
      },
      (error) => {
        logger.error('ThingSpeak API Response Error:', error.response?.data || error.message);
        return Promise.reject(error);
      }
    );
  }

  // Write data to ThingSpeak channel
  async writeData(data: SensorData): Promise<boolean> {
    try {
      const response: AxiosResponse = await this.axiosInstance.post(
        `/update.json`,
        {
          api_key: this.config.writeApiKey,
          ...data,
        }
      );

      if (response.data && response.data !== '0') {
        logger.info(`Data written to ThingSpeak successfully. Entry ID: ${response.data}`);
        return true;
      } else {
        logger.warn('ThingSpeak write failed - no entry ID returned');
        return false;
      }
    } catch (error) {
      logger.error('Error writing to ThingSpeak:', error);
      return false;
    }
  }

  // Read latest data from ThingSpeak channel
  async readLatestData(): Promise<SensorData | null> {
    try {
      const response: AxiosResponse<ThingSpeakResponse> = await this.axiosInstance.get(
        `/channels/${this.config.channelId}/feeds.json`,
        {
          params: {
            api_key: this.config.readApiKey,
            results: 1,
          },
        }
      );

      if (response.data.feeds && response.data.feeds.length > 0) {
        const feed = response.data.feeds[0];
        return {
          field1: feed.field1 ? parseFloat(feed.field1) : undefined,
          field2: feed.field2 ? parseFloat(feed.field2) : undefined,
          field3: feed.field3 ? parseFloat(feed.field3) : undefined,
          field4: feed.field4 ? parseFloat(feed.field4) : undefined,
          field5: feed.field5 ? parseFloat(feed.field5) : undefined,
          field6: feed.field6 ? parseFloat(feed.field6) : undefined,
          field7: feed.field7 ? parseFloat(feed.field7) : undefined,
          field8: feed.field8 ? parseFloat(feed.field8) : undefined,
        };
      }

      return null;
    } catch (error) {
      logger.error('Error reading from ThingSpeak:', error);
      return null;
    }
  }

  // Read historical data from ThingSpeak channel
  async readHistoricalData(results: number = 100, start?: string, end?: string): Promise<SensorData[]> {
    try {
      const params: any = {
        api_key: this.config.readApiKey,
        results,
      };

      if (start) params.start = start;
      if (end) params.end = end;

      const response: AxiosResponse<ThingSpeakResponse> = await this.axiosInstance.get(
        `/channels/${this.config.channelId}/feeds.json`,
        { params }
      );

      if (response.data.feeds) {
        return response.data.feeds.map(feed => ({
          field1: feed.field1 ? parseFloat(feed.field1) : undefined,
          field2: feed.field2 ? parseFloat(feed.field2) : undefined,
          field3: feed.field3 ? parseFloat(feed.field3) : undefined,
          field4: feed.field4 ? parseFloat(feed.field4) : undefined,
          field5: feed.field5 ? parseFloat(feed.field5) : undefined,
          field6: feed.field6 ? parseFloat(feed.field6) : undefined,
          field7: feed.field7 ? parseFloat(feed.field7) : undefined,
          field8: feed.field8 ? parseFloat(feed.field8) : undefined,
        }));
      }

      return [];
    } catch (error) {
      logger.error('Error reading historical data from ThingSpeak:', error);
      return [];
    }
  }

  // Get channel status
  async getChannelStatus(): Promise<any> {
    try {
      const response = await this.axiosInstance.get(
        `/channels/${this.config.channelId}.json`,
        {
          params: {
            api_key: this.config.readApiKey,
          },
        }
      );

      return response.data;
    } catch (error) {
      logger.error('Error getting ThingSpeak channel status:', error);
      return null;
    }
  }

  // Clear channel data (use with caution)
  async clearChannel(): Promise<boolean> {
    try {
      const response = await this.axiosInstance.delete(
        `/channels/${this.config.channelId}/feeds.json`,
        {
          params: {
            api_key: this.config.writeApiKey,
          },
        }
      );

      logger.info('ThingSpeak channel cleared successfully');
      return true;
    } catch (error) {
      logger.error('Error clearing ThingSpeak channel:', error);
      return false;
    }
  }
}

// Lazy-loaded singleton instance
let thingSpeakServiceInstance: ThingSpeakService | null = null;

export const getThingSpeakService = (): ThingSpeakService => {
  if (!thingSpeakServiceInstance) {
    thingSpeakServiceInstance = new ThingSpeakService();
  }
  return thingSpeakServiceInstance;
};

// Export types for use in other modules
export { SensorData, ThingSpeakResponse };

export default getThingSpeakService;

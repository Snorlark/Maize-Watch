// config.ts (fixed service layer)
import axios from "axios";
import { format } from "date-fns";
import authService from '../api/services/authService'; // Import your auth service

// Use your local development URL (matching your current setup)
const API_BASE = import.meta.env.VITE_API_URL || "http://localhost:8080/api";

console.log('Dashboard API Base URL being used:', API_BASE);

// Create axios instance with authentication (similar to client.ts)
const dashboardApiClient = axios.create({
  baseURL: API_BASE, // ✅ Use API_BASE directly - don't remove /api
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000, // Reduced timeout to 10 seconds for faster fallback
  withCredentials: false,
});

// Add auth interceptor (same as client.ts)
dashboardApiClient.interceptors.request.use(
  (config) => {
    const token = authService.getToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Handle response errors (same as client.ts)
dashboardApiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    // Handle CORS errors
    if (error.message === 'Network Error') {
      console.error('CORS or network error detected:', error);
    }
    
    // Handle authentication errors
    if (error.response?.status === 401) {
      console.log('Authentication error - clearing tokens');
      authService.logout();
      window.dispatchEvent(new CustomEvent('auth:logout'));
    }
    
    return Promise.reject(error);
  }
);

export const apiService = {
  async fetchHistoricalData(period: "daily" | "weekly" | "monthly", limit: number, baseDate?: Date) {
    try {
      // Enhanced auth debugging
      const token = authService.getToken();
      const isAuth = authService.isAuthenticated();
      const user = authService.getCurrentUser();
      
      console.log(`[apiService] Auth Debug:`, {
        hasToken: !!token,
        tokenPreview: token ? `${token.substring(0, 20)}...` : 'none',
        isAuthenticated: isAuth,
        currentUser: user
      });

      if (!isAuth) {
        console.error('[apiService] Authentication failed - details:', {
          tokenExists: !!token,
          tokenValid: token ? 'checking...' : 'no token',
          userExists: !!user
        });
        throw new Error('Authentication required');
      }

      console.log(`[apiService] Fetching ${period} data with limit ${limit}`);
      const baseDateParam = baseDate ? baseDate.toISOString() : undefined;
      console.log(`[apiService] URL: ${API_BASE}/historical-data?period=${period}&limit=${limit}${baseDateParam ? `&baseDate=${baseDateParam}` : ''}`);
      
      const response = await dashboardApiClient.get(`/historical-data`, {
        params: {
          period,
          limit,
          ...(baseDateParam ? { baseDate: baseDateParam } : {})
        }
      });

      console.log(`[apiService] Raw response:`, response.data);

      const rawData = response.data?.data || [];
      console.log(`[apiService] Raw data length:`, rawData.length);

      if (rawData.length === 0) {
        console.warn(`[apiService] No data returned for ${period} period`);
        return {
          success: true,
          data: [],
          rawData: [],
          message: `No ${period} data available`
        };
      }

      // ✅ Normalize data here
      const normalizedData = rawData.map((item: any, index: number) => {
        let label = "";
        
        console.log(`[apiService] Processing item ${index}:`, item);
        
        if (period === "daily" && item.date) {
          label = format(new Date(item.date), "MMM d");
        } else if (period === "weekly" && item.weekStart && item.weekEnd) {
          label = `${format(new Date(item.weekStart), "MMM d")} - ${format(new Date(item.weekEnd), "MMM d")}`;
        } else if (period === "monthly" && item.monthStart) {
          label = format(new Date(item.monthStart), "MMM yyyy");
        } else {
          // Fallback label generation
          label = item.label || item.date || `#${index + 1}`;
        }

        return {
          ...item,
          label,
        };
      });

      console.log(`[apiService] Normalized data:`, normalizedData);

      return {
        success: true,
        data: normalizedData,
        rawData,
        message: `Successfully fetched ${normalizedData.length} ${period} records`
      };
    } catch (error: any) {
      console.error(`[apiService] Error fetching ${period} data:`, error);
      
      // Provide more detailed error information
      let errorMessage = 'Failed to fetch historical data';
      let serverMessage = 'Unknown server error';
      
      if (error.code === 'ECONNABORTED') {
        errorMessage = 'Request timeout - server might be slow or unreachable';
      } else if (error.response?.status === 401) {
        errorMessage = 'Authentication required - please log in again';
      } else if (error.response?.status === 404) {
        errorMessage = 'Historical data endpoint not found';
      } else if (error.response?.status >= 500) {
        errorMessage = 'Server error - please try again later';
      }
      
      if (error.response?.data?.message) {
        serverMessage = error.response.data.message;
      }

      return {
        success: false,
        data: [],
        error: errorMessage,
        message: serverMessage,
        status: error.response?.status || 0
      };
    }
  }
};

// Sensor service for live data
export const sensorService = {
  async getRawSensorReadings(farmId: string, limit: number = 10) {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }

      console.log('[sensorService] Fetching raw sensor readings...');
      
      // Use the existing endpoint that gets latest readings by farm
      const response = await dashboardApiClient.get(`/farms/${farmId}/readings/latest`);

      console.log('[sensorService] Raw sensor data:', response.data);
      return {
        success: true,
        data: response.data
      };
    } catch (error: any) {
      console.error('[sensorService] Error fetching sensor readings:', error);
      return {
        success: false,
        error: error.message || 'Failed to fetch sensor readings'
      };
    }
  },

  async getLatestSensorData(farmId?: string) {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }

      console.log('[sensorService] Fetching latest sensor data...', { farmId });
      
      let response;
      
      // Try farm-specific endpoint first if farmId is provided
      if (farmId) {
        try {
          console.log(`[sensorService] Trying farm-specific endpoint: /farms/${farmId}/readings/latest`);
          response = await dashboardApiClient.get(`/farms/${farmId}/readings/latest`);
        } catch (farmError: any) {
          console.log('[sensorService] Farm-specific endpoint failed, trying test endpoint');
          // Skip the problematic MongoDB endpoint and go straight to test endpoint
          response = await dashboardApiClient.get('/sensors/test-simple');
        }
      } else {
        // Try test endpoint first since MongoDB endpoint is timing out
        console.log('[sensorService] Using test endpoint (MongoDB endpoint has timeout issues)');
        response = await dashboardApiClient.get('/sensors/test-simple');
      }

      console.log('[sensorService] Latest sensor data response:', response.data);
      
      if (response.data?.success) {
        // Handle different response formats
        let sensorData = response.data.data;
        
        // If data is directly in response (like latest-no-thingspeak endpoint)
        if (!sensorData && response.data.temperature !== undefined) {
          sensorData = {
            _id: response.data._id,
            timestamp: response.data.timestamp,
            temperature: response.data.temperature,
            humidity: response.data.humidity,
            soilMoisture: response.data.soilMoisture,
            soilPh: response.data.soilPh,
            lightIntensity: response.data.lightIntensity
          };
        }
        
        // If data is in mockData field (like test-simple endpoint)
        if (!sensorData && response.data.mockData) {
          const mockData = response.data.mockData;
          sensorData = {
            _id: 'test-reading-' + Date.now(),
            timestamp: response.data.timestamp || new Date().toISOString(),
            temperature: mockData.temperature,
            humidity: mockData.humidity,
            soilMoisture: mockData.soilMoisture,
            soilPh: mockData.soilPh,
            lightIntensity: mockData.lightIntensity
          };
        }
        
        if (sensorData) {
          return {
            success: true,
            data: sensorData,
            message: response.data.message || 'Latest sensor data retrieved successfully'
          };
        }
      }
      
      throw new Error('Invalid response format from sensor API');
    } catch (error: any) {
      console.error('[sensorService] Error fetching latest sensor data:', error);
      console.error('[sensorService] Error details:', {
        status: error.response?.status,
        statusText: error.response?.statusText,
        data: error.response?.data,
        message: error.message,
        config: {
          url: error.config?.url,
          method: error.config?.method,
          headers: error.config?.headers
        }
      });
      
      // Try MongoDB endpoint as fallback if test endpoint fails
      try {
        console.log('[sensorService] Trying MongoDB endpoint as fallback...');
        const fallbackResponse = await dashboardApiClient.get('/sensors/latest-no-thingspeak');
        
        if (fallbackResponse.data?.success && fallbackResponse.data.temperature !== undefined) {
          console.log('[sensorService] MongoDB fallback endpoint succeeded');
          return {
            success: true,
            data: {
              _id: fallbackResponse.data._id || 'mongodb-reading-' + Date.now(),
              timestamp: fallbackResponse.data.timestamp || new Date().toISOString(),
              temperature: fallbackResponse.data.temperature,
              humidity: fallbackResponse.data.humidity,
              soilMoisture: fallbackResponse.data.soilMoisture,
              soilPh: fallbackResponse.data.soilPh,
              lightIntensity: fallbackResponse.data.lightIntensity
            },
            message: 'Using MongoDB data - ' + (fallbackResponse.data.message || 'MongoDB sensor data retrieved')
          };
        }
      } catch (fallbackError: any) {
        console.error('[sensorService] MongoDB fallback also failed:', fallbackError);
        console.error('[sensorService] MongoDB fallback error details:', {
          status: fallbackError.response?.status,
          statusText: fallbackError.response?.statusText,
          data: fallbackError.response?.data,
          message: fallbackError.message
        });
      }
      
      let errorMessage = 'Failed to fetch latest sensor data';
      if (error.response?.status === 401) {
        errorMessage = 'Authentication required - please log in again';
      } else if (error.response?.status === 404) {
        errorMessage = 'Sensor data endpoint not found';
      } else if (error.response?.status >= 500) {
        errorMessage = 'Server error - please try again later';
      }
      
      return {
        success: false,
        error: errorMessage,
        message: error.response?.data?.message || error.message
      };
    }
  },

  // NEW: ThingSpeak live data endpoint
  async getThingSpeakLiveData() {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }

      console.log('[sensorService] Fetching live data from ThingSpeak...');
      
      const response = await dashboardApiClient.get('/sensors/thingspeak/live');
      
      console.log('[sensorService] ThingSpeak live data response:', response.data);
      
      if (response.data?.success && response.data.data) {
        return {
          success: true,
          data: response.data.data,
          message: response.data.message || 'ThingSpeak live data retrieved successfully'
        };
      }
      
      throw new Error('Invalid response from ThingSpeak live endpoint');
    } catch (error: any) {
      console.error('[sensorService] Error fetching ThingSpeak live data:', error);
      
      return {
        success: false,
        error: error.response?.data?.message || error.message || 'Failed to fetch ThingSpeak live data',
        message: error.response?.data?.message || error.message
      };
    }
  },

  // NEW: ThingSpeak historical data endpoint
  async getThingSpeakHistoricalData(results: number = 20, hours: number = 24) {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }

      console.log(`[sensorService] Fetching ${results} historical readings from ThingSpeak (last ${hours} hours)...`);
      
      const response = await dashboardApiClient.get('/sensors/thingspeak/historical', {
        params: { results, hours }
      });
      
      console.log('[sensorService] ThingSpeak historical data response:', response.data);
      
      if (response.data?.success) {
        return {
          success: true,
          data: response.data.data || [],
          count: response.data.count || 0,
          message: response.data.message || 'ThingSpeak historical data retrieved successfully'
        };
      }
      
      throw new Error('Invalid response from ThingSpeak historical endpoint');
    } catch (error: any) {
      console.error('[sensorService] Error fetching ThingSpeak historical data:', error);
      
      return {
        success: false,
        error: error.response?.data?.message || error.message || 'Failed to fetch ThingSpeak historical data',
        message: error.response?.data?.message || error.message,
        data: []
      };
    }
  }
};
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
  timeout: 30000,
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

// Optional: Add a direct sensor readings service for debugging
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
  }
};
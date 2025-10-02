// client.ts
import axios, { AxiosError } from 'axios';
import authService from '../api/services/authService';
import type { User } from '../api/services/authService';

// Environment configuration
const isDevelopment = import.meta.env.DEV;
const API_BASE_URL = isDevelopment ? 'http://localhost:8080' : 'https://maize-watch-rdcy.onrender.com';

console.log('Development mode:', isDevelopment);
console.log('API Base URL:', API_BASE_URL);

// Create axios instance with base configuration
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000, // 30 seconds timeout (increased for slow backend)
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: false,
});
// Add auth token to requests if available
apiClient.interceptors.request.use(
  (config) => {
    // Get token directly from localStorage to avoid circular imports
    const token = localStorage.getItem('token');
    console.log('🔍 Request interceptor debug:', {
      url: config.url,
      hasToken: !!token,
      tokenPreview: token ? `${token.substring(0, 20)}...` : 'none',
      headers: config.headers
    });
    
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Handle response errors (including token expiration)
apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  (error: AxiosError) => {
    // Reduce console noise for timeout errors
    if (error.code === 'ECONNABORTED') {
      // Only log timeout errors in development
      if (isDevelopment) {
        console.warn('Request timeout:', error.config?.url);
      }
    } else if (error.message === 'Network Error') {
      console.error('CORS or network error detected:', error);
    } else {
      // Log other errors normally
      console.error('API Error:', error);
    }
    
    // Handle authentication errors
    if (error.response?.status === 401) {
      console.log('Authentication error - clearing tokens');
      authService.logout(); // Use authService logout for consistency
      
      // You can emit an event or use a state management solution to notify components
      window.dispatchEvent(new CustomEvent('auth:logout'));
    }
    
    return Promise.reject(error);
  }
);

// User API services
export const userService = {
  // Login user - now uses authService for consistency
  login: async (credentials: { username: string; password: string }): Promise<{ token: string; user: User }> => {
    try {
      console.log('Making login request to:', `${API_BASE_URL}/auth/login`);
      
      // Use authService for login to maintain consistency
      const result = await authService.login(credentials.username, credentials.password);
      
      if (result.success && result.data) {
        return {
          token: result.data.token,
          user: result.data.user // This should now match the imported User type
        };
      } else {
        throw new Error(result.message || 'Login failed');
      }
    } catch (error) {
      console.error('Login error:', error);
      throw error;
    }
  },
  
  // Get all users with field selection
  getUsers: async (retryCount = 0): Promise<User[]> => {
    try {
      // Check authentication first
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      
      const response = await apiClient.get('/api/users', {
        params: {
          limit: 1000, // Get all users, increase limit to avoid pagination issues
          page: 1
        },
        timeout: 10000 // Shorter timeout for user list requests
      });
      
      // Backend returns: { success: true, data: { users: [...], pagination: {...} } }
      if (response.data?.success && response.data?.data?.users) {
        return response.data.data.users;
      } else {
        console.warn('Unexpected response format:', response.data);
        return response.data?.users || response.data || [];
      }
    } 
    catch (error: any) {
      // Retry logic for timeout errors
      if (error.code === 'ECONNABORTED' && retryCount < 2) {
        console.log(`Retrying getUsers request (attempt ${retryCount + 1}/3)...`);
        return userService.getUsers(retryCount + 1);
      }
      
      // Reduce console noise - only log if it's not a timeout
      if (error.code !== 'ECONNABORTED') {
        console.error('Error in getUsers:', error);
      }
      
      throw error;
    }
  },
  
  // Get a single user by ID
  getUserById: async (id: string): Promise<User> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      
      const response = await apiClient.get(`/api/users/${id}`);
      
      // Handle backend response format
      if (response.data?.success && response.data?.data?.user) {
        return response.data.data.user;
      } else {
        return response.data?.user || response.data;
      }
    } catch (error: any) {
      console.error(`Error getting user ${id}:`, error);
      throw error;
    }
  },

  // Create a new user
  createUser: async (userData: Omit<User, "_id">): Promise<User> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      
      const response = await apiClient.post('/api/users', userData);
      
      // Handle backend response format
      if (response.data?.success && response.data?.data?.user) {
        return response.data.data.user;
      } else {
        return response.data?.user || response.data;
      }
    } catch (error: any) {
      console.error('Error creating user:', error);
      throw error;
    }
  },

  // Update an existing user
  updateUser: async (id: string, userData: Partial<User>): Promise<User> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      
      const response = await apiClient.put(`/api/users/${id}`, userData);
      
      // Handle backend response format
      if (response.data?.success && response.data?.data?.user) {
        return response.data.data.user;
      } else {
        return response.data?.user || response.data;
      }
    } catch (error: any) {
      console.error(`Error updating user ${id}:`, error);
      throw error;
    }
  },

  // Get current user profile
  getProfile: async (): Promise<User> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      
      const response = await apiClient.get('/api/profile');
      
      // Update stored user data
      if (response.data) {
        localStorage.setItem('user_data', JSON.stringify(response.data));
      }
      
      return response.data;
    } catch (error: any) {
      console.error('Error getting user profile:', error);
      throw error;
    }
  },

  // Update current user profile
  updateProfile: async (userData: Partial<User>): Promise<User> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      
      // Use the auth profile update endpoint
      const response = await apiClient.put('/api/auth/me', userData);
      
      // Update stored user data
      if (response.data?.data) {
        const updatedUser = response.data.data;
        localStorage.setItem('user_data', JSON.stringify(updatedUser));
      }
      
      return response.data?.data || response.data;
    } catch (error: any) {
      console.error('Error updating user profile:', error);
      if (error.response?.data?.message) {
        throw new Error(error.response.data.message);
      }
      throw new Error('Failed to update profile. Please try again.');
    }
  },

  // Delete a user
  deleteUser: async (id: string): Promise<void> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      
      await apiClient.delete(`/api/users/${id}`);
    } catch (error: any) {
      console.error(`Error deleting user ${id}:`, error);
      throw error;
    }
  },
};

// Activity logs API service (matching your utils/api.ts functionality)
export const activityLogAPI = {
  getLogs: async (filters: Record<string, any> = {}, page = 1, limit = 50) => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      
      const params: Record<string, string> = {
        page: page.toString(),
        limit: limit.toString()
      };

      // Add filters to params
      Object.entries(filters).forEach(([key, value]) => {
        if (value !== '' && value !== false && value !== null && value !== undefined) {
          params[key] = value.toString();
        }
      });

      const response = await apiClient.get('/api/activity-logs', { params });
      return {
        success: true,
        data: response.data,
        status: response.status
      };
    } catch (error: any) {
      console.error('Error getting activity logs:', error);
      return {
        success: false,
        error: error.response?.data?.message || error.message,
        status: error.response?.status || 0
      };
    }
  },

  getSummary: async (dateRange: { startDate?: string; endDate?: string } = {}) => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      
      const params: Record<string, string> = {};
      if (dateRange.startDate) params.startDate = dateRange.startDate;
      if (dateRange.endDate) params.endDate = dateRange.endDate;

      const response = await apiClient.get('/api/activity-logs', { params });
      return {
        success: true,
        data: response.data,
        status: response.status
      };
    } catch (error: any) {
      console.error('Error getting activity summary:', error);
      return {
        success: false,
        error: error.response?.data?.message || error.message,
        status: error.response?.status || 0
      };
    }
  }
};

export default apiClient;
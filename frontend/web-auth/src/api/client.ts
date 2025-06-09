// client.ts
import axios, { AxiosError } from 'axios';
import authService from '../api/services/authService';
import type { User } from '../api/services/authService';

// Alternative: If you can't import from authService, define a compatible interface
// export interface User {
//   _id?: string;
//   username: string;
//   password?: string;
//   fullName?: string; // Make optional to match authService
//   contactNumber?: string; // Consider making optional if needed
//   address?: string; // Consider making optional if needed
//   role: string;
//   createdAt?: string;
//   __v?: number;
// }

// Base URL configuration
const isDevelopment = import.meta.env?.MODE === 'development';
const apiBaseUrl = isDevelopment ? 'https://maize-watch.onrender.com' : 'https://maize-watch.onrender.com';
console.log('API Base URL being used:', apiBaseUrl);

// Create the Axios instance
const apiClient = axios.create({
  baseURL: apiBaseUrl,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 30000,
  withCredentials: false,
});

// Add auth token to requests if available
apiClient.interceptors.request.use(
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

// Handle response errors (including token expiration)
apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  (error: AxiosError) => {
    // Handle CORS errors
    if (error.message === 'Network Error') {
      console.error('CORS or network error detected:', error);
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
      console.log('Making login request to:', `${apiBaseUrl}/auth/login`);
      
      // Use authService for login to maintain consistency
      const result = await authService.login(credentials);
      
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
  getUsers: async (): Promise<User[]> => {
    try {
      // Check authentication first
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      
      console.log('Making getUsers request to:', `${apiBaseUrl}/api/users`);
      const response = await apiClient.get('/api/users', {
        params: {
          fields: 'username,fullName,contactNumber,address,role'
        }
      });
      
      return response.data;
    } 
    catch (error: any) {
      console.error('Error in getUsers:', error);
      
      if (error.code === 'ECONNABORTED') {
        console.error('Connection timeout. Is your backend server running at', apiBaseUrl, '?');
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
      
      const response = await apiClient.get(`/api/users/${id}`, {
        params: {
          fields: 'username,fullName,contactNumber,address,role'
        }
      });
      return response.data;
    } catch (error) {
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
      return response.data;
    } catch (error) {
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
      return response.data;
    } catch (error) {
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
    } catch (error) {
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
      
      // Get current user to get username
      const currentUser = authService.getCurrentUser();
      if (!currentUser?.username) {
        throw new Error('User information not found');
      }
      
      const response = await apiClient.put(`/api/auth/user/${currentUser.username}`, userData);
      
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
    } catch (error) {
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
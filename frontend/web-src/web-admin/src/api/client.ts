// client.ts
import axios, { AxiosError } from 'axios';
import authService from '../api/services/authService';
import type { User } from '../api/services/authService';

// Environment configuration
const isDevelopment = import.meta.env.DEV;
// Build RAW base without '/api', then append '/api' exactly once
const RAW_BASE = (import.meta.env.VITE_API_URL as string) || (isDevelopment ? 'http://localhost:3001' : 'https://maize-watch-web-backend.onrender.com');
const API_BASE_URL = `${RAW_BASE.replace(/\/+$/, '')}/api`;

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
    // Normalize path: remove any leading '/api' because baseURL already ends with '/api'
    if (typeof config.url === 'string') {
      config.url = config.url.replace(/^\/api(\/|$)/, '/');
    }

    // Get token directly from localStorage to avoid circular imports
    const token = localStorage.getItem('token');
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
    // Handle authentication errors
    if (error.response?.status === 401) {
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
      throw error;
    }
  },

  // Get all users with field selection
  getUsers: async (retryCount = 0): Promise<User[]> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      const response = await apiClient.get('/users', {
        params: { limit: 1000, page: 1 },
        timeout: 10000
      });
      if (response.data?.success && response.data?.data?.users) {
        return response.data.data.users;
      } else {
        return response.data?.users || response.data || [];
      }
    } catch (error: any) {
      if (error.code === 'ECONNABORTED' && retryCount < 2) {
        return userService.getUsers(retryCount + 1);
      }
      throw error;
    }
  },

  getTotalUsers: async (): Promise<number> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      const response = await apiClient.get('/users/stats');
      if (response.data?.success && response.data?.data?.overview?.totalUsers !== undefined) {
        return response.data.data.overview.totalUsers;
      }
      return 0;
    } catch (error: any) {
      return 0;
    }
  },

  getUserById: async (id: string): Promise<User> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      const response = await apiClient.get(`/users/${id}`);
      if (response.data?.success && response.data?.data?.user) {
        return response.data.data.user;
      } else {
        return response.data?.user || response.data;
      }
    } catch (error: any) {
      throw error;
    }
  },

  createUser: async (userData: Omit<User, "_id">): Promise<User> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      console.log("SENDING createUser payload:", userData);
      const response = await apiClient.post('/users', userData);

      if (response.data?.success && response.data?.data?.user) {
        return response.data.data.user;
      } else {
        return response.data?.user || response.data;
      }
    } catch (error: any) {
      console.log("CREATE USER FAILED");
      console.log("status:", error?.response?.status);
      console.log("data:", error?.response?.data);          // ✅ this is err.response.data
      console.log("message:", error?.message);
      throw error;
    }
  },


  updateUser: async (id: string, userData: Partial<User>): Promise<User> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      const response = await apiClient.put(`/users/${id}`, userData);
      if (response.data?.success && response.data?.data?.user) {
        return response.data.data.user;
      } else {
        return response.data?.user || response.data;
      }
    } catch (error: any) {
      throw error;
    }
  },

  getProfile: async (): Promise<User> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      const response = await apiClient.get('/profile');
      if (response.data) {
        localStorage.setItem('user_data', JSON.stringify(response.data));
      }
      return response.data;
    } catch (error: any) {
      throw error;
    }
  },

  updateProfile: async (userData: Partial<User>): Promise<User> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      const response = await apiClient.put('/auth/me', userData);
      if (response.data?.data) {
        const updatedUser = response.data.data;
        localStorage.setItem('user_data', JSON.stringify(updatedUser));
      }
      return response.data?.data || response.data;
    } catch (error: any) {
      if (error.response?.data?.message) {
        throw new Error(error.response.data.message);
      }
      throw new Error('Failed to update profile. Please try again.');
    }
  },

  deleteUser: async (id: string, reason?: string): Promise<{ message: string }> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      const response = await apiClient.delete(`/users/${id}`, {
        data: { reason }
      });
      return response.data;
    } catch (error: any) {
      throw error;
    }
  },

  getPendingDeletions: async (): Promise<any[]> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      const response = await apiClient.get('/users/pending-deletions');
      if (response.data?.success && response.data?.data?.pendingDeletions) {
        return response.data.data.pendingDeletions;
      }
      return [];
    } catch (error: any) {
      throw error;
    }
  },

  approveDeletion: async (id: string): Promise<{ message: string }> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      const response = await apiClient.post(`/users/${id}/approve-deletion`);
      return response.data;
    } catch (error: any) {
      throw error;
    }
  },

  rejectDeletion: async (id: string, rejectionReason?: string): Promise<{ message: string }> => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      const response = await apiClient.post(`/users/${id}/reject-deletion`, {
        rejectionReason
      });
      return response.data;
    } catch (error: any) {
      throw error;
    }
  },
};

// Activity logs API service
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
      Object.entries(filters).forEach(([key, value]) => {
        if (value !== '' && value !== false && value !== null && value !== undefined) {
          params[key] = value.toString();
        }
      });
      const response = await apiClient.get('/activity-logs', { params });
      return { success: true, data: response.data, status: response.status };
    } catch (error: any) {
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
      const response = await apiClient.get('/activity-logs', { params });
      return { success: true, data: response.data, status: response.status };
    } catch (error: any) {
      return {
        success: false,
        error: error.response?.data?.message || error.message,
        status: error.response?.status || 0
      };
    }
  }
};

export default apiClient;

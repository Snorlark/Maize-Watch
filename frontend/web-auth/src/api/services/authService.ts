// src/api/services/authService.ts
import apiClient from '../client';

// Define types
export interface RegisterPayload {
  username: string;
  password: string;
  fullName: string;
  contactNumber: string;
  address: string;
}

export interface LoginPayload {
  username: string;
  password: string;
}

export interface User {
  _id: string;
  username: string;
  fullName: string;
  contactNumber: string;
  address: string;
  role: string;
}

export interface AuthResponse {
  success: boolean;
  message: string;
  data?: {
    user: User;
    token: string;
  };
}

const authService = {
  // Register a new user
  register: async (userData: RegisterPayload): Promise<AuthResponse> => {
    try {
      const response = await apiClient.post('/auth/register', userData);
      return response.data;
    } catch (error: any) {
      if (error.response) {
        return error.response.data;
      }
      return {
        success: false,
        message: 'Network error. Please try again.',
      };
    }
  },

  // Login user
  login: async (credentials: LoginPayload): Promise<AuthResponse> => {
    try {
      const response = await apiClient.post('/auth/login', credentials);
      
      // Store token and user data if login successful
      if (response.data.success && response.data.data?.token) {
        localStorage.setItem('token', response.data.data.token);
        localStorage.setItem('user', JSON.stringify(response.data.data.user));
      }
      
      return response.data;
    } catch (error: any) {
      if (error.response) {
        return error.response.data;
      }
      return {
        success: false,
        message: 'Network error. Please try again.',
      };
    }
  },

  // Logout user
  logout: (): void => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  },

  // Check if user is authenticated
  isAuthenticated: (): boolean => {
    return !!localStorage.getItem('token');
  },

  // Get current user info
  getCurrentUser: (): User | null => {
    const userString = localStorage.getItem('user');
    if (userString) {
      return JSON.parse(userString);
    }
    return null;
  },

  // Check if current user is an admin
  isAdmin: (): boolean => {
    const user = authService.getCurrentUser();
    return user?.role === 'admin';
  },

  // Setup admin account (one-time use)
  setupAdmin: async (adminData?: Partial<RegisterPayload>): Promise<AuthResponse> => {
    try {
      const response = await apiClient.post('/setup/create-admin', adminData || {});
      return response.data;
    } catch (error: any) {
      if (error.response) {
        return error.response.data;
      }
      return {
        success: false,
        message: 'Network error. Please try again.',
      };
    }
  }
};

export default authService;
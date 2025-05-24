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
  _id?: string;
  userId?: string;
  username: string;
  fullName?: string;
  contactNumber?: string;
  address?: string;
  role: string;
  email?: string;
}

export interface AuthResponse {
  success: boolean;
  message: string;
  data?: {
    user: User;
    token: string;
  };
}

const TOKEN_KEY = 'auth_token';
const USER_KEY = 'user_data';
  // Register a new user
  register: async (userData: RegisterPayload): Promise<AuthResponse> => {
    try {
      const response = await apiClient.post('/api/register', userData);
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

  // Login user (API version)
  login: async (credentials: LoginPayload): Promise<AuthResponse> => {
    try {
      const response = await apiClient.post('/auth/login', credentials);

      if (response.data.success && response.data.data?.token) {
        localStorage.setItem(TOKEN_KEY, response.data.data.token);
        localStorage.setItem(USER_KEY, JSON.stringify(response.data.data.user));
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
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
  },

  // Check if user is authenticated
  isAuthenticated: (): boolean => {
    return !!localStorage.getItem(TOKEN_KEY);
  },

  // Get stored token
  getToken: (): string | null => {
    return localStorage.getItem(TOKEN_KEY);
  },

  // Get current user info from localStorage
  getCurrentUser: (): User | null => {
    const userString = localStorage.getItem(USER_KEY);
    if (userString) {
      try {
        return JSON.parse(userString);
      } catch (e) {
        return null;
      }
    }

    // Fallback: Try decoding from token (mock/demo fallback)
    const token = authService.getToken();
    if (token) {
      const parts = token.split('.');
      if (parts.length === 2) {
        try {
          const payload = JSON.parse(atob(parts[1]));
          return {
            userId: payload.userId,
            role: payload.role,
            username: payload.username
          };
        } catch (e) {
          return null;
        }
      }
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

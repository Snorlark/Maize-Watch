// src/api/services/authService.ts
import apiClient from '../client';

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

// Use consistent token key across your app
const TOKEN_KEY = 'token'; // Changed to match client.ts and utils/api.ts
const USER_KEY = 'user_data';

// Helper function to validate JWT token format
const isValidJWTFormat = (token: string): boolean => {
  if (!token || typeof token !== 'string') {
    return false;
  }
  
  const parts = token.split('.');
  return parts.length === 3 && parts.every(part => part.length > 0);
};

// Helper function to safely decode JWT payload
const decodeJWTPayload = (token: string): any | null => {
  try {
    if (!isValidJWTFormat(token)) {
      console.warn('Invalid JWT format detected');
      return null;
    }
    
    const parts = token.split('.');
    const payload = JSON.parse(atob(parts[1]));
    
    // Check if token is expired
    const currentTime = Math.floor(Date.now() / 1000);
    if (payload.exp && payload.exp < currentTime) {
      console.warn('Token has expired');
      return null;
    }
    
    return payload;
  } catch (error) {
    console.error('Error decoding JWT payload:', error);
    return null;
  }
};

// Helper function to clean up invalid tokens
const cleanupInvalidTokens = (): void => {
  const token = localStorage.getItem(TOKEN_KEY);
  if (token && !isValidJWTFormat(token)) {
    console.log('Cleaning up invalid token from storage');
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
  }
};

const authService = {
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
      const response = await apiClient.post('/api/auth/login', credentials);

      if (response.data.success && response.data.data?.token) {
        const token = response.data.data.token;
        
        // Validate token format before storing
        if (isValidJWTFormat(token)) {
          localStorage.setItem(TOKEN_KEY, token);
          localStorage.setItem(USER_KEY, JSON.stringify(response.data.data.user));
        } else {
          console.error('Received invalid JWT token format from server');
          return {
            success: false,
            message: 'Invalid token received from server',
          };
        }
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

  // Check if user is authenticated with proper validation
  isAuthenticated: (): boolean => {
    cleanupInvalidTokens();
    const token = localStorage.getItem(TOKEN_KEY);
    
    if (!token || !isValidJWTFormat(token)) {
      return false;
    }
    
    // Additional check for token expiration
    const payload = decodeJWTPayload(token);
    if (!payload) {
      authService.logout(); // Clean up expired token
      return false;
    }
    
    return true;
  },

  // Get stored token (with validation)
  getToken: (): string | null => {
    cleanupInvalidTokens();
    const token = localStorage.getItem(TOKEN_KEY);
    
    if (!token) {
      return null;
    }
    
    // Validate token format and expiration
    if (!isValidJWTFormat(token)) {
      console.warn('Invalid JWT token found in storage, removing it');
      authService.logout();
      return null;
    }
    
    // Check if token is expired
    const payload = decodeJWTPayload(token);
    if (!payload) {
      console.warn('Token is expired or invalid, removing it');
      authService.logout();
      return null;
    }
    
    return token;
  },

  // Get current user info from localStorage with fallback to token
  getCurrentUser: (): User | null => {
    // Clean up any invalid tokens first
    cleanupInvalidTokens();
    
    // First, try to get user data from localStorage
    const userString = localStorage.getItem(USER_KEY);
    if (userString) {
      try {
        const user = JSON.parse(userString);
        // Verify we still have a valid token
        if (authService.getToken()) {
          return user;
        }
      } catch (e) {
        console.error('Error parsing user data from localStorage:', e);
        localStorage.removeItem(USER_KEY);
      }
    }

    // Fallback: Try decoding from valid JWT token
    const token = authService.getToken();
    if (token) {
      const payload = decodeJWTPayload(token);
      if (payload && payload.userId) {
        return {
          userId: payload.userId,
          role: payload.role,
          username: payload.username || ''
        };
      }
    }

    return null;
  },

  // Check if current user is an admin
  isAdmin: (): boolean => {
    const user = authService.getCurrentUser();
    return user?.role === 'admin';
  },
  
  isSuperAdmin: (): boolean => {
    const user = authService.getCurrentUser();
    return user?.role === 'super_admin';
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
  },

  // Utility method to refresh user data
  refreshUserData: async (): Promise<User | null> => {
    try {
      if (!authService.isAuthenticated()) {
        return null;
      }
      
      const response = await apiClient.get('/api/profile');
      if (response.data) {
        localStorage.setItem(USER_KEY, JSON.stringify(response.data));
        return response.data;
      }
    } catch (error) {
      console.error('Error refreshing user data:', error);
    }
    return null;
  },

  // Clear invalid tokens (utility method)
  clearInvalidTokens: (): void => {
    cleanupInvalidTokens();
  }
};

export default authService;
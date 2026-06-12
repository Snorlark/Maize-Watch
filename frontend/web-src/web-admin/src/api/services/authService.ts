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
  username?: string;
  email?: string;
  password: string;
  deviceType?: string;
}

export interface User {
  _id?: string;
  userId?: string;
  username: string;
  email?: string;
  fullName?: string;
  contactNumber?: string;
  address?: {
    region: string;
    province: string;
    municipality: string;
    barangay: string;
  } | string;
  region?: string;
  province?: string;
  municipality?: string;
  barangay?: string;
  role: string;
  assignedRegion?: string;
  isActive?: boolean;
  createdAt?: string;
  lastLogin?: string;
}

export interface AuthResponse {
  success: boolean;
  message: string;
  data?: {
    user: User;
    token: string;
  };
}

const TOKEN_KEY = 'token';
const USER_KEY = 'user_data';

const isValidJWTFormat = (token: string): boolean => {
  if (!token || typeof token !== 'string') {
    return false;
  }
  const parts = token.split('.');
  return parts.length === 3 && parts.every(part => part.length > 0);
};

const decodeJWTPayload = (token: string): any | null => {
  try {
    if (!isValidJWTFormat(token)) {
      return null;
    }
    const parts = token.split('.');
    const payload = JSON.parse(atob(parts[1]));
    const currentTime = Math.floor(Date.now() / 1000);
    if (payload.exp && payload.exp < currentTime) {
      return null;
    }
    return payload;
  } catch {
    return null;
  }
};

const cleanupInvalidTokens = (): void => {
  const token = localStorage.getItem(TOKEN_KEY);
  if (token && !isValidJWTFormat(token)) {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
  }
};

const authService = {
  register: async (userData: RegisterPayload): Promise<AuthResponse> => {
    try {
      const response = await apiClient.post('/api/register', userData);
      return response.data;
    } catch (error: any) {
      if (error.response) {
        return error.response.data;
      }
      return { success: false, message: 'Network error. Please try again.' };
    }
  },

  login: async (usernameOrEmail: string, password: string): Promise<AuthResponse> => {
    try {
      const isEmail = usernameOrEmail.includes('@');
      const credentials = {
        email: isEmail ? usernameOrEmail : '',
        username: isEmail ? '' : usernameOrEmail,
        password,
        deviceType: 'web'
      };
      const response = await apiClient.post('/api/auth/login', credentials);
      const token = response.data.data?.accessToken || response.data.data?.token;

      if (response.data.success && token) {
        if (isValidJWTFormat(token)) {
          localStorage.setItem(TOKEN_KEY, token);
          localStorage.setItem(USER_KEY, JSON.stringify(response.data.data.user));
        } else {
          return { success: false, message: 'Invalid token received from server' };
        }
      }
      return response.data;
    } catch (error: any) {
      if (error.response) {
        return error.response.data;
      }
      return { success: false, message: 'Network error. Please try again.' };
    }
  },

  logout: (): void => {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
  },

  isAuthenticated: (): boolean => {
    cleanupInvalidTokens();
    const token = localStorage.getItem(TOKEN_KEY);
    if (!token || !isValidJWTFormat(token)) {
      return false;
    }
    const payload = decodeJWTPayload(token);
    if (!payload) {
      authService.logout();
      return false;
    }
    return true;
  },

  getToken: (): string | null => {
    cleanupInvalidTokens();
    const token = localStorage.getItem(TOKEN_KEY);
    if (!token) {
      return null;
    }
    if (!isValidJWTFormat(token)) {
      authService.logout();
      return null;
    }
    const payload = decodeJWTPayload(token);
    if (!payload) {
      authService.logout();
      return null;
    }
    return token;
  },

  getCurrentUser: (): User | null => {
    cleanupInvalidTokens();
    const userString = localStorage.getItem(USER_KEY);
    if (userString) {
      try {
        const user = JSON.parse(userString);
        if (authService.getToken()) {
          return user;
        }
      } catch {
        localStorage.removeItem(USER_KEY);
      }
    }
    const token = authService.getToken();
    if (token) {
      const payload = decodeJWTPayload(token);
      if (payload && payload.userId) {
        return { userId: payload.userId, role: payload.role, username: payload.username || '' };
      }
    }
    return null;
  },

  isAdmin: (): boolean => {
    const user = authService.getCurrentUser();
    return user?.role === 'regional_admin' || user?.role === 'admin' || user?.role === 'super_admin';
  },

  isSuperAdmin: (): boolean => {
    const user = authService.getCurrentUser();
    return user?.role === 'super_admin';
  },

  setupAdmin: async (adminData?: Partial<RegisterPayload>): Promise<AuthResponse> => {
    try {
      const response = await apiClient.post('/setup/create-admin', adminData || {});
      return response.data;
    } catch (error: any) {
      if (error.response) {
        return error.response.data;
      }
      return { success: false, message: 'Network error. Please try again.' };
    }
  },

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
    } catch {
      return null;
    }
    return null;
  },

  clearInvalidTokens: (): void => {
    cleanupInvalidTokens();
  },

  sendLoginOTP: async (email: string): Promise<AuthResponse> => {
    try {
      const response = await apiClient.post('/api/auth/send-login-otp', { email });
      return response.data;
    } catch (error: any) {
      if (error.response) {
        return error.response.data;
      }
      return { success: false, message: 'Network error. Please try again.' };
    }
  },

  verifyLoginOTP: async (email: string, otp: string): Promise<AuthResponse> => {
    try {
      const response = await apiClient.post('/api/auth/verify-login-otp', { email, otp });
      if (response.data.success && response.data.data?.accessToken) {
        const token = response.data.data.accessToken;
        if (isValidJWTFormat(token)) {
          localStorage.setItem(TOKEN_KEY, token);
          localStorage.setItem(USER_KEY, JSON.stringify(response.data.data.user));
        } else {
          return { success: false, message: 'Invalid token received from server' };
        }
      }
      return response.data;
    } catch (error: any) {
      if (error.response) {
        return error.response.data;
      }
      return { success: false, message: 'Network error. Please try again.' };
    }
  },

  sendForgotPasswordOTP: async (email: string): Promise<AuthResponse> => {
    try {
      const response = await apiClient.post('/api/auth/send-forgot-password-otp', { email });
      return response.data;
    } catch (error: any) {
      if (error.response) {
        return error.response.data;
      }
      return { success: false, message: 'Network error. Please try again.' };
    }
  },

  verifyForgotPasswordOTP: async (email: string, otp: string): Promise<AuthResponse> => {
    try {
      const response = await apiClient.post('/api/auth/verify-forgot-password-otp', { email, otp });
      return response.data;
    } catch (error: any) {
      if (error?.response) {
        return error.response.data;
      }
      return { success: false, message: 'Network error. Please try again.' };
    }
  },

  resetPassword: async (email: string, otp: string, newPassword: string): Promise<AuthResponse> => {
    try {
      const response = await apiClient.post('/api/auth/reset-password', { email, otp, newPassword });
      return response.data;
    } catch (error: any) {
      if (error?.response) {
        return error.response.data;
      }
      return { success: false, message: 'Network error. Please try again.' };
    }
  }
};

export default authService;

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
  } | string; // Support both old string format and new object format
  region?: string; // Keep for backward compatibility
  province?: string; // Keep for backward compatibility
  municipality?: string; // Keep for backward compatibility
  barangay?: string; // Keep for backward compatibility
  role: string;
  assignedRegion?: string; // For regional admins
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
  login: async (usernameOrEmail: string, password: string): Promise<AuthResponse> => {
    try {
      // Determine if input is email or username
      const isEmail = usernameOrEmail.includes('@');
      
      const credentials = {
        email: isEmail ? usernameOrEmail : '',
        username: isEmail ? '' : usernameOrEmail,
        password,
        deviceType: 'web'
      };
      
      console.log('🔐 Login attempt with credentials:', {
        ...credentials,
        password: '[REDACTED]'
      });
      
      const response = await apiClient.post('/api/auth/login', credentials);
      
      console.log('🔍 Login response debug:', {
        success: response.data.success,
        hasData: !!response.data.data,
        hasToken: !!response.data.data?.token,
        dataKeys: response.data.data ? Object.keys(response.data.data) : [],
        fullResponse: response.data
      });

      // Backend returns accessToken, not token
      const token = response.data.data?.accessToken || response.data.data?.token;
      
      console.log('🔍 Token extraction debug:', {
        hasAccessToken: !!response.data.data?.accessToken,
        hasToken: !!response.data.data?.token,
        extractedToken: token ? `${token.substring(0, 30)}...` : 'none',
        tokenType: typeof token,
        tokenLength: token ? token.length : 0
      });
      
      if (response.data.success && token) {
        
        // Validate token format before storing
        const isValidFormat = isValidJWTFormat(token);
        console.log('🔍 JWT validation debug:', {
          isValidFormat,
          tokenParts: token.split('.').length,
          tokenPreview: token.substring(0, 50) + '...'
        });
        
        if (isValidFormat) {
          localStorage.setItem(TOKEN_KEY, token);
          localStorage.setItem(USER_KEY, JSON.stringify(response.data.data.user));
          
          console.log('✅ Token stored successfully:', {
            tokenKey: TOKEN_KEY,
            tokenStored: !!localStorage.getItem(TOKEN_KEY),
            userStored: !!localStorage.getItem(USER_KEY),
            tokenPreview: token.substring(0, 20) + '...'
          });
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

  // Check if current user is an admin (including regional admin)
  isAdmin: (): boolean => {
    const user = authService.getCurrentUser();
    return user?.role === 'regional_admin' || user?.role === 'admin' || user?.role === 'super_admin';
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
  },

  // Send OTP for email-based login (Web Admin)
  sendLoginOTP: async (email: string): Promise<AuthResponse> => {
    try {
      console.log('🔐 Sending OTP to email:', email);
      
      const response = await apiClient.post('/api/auth/send-login-otp', { email });
      
      console.log('📧 OTP send response:', {
        success: response.data.success,
        message: response.data.message,
        expiresIn: response.data.expiresIn
      });

      return response.data;
    } catch (error: any) {
      console.error('❌ Failed to send OTP:', error);
      if (error.response) {
        return error.response.data;
      }
      return {
        success: false,
        message: 'Network error. Please try again.',
      };
    }
  },

  // Verify OTP and complete login (Web Admin)
  verifyLoginOTP: async (email: string, otp: string): Promise<AuthResponse> => {
    try {
      console.log('🔐 Verifying OTP for email:', email);
      console.log('🔐 OTP being sent:', otp);
      console.log('🔐 Request payload:', { email, otp });
      
      const response = await apiClient.post('/api/auth/verify-login-otp', { 
        email, 
        otp 
      });
      
      console.log('🔍 OTP verification response:', {
        success: response.data.success,
        hasData: !!response.data.data,
        hasToken: !!response.data.data?.accessToken,
        message: response.data.message
      });

      // Handle successful OTP verification
      if (response.data.success && response.data.data?.accessToken) {
        const token = response.data.data.accessToken;
        
        // Validate token format before storing
        const isValidFormat = isValidJWTFormat(token);
        console.log('🔍 OTP JWT validation:', {
          isValidFormat,
          tokenParts: token.split('.').length,
          tokenPreview: token.substring(0, 50) + '...'
        });
        
        if (isValidFormat) {
          localStorage.setItem(TOKEN_KEY, token);
          localStorage.setItem(USER_KEY, JSON.stringify(response.data.data.user));
          
          console.log('✅ OTP login successful, token stored:', {
            tokenKey: TOKEN_KEY,
            tokenStored: !!localStorage.getItem(TOKEN_KEY),
            userStored: !!localStorage.getItem(USER_KEY)
          });
        } else {
          console.error('Received invalid JWT token format from OTP verification');
          return {
            success: false,
            message: 'Invalid token received from server',
          };
        }
      }

      return response.data;
    } catch (error: any) {
      console.error('❌ OTP verification failed:', error);
      console.error('❌ Error response data:', error.response?.data);
      console.error('❌ Error status:', error.response?.status);
      if (error.response) {
        return error.response.data;
      }
      return {
        success: false,
        message: 'Network error. Please try again.',
      };
    }
  },

  // Send forgot password OTP
  sendForgotPasswordOTP: async (email: string): Promise<AuthResponse> => {
    try {
      console.log('🔐 Sending forgot password OTP to email:', email);
      
      const response = await apiClient.post('/api/auth/send-forgot-password-otp', { 
        email 
      });
      
      console.log('🔍 Forgot password OTP response:', {
        success: response.data.success,
        message: response.data.message
      });

      return response.data;
    } catch (error: any) {
      console.error('❌ Send forgot password OTP failed:', error);
      console.error('❌ Error response data:', error.response?.data);
      if (error.response) {
        return error.response.data;
      }
      return {
        success: false,
        message: 'Network error. Please try again.',
      };
    }
  },
  
  // Verify forgot password OTP
  verifyForgotPasswordOTP: async (email: string, otp: string): Promise<AuthResponse> => {
    try {
      console.log('🔐 Verifying forgot password OTP for email:', email);
      
      const response = await apiClient.post('/api/auth/verify-forgot-password-otp', { 
        email, 
        otp 
      });
      
      console.log('🔍 Forgot password OTP verification response:', {
        success: response.data.success,
        message: response.data.message
      });

      return response.data;
    } catch (error: any) {
      console.error('❌ Forgot password OTP verification failed:', error);
      console.error('❌ Error response data:', error?.response?.data);
      if (error?.response) {
        return error.response.data;
      }
      return {
        success: false,
        message: 'Network error. Please try again.',
      };
    }
  },
  
  // Reset password with verified OTP
  resetPassword: async (email: string, otp: string, newPassword: string): Promise<AuthResponse> => {
    try {
      console.log('🔐 Resetting password for email:', email);
      
      const response = await apiClient.post('/api/auth/reset-password', { 
        email, 
        otp,
        newPassword 
      });
      
      console.log('🔍 Password reset response:', {
        success: response.data.success,
        message: response.data.message
      });

      return response.data;
    } catch (error: any) {
      console.error('❌ Password reset failed:', error);
      console.error('❌ Error response data:', error?.response?.data);
      if (error?.response) {
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
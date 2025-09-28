import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import authService, { User } from '../api/services/authService';
import * as jwt_decode from 'jwt-decode';

// Define token payload type
interface TokenPayload {
  userId: string;
  username: string;
  role: string;
  exp: number;
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  loading: boolean;
  login: (username: string, password: string) => Promise<{ success: boolean; requiresOTP?: boolean; email?: string; message?: string; data?: any }>;
  verifyOTP: (email: string, otp: string) => Promise<boolean>;
  sendForgotPasswordOTP: (email: string) => Promise<{ success: boolean; message?: string }>;
  verifyForgotPasswordOTP: (email: string, otp: string) => Promise<{ success: boolean; message?: string }>;
  resetPassword: (email: string, otp: string, newPassword: string) => Promise<{ success: boolean; message?: string }>;
  logout: () => void;
  resetInactivityTimer: () => void;
  refreshUserData: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

interface AuthProviderProps {
  children: ReactNode;
}

// Add to your existing auth utilities
export const hasRole = (userRole: string, requiredRole: string): boolean => {
  const roleHierarchy: Record<string, number> = {
    'farmer': 1,
    'admin': 2,
    'super_admin': 3
  };
  
  const userLevel = roleHierarchy[userRole] || 0;
  const requiredLevel = roleHierarchy[requiredRole] || 0;
  
  return userLevel >= requiredLevel;
};

export const isSuperAdmin = (userRole: string): boolean => {
  return userRole === 'super_admin';
};

// Inactivity timeout in milliseconds (15 minutes = 900000ms)
const INACTIVITY_TIMEOUT = 900000;

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [inactivityTimer, setInactivityTimer] = useState<NodeJS.Timeout | null>(null);
  const navigate = useNavigate();

  // Function to decode and validate token
  const parseToken = (token: string): User | null => {
    try {
      const decoded = jwt_decode.jwtDecode<TokenPayload>(token);
      
      // Check if token is expired
      const currentTime = Date.now() / 1000;
      if (decoded.exp < currentTime) {
        return null;
      }
      
      // Return user data from token
      return {
        userId: decoded.userId,
        username: decoded.username,
        role: decoded.role
      };
    } catch (error) {
      console.error('Error parsing token:', error);
      return null;
    }
  };

  // Start the inactivity timer
  const startInactivityTimer = () => {
    // Clear any existing timer
    if (inactivityTimer) {
      clearTimeout(inactivityTimer);
    }
    
    // Set inactivity timer (full timeout - direct logout)
    const inactivityTimerInstance = setTimeout(() => {
      logout();
    }, INACTIVITY_TIMEOUT);
    
    setInactivityTimer(inactivityTimerInstance);
  };

  // Reset the inactivity timer
  const resetInactivityTimer = () => {
    if (user) {
      startInactivityTimer();
    }
  };

  useEffect(() => {
    // Check if user is already logged in
    const checkAuth = async () => {
      const token = authService.getToken();
      if (token) {
        const userData = parseToken(token);
        if (userData) {
          setUser(userData);
          startInactivityTimer();
        } else {
          // Token is invalid or expired, clear it
          authService.logout();
        }
      }
      setLoading(false);
    };
    
    checkAuth();
  }, []);

  // Add event listeners for user activity
  useEffect(() => {
    if (user) {
      // Track user activity events
      const activityEvents = ['mousedown', 'keypress', 'scroll', 'mousemove', 'click', 'touchstart'];
      
      const resetTimer = () => {
        resetInactivityTimer();
      };
      
      // Add event listeners
      activityEvents.forEach(event => {
        window.addEventListener(event, resetTimer);
      });
      
      // Initial timer
      startInactivityTimer();
      
      // Cleanup
      return () => {
        if (inactivityTimer) {
          clearTimeout(inactivityTimer);
        }
        
        activityEvents.forEach(event => {
        });
      };
    }
  }, [user]);

  const login = async (username: string, password: string): Promise<{ success: boolean; requiresOTP?: boolean; email?: string; message?: string; data?: any }> => {
    try {
      const response = await authService.login(username, password);
      
      if (response.success) {
        // Check if OTP is required
        if ((response as any).requiresOTP) {
          console.log('Login response with OTP required:', response);
          return {
            success: true,
            requiresOTP: true,
            data: (response as any).data, // Pass the entire data object
            message: response.message
          };
        }
        
        // Complete login (no OTP required)
        if (response.data?.user) {
          setUser(response.data.user);
          startInactivityTimer();
          return { success: true };
        }
      }
      
      return { 
        success: false, 
        message: response.message || 'Login failed' 
      };
    } catch (error) {
      console.error('Login error:', error);
      return { 
        success: false, 
        message: 'Login failed. Please try again.' 
      };
    }
  };

  const verifyOTP = async (email: string, otp: string): Promise<boolean> => {
    try {
      const response = await authService.verifyLoginOTP(email, otp);
      if (response.success && response.data?.user) {
        setUser(response.data.user);
        startInactivityTimer();
        return true;
      }
      return false;
    } catch (error) {
      console.error('Verify OTP error:', error);
      return false;
    }
  };

  const logout = () => {
    authService.logout();
    setUser(null);
    
    if (inactivityTimer) {
      clearTimeout(inactivityTimer);
      setInactivityTimer(null);
    }
    
    // Redirect to login page
    navigate('/');
  };

  const refreshUserData = () => {
    const token = authService.getToken();
    if (token) {
      const userData = parseToken(token);
      if (userData) {
        setUser(userData);
      }
    }
  };

  // Forgot password methods
  const sendForgotPasswordOTP = async (email: string): Promise<{ success: boolean; message?: string }> => {
    try {
      const response = await authService.sendForgotPasswordOTP(email);
      return { success: response.success, message: response.message };
    } catch (error) {
      console.error('Send forgot password OTP error:', error);
      return { success: false, message: 'Failed to send OTP. Please try again.' };
    }
  };

  const verifyForgotPasswordOTP = async (email: string, otp: string): Promise<{ success: boolean; message?: string }> => {
    try {
      const response = await authService.verifyForgotPasswordOTP(email, otp);
      return { success: response.success, message: response.message };
    } catch (error) {
      console.error('Verify forgot password OTP error:', error);
      return { success: false, message: 'Failed to verify OTP. Please try again.' };
    }
  };

  const resetPassword = async (email: string, otp: string, newPassword: string): Promise<{ success: boolean; message?: string }> => {
    try {
      const response = await authService.resetPassword(email, otp, newPassword);
      return { success: response.success, message: response.message };
    } catch (error) {
      console.error('Reset password error:', error);
      return { success: false, message: 'Failed to reset password. Please try again.' };
    }
  };

  const value: AuthContextType = {
    user,
    isAuthenticated: !!user,
    loading,
    login,
    verifyOTP,
    sendForgotPasswordOTP,
    verifyForgotPasswordOTP,
    resetPassword,
    logout,
    resetInactivityTimer,
    refreshUserData
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};
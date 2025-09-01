import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import authService, { User } from '../api/services/authService';
import * as jwt_decode from 'jwt-decode'; // Changed to named import
import SessionExpirationModal from '../components/SessionExpirationModal';

// Define token payload type
interface TokenPayload {
  userId: string;
  username: string; // Added username to the TokenPayload
  role: string;
  exp: number;
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  loading: boolean;
  login: (username: string, password: string) => Promise<boolean>;
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
// Warning timeout (2 minutes before expiration = 120000ms)
const WARNING_TIMEOUT = 120000;

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [inactivityTimer, setInactivityTimer] = useState<NodeJS.Timeout | null>(null);
  const [warningTimer, setWarningTimer] = useState<NodeJS.Timeout | null>(null);
  const [showSessionModal, setShowSessionModal] = useState(false);
  const [timeRemaining, setTimeRemaining] = useState(120); // 2 minutes in seconds
  const navigate = useNavigate();

  // Function to decode and validate token
  const parseToken = (token: string): User | null => {
    try {
      const decoded = jwt_decode.jwtDecode<TokenPayload>(token); // Using named import
      
      // Check if token is expired
      const currentTime = Date.now() / 1000;
      if (decoded.exp < currentTime) {
        return null;
      }
      
      // Return user data from token
      return {
        userId: decoded.userId,
        username: decoded.username, // Include username from token
        role: decoded.role
      };
    } catch (error) {
      console.error('Error parsing token:', error);
      return null;
    }
  };

  // Start the inactivity timer
  const startInactivityTimer = () => {
    // Clear any existing timers
    if (inactivityTimer) {
      clearTimeout(inactivityTimer);
    }
    if (warningTimer) {
      clearTimeout(warningTimer);
    }
    
    // Set warning timer (2 minutes before expiration)
    const warningTimerInstance = setTimeout(() => {
      setShowSessionModal(true);
      setTimeRemaining(120); // 2 minutes
    }, INACTIVITY_TIMEOUT - WARNING_TIMEOUT);
    
    // Set inactivity timer (full timeout)
    const inactivityTimerInstance = setTimeout(() => {
      logout();
    }, INACTIVITY_TIMEOUT);
    
    setWarningTimer(warningTimerInstance);
    setInactivityTimer(inactivityTimerInstance);
  };

  // Reset the inactivity timer
  const resetInactivityTimer = () => {
    if (user) {
      startInactivityTimer();
    }
  };

  // Handle session extension
  const handleExtendSession = () => {
    setShowSessionModal(false);
    resetInactivityTimer();
  };

  // Handle session logout
  const handleSessionLogout = () => {
    setShowSessionModal(false);
    logout();
  };

  // Close session modal
  const handleCloseSessionModal = () => {
    setShowSessionModal(false);
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
        if (warningTimer) {
          clearTimeout(warningTimer);
        }
        
        activityEvents.forEach(event => {
          window.removeEventListener(event, resetTimer);
        });
      };
    }
  }, [user]);

  const login = async (username: string, password: string): Promise<boolean> => {
    try {
      const response = await authService.login({ username, password });
      if (response.success && response.data?.user) {
        setUser(response.data.user);
        startInactivityTimer();
        return true;
      }
      return false;
    } catch (error) {
      console.error('Login error:', error);
      return false;
    }
  };

  const logout = () => {
    authService.logout();
    setUser(null);
    setShowSessionModal(false);
    
    if (inactivityTimer) {
      clearTimeout(inactivityTimer);
      setInactivityTimer(null);
    }
    if (warningTimer) {
      clearTimeout(warningTimer);
      setWarningTimer(null);
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

  const value = {
    user,
    isAuthenticated: !!user,
    loading,
    login,
    logout,
    resetInactivityTimer,
    refreshUserData
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
      <SessionExpirationModal
        isOpen={showSessionModal}
        onClose={handleCloseSessionModal}
        onExtendSession={handleExtendSession}
        onLogout={handleSessionLogout}
        timeRemaining={timeRemaining}
      />
    </AuthContext.Provider>
  );
};
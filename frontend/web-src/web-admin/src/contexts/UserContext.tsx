import { createContext, useContext, useState, useEffect, ReactNode } from "react";
import { userService } from "../api/client";
import { useAuth } from './AuthContext';
import { User } from "../api/services/authService"; // Single source of truth for User type
import authService from '../api/services/authService';

// Define the context shape
interface UserContextType {
  users: User[];
  farmers: User[]; // Farmers filtered from users
  totalUsersCount: number; // Total count of users
  loading: boolean;
  error: string | null;
  errorType: 'network' | 'backend' | 'auth' | 'general' | null;
  currentUser: User | null;
  isAdmin: boolean;
  hasAdminAccess: boolean; // Super Admin only — user management
  fetchUsers: () => Promise<void>;
  addUser: (userData: Omit<User, "_id">) => Promise<User>;
  updateUserById: (id: string, userData: Partial<User>) => Promise<User>;
  deleteUserById: (id: string) => Promise<void>;
  clearError: () => void;
}

// Create the context with default values
const UserContext = createContext<UserContextType | undefined>(undefined);

// Props for the provider component
interface UserProviderProps {
  children: ReactNode;
}

// Provider component
export function UserProvider({ children }: UserProviderProps) {
  const { user, isAuthenticated } = useAuth();
  const [users, setUsers] = useState<User[]>([]);
  const [totalUsersCount, setTotalUsersCount] = useState<number>(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [errorType, setErrorType] = useState<'network' | 'backend' | 'auth' | 'general' | null>(null);
  const [fetchTriggered, setFetchTriggered] = useState(false);
  const [lastFetchTime, setLastFetchTime] = useState<number>(0);
  
  // Current user is directly from AuthContext (no conversion needed)
  const currentUser = user;

  // Compute isAdmin for backward compatibility (only admin role)
  const isAdmin = user?.role === 'admin';

  // User management is restricted to super_admin
  const hasAdminAccess = user?.role === 'super_admin';

  // Derive farmers from users whenever users change
  const farmers = users.filter(user => user.role === 'user' || user.role === 'farmer');
  
  // Update total users count whenever users array changes
  useEffect(() => {
    setTotalUsersCount(users.length);
  }, [users]);

  // Fetch users only when explicitly called 
  // or when component is mounted with valid admin user
  useEffect(() => {
    const shouldFetchUsers = isAuthenticated && hasAdminAccess && !fetchTriggered;
    
    if (shouldFetchUsers) {
      setFetchTriggered(true);
      fetchUsers().catch(err => {
        console.error('Failed initial user fetch:', err);
      });
    } else if (!hasAdminAccess) {
      // Clear users array when not admin or super_admin
      setUsers([]);
    }
  }, [isAuthenticated, hasAdminAccess]);

  // Function to fetch all users
  const fetchUsers = async () => {
    // Debounce: prevent rapid successive calls
    const now = Date.now();
    if (now - lastFetchTime < 5000) { // 5 second debounce
      console.log('Fetch users debounced - too soon since last call');
      return;
    }
    setLastFetchTime(now);

    // Verify authentication state before attempting to fetch
    if (!isAuthenticated) {
      setError("Authentication required");
      setErrorType('auth');
      setLoading(false);
      return;
    }
    
    // Check if token exists
    const token = authService.getToken();
    if (!token) {
      setError("Authentication token missing. Please log in again.");
      setErrorType('auth');
      setLoading(false);
      return;
    }
    
    setLoading(true);
    setError(null);
    setErrorType(null);
    
    try {
      const fetchedUsers = await userService.getUsers();
      setUsers(fetchedUsers);
    } catch (err: any) {
      // Only log non-timeout errors to reduce console noise
      if (err.code !== 'ECONNABORTED') {
        console.error('Error in fetchUsers:', err);
      }
      
      // Determine error type based on the error
      if (err.code === 'ECONNABORTED' || err.message?.includes('Network Error')) {
        // Don't set error state for timeouts if users are already loaded
        if (users.length === 0) {
          setError('Connection timeout. Please check your internet connection.');
          setErrorType('network');
        }
      } else if (err.response?.status >= 500) {
        setError('Server error. Please try again later.');
        setErrorType('backend');
      } else if (err.response?.status === 401) {
        setError('Authentication failed. Please log in again.');
        setErrorType('auth');
      } else {
        setError(err.message || 'Failed to fetch users');
        setErrorType('general');
      }
    } finally {
      setLoading(false);
    }
  };

  // Function to add a new user
  const addUser = async (userData: Omit<User, "_id">) => {
    if (!hasAdminAccess) {
      const error = new Error("Unauthorized: Admin privileges required");
      setError(error.message);
      setErrorType('auth');
      throw error;
    }

    try {
      setError(null);
      setErrorType(null);
      const newUser = await userService.createUser(userData);
      setUsers((prevUsers) => [...prevUsers, newUser]);
      return newUser;
    } catch (err: any) {
      const errorMessage = err?.response?.data?.message || err?.message || "Failed to add user. Please try again.";
      setError(errorMessage);
      setErrorType(err.response?.status >= 500 ? 'backend' : 'general');
      console.error("Error adding user:", err);
      throw err;
    }
  };

  // Function to update a user
  const updateUserById = async (id: string, userData: Partial<User>) => {
    if (!hasAdminAccess) {
      const error = new Error("Unauthorized: Admin privileges required");
      setError(error.message);
      setErrorType('auth');
      throw error;
    }

    try {
      setError(null);
      setErrorType(null);
      const updatedUser = await userService.updateUser(id, userData);
      setUsers((prevUsers) =>
        prevUsers.map((user) => (user._id === id ? updatedUser : user))
      );
      return updatedUser;
    } catch (err: any) {
      const errorMessage = err?.response?.data?.message || err?.message || "Failed to update user. Please try again.";
      setError(errorMessage);
      setErrorType(err.response?.status >= 500 ? 'backend' : 'general');
      console.error("Error updating user:", err);
      throw err;
    }
  };

  // Function to delete a user
  const deleteUserById = async (id: string) => {
    if (!hasAdminAccess) {
      const error = new Error("Unauthorized: Admin privileges required");
      setError(error.message);
      setErrorType('auth');
      throw error;
    }

    try {
      setError(null);
      setErrorType(null);
      await userService.deleteUser(id);
      setUsers((prevUsers) => prevUsers.filter((user) => user._id !== id));
    } catch (err: any) {
      const errorMessage = err?.response?.data?.message || err?.message || "Failed to delete user. Please try again.";
      setError(errorMessage);
      setErrorType(err.response?.status >= 500 ? 'backend' : 'general');
      console.error("Error deleting user:", err);
      throw err;
    }
  };

  // Function to clear error
  const clearError = () => {
    setError(null);
    setErrorType(null);
  };

  const contextValue: UserContextType = {
    users,
    farmers,
    totalUsersCount,
    loading,
    error,
    errorType,
    fetchUsers,
    addUser,
    updateUserById,
    deleteUserById,
    currentUser,
    isAdmin,
    hasAdminAccess,
    clearError
  };

  return (
    <UserContext.Provider value={contextValue}>
      {children}
    </UserContext.Provider>
  );
}

// Custom hook for accessing the context
export function useUserContext(): UserContextType {
  const context = useContext(UserContext);
  if (context === undefined) {
    throw new Error('useUserContext must be used within a UserProvider');
  }
  return context;
}
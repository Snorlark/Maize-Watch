import { createContext, useContext, useState, useEffect, ReactNode } from "react";
import { userService } from "../api/client";
import { useAuth } from './AuthContext';
import { User } from "../api/services/authService"; // Single source of truth for User type
import authService from '../api/services/authService';

// Define the context shape
interface UserContextType {
  users: User[];
  farmers: User[]; // Farmers filtered from users
  loading: boolean;
  error: string | null;
  currentUser: User | null;
  isAdmin: boolean;
  hasAdminAccess: boolean; // New property for both admin and super_admin
  fetchUsers: () => Promise<void>;
  addUser: (userData: Omit<User, "_id">) => Promise<User>;
  updateUserById: (id: string, userData: Partial<User>) => Promise<User>;
  deleteUserById: (id: string) => Promise<void>;
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
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [fetchTriggered, setFetchTriggered] = useState(false);
  
  // Current user is directly from AuthContext (no conversion needed)
  const currentUser = user;

  // Compute isAdmin for backward compatibility (only admin role)
  const isAdmin = user?.role === 'admin';

  // New property to check for both admin and super_admin access
  const hasAdminAccess = user?.role === 'admin' || user?.role === 'super_admin';

  // Derive farmers from users whenever users change
  const farmers = users.filter(user => user.role === 'user');

  console.log('UserProvider initialized:', { 
    isAuthenticated, 
    isAdmin,
    hasAdminAccess,
    userId: user?._id || user?.userId,
    userRole: user?.role
  });

  // Fetch users only when explicitly called 
  // or when component is mounted with valid admin user
  useEffect(() => {
    const shouldFetchUsers = isAuthenticated && hasAdminAccess && !fetchTriggered;
    
    if (shouldFetchUsers) {
      console.log('Initiating fetchUsers in UserProvider effect');
      setFetchTriggered(true);
      fetchUsers().catch(err => {
        console.error('Failed initial user fetch:', err);
      });
    } else if (!hasAdminAccess) {
      // Clear users array when not admin or super_admin
      setUsers([]);
      setLoading(false);
    }
  }, [isAuthenticated, hasAdminAccess]);

  // Function to fetch all users
  const fetchUsers = async () => {
    console.log('fetchUsers called, hasAdminAccess:', hasAdminAccess, 'isAuthenticated:', isAuthenticated);
    
    // Verify authentication state before attempting to fetch
    if (!isAuthenticated) {
      console.warn('User not authenticated');
      setLoading(false);
      setError("Authentication required");
      return;
    }
    
    // Immediately return if not admin or super_admin to prevent unauthorized requests
    if (!hasAdminAccess) {
      console.warn('Non-admin user attempted to fetch users');
      setLoading(false);
      setError("Unauthorized: Admin privileges required");
      return;
    }
    
    // Check if token exists
    const token = authService.getToken();
    if (!token) {
      console.warn('No auth token found');
      setError("Authentication token missing. Please log in again.");
      setLoading(false);
      return;
    }
    
    setLoading(true);
    setError(null);
    try {
      console.log('Making API request to fetch users');
      const fetchedUsers = await userService.getUsers();
      console.log(`Fetched ${fetchedUsers.length} users successfully`);
      setUsers(fetchedUsers);
    } catch (err: any) {
      
    } finally {
      setLoading(false);
    }
  };

  // Function to add a new user
  const addUser = async (userData: Omit<User, "_id">) => {
    if (!hasAdminAccess) {
      const error = new Error("Unauthorized: Admin privileges required");
      setError(error.message);
      throw error;
    }

    try {
      setError(null);
      const newUser = await userService.createUser(userData);
      setUsers((prevUsers) => [...prevUsers, newUser]);
      return newUser;
    } catch (err: any) {
      const errorMessage = err?.response?.data?.message || err?.message || "Failed to add user. Please try again.";
      setError(errorMessage);
      console.error("Error adding user:", err);
      throw err;
    }
  };

  // Function to update a user
  const updateUserById = async (id: string, userData: Partial<User>) => {
    if (!hasAdminAccess) {
      const error = new Error("Unauthorized: Admin privileges required");
      setError(error.message);
      throw error;
    }

    try {
      setError(null);
      const updatedUser = await userService.updateUser(id, userData);
      setUsers((prevUsers) =>
        prevUsers.map((user) => (user._id === id ? updatedUser : user))
      );
      return updatedUser;
    } catch (err: any) {
      const errorMessage = err?.response?.data?.message || err?.message || "Failed to update user. Please try again.";
      setError(errorMessage);
      console.error("Error updating user:", err);
      throw err;
    }
  };

  // Function to delete a user
  const deleteUserById = async (id: string) => {
    if (!hasAdminAccess) {
      const error = new Error("Unauthorized: Admin privileges required");
      setError(error.message);
      throw error;
    }

    try {
      setError(null);
      await userService.deleteUser(id);
      setUsers((prevUsers) => prevUsers.filter((user) => user._id !== id));
    } catch (err: any) {
      const errorMessage = err?.response?.data?.message || err?.message || "Failed to delete user. Please try again.";
      setError(errorMessage);
      console.error("Error deleting user:", err);
      throw err;
    }
  };

  const contextValue: UserContextType = {
    users,
    farmers,
    loading,
    error,
    fetchUsers,
    addUser,
    updateUserById,
    deleteUserById,
    currentUser,
    isAdmin,
    hasAdminAccess
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
    throw new Error("useUserContext must be used within a UserProvider");
  }
  return context;
}
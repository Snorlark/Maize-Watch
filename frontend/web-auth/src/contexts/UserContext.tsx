import { createContext, useContext, useState, useEffect, ReactNode } from "react";
import { userService, User as ClientUser } from "../api/client";
import { useAuth } from './AuthContext';
import { User as AuthUser } from "../api/services/authService";

// Define the context shape
interface UserContextType {
  users: ClientUser[];
  loading: boolean;
  error: string | null;
  currentUser: ClientUser | null;
  isAdmin: boolean;
  fetchUsers: () => Promise<void>;
  addUser: (userData: Omit<ClientUser, "_id">) => Promise<ClientUser>;
  updateUserById: (id: string, userData: Partial<ClientUser>) => Promise<ClientUser>;
  deleteUserById: (id: string) => Promise<void>;
}

// Create the context with default values
const UserContext = createContext<UserContextType | undefined>(undefined);

// Props for the provider component
interface UserProviderProps {
  children: ReactNode;
}

// Helper function to convert AuthUser to ClientUser
const convertAuthUserToClientUser = (authUser: AuthUser | null): ClientUser | null => {
  if (!authUser) return null;
  
  return {
    _id: authUser._id || authUser.userId || '',
    username: authUser.username,
    fullName: authUser.fullName || '',
    contactNumber: authUser.contactNumber || '',
    email: authUser.email || '',
    address: authUser.address || '',
    role: authUser.role
  };
};

// Provider component
export function UserProvider({ children }: UserProviderProps) {
  const { user, isAuthenticated } = useAuth();
  const [users, setUsers] = useState<ClientUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [fetchTriggered, setFetchTriggered] = useState(false);
  
  // Convert AuthUser to ClientUser
  const clientUser = convertAuthUserToClientUser(user);

  // Compute isAdmin whenever user changes
  const isAdmin = user?.role === 'admin';

  console.log('UserProvider initialized:', { 
    isAuthenticated, 
    isAdmin,
    userId: user?._id,
    userRole: user?.role
  });

  // Fetch users only when explicitly called 
  // or when component is mounted with valid admin user
  useEffect(() => {
    const shouldFetchUsers = isAuthenticated && isAdmin && !fetchTriggered;
    
    if (shouldFetchUsers) {
      console.log('Initiating fetchUsers in UserProvider effect');
      setFetchTriggered(true);
      fetchUsers().catch(err => {
        console.error('Failed initial user fetch:', err);
      });
    } else if (!isAdmin) {
      // Clear users array when not admin
      setUsers([]);
      setLoading(false);
    }
  }, [isAuthenticated, isAdmin]);

  // Function to fetch all users
  const fetchUsers = async () => {
    console.log('fetchUsers called, isAdmin:', isAdmin, 'isAuthenticated:', isAuthenticated);
    
    // Verify authentication state before attempting to fetch
    if (!isAuthenticated) {
      console.warn('User not authenticated');
      setLoading(false);
      setError("Authentication required");
      return;
    }
    
    // Immediately return if not admin to prevent unauthorized requests
    if (!isAdmin) {
      console.warn('Non-admin user attempted to fetch users');
      setLoading(false);
      setError("Unauthorized: Admin privileges required");
      return;
    }
    
    // Check if token exists
    const token = localStorage.getItem('token');
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
      const errorMessage = err?.code === 'ECONNABORTED' 
        ? "Connection timeout. Please check if your backend server is running."
        : err?.message || "Failed to fetch users. Please try again later.";
        
      console.error("Error fetching users:", err);
      setError(errorMessage);
      
      // Check if it's an auth error - handle accordingly
      if (err?.response?.status === 401 || err?.response?.status === 403) {
        console.error("Authorization error fetching users:", err);
        setError("Authentication failed. Please log in again.");
      }
    } finally {
      setLoading(false);
    }
  };

  // Function to add a new user
  const addUser = async (userData: Omit<ClientUser, "_id">) => {
    if (!isAdmin) {
      const error = new Error("Unauthorized: Admin privileges required");
      setError(error.message);
      throw error;
    }

    try {
      const newUser = await userService.createUser(userData);
      setUsers((prevUsers) => [...prevUsers, newUser]);
      return newUser;
    } catch (err: any) {
      const errorMessage = err?.message || "Failed to add user. Please try again.";
      setError(errorMessage);
      console.error("Error adding user:", err);
      throw err;
    }
  };

  // Function to update a user
  const updateUserById = async (id: string, userData: Partial<ClientUser>) => {
    if (!isAdmin) {
      const error = new Error("Unauthorized: Admin privileges required");
      setError(error.message);
      throw error;
    }

    try {
      const updatedUser = await userService.updateUser(id, userData);
      setUsers((prevUsers) =>
        prevUsers.map((user) => (user._id === id ? updatedUser : user))
      );
      return updatedUser;
    } catch (err: any) {
      const errorMessage = err?.message || "Failed to update user. Please try again.";
      setError(errorMessage);
      console.error("Error updating user:", err);
      throw err;
    }
  };

  // Function to delete a user
  const deleteUserById = async (id: string) => {
    if (!isAdmin) {
      const error = new Error("Unauthorized: Admin privileges required");
      setError(error.message);
      throw error;
    }

    try {
      await userService.deleteUser(id);
      setUsers((prevUsers) => prevUsers.filter((user) => user._id !== id));
    } catch (err: any) {
      const errorMessage = err?.message || "Failed to delete user. Please try again.";
      setError(errorMessage);
      console.error("Error deleting user:", err);
      throw err;
    }
  };

  const contextValue: UserContextType = {
    users,
    loading,
    error,
    fetchUsers,
    addUser,
    updateUserById,
    deleteUserById,
    currentUser: clientUser,
    isAdmin
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
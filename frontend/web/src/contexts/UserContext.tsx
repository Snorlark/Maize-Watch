import { createContext, useContext, useState, useEffect, ReactNode } from "react";
import { userService, User } from "../api/client";

// Define the context shape
interface UserContextType {
  users: User[];
  loading: boolean;
  error: string | null;
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
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Fetch users on component mount
  useEffect(() => {
    fetchUsers();
  }, []);

  // Function to fetch all users
  const fetchUsers = async () => {
    setLoading(true);
    setError(null);
    try {
      const fetchedUsers = await userService.getUsers();
      setUsers(fetchedUsers);
    } catch (err) {
      setError("Failed to fetch users. Please try again later.");
      console.error("Error fetching users:", err);
    } finally {
      setLoading(false);
    }
  };

  // Function to add a new user
  const addUser = async (userData: Omit<User, "_id">) => {
    try {
      const newUser = await userService.createUser(userData);
      setUsers((prevUsers) => [...prevUsers, newUser]);
      return newUser;
    } catch (err) {
      setError("Failed to add user. Please try again.");
      console.error("Error adding user:", err);
      throw err;
    }
  };

  // Function to update a user
  const updateUserById = async (id: string, userData: Partial<User>) => {
    try {
      const updatedUser = await userService.updateUser(id, userData);
      setUsers((prevUsers) =>
        prevUsers.map((user) => (user._id === id ? updatedUser : user))
      );
      return updatedUser;
    } catch (err) {
      setError("Failed to update user. Please try again.");
      console.error("Error updating user:", err);
      throw err;
    }
  };

  // Function to delete a user
  const deleteUserById = async (id: string) => {
    try {
      await userService.deleteUser(id);
      setUsers((prevUsers) => prevUsers.filter((user) => user._id !== id));
    } catch (err) {
      setError("Failed to delete user. Please try again.");
      console.error("Error deleting user:", err);
      throw err;
    }
  };

  // Create the context value object
  const contextValue: UserContextType = {
    users,
    loading,
    error,
    fetchUsers,
    addUser,
    updateUserById,
    deleteUserById,
  };

  return (
    <UserContext.Provider value={contextValue}>{children}</UserContext.Provider>
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
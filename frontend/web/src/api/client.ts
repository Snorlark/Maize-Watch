// src/api/client.ts
import axios from 'axios';

// Define the User interface based on your MongoDB schema
export interface User {
  _id?: string;
  username: string;
  password?: string;
  fullName: string;
  contactNumber: string;
  address: string;
  role: string;
  createdAt?: string;
  __v?: number;
  email?: string;
  lot?: number;
}

// Base URL configuration
const apiBaseUrl = 'http://localhost:8080';
console.log('API Base URL being used:', apiBaseUrl); // Verify URL in console

// Create the Axios instance
const apiClient = axios.create({
  baseURL: apiBaseUrl,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000, // 10 seconds timeout
  withCredentials: true,
});

// Add auth token to requests if available
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// User API services
export const userService = {
  // Get all users
  getUsers: async (): Promise<User[]> => {
    try {
      const response = await apiClient.get('/auth');
      return response.data;
    } catch (error) {
      console.error('Error in getUsers:', error);
      throw error;
    }
  },

  // Get a single user by ID
  getUserById: async (id: string): Promise<User> => {
    try {
      const response = await apiClient.get(`/auth/${id}`);
      return response.data;
    } catch (error) {
      console.error(`Error getting user ${id}:`, error);
      throw error;
    }
  },

  // Create a new user
  createUser: async (userData: Omit<User, "_id">): Promise<User> => {
    try {
      const response = await apiClient.post('/auth', userData);
      return response.data;
    } catch (error) {
      console.error('Error creating user:', error);
      throw error;
    }
  },

  // Update an existing user
  updateUser: async (
    id: string,
    userData: Partial<User>
  ): Promise<User> => {
    try {
      const response = await apiClient.put(`/auth/${id}`, userData);
      return response.data;
    } catch (error) {
      console.error(`Error updating user ${id}:`, error);
      throw error;
    }
  },

  // Delete a user
  deleteUser: async (id: string): Promise<void> => {
    try {
      await apiClient.delete(`/auth/${id}`);
    } catch (error) {
      console.error(`Error deleting user ${id}:`, error);
      throw error;
    }
  },
};

export default apiClient;
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
  email?: string; // Adding email since it appears in your UI but not in the MongoDB sample
  lot?: number;   // Adding lot since it appears in your UI but not in the MongoDB sample
}

// Create axios instance with base URL
const api = axios.create({
    baseURL: 'http://localhost:8080', // ✅ Fix: changed from 3000 to 8080
    withCredentials: true,
  });
  
  // Get all users
  export async function getUsers(): Promise<User[]> {
    try {
      const response = await api.get('/api/users');
      return response.data;
    } catch (error) {
      console.error('Error in getUsers:', error);
      throw error;
    }
  }
  
  // Get a single user by ID
  export async function getUserById(id: string): Promise<User> {
    try {
      const response = await api.get(`/api/users/${id}`);
      return response.data;
    } catch (error) {
      console.error(`Error getting user ${id}:`, error);
      throw error;
    }
  }
  
  // Create a new user
  export async function createUser(userData: Omit<User, "_id">): Promise<User> {
    try {
      const response = await api.post('/api/users', userData);
      return response.data;
    } catch (error) {
      console.error('Error creating user:', error);
      throw error;
    }
  }
  
  // Update an existing user
  export async function updateUser(
    id: string,
    userData: Partial<User>
  ): Promise<User> {
    try {
      const response = await api.put(`/api/users/${id}`, userData);
      return response.data;
    } catch (error) {
      console.error(`Error updating user ${id}:`, error);
      throw error;
    }
  }
  
  // Delete a user
  export async function deleteUser(id: string): Promise<void> {
    try {
      await api.delete(`/api/users/${id}`);
    } catch (error) {
      console.error(`Error deleting user ${id}:`, error);
      throw error;
    }
  }
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
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Handle response errors (including token expiration)
apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  (error: AxiosError) => {
    // Handle CORS errors
    if (error.message === 'Network Error') {
      console.error('CORS or network error detected:', error);
    }
    
    // Handle authentication errors
    if (error.response?.status === 401) {
      console.log('Authentication error - clearing token');
      localStorage.removeItem('token');
      
      // Don't force redirect here - let the component handle it
    }
    return Promise.reject(error);
  }
);

// User API services
export const userService = {
  // Login user
  login: async (credentials: { username: string; password: string }): Promise<{ token: string; user: User }> => {
    try {
      console.log('Making login request to:', `${apiBaseUrl}/auth/login`);
      // Use the internal apiClient but override the withCredentials setting for this specific request
      const response = await apiClient.post('/auth/login', credentials, { withCredentials: false });
      
      // If login is successful, store the token
      if (response.data && response.data.token) {
        localStorage.setItem('token', response.data.token);
      }
      
      return response.data;
    } catch (error) {
      console.error('Login error:', error);
      throw error;
    }
  },
  
  // Get all users with field selection (to avoid requesting unused fields)
  getUsers: async (): Promise<User[]> => {
    try {
      // Check if token exists before making the request
      const token = authService.getToken();
      if (!token) {
        throw new Error('Authentication token is missing');
      }
      
      console.log('Making getUsers request to:', `${apiBaseUrl}/api/users`);
      // Modify to request only needed fields
      const response = await apiClient.get('/api/users', {
        params: {
          fields: 'username,fullName,contactNumber,address,role' // Only request needed fields
        }
      });
      
      // Filter farmers on the client side
      return response.data;
    } 
    catch (error: any) {
      console.error('Error in getUsers:', error);
      
      // Add specific handling for timeout errors
      if (error.code === 'ECONNABORTED') {
        console.error('Connection timeout. Is your backend server running at', apiBaseUrl, '?');
      }
      throw error;
    }
  },

  // Get a single user by ID - request only needed fields
  getUserById: async (id: string): Promise<User> => {
    try {
      const response = await apiClient.get(`/api/users/${id}`, {
        params: {
          fields: 'username,fullName,contactNumber,address,role'
        }
      });
      return response.data;
    } catch (error) {
      console.error(`Error getting user ${id}:`, error);
      throw error;
    }
  },

  // Create a new user
  createUser: async (userData: Omit<User, "_id">): Promise<User> => {
    try {
      const response = await apiClient.post('/api/users', userData);
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
      const response = await apiClient.put(`/api/users/${id}`, userData);
      return response.data; // This now returns the updated user object
    } catch (error) {
      console.error(`Error updating user ${id}:`, error);
      throw error;
    }
  },

  getProfile: async (): Promise<User> => {
    try {
      const token = authService.getToken();
      if (!token) {
        throw new Error('Authentication token is missing');
      }
      
      const response = await apiClient.get('/api/profile');
      return response.data;
    } catch (error) {
      console.error('Error getting user profile:', error);
      throw error;
    }
  },

  updateProfile: async (userData: Partial<User>): Promise<User> => {
    try {
      const token = authService.getToken();
      if (!token) {
        throw new Error('Authentication token is missing');
      }
      
      const response = await apiClient.put('/api/profile', userData);
      return response.data;
    } catch (error) {
      console.error('Error updating user profile:', error);
      throw error;
    }
  },

  // Delete a user
  deleteUser: async (id: string): Promise<void> => {
    try {
      await apiClient.delete(`/api/users/${id}`);
    } catch (error) {
      console.error(`Error deleting user ${id}:`, error);
      throw error;
    }
  },
};

export default apiClient;
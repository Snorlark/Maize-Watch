// src/services/authService.js
import axios from 'axios';

// Set your API base URL - adjust this to match your backend URL
const API_URL = 'https://maize-watch.onrender.com'; // Update this with your actual backend URL

// Authentication service
const authService = {
  // Login user
  login: async (username, password) => {
    try {
      const response = await axios.post(`${API_URL}/users/login`, { username, password });
      
      if (response.data.token) {
        localStorage.setItem('token', response.data.token);
        localStorage.setItem('user', JSON.stringify(response.data.user));
        
        // Set auth token in headers for future requests
        axios.defaults.headers.common['Authorization'] = `Bearer ${response.data.token}`;
      }
      
      return response.data;
    } catch (error) {
      throw error.response ? error.response.data : error;
    }
  },
  
  // Logout user
  logout: () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    delete axios.defaults.headers.common['Authorization'];
  },
  
  // Get current user from localStorage
  getCurrentUser: () => {
    return JSON.parse(localStorage.getItem('user'));
  },
  
  // Check if user is logged in
  isAuthenticated: () => {
    const token = localStorage.getItem('token');
    return !!token;
  },
  
  // Set token if exists in localStorage (call this on app init)
  setupTokenFromStorage: () => {
    const token = localStorage.getItem('token');
    if (token) {
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      return true;
    }
    return false;
  }
};

export default authService;
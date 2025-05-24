// authController.js
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { MongoClient, ObjectId } from 'mongodb';
import { generateToken } from './auth.middleware';
import { blacklistToken } from './tokenBlacklist';

// Connect to MongoDB
const connectDB = async () => {
  const client = new MongoClient(process.env.MONGODB_URI);
  await client.connect();
  return client;
};

// Login controller
export const login = async (req, res) => {
  const { username, password } = req.body;
  
  if (!username || !password) {
    return res.status(400).json({ message: 'Username and password are required' });
  }
  
  let client;
  
  try {
    client = await connectDB();
    const db = client.db();
    
    // Find user by username
    const user = await db.collection('users').findOne({ username });
    
    // Check if user exists
    if (!user) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }
    
    // Compare passwords
    const isPasswordValid = await bcrypt.compare(password, user.password);
    
    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }
    
    // Generate JWT token
    const token = generateToken(user._id.toString(), user.role);
    
    // Return token and user data (without password)
    const { password: _, ...userData } = user;
    
    return res.status(200).json({
      message: 'Login successful',
      token,
      user: userData
    });
    
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({ message: 'Server error' });
  } finally {
    if (client) {
      await client.close();
    }
  }
};

// Logout controller
export const logout = async (req, res) => {
  // Get the token from the Authorization header
  const authHeader = req.headers.authorization;
  
  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.split(' ')[1];
    
    // Add the token to the blacklist
    blacklistToken(token);
  }
  
  return res.status(200).json({ message: 'Logout successful' });
};

// Get user profile
export const getUserProfile = async (req, res) => {
  // The user ID comes from the authenticated token
  const userId = req.user.userId;
  
  let client;
  
  try {
    client = await connectDB();
    const db = client.db();
    
    // Find user by ID
    const user = await db.collection('users').findOne({ _id: new ObjectId(userId) });
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Return user data without password
    const { password, ...userData } = user;
    
    return res.status(200).json(userData);
    
  } catch (error) {
    console.error('Get user profile error:', error);
    return res.status(500).json({ message: 'Server error' });
  } finally {
    if (client) {
      await client.close();
    }
  }
};
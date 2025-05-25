// auth.middleware.js
import jwt from 'jsonwebtoken';
import { MongoClient, ObjectId } from 'mongodb';
import { isTokenBlacklisted } from './tokenBlacklist.js';

// Token expiration time (1 hour in seconds)
const TOKEN_EXPIRATION = 3600;

// Helper function to validate JWT token format
const isValidJWTFormat = (token) => {
  if (!token || typeof token !== 'string') {
    return false;
  }
  
  const parts = token.split('.');
  return parts.length === 3 && parts.every(part => part.length > 0);
};

// Function to generate a new JWT token
export const generateToken = (userId, role) => {
  return jwt.sign(
    { userId, role },
    process.env.JWT_SECRET,
    { expiresIn: TOKEN_EXPIRATION }
  );
};

export const authorize = (roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ message: 'Unauthorized' });
    }
    
    if (roles && !roles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Forbidden' });
    }
    
    next();
  };
};

// Admin authorization middleware (includes super_admin)
export const isAdmin = async (req, res, next) => {
  try {
    // 1. Get token from Authorization header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Unauthorized - No token provided' });
    }
    
    const token = authHeader.split(' ')[1];
    
    // Validate token format before processing
    if (!isValidJWTFormat(token)) {
      console.error('Invalid JWT format received:', token.substring(0, 20) + '...');
      return res.status(401).json({ message: 'Unauthorized - Malformed token' });
    }
    
    // 2. Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (!decoded || !decoded.userId) {
      return res.status(401).json({ message: 'Unauthorized - Invalid token' });
    }
    
    // 3. Check if token is blacklisted
    if (isTokenBlacklisted(token)) {
      return res.status(401).json({ message: 'Unauthorized - Token revoked' });
    }
    
    // 4. Find user and check if admin or super_admin
    const client = new MongoClient(process.env.MONGODB_URI);
    await client.connect();
    const db = client.db();
    
    const user = await db.collection('users').findOne({ _id: new ObjectId(decoded.userId) });
    await client.close();
    
    if (!user) {
      return res.status(401).json({ message: 'Unauthorized - User not found' });
    }
    
    if (user.role !== 'admin' && user.role !== 'super_admin') {
      return res.status(403).json({ message: 'Forbidden - Admin access required' });
    }
    
    // Add user info to request object for later use
    req.user = {
      userId: user._id,
      username: user.username,
      role: user.role
    };
    
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Unauthorized - Token expired' });
    }
    
    if (error.name === 'JsonWebTokenError') {
      console.error('JWT Error:', error.message);
      return res.status(401).json({ message: 'Unauthorized - Invalid token format' });
    }
    
    console.error('Auth middleware error:', error);
    return res.status(401).json({ message: 'Unauthorized - Authentication failed' });
  }
};

// Super Admin only authorization middleware
export const isSuperAdmin = async (req, res, next) => {
  try {
    // 1. Get token from Authorization header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Unauthorized - No token provided' });
    }
    
    const token = authHeader.split(' ')[1];
    
    // Validate token format before processing
    if (!isValidJWTFormat(token)) {
      console.error('Invalid JWT format received:', token.substring(0, 20) + '...');
      return res.status(401).json({ message: 'Unauthorized - Malformed token' });
    }
    
    // 2. Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (!decoded || !decoded.userId) {
      return res.status(401).json({ message: 'Unauthorized - Invalid token' });
    }
    
    // 3. Check if token is blacklisted
    if (isTokenBlacklisted(token)) {
      return res.status(401).json({ message: 'Unauthorized - Token revoked' });
    }
    
    // 4. Find user and check if super_admin
    const client = new MongoClient(process.env.MONGODB_URI);
    await client.connect();
    const db = client.db();
    
    const user = await db.collection('users').findOne({ _id: new ObjectId(decoded.userId) });
    await client.close();
    
    if (!user) {
      return res.status(401).json({ message: 'Unauthorized - User not found' });
    }
    
    if (user.role !== 'super_admin') {
      return res.status(403).json({ message: 'Forbidden - Super Admin access required' });
    }
    
    // Add user info to request object for later use
    req.user = {
      userId: user._id,
      username: user.username,
      role: user.role
    };
    
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Unauthorized - Token expired' });
    }
    
    if (error.name === 'JsonWebTokenError') {
      console.error('JWT Error:', error.message);
      return res.status(401).json({ message: 'Unauthorized - Invalid token format' });
    }
    
    console.error('Auth middleware error:', error);
    return res.status(401).json({ message: 'Unauthorized - Authentication failed' });
  }
};

// Combined admin or super_admin middleware
export const isAdminOrSuperAdmin = async (req, res, next) => {
  return isAdmin(req, res, next);
};

// Basic authentication middleware (for any logged-in user)
export const isAuthenticated = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Unauthorized - No token provided' });
    }
    
    const token = authHeader.split(' ')[1];
    
    // Validate token format before processing
    if (!isValidJWTFormat(token)) {
      console.error('Invalid JWT format received in isAuthenticated:', token.substring(0, 20) + '...');
      return res.status(401).json({ message: 'Unauthorized - Malformed token' });
    }
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    if (!decoded || !decoded.userId) {
      return res.status(401).json({ message: 'Unauthorized - Invalid token' });
    }
    
    // Check if token is blacklisted
    if (isTokenBlacklisted(token)) {
      return res.status(401).json({ message: 'Unauthorized - Token revoked' });
    }
    
    req.user = {
      userId: decoded.userId,
      role: decoded.role
    };
    
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Unauthorized - Token expired' });
    }
    
    if (error.name === 'JsonWebTokenError') {
      console.error('JWT Error in isAuthenticated:', error.message);
      return res.status(401).json({ message: 'Unauthorized - Invalid token format' });
    }
    
    console.error('Auth middleware error:', error);
    return res.status(401).json({ message: 'Unauthorized - Authentication failed' });
  }
};

// Logout middleware to invalidate token
export const logout = (req, res) => {
  // In a stateless JWT system, the client just removes the token
  // But we can implement a token blacklist for additional security
  
  // Return success response
  return res.status(200).json({ message: 'Logged out successfully' });
};
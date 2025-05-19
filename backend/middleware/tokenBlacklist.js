// tokenBlacklist.js
/**
 * Simple in-memory token blacklist implementation
 * Note: In a production environment, you'd want to use Redis or another
 * distributed cache system for the blacklist, especially in a multi-server setup
 */

// Store for blacklisted tokens
const blacklistedTokens = new Set();

// Add a token to the blacklist
export const blacklistToken = (token) => {
  blacklistedTokens.add(token);
};

// Check if a token is blacklisted
export const isTokenBlacklisted = (token) => {
  return blacklistedTokens.has(token);
};

// Cleanup expired tokens (should be called periodically)
export const cleanupBlacklist = () => {
  // In a real implementation, you'd remove expired tokens based on their expiry time
  // For demo purposes, we're not implementing this fully
  console.log('Token blacklist cleanup would happen here');
};

// Middleware for checking blacklisted tokens
export const checkTokenBlacklist = (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.split(' ')[1];
    
    if (isTokenBlacklisted(token)) {
      return res.status(401).json({ message: 'Token has been revoked' });
    }
  }
  
  next();
};
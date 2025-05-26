// auth.middleware.js
import jwt from 'jsonwebtoken';
import User from '../models/User.js';

// Token generation utility
export const generateToken = (userId, role) => {
  return jwt.sign(
    { 
      userId: userId,
      role: role 
    },
    process.env.JWT_SECRET,
    { 
      expiresIn: process.env.JWT_EXPIRES_IN || '24h' 
    }
  );
};

// Authentication middleware
export const isAuthenticated = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ 
        error: 'Authentication required. Please provide a valid token.' 
      });
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix
    
    if (!token) {
      return res.status(401).json({ 
        error: 'Authentication token not found.' 
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.userId).select('-password');
    
    if (!user) {
      return res.status(401).json({ 
        error: 'User not found. Token may be invalid.' 
      });
    }

    // Check if user account is active
    if (user.status === 'inactive' || user.status === 'suspended') {
      return res.status(403).json({ 
        error: 'Account is inactive or suspended.' 
      });
    }

    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ 
        error: 'Invalid authentication token.' 
      });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        error: 'Authentication token has expired.' 
      });
    }
    return res.status(500).json({ 
      error: 'Authentication error.',
      message: error.message 
    });
  }
};

// Generic role authorization middleware
export const authorize = (allowedRoles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ 
        error: 'Authentication required.' 
      });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ 
        error: `Access denied. Required roles: ${allowedRoles.join(', ')}.`,
        userRole: req.user.role 
      });
    }

    next();
  };
};

// Individual role middleware
export const isAdmin = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ 
      error: 'Authentication required.' 
    });
  }

  if (req.user.role !== 'admin') {
    return res.status(403).json({ 
      error: 'Access denied. Admin privileges required.',
      userRole: req.user.role 
    });
  }

  next();
};

export const isSuperAdmin = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ 
      error: 'Authentication required.' 
    });
  }

  if (req.user.role !== 'super_admin') {
    return res.status(403).json({ 
      error: 'Access denied. Super Admin privileges required.',
      userRole: req.user.role 
    });
  }

  next();
};

export const isFarmer = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ 
      error: 'Authentication required.' 
    });
  }

  if (req.user.role !== 'farmer') {
    return res.status(403).json({ 
      error: 'Access denied. Farmer privileges required.',
      userRole: req.user.role 
    });
  }

  next();
};

// Combined admin or super_admin middleware - UPDATED VERSION
export const isAdminOrSuperAdmin = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ 
      error: 'Authentication required.' 
    });
  }

  if (req.user.role !== 'admin' && req.user.role !== 'super_admin') {
    return res.status(403).json({ 
      error: 'Access denied. Admin or Super Admin privileges required.',
      userRole: req.user.role 
    });
  }

  next();
};

// Helper middleware to check if user can manage other users
export const canManageUsers = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ 
      error: 'Authentication required.' 
    });
  }

  const allowedRoles = ['admin', 'super_admin'];
  if (!allowedRoles.includes(req.user.role)) {
    return res.status(403).json({ 
      error: 'Access denied. User management privileges required.',
      userRole: req.user.role 
    });
  }

  next();
};

// Middleware to check if user can access activity logs
export const canViewActivityLogs = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ 
      error: 'Authentication required.' 
    });
  }

  const allowedRoles = ['admin', 'super_admin'];
  if (!allowedRoles.includes(req.user.role)) {
    return res.status(403).json({ 
      error: 'Access denied. Activity log access requires admin privileges.',
      userRole: req.user.role 
    });
  }

  next();
};

// Middleware to check if user can perform system-wide operations
export const canPerformSystemOperations = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ 
      error: 'Authentication required.' 
    });
  }

  if (req.user.role !== 'super_admin') {
    return res.status(403).json({ 
      error: 'Access denied. System operations require Super Admin privileges.',
      userRole: req.user.role 
    });
  }

  next();
};

// Middleware to prevent self-actions (like deleting own account)
export const preventSelfAction = (req, res, next) => {
  const targetUserId = req.params.id || req.params.userId;
  
  if (req.user._id.toString() === targetUserId) {
    return res.status(400).json({ 
      error: 'Cannot perform this action on your own account.' 
    });
  }

  next();
};

// Middleware to check resource ownership or admin privileges
export const isOwnerOrAdmin = async (req, res, next) => {
  try {
    const resourceUserId = req.params.userId || req.body.userId;
    
    // Super admins and admins can access any resource
    if (['admin', 'super_admin'].includes(req.user.role)) {
      return next();
    }

    // Users can only access their own resources
    if (req.user._id.toString() === resourceUserId) {
      return next();
    }

    return res.status(403).json({ 
      error: 'Access denied. You can only access your own resources.' 
    });
  } catch (error) {
    return res.status(500).json({ 
      error: 'Authorization error.',
      message: error.message 
    });
  }
};

export default {
  isAuthenticated,
  authorize,
  isAdmin,
  isSuperAdmin,
  isFarmer,
  isAdminOrSuperAdmin,
  canManageUsers,
  canViewActivityLogs,
  canPerformSystemOperations,
  preventSelfAction,
  isOwnerOrAdmin,
  generateToken
};
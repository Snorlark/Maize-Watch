import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import User from '../models/User';
import { HTTP_STATUS, USER_ROLES, RESPONSE_MESSAGES } from '../utils/constants';
import { logger } from '../utils/logger';
import { AppError } from './errorHandler';

// Extend Request interface to include user
declare global {
  namespace Express {
    interface Request {
      user?: any;
    }
  }
}

interface JwtPayload {
  id: string;
  username: string;
  role: string;
  isActive: boolean;
  iat?: number;
  exp?: number;
}

// Middleware to verify JWT token
export const authenticate = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const authHeader = req.header('Authorization');
    
    if (!authHeader) {
      res.status(HTTP_STATUS.UNAUTHORIZED).json({
        success: false,
        message: 'Access denied. No token provided.',
      });
      return;
    }

    // Extract token from "Bearer <token>"
    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : authHeader;

    if (!token) {
      res.status(HTTP_STATUS.UNAUTHORIZED).json({
        success: false,
        message: 'Access denied. Invalid token format.',
      });
      return;
    }

    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
      logger.error('JWT_SECRET environment variable is not set');
      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        success: false,
        message: RESPONSE_MESSAGES.ERROR.INTERNAL_ERROR,
      });
      return;
    }

    // Verify token
    let decoded: JwtPayload;
    try {
      decoded = jwt.verify(token, jwtSecret) as JwtPayload;
    } catch (error: any) {
      logger.error('JWT verification failed', { error: error.message });
      throw new AppError('Authentication error: ' + error.message, HTTP_STATUS.UNAUTHORIZED);
    }

    // Find user in database
    const user = await User.findById(decoded.id).select('-password -refreshTokens');
    
    if (!user) {
      res.status(HTTP_STATUS.UNAUTHORIZED).json({
        success: false,
        message: 'Access denied. User not found.',
      });
      return;
    }

    if (!user.isActive) {
      res.status(HTTP_STATUS.UNAUTHORIZED).json({
        success: false,
        message: 'Access denied. Account is deactivated.',
      });
      return;
    }

    // Add user to request object
    req.user = user;
    next();
  } catch (error) {
    logger.error('Authentication error:', error);
    
    if (error instanceof jwt.JsonWebTokenError) {
      res.status(HTTP_STATUS.UNAUTHORIZED).json({
        success: false,
        message: 'Access denied. Invalid token.',
      });
      return;
    }

    if (error instanceof jwt.TokenExpiredError) {
      res.status(HTTP_STATUS.UNAUTHORIZED).json({
        success: false,
        message: 'Access denied. Token expired.',
      });
      return;
    }

    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: RESPONSE_MESSAGES.ERROR.INTERNAL_ERROR,
    });
  }
};

// Middleware to check if user has required role
export const authorize = (...roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(HTTP_STATUS.UNAUTHORIZED).json({
        success: false,
        message: RESPONSE_MESSAGES.ERROR.UNAUTHORIZED,
      });
      return;
    }

    if (!roles.includes(req.user.role)) {
      res.status(HTTP_STATUS.FORBIDDEN).json({
        success: false,
        message: RESPONSE_MESSAGES.ERROR.FORBIDDEN,
      });
      return;
    }

    next();
  };
};

// Middleware to check if user is admin or super admin
export const requireAdmin = authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN);

// Middleware to check if user is super admin
export const requireSuperAdmin = authorize(USER_ROLES.SUPER_ADMIN);

export const requireRegionalAdmin = requireAdmin;

// Middleware to check if user owns the resource or is admin
export const authorizeOwnerOrAdmin = (resourceUserIdField: string = 'userId') => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      res.status(HTTP_STATUS.UNAUTHORIZED).json({
        success: false,
        message: RESPONSE_MESSAGES.ERROR.UNAUTHORIZED,
      });
      return;
    }

    const resourceUserId = req.params[resourceUserIdField] || req.body[resourceUserIdField];
    const isOwner = req.user._id.toString() === resourceUserId;
    const isAdmin = [USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN].includes(req.user.role);

    if (!isOwner && !isAdmin) {
      res.status(HTTP_STATUS.FORBIDDEN).json({
        success: false,
        message: RESPONSE_MESSAGES.ERROR.FORBIDDEN,
      });
      return;
    }

    next();
  };
};

// Middleware to check if user can access farm data
export const authorizeFarmAccess = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.user) {
      res.status(HTTP_STATUS.UNAUTHORIZED).json({
        success: false,
        message: RESPONSE_MESSAGES.ERROR.UNAUTHORIZED,
      });
      return;
    }

    const farmId = req.params.farmId || req.body.farmId;
    
    if (!farmId) {
      res.status(HTTP_STATUS.BAD_REQUEST).json({
        success: false,
        message: 'Farm ID is required',
      });
      return;
    }

    // Admin and super admin can access all farms
    if ([USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN].includes(req.user.role)) {
      next();
      return;
    }

    // Check if user owns the farm
    const Farm = require('../models/Farm').default;
    const farm = await Farm.findById(farmId);

    if (!farm) {
      res.status(HTTP_STATUS.NOT_FOUND).json({
        success: false,
        message: 'Farm not found',
      });
      return;
    }

    if (farm.owner.toString() !== req.user._id.toString()) {
      res.status(HTTP_STATUS.FORBIDDEN).json({
        success: false,
        message: RESPONSE_MESSAGES.ERROR.FORBIDDEN,
      });
      return;
    }

    next();
  } catch (error) {
    logger.error('Farm authorization error:', error);
    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: RESPONSE_MESSAGES.ERROR.INTERNAL_ERROR,
    });
  }
};

// Middleware for optional authentication (doesn't fail if no token)
export const optionalAuth = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const authHeader = req.header('Authorization');
    
    if (!authHeader) {
      next();
      return;
    }

    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : authHeader;

    if (!token) {
      next();
      return;
    }

    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
      next();
      return;
    }

    const decoded = jwt.verify(token, jwtSecret) as JwtPayload;
    const user = await User.findById(decoded.id).select('-password -refreshTokens');
    
    if (user && user.isActive) {
      req.user = user;
    }

    next();
  } catch (error) {
    // Silently continue without authentication
    next();
  }
};

// Middleware to check account status
export const checkAccountStatus = (req: Request, res: Response, next: NextFunction): void => {
  if (!req.user) {
    res.status(HTTP_STATUS.UNAUTHORIZED).json({
      success: false,
      message: RESPONSE_MESSAGES.ERROR.UNAUTHORIZED,
    });
    return;
  }

  if (!req.user.isActive) {
    res.status(HTTP_STATUS.FORBIDDEN).json({
      success: false,
      message: 'Account is deactivated',
    });
    return;
  }

  if (req.user.isLocked) {
    res.status(HTTP_STATUS.FORBIDDEN).json({
      success: false,
      message: RESPONSE_MESSAGES.ERROR.ACCOUNT_LOCKED,
    });
    return;
  }

  if (!req.user.emailVerified && process.env.REQUIRE_EMAIL_VERIFICATION === 'true') {
    res.status(HTTP_STATUS.FORBIDDEN).json({
      success: false,
      message: RESPONSE_MESSAGES.ERROR.EMAIL_NOT_VERIFIED,
    });
    return;
  }

  next();
};

// Middleware to log user activity
export const logUserActivity = (action: string) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (req.user) {
      logger.info(`User activity: ${req.user.username} performed ${action}`, {
        userId: req.user._id,
        username: req.user.username,
        action,
        ip: req.ip,
        userAgent: req.get('User-Agent'),
        timestamp: new Date().toISOString(),
      });
    }
    next();
  };
};

export default {
  authenticate,
  authorize,
  requireAdmin,
  requireSuperAdmin,
  authorizeOwnerOrAdmin,
  authorizeFarmAccess,
  optionalAuth,
  checkAccountStatus,
  logUserActivity,
};

import rateLimit from 'express-rate-limit';
import { Request, Response } from 'express';
import { HTTP_STATUS, RATE_LIMITS } from '../utils/constants';
import { logger } from '../utils/logger';

// Store for rate limiting (in production, use Redis)
const store = new Map();

// Custom rate limit store using Redis (when available)
class CustomStore {
  private prefix: string;

  constructor(prefix: string = 'rl:') {
    this.prefix = prefix;
  }

  async incr(key: string): Promise<{ totalHits: number; resetTime?: Date }> {
    const fullKey = this.prefix + key;
    const current = store.get(fullKey) || { count: 0, resetTime: Date.now() + 15 * 60 * 1000 };
    
    if (Date.now() > current.resetTime) {
      current.count = 1;
      current.resetTime = Date.now() + 15 * 60 * 1000;
    } else {
      current.count++;
    }
    
    store.set(fullKey, current);
    
    return {
      totalHits: current.count,
      resetTime: new Date(current.resetTime)
    };
  }

  async decrement(key: string): Promise<void> {
    const fullKey = this.prefix + key;
    const current = store.get(fullKey);
    if (current && current.count > 0) {
      current.count--;
      store.set(fullKey, current);
    }
  }

  async resetKey(key: string): Promise<void> {
    store.delete(this.prefix + key);
  }
}

// General rate limiter
export const generalLimiter = rateLimit({
  windowMs: RATE_LIMITS.GENERAL.WINDOW_MS,
  max: RATE_LIMITS.GENERAL.MAX_REQUESTS,
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again later.',
    retryAfter: Math.ceil(RATE_LIMITS.GENERAL.WINDOW_MS / 1000),
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req: Request, res: Response) => {
    logger.warn('Rate limit exceeded', {
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      path: req.path,
      method: req.method,
    });

    res.status(HTTP_STATUS.TOO_MANY_REQUESTS).json({
      success: false,
      message: 'Too many requests from this IP, please try again later.',
      retryAfter: Math.ceil(RATE_LIMITS.GENERAL.WINDOW_MS / 1000),
    });
  },
});

// Authentication rate limiter (stricter)
export const authLimiter = rateLimit({
  windowMs: RATE_LIMITS.AUTH.WINDOW_MS,
  max: RATE_LIMITS.AUTH.MAX_REQUESTS,
  message: {
    success: false,
    message: 'Too many authentication attempts, please try again later.',
    retryAfter: Math.ceil(RATE_LIMITS.AUTH.WINDOW_MS / 1000),
  },
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true, // Don't count successful requests
  handler: (req: Request, res: Response) => {
    logger.warn('Auth rate limit exceeded', {
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      path: req.path,
      method: req.method,
      body: { ...req.body, password: '[REDACTED]' },
    });

    res.status(HTTP_STATUS.TOO_MANY_REQUESTS).json({
      success: false,
      message: 'Too many authentication attempts from this IP, please try again later.',
      retryAfter: Math.ceil(RATE_LIMITS.AUTH.WINDOW_MS / 1000),
    });
  },
});

// API rate limiter
export const apiLimiter = rateLimit({
  windowMs: RATE_LIMITS.API.WINDOW_MS,
  max: RATE_LIMITS.API.MAX_REQUESTS,
  message: {
    success: false,
    message: 'API rate limit exceeded, please slow down.',
    retryAfter: Math.ceil(RATE_LIMITS.API.WINDOW_MS / 1000),
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req: Request, res: Response) => {
    logger.warn('API rate limit exceeded', {
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      path: req.path,
      method: req.method,
      userId: req.user?.id,
    });

    res.status(HTTP_STATUS.TOO_MANY_REQUESTS).json({
      success: false,
      message: 'API rate limit exceeded, please slow down.',
      retryAfter: Math.ceil(RATE_LIMITS.API.WINDOW_MS / 1000),
    });
  },
});

// File upload rate limiter
export const uploadLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 10, // 10 uploads per minute
  message: {
    success: false,
    message: 'Too many file uploads, please try again later.',
    retryAfter: 60,
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req: Request, res: Response) => {
    logger.warn('Upload rate limit exceeded', {
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      path: req.path,
      userId: req.user?.id,
    });

    res.status(HTTP_STATUS.TOO_MANY_REQUESTS).json({
      success: false,
      message: 'Too many file uploads from this IP, please try again later.',
      retryAfter: 60,
    });
  },
});

// Password reset rate limiter
export const passwordResetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3, // 3 password reset attempts per hour
  message: {
    success: false,
    message: 'Too many password reset attempts, please try again later.',
    retryAfter: 3600,
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req: Request, res: Response) => {
    logger.warn('Password reset rate limit exceeded', {
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      email: req.body.email,
    });

    res.status(HTTP_STATUS.TOO_MANY_REQUESTS).json({
      success: false,
      message: 'Too many password reset attempts from this IP, please try again later.',
      retryAfter: 3600,
    });
  },
});

// Create custom rate limiter
export const createRateLimiter = (windowMs: number, max: number, message?: string) => {
  return rateLimit({
    windowMs,
    max,
    message: {
      success: false,
      message: message || 'Rate limit exceeded, please try again later.',
      retryAfter: Math.ceil(windowMs / 1000),
    },
    standardHeaders: true,
    legacyHeaders: false,
    handler: (req: Request, res: Response) => {
      logger.warn('Custom rate limit exceeded', {
        ip: req.ip,
        userAgent: req.get('User-Agent'),
        path: req.path,
        method: req.method,
        windowMs,
        max,
      });

      res.status(HTTP_STATUS.TOO_MANY_REQUESTS).json({
        success: false,
        message: message || 'Rate limit exceeded, please try again later.',
        retryAfter: Math.ceil(windowMs / 1000),
      });
    },
  });
};

export default {
  generalLimiter,
  authLimiter,
  apiLimiter,
  uploadLimiter,
  passwordResetLimiter,
  createRateLimiter,
};

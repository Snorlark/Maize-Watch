import rateLimit, { Store } from 'express-rate-limit';
import { Request, Response } from 'express';
import { HTTP_STATUS, RATE_LIMITS } from '../utils/constants';
import { logger } from '../utils/logger';

// Helper: allow temporary disable or IP whitelist via env
// RATE_LIMIT_DISABLE=true will skip all rate limits
// RATE_LIMIT_WHITELIST=ip1,ip2 will skip for those IPs
const isRateLimitDisabled = () => process.env.RATE_LIMIT_DISABLE === 'true';
const getWhitelistedIps = (): Set<string> => {
  const raw = process.env.RATE_LIMIT_WHITELIST || '';
  return new Set(
    raw
      .split(',')
      .map(ip => ip.trim())
      .filter(ip => ip.length > 0)
  );
};

const shouldSkipRateLimit = (req: Request): boolean => {
  if (isRateLimitDisabled()) return true;
  const whitelist = getWhitelistedIps();
  const ipCandidates = [req.ip, req.socket.remoteAddress, req.headers['x-forwarded-for'] as string | undefined]
    .filter(Boolean)
    .flatMap(val => (typeof val === 'string' ? val.split(',') : []))
    .map(ip => ip.trim());
  return ipCandidates.some(ip => whitelist.has(ip));
};

// Simple in-memory rate limit store compatible with express-rate-limit
class MemoryRateLimitStore implements Store {
  private store: Map<string, { count: number; resetTime: number }> = new Map();
  public prefix: string;
  private windowMs: number;

  constructor(prefix: string = 'rl:', windowMs: number = 15 * 60 * 1000) {
    this.prefix = prefix;
    this.windowMs = windowMs;
  }

  async increment(key: string): Promise<{ totalHits: number; resetTime: Date }> {
    const now = Date.now();
    const fullKey = this.prefix + key;
    
    const existing = this.store.get(fullKey);
    
    if (!existing || now > existing.resetTime) {
      // Create new entry or reset expired entry
      const resetTime = now + this.windowMs;
      this.store.set(fullKey, { count: 1, resetTime });
      return {
        totalHits: 1,
        resetTime: new Date(resetTime)
      };
    } else {
      // Increment existing entry
      existing.count++;
      this.store.set(fullKey, existing);
      return {
        totalHits: existing.count,
        resetTime: new Date(existing.resetTime)
      };
    }
  }

  async decrement(key: string): Promise<void> {
    const fullKey = this.prefix + key;
    const existing = this.store.get(fullKey);
    
    if (existing && existing.count > 0) {
      existing.count--;
      this.store.set(fullKey, existing);
    }
  }

  async resetKey(key: string): Promise<void> {
    const fullKey = this.prefix + key;
    this.store.delete(fullKey);
  }

  // Optional: Clean up expired entries periodically
  private cleanup(): void {
    const now = Date.now();
    for (const [key, value] of this.store.entries()) {
      if (now > value.resetTime) {
        this.store.delete(key);
      }
    }
  }
}

// General rate limiter with Memory store
export const generalLimiter = rateLimit({
  store: new MemoryRateLimitStore('rl:general:', RATE_LIMITS.GENERAL.WINDOW_MS),
  windowMs: RATE_LIMITS.GENERAL.WINDOW_MS,
  max: RATE_LIMITS.GENERAL.MAX_REQUESTS,
  skip: shouldSkipRateLimit,
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

// Authentication rate limiter (stricter) with Memory store
export const authLimiter = rateLimit({
  store: new MemoryRateLimitStore('rl:auth:', RATE_LIMITS.AUTH.WINDOW_MS),
  windowMs: RATE_LIMITS.AUTH.WINDOW_MS,
  max: RATE_LIMITS.AUTH.MAX_REQUESTS,
  skip: shouldSkipRateLimit,
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

// API rate limiter with Memory store
export const apiLimiter = rateLimit({
  store: new MemoryRateLimitStore('rl:api:', RATE_LIMITS.API.WINDOW_MS),
  windowMs: RATE_LIMITS.API.WINDOW_MS,
  max: RATE_LIMITS.API.MAX_REQUESTS,
  skip: shouldSkipRateLimit,
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

// File upload rate limiter with Memory store
export const uploadLimiter = rateLimit({
  store: new MemoryRateLimitStore('rl:upload:', 60 * 1000),
  windowMs: 60 * 1000, // 1 minute
  max: 10, // 10 uploads per minute
  skip: shouldSkipRateLimit,
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

// Password reset rate limiter with Memory store
export const passwordResetLimiter = rateLimit({
  store: new MemoryRateLimitStore('rl:password:', 60 * 60 * 1000),
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3, // 3 password reset attempts per hour
  skip: shouldSkipRateLimit,
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

// Create custom rate limiter with Memory store
export const createRateLimiter = (windowMs: number, max: number, message?: string, prefix?: string) => {
  return rateLimit({
    store: new MemoryRateLimitStore(prefix || 'rl:custom:', windowMs),
    windowMs,
    max,
    skip: shouldSkipRateLimit,
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

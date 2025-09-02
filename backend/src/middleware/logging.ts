import { Request, Response, NextFunction } from 'express';
import morgan from 'morgan';
import { logger } from '../utils/logger';

// Custom token for user ID
morgan.token('user', (req: Request) => {
  return req.user ? req.user.id : 'anonymous';
});

// Custom token for request ID (for tracing)
morgan.token('reqId', (req: Request) => {
  return req.headers['x-request-id'] as string || 'unknown';
});

// Custom token for response time in milliseconds
morgan.token('response-time-ms', (req: Request, res: Response) => {
  const startTime = req.startTime || Date.now();
  return `${Date.now() - startTime}ms`;
});

// Development logging format
const developmentFormat = ':method :url :status :response-time ms - :res[content-length] - User: :user - ReqId: :reqId';

// Production logging format
const productionFormat = ':remote-addr - :user [:date[clf]] ":method :url HTTP/:http-version" :status :res[content-length] ":referrer" ":user-agent" :response-time-ms - ReqId: :reqId';

// Create morgan middleware based on environment
export const requestLogger = morgan(
  process.env.NODE_ENV === 'production' ? productionFormat : developmentFormat,
  {
    stream: {
      write: (message: string) => {
        logger.http(message.trim());
      },
    },
    skip: (req: Request) => {
      // Skip logging for health checks and static assets
      return req.url === '/health' || 
             req.url === '/favicon.ico' || 
             req.url.startsWith('/static/');
    },
  }
);

// Middleware to add request start time
export const addRequestTime = (req: Request, res: Response, next: NextFunction): void => {
  req.startTime = Date.now();
  next();
};

// Middleware to add request ID
export const addRequestId = (req: Request, res: Response, next: NextFunction): void => {
  const requestId = req.headers['x-request-id'] as string || 
                   `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  
  req.requestId = requestId;
  res.setHeader('X-Request-ID', requestId);
  next();
};

// Middleware to log API responses
export const responseLogger = (req: Request, res: Response, next: NextFunction): void => {
  const originalSend = res.send;
  
  res.send = function(data) {
    // Log response details
    logger.info('API Response', {
      requestId: req.requestId,
      method: req.method,
      url: req.originalUrl,
      statusCode: res.statusCode,
      userId: req.user?.id,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      responseTime: req.startTime ? Date.now() - req.startTime : undefined,
      responseSize: data ? Buffer.byteLength(data, 'utf8') : 0,
    });
    
    return originalSend.call(this, data);
  };
  
  next();
};

// Middleware to log errors
export const errorLogger = (err: any, req: Request, res: Response, next: NextFunction): void => {
  logger.error('Request Error', {
    requestId: req.requestId,
    method: req.method,
    url: req.originalUrl,
    userId: req.user?.id,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    error: {
      name: err.name,
      message: err.message,
      stack: err.stack,
      statusCode: err.statusCode || 500,
    },
    body: req.body,
    params: req.params,
    query: req.query,
  });
  
  next(err);
};

// Middleware to log slow requests
export const slowRequestLogger = (threshold: number = 1000) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const startTime = Date.now();
    
    res.on('finish', () => {
      const duration = Date.now() - startTime;
      
      if (duration > threshold) {
        logger.warn('Slow Request Detected', {
          requestId: req.requestId,
          method: req.method,
          url: req.originalUrl,
          duration: `${duration}ms`,
          statusCode: res.statusCode,
          userId: req.user?.id,
          ip: req.ip,
          userAgent: req.get('User-Agent'),
        });
      }
    });
    
    next();
  };
};

// Middleware to log security events
export const securityLogger = (event: string, details?: any) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    logger.warn('Security Event', {
      event,
      requestId: req.requestId,
      method: req.method,
      url: req.originalUrl,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      userId: req.user?.id,
      timestamp: new Date().toISOString(),
      ...details,
    });
    
    next();
  };
};

// Extend Express Request interface
declare global {
  namespace Express {
    interface Request {
      startTime?: number;
      requestId?: string;
    }
  }
}

export default {
  requestLogger,
  addRequestTime,
  addRequestId,
  responseLogger,
  errorLogger,
  slowRequestLogger,
  securityLogger,
};

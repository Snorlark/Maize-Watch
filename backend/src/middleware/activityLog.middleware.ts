import { Request, Response, NextFunction } from 'express';
import ActivityLogService, { CreateLogData } from '../services/activityLog.service';
import { UserRole, Action, Resource } from '../models/activityLog.model';

// Define user interface based on the properties used in the code
interface User {
  id: string | number;
  email?: string;
  role: string;
}

// // Extend Express Request interface to include user property
// declare global {
//   namespace Express {
//     interface Request {
//       user?: User;
//     }
//   }
// }

// Define the log data structure
interface LogData {
  userId: string | number;
  userEmail: string;
  userRole: string;
  action: string;
  resource: string;
  resourceId: string | null;
  details: {
    method: string;
    path: string;
    query: any;
    body?: any;
    statusCode: number;
  };
  ipAddress: string | undefined;
  userAgent: string;
  timestamp: Date;
}

// Authentication middleware - checks if user is logged in
export const isAuthenticated = (req: Request, res: Response, next: NextFunction): void => {
  if (!req.user) {
    res.status(401).json({
      success: false,
      message: 'Authentication required'
    });
    return;
  }
  next();
};

// Admin authorization middleware - checks if user has admin role
export const isAdmin = (req: Request, res: Response, next: NextFunction): void => {
  if (!req.user) {
    res.status(401).json({
      success: false,
      message: 'Authentication required'
    });
    return;
  }

  if (req.user.role !== 'admin' && req.user.role !== 'super_admin') {
    res.status(403).json({
      success: false,
      message: 'Admin access required'
    });
    return;
  }

  next();
};

// Activity logging middleware factory
export const logActivity = (action: Action, resource: Resource) => {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    // Store the original end function
    const originalEnd = res.end.bind(res);

    // Override the end function to intercept response using proper overloads
    res.end = function (chunk?: any, encoding?: any, cb?: any): Response {
      // Restore the original end function immediately
      res.end = originalEnd;

      // Only log if the request was successful (status code 2xx)
      if (res.statusCode >= 200 && res.statusCode < 300) {
        // Perform logging asynchronously without blocking response
        setImmediate(async () => {
          try {
            // Get user info from the request (set by auth middleware)
            const user = req.user;
            if (!user) {
              console.warn('No user found in request for activity logging');
              return;
            }

            // Get IP address with better type safety and fallback
            const getClientIP = (): string => {
              return req.ip || 
                     req.connection?.remoteAddress || 
                     (req.socket as any)?.remoteAddress || 
                     (req.connection as any)?.socket?.remoteAddress ||
                     '127.0.0.1'; // Fallback to localhost instead of 'unknown'
            };

            const ipAddress = getClientIP();
            const userAgent = req.headers['user-agent'] || 'Unknown';

            // Get the user ID as string or ObjectId
            let userId: string;
            if (user._id) {
              userId = user._id.toString();
            } else if (user.id) {
              userId = user.id.toString();
            } else {
              console.warn('No user ID found for activity logging');
              return;
            }

            // Create log entry using the exact CreateLogData interface
            const logData: CreateLogData = {
              userId: userId, // Now definitely a string
              userEmail: user.email || 'unknown@email.com',
              userRole: user.role as UserRole, // Cast to enum type
              action,
              resource,
              resourceId: req.params.id || null,
              details: {
                method: req.method,
                path: req.path,
                query: req.query,
                body: req.method !== 'GET' ? req.body : undefined,
                statusCode: res.statusCode
              },
              ipAddress, // Now guaranteed to be a string
              userAgent,
              timestamp: new Date()
            };

            // Save the log asynchronously
            await ActivityLogService.createLog(logData);
          } catch (error) {
            console.error('Error in activity logging middleware:', error);
          }
        });
      }

      const result = originalEnd.apply(this, arguments as any);

      return result;
    };

    next();
  };
};
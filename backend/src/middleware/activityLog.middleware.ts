import { Request, Response, NextFunction } from 'express';
import ActivityLogService, { CreateLogData } from '../services/activityLog.service';
import { UserRole, Action, Resource } from '../models/activityLog.model';

// Define user interface based on the properties used in the code
interface User {
  id: string | number;
  email?: string;
  role: string;
}

// In-memory store to track recent view activities per user session
// Format: Map<string, Set<string>> where key is userId and value is set of resource identifiers
const recentViewLogs = new Map<string, Map<string, number>>();

// Time window in milliseconds to prevent duplicate view logs (5 minutes)
const VIEW_LOG_COOLDOWN = 5 * 60 * 1000; // 5 minutes

// Cleanup interval to remove old entries (runs every 10 minutes)
setInterval(() => {
  const now = Date.now();
  for (const [userId, resourceMap] of recentViewLogs.entries()) {
    for (const [resourceKey, timestamp] of resourceMap.entries()) {
      if (now - timestamp > VIEW_LOG_COOLDOWN) {
        resourceMap.delete(resourceKey);
      }
    }
    // Remove user entry if no resources are being tracked
    if (resourceMap.size === 0) {
      recentViewLogs.delete(userId);
    }
  }
}, 10 * 60 * 1000); // 10 minutes

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

// Helper function to check if a view action should be logged
const shouldLogViewAction = (userId: string, action: Action, resource: Resource, resourceId?: string): boolean => {
  // Only apply cooldown logic for VIEW actions
  if (action !== Action.VIEW) {
    return true;
  }

  const now = Date.now();
  const resourceKey = `${resource}:${resourceId || 'general'}`;
  
  // Get user's resource map or create new one
  let userResourceMap = recentViewLogs.get(userId);
  if (!userResourceMap) {
    userResourceMap = new Map<string, number>();
    recentViewLogs.set(userId, userResourceMap);
  }

  // Check if this resource was recently viewed
  const lastLogTime = userResourceMap.get(resourceKey);
  if (lastLogTime && (now - lastLogTime) < VIEW_LOG_COOLDOWN) {
    return false; // Skip logging - too recent
  }

  // Update the timestamp for this resource
  userResourceMap.set(resourceKey, now);
  return true; // Log this view action
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

            // Get the user ID as string
            let userId: string;
            if (user._id) {
              userId = user._id.toString();
            } else if (user.id) {
              userId = user.id.toString();
            } else {
              console.warn('No user ID found for activity logging');
              return;
            }

            // Check if this view action should be logged (prevents spam)
            const resourceId = req.params.id || undefined;
            if (!shouldLogViewAction(userId, action, resource, resourceId)) {
              return; // Skip logging this view action
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

            // Create log entry using the exact CreateLogData interface
            const logData: CreateLogData = {
              userId: userId,
              userEmail: user.email || 'unknown@email.com',
              userRole: user.role as UserRole,
              action,
              resource,
              resourceId: resourceId,
              details: {
                method: req.method,
                path: req.path,
                query: req.query,
                body: req.method !== 'GET' ? req.body : undefined,
                statusCode: res.statusCode
              },
              ipAddress,
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

// Alternative: More granular control - log only on specific conditions
export const logActivityConditional = (
  action: Action, 
  resource: Resource, 
  options: {
    skipDuplicates?: boolean;
    cooldownMinutes?: number;
    logOnlyUnique?: boolean;
  } = {}
) => {
  const { 
    skipDuplicates = true, 
    cooldownMinutes = 5,
    logOnlyUnique = false 
  } = options;

  return logActivity(action, resource);
};

// Utility function to clear view logs for a specific user (useful for logout)
export const clearUserViewLogs = (userId: string): void => {
  recentViewLogs.delete(userId);
};

// Utility function to get current view log stats (for debugging)
export const getViewLogStats = () => {
  const stats = {
    totalUsers: recentViewLogs.size,
    totalResources: 0,
    userBreakdown: {} as Record<string, number>
  };

  for (const [userId, resourceMap] of recentViewLogs.entries()) {
    stats.totalResources += resourceMap.size;
    stats.userBreakdown[userId] = resourceMap.size;
  }

  return stats;
};
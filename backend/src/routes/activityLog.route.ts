import express, { Request, Response } from 'express';
import { authenticate, requireRegionalAdmin } from '../middleware/auth';
import { isAdmin, clearUserViewLogs, getViewLogStats } from '../middleware/activityLog.middleware';
import ActivityLogService from '../services/activityLog.service';
import { UserRole, Action, Resource } from '../models/activityLog.model';

const router = express.Router();
interface LogsQueryParams {
  page?: string;
  limit?: string;
  userId?: string;
  action?: Action;
  resource?: Resource;
  userRole?: UserRole;
  startDate?: string;
  endDate?: string;
  search?: string;
  consolidated?: string; // New option for consolidated view logs
}

interface StatsQueryParams {
  days?: string;
}

// Type-safe request interfaces
interface LogsRequest extends Omit<Request, 'query'> {
  query: LogsQueryParams;
}

interface StatsRequest extends Omit<Request, 'query'> {
  query: StatsQueryParams;
}

// Get activity logs with filters and pagination
router.get('/', authenticate, requireRegionalAdmin, async (req: LogsRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const consolidated = req.query.consolidated === 'true';
    
    // Validate pagination parameters
    if (page < 1) {
      return res.status(400).json({
        success: false,
        message: 'Page number must be greater than 0'
      });
    }

    if (limit < 1 || limit > 100) {
      return res.status(400).json({
        success: false,
        message: 'Limit must be between 1 and 100'
      });
    }
    
    // Extract filters from query parameters (remove undefined values)
    const filters = Object.fromEntries(
      Object.entries({
        userId: req.query.userId,
        action: req.query.action,
        resource: req.query.resource,
        userRole: req.query.userRole,
        startDate: req.query.startDate,
        endDate: req.query.endDate,
        search: req.query.search
      }).filter(([_, value]) => value !== undefined)
    );
    
    // For regional_admin users, exclude super_admin actions
    const currentUser = (req as any).user;
    if (currentUser && currentUser.role === 'regional_admin') {
      filters.excludeSuperAdmin = 'true';
    }

    // Use consolidated view logs if requested and action is VIEW
    let result;
    if (consolidated && (!filters.action || filters.action === Action.VIEW)) {
      result = await ActivityLogService.getConsolidatedViewLogs(filters, page, limit);
    } else {
      result = await ActivityLogService.getLogs(filters, page, limit);
    }
    
    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Error fetching activity logs:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching activity logs',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// Get activity statistics
router.get('/stats', authenticate, requireRegionalAdmin, async (req: StatsRequest, res: Response) => {
  try {
    const days = parseInt(req.query.days as string) || 30;
    
    // Validate days parameter
    if (days < 1 || days > 365) {
      return res.status(400).json({
        success: false,
        message: 'Days parameter must be between 1 and 365'
      });
    }

    const stats = await ActivityLogService.getStats(days);
    
    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('Error fetching activity stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching activity statistics',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// Get logs for current user (non-admin endpoint)
router.get('/my-activity', authenticate, async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const consolidated = req.query.consolidated === 'true';
    
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'User not found'
      });
    }

    // Only show logs for the current user
    const filters = {
      userId: (req.user._id || req.user.id).toString()
    };

    // Use consolidated view logs if requested
    let result;
    if (consolidated) {
      result = await ActivityLogService.getConsolidatedViewLogs(filters, page, limit);
    } else {
      result = await ActivityLogService.getLogs(filters, page, limit);
    }
    
    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Error fetching user activity logs:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching your activity logs',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// Clear view logs for current user (useful for testing or manual reset)
router.post('/clear-view-cache', authenticate, async (req: Request, res: Response) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'User not found'
      });
    }

    const userId = (req.user._id || req.user.id).toString();
    clearUserViewLogs(userId);
    
    res.json({
      success: true,
      message: 'View cache cleared for current user'
    });
  } catch (error) {
    console.error('Error clearing view cache:', error);
    res.status(500).json({
      success: false,
      message: 'Error clearing view cache',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// Get current view log statistics (admin only - for debugging/monitoring)
router.get('/view-cache-stats', authenticate, requireRegionalAdmin, async (req: Request, res: Response) => {
  try {
    const stats = getViewLogStats();
    
    res.json({
      success: true,
      data: {
        ...stats,
        description: 'Current in-memory view log cache statistics',
        cooldownMinutes: 5
      }
    });
  } catch (error) {
    console.error('Error fetching view cache stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching view cache statistics',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// Cleanup old logs (admin only - for maintenance)
router.delete('/cleanup', authenticate, isAdmin, async (req: Request, res: Response) => {
  try {
    const daysToKeep = parseInt(req.query.days as string) || 90;
    
    // Validate days parameter
    if (daysToKeep < 1 || daysToKeep > 365) {
      return res.status(400).json({
        success: false,
        message: 'Days to keep must be between 1 and 365'
      });
    }

    const deletedCount = await ActivityLogService.cleanupOldLogs(daysToKeep);
    
    res.json({
      success: true,
      message: `Cleanup completed. Deleted ${deletedCount} old activity logs.`,
      data: {
        deletedCount,
        daysKept: daysToKeep
      }
    });
  } catch (error) {
    console.error('Error cleaning up logs:', error);
    res.status(500).json({
      success: false,
      message: 'Error cleaning up old logs',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;
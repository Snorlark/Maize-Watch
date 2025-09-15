import express, { Request, Response } from 'express';
import { isAuthenticated, isAdmin } from '../middleware/activityLog.middleware';
import ActivityLogService from '../services/activityLog.service';
import { UserRole, Action, Resource } from '../models/activityLog.model';

const router = express.Router();

// Define query parameter interfaces
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
router.get('/', isAuthenticated, isAdmin, async (req: LogsRequest, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    
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

    const result = await ActivityLogService.getLogs(filters, page, limit);
    
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
router.get('/stats', isAuthenticated, isAdmin, async (req: StatsRequest, res: Response) => {
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
router.get('/my-activity', isAuthenticated, async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    
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

    const result = await ActivityLogService.getLogs(filters, page, limit);
    
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

export default router;
//activityLogs.js
import express from 'express';
import ActivityLog from '../models/ActivityLog.js';
import { login, logout, getUserProfile } from '../authController.js';
import { isAuthenticated, authorize, isAdminOrSuperAdmin } from '../middleware/auth.middleware.js';

const router = express.Router();

// GET /api/activity-logs - Fetch activity logs (Admin and Super Admin only)
router.get('/', 
  isAuthenticated, 
  isAdminOrSuperAdmin, 
  async (req, res) => {
    try {
      const { 
        page = 1, 
        limit = 20, 
        userId, 
        action, 
        resource,
        startDate,
        endDate,
        search 
      } = req.query;

      // Build filter object
      const filter = {};
      
      if (userId) filter.userId = userId;
      if (action) filter.action = new RegExp(action, 'i');
      if (resource) filter.resource = new RegExp(resource, 'i');
      
      // Role-based filtering - Admins can only see farmer/user activities
      if (req.user.role === 'admin') {
        filter.userRole = { $in: ['farmer', 'user'] };
      }
      // Super admins can see all activities (no additional filter)
      
      // Date range filter
      if (startDate || endDate) {
        filter.timestamp = {};
        if (startDate) filter.timestamp.$gte = new Date(startDate);
        if (endDate) {
          const endOfDay = new Date(endDate);
          endOfDay.setHours(23, 59, 59, 999);
          filter.timestamp.$lte = endOfDay;
        }
      }

      // Search filter (searches in userEmail and action)
      if (search) {
        filter.$or = [
          { userEmail: new RegExp(search, 'i') },
          { action: new RegExp(search, 'i') },
          { resource: new RegExp(search, 'i') }
        ];
      }

      // Calculate pagination
      const pageNum = parseInt(page);
      const limitNum = parseInt(limit);
      const skip = (pageNum - 1) * limitNum;

      // Fetch logs with pagination
      const logs = await ActivityLog
        .find(filter)
        .sort({ timestamp: -1 })
        .limit(limitNum)
        .skip(skip)
        .populate('userId', 'name email role')
        .exec();

      // Get total count for pagination
      const total = await ActivityLog.countDocuments(filter);

      res.json({
        logs,
        pagination: {
          currentPage: pageNum,
          totalPages: Math.ceil(total / limitNum),
          totalItems: total,
          itemsPerPage: limitNum,
          hasNextPage: pageNum < Math.ceil(total / limitNum),
          hasPrevPage: pageNum > 1
        }
      });
    } catch (error) {
      console.error('Error fetching activity logs:', error);
      res.status(500).json({ 
        error: 'Failed to fetch activity logs',
        message: error.message 
      });
    }
  }
);

// GET /api/activity-logs/stats - Get activity statistics (Admin and Super Admin only)
router.get('/stats',
  isAuthenticated,
  isAdminOrSuperAdmin,
  async (req, res) => {
    try {
      const { days = 30 } = req.query;
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - parseInt(days));

      // Base filter for role-based access
      const baseFilter = { timestamp: { $gte: startDate } };
      
      // Role-based filtering - Admins can only see farmer/user activities
      if (req.user.role === 'admin') {
        baseFilter.userRole = { $in: ['farmer', 'user'] };
      }

      const stats = await ActivityLog.aggregate([
        { $match: baseFilter },
        {
          $group: {
            _id: {
              action: '$action',
              date: { $dateToString: { format: '%Y-%m-%d', date: '$timestamp' } }
            },
            count: { $sum: 1 }
          }
        },
        { $sort: { '_id.date': 1 } }
      ]);

      const actionStats = await ActivityLog.aggregate([
        { $match: baseFilter },
        { $group: { _id: '$action', count: { $sum: 1 } } },
        { $sort: { count: -1 } }
      ]);

      const resourceStats = await ActivityLog.aggregate([
        { $match: baseFilter },
        { $group: { _id: '$resource', count: { $sum: 1 } } },
        { $sort: { count: -1 } }
      ]);

      res.json({
        dailyStats: stats,
        actionStats,
        resourceStats
      });
    } catch (error) {
      console.error('Error fetching activity statistics:', error);
      res.status(500).json({ 
        error: 'Failed to fetch statistics',
        message: error.message 
      });
    }
  }
);

export default router;
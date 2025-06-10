import express from 'express';
import { isAuthenticated, isAdmin } from '../middleware/auth.middleware.js';
import ActivityLogService from '../services/activityLog.service.js';

const router = express.Router();

// Get activity logs with filters and pagination
router.get('/', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    
    // Extract filters from query parameters
    const filters = {
      userId: req.query.userId,
      action: req.query.action,
      resource: req.query.resource,
      userRole: req.query.userRole,
      startDate: req.query.startDate,
      endDate: req.query.endDate,
      search: req.query.search
    };

    // Pass the requesting user's role for role-based filtering
    const requestingUserRole = req.user.role;
    const result = await ActivityLogService.getLogs(filters, page, limit, requestingUserRole);
    res.json(result);
  } catch (error) {
    console.error('Error fetching activity logs:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching activity logs',
      error: error.message
    });
  }
});

// Get activity statistics
router.get('/stats', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const days = parseInt(req.query.days) || 30;
    const stats = await ActivityLogService.getStats(days);
    res.json(stats);
  } catch (error) {
    console.error('Error fetching activity stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching activity statistics',
      error: error.message
    });
  }
});

export default router; 
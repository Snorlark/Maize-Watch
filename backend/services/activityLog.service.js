import ActivityLog from '../models/activityLog.model.js';
import mongoose from 'mongoose';

class ActivityLogService {
  static async createLog(logData) {
    try {
      const log = new ActivityLog(logData);
      await log.save();
      return log;
    } catch (error) {
      console.error('Error creating activity log:', error);
      throw error;
    }
  }

  static async getLogs(filters = {}, page = 1, limit = 20) {
    try {
      const query = {};
      
      // Apply filters
      if (filters.userId) {
        query.userId = new mongoose.Types.ObjectId(filters.userId);
      }
      if (filters.action) {
        query.action = filters.action;
      }
      if (filters.resource) {
        query.resource = filters.resource;
      }
      if (filters.userRole) {
        query.userRole = filters.userRole;
      }
      if (filters.startDate && filters.endDate) {
        query.timestamp = {
          $gte: new Date(filters.startDate),
          $lte: new Date(filters.endDate)
        };
      }
      if (filters.search) {
        query.$or = [
          { userEmail: { $regex: filters.search, $options: 'i' } },
          { details: { $regex: filters.search, $options: 'i' } }
        ];
      }

      // Calculate pagination
      const skip = (page - 1) * limit;
      
      // Get total count for pagination
      const total = await ActivityLog.countDocuments(query);
      
      // Get logs with pagination
      const logs = await ActivityLog.find(query)
        .sort({ timestamp: -1 })
        .skip(skip)
        .limit(limit)
        .populate('userId', 'username fullName email');

      return {
        logs,
        pagination: {
          currentPage: page,
          totalPages: Math.ceil(total / limit),
          totalItems: total,
          itemsPerPage: limit,
          hasNextPage: skip + logs.length < total,
          hasPrevPage: page > 1
        }
      };
    } catch (error) {
      console.error('Error fetching activity logs:', error);
      throw error;
    }
  }

  static async getStats(days = 30) {
    try {
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      // Get daily stats by action
      const dailyStats = await ActivityLog.aggregate([
        {
          $match: {
            timestamp: { $gte: startDate }
          }
        },
        {
          $group: {
            _id: {
              action: '$action',
              date: { $dateToString: { format: '%Y-%m-%d', date: '$timestamp' } }
            },
            count: { $sum: 1 }
          }
        },
        {
          $sort: { '_id.date': -1, '_id.action': 1 }
        }
      ]);

      // Get stats by action
      const actionStats = await ActivityLog.aggregate([
        {
          $match: {
            timestamp: { $gte: startDate }
          }
        },
        {
          $group: {
            _id: '$action',
            count: { $sum: 1 }
          }
        },
        {
          $sort: { count: -1 }
        }
      ]);

      // Get stats by resource
      const resourceStats = await ActivityLog.aggregate([
        {
          $match: {
            timestamp: { $gte: startDate }
          }
        },
        {
          $group: {
            _id: '$resource',
            count: { $sum: 1 }
          }
        },
        {
          $sort: { count: -1 }
        }
      ]);

      return {
        dailyStats,
        actionStats,
        resourceStats
      };
    } catch (error) {
      console.error('Error fetching activity stats:', error);
      throw error;
    }
  }
}

export default ActivityLogService; 
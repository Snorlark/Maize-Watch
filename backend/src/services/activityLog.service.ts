import ActivityLog, { IActivityLog, UserRole, Action, Resource } from '../models/activityLog.model';
import mongoose from 'mongoose';

// Define interfaces for service methods
export interface LogFilters {
  userId?: string;
  action?: Action;
  resource?: Resource;
  userRole?: UserRole;
  startDate?: string;
  endDate?: string;
  search?: string;
  excludeSuperAdmin?: string;
}

export interface CreateLogData {
  userId: string | mongoose.Types.ObjectId;
  userEmail: string;
  userRole: UserRole;
  action: Action;
  resource: Resource;
  resourceId?: string | mongoose.Types.ObjectId | null;
  details: Record<string, any>;
  ipAddress: string | undefined;
  userAgent: string;
  timestamp: Date;
}

export interface PaginationInfo {
  currentPage: number;
  totalPages: number;
  totalItems: number;
  itemsPerPage: number;
  hasNextPage: boolean;
  hasPrevPage: boolean;
}

export interface LogsResponse {
  logs: IActivityLog[];
  pagination: PaginationInfo;
}

export interface DailyStat {
  _id: {
    action: Action;
    date: string;
  };
  count: number;
}

export interface ActionStat {
  _id: Action;
  count: number;
}

export interface ResourceStat {
  _id: Resource;
  count: number;
}

export interface StatsResponse {
  dailyStats: DailyStat[];
  actionStats: ActionStat[];
  resourceStats: ResourceStat[];
}

class ActivityLogService {
  static async createLog(logData: CreateLogData): Promise<IActivityLog> {
    try {
      const log = new ActivityLog(logData);
      await log.save();
      return log;
    } catch (error) {
      console.error('Error creating activity log:', error);
      throw error;
    }
  }

  // Check if a similar log exists within a time window (useful for preventing duplicates)
  static async checkRecentLog(
    userId: string,
    action: Action,
    resource: Resource,
    resourceId?: string | null,
    withinMinutes: number = 5
  ): Promise<boolean> {
    try {
      const cutoffTime = new Date(Date.now() - withinMinutes * 60 * 1000);
      
      const query: any = {
        userId: new mongoose.Types.ObjectId(userId),
        action,
        resource,
        timestamp: { $gte: cutoffTime }
      };

      if (resourceId) {
        query.resourceId = new mongoose.Types.ObjectId(resourceId);
      }

      const existingLog = await ActivityLog.findOne(query);
      return !!existingLog;
    } catch (error) {
      console.error('Error checking recent log:', error);
      return false;
    }
  }

  // Create log only if no recent similar log exists
  static async createLogIfNotRecent(
    logData: CreateLogData, 
    withinMinutes: number = 5
  ): Promise<IActivityLog | null> {
    try {
      const userId = typeof logData.userId === 'string' ? logData.userId : logData.userId.toString();
      const resourceId = logData.resourceId ? 
        (typeof logData.resourceId === 'string' ? logData.resourceId : logData.resourceId.toString()) 
        : null;

      const hasRecentLog = await this.checkRecentLog(
        userId,
        logData.action,
        logData.resource,
        resourceId,
        withinMinutes
      );

      if (hasRecentLog && logData.action === Action.VIEW) {
        console.log(`Skipping duplicate ${logData.action} log for user ${userId} on ${logData.resource}`);
        return null;
      }

      return await this.createLog(logData);
    } catch (error) {
      console.error('Error creating conditional log:', error);
      throw error;
    }
  }

  static async getLogs(
    filters: LogFilters = {}, 
    page: number = 1, 
    limit: number = 20
  ): Promise<LogsResponse> {
    try {
      const query: any = {};
      
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
      // Exclude super_admin actions for regional_admin users
      if (filters.excludeSuperAdmin === 'true') {
        query.userRole = { $ne: UserRole.SUPER_ADMIN };
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

  // Get unique view sessions (consolidated view logs per user per resource per day)
  static async getConsolidatedViewLogs(
    filters: LogFilters = {},
    page: number = 1,
    limit: number = 20
  ): Promise<LogsResponse> {
    try {
      const matchQuery: any = { action: Action.VIEW };
      
      // Apply filters
      if (filters.userId) {
        matchQuery.userId = new mongoose.Types.ObjectId(filters.userId);
      }
      if (filters.resource) {
        matchQuery.resource = filters.resource;
      }
      if (filters.userRole) {
        matchQuery.userRole = filters.userRole;
      }
      if (filters.startDate && filters.endDate) {
        matchQuery.timestamp = {
          $gte: new Date(filters.startDate),
          $lte: new Date(filters.endDate)
        };
      }

      // Aggregate to get consolidated view sessions
      const pipeline: any[] = [
        { $match: matchQuery },
        {
          $group: {
            _id: {
              userId: '$userId',
              resource: '$resource',
              resourceId: '$resourceId',
              date: { $dateToString: { format: '%Y-%m-%d', date: '$timestamp' } }
            },
            firstView: { $min: '$timestamp' },
            lastView: { $max: '$timestamp' },
            viewCount: { $sum: 1 },
            userEmail: { $first: '$userEmail' },
            userRole: { $first: '$userRole' },
            details: { $first: '$details' },
            ipAddress: { $first: '$ipAddress' },
            userAgent: { $first: '$userAgent' }
          }
        },
        { $sort: { firstView: -1 } },
        { $skip: (page - 1) * limit },
        { $limit: limit }
      ];

      const consolidatedLogs = await ActivityLog.aggregate(pipeline);
      
      // Get total count for pagination
      const countPipeline: any[] = [
        { $match: matchQuery },
        {
          $group: {
            _id: {
              userId: '$userId',
              resource: '$resource',
              resourceId: '$resourceId',
              date: { $dateToString: { format: '%Y-%m-%d', date: '$timestamp' } }
            }
          }
        },
        { $count: 'total' }
      ];
      const countResult = await ActivityLog.aggregate(countPipeline);
      const total = countResult[0]?.total || 0;

      // Transform aggregated results to match IActivityLog interface
      const logs = consolidatedLogs.map(log => ({
        _id: `consolidated_${log._id.userId}_${log._id.resource}_${log._id.date}`,
        userId: log._id.userId,
        userEmail: log.userEmail,
        userRole: log.userRole,
        action: Action.VIEW,
        resource: log._id.resource,
        resourceId: log._id.resourceId,
        details: {
          ...log.details,
          consolidatedSession: true,
          viewCount: log.viewCount,
          sessionDuration: log.lastView.getTime() - log.firstView.getTime()
        },
        ipAddress: log.ipAddress,
        userAgent: log.userAgent,
        timestamp: log.firstView
      })) as IActivityLog[];

      return {
        logs,
        pagination: {
          currentPage: page,
          totalPages: Math.ceil(total / limit),
          totalItems: total,
          itemsPerPage: limit,
          hasNextPage: (page - 1) * limit + logs.length < total,
          hasPrevPage: page > 1
        }
      };
    } catch (error) {
      console.error('Error fetching consolidated view logs:', error);
      throw error;
    }
  }

  static async getStats(days: number = 30): Promise<StatsResponse> {
    try {
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      // Get daily stats by action
      const dailyStats = await ActivityLog.aggregate<DailyStat>([
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
      const actionStats = await ActivityLog.aggregate<ActionStat>([
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
      const resourceStats = await ActivityLog.aggregate<ResourceStat>([
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

  // Clean up old activity logs (useful for data retention)
  static async cleanupOldLogs(daysToKeep: number = 90): Promise<number> {
    try {
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - daysToKeep);

      const result = await ActivityLog.deleteMany({
        timestamp: { $lt: cutoffDate }
      });

      console.log(`Cleaned up ${result.deletedCount} activity logs older than ${daysToKeep} days`);
      return result.deletedCount || 0;
    } catch (error) {
      console.error('Error cleaning up old logs:', error);
      throw error;
    }
  }
}

export default ActivityLogService;
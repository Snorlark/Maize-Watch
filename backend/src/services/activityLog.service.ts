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
}

export default ActivityLogService;
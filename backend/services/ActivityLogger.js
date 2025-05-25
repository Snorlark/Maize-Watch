import ActivityLog from '../models/ActivityLog.js';

class ActivityLogger {
  static async log({
    userId,
    userEmail,
    userRole,
    action,
    resource,
    resourceId = null,
    details = {},
    req,
    metadata = {}
  }) {
    try {
      // Extract IP address with fallbacks
      const ipAddress = req.ip || 
                       req.connection?.remoteAddress || 
                       req.socket?.remoteAddress ||
                       (req.connection?.socket ? req.connection.socket.remoteAddress : null) ||
                       '0.0.0.0';

      const logEntry = new ActivityLog({
        userId,
        userEmail,
        userRole,
        action,
        resource,
        resourceId,
        details,
        ipAddress,
        userAgent: req.get('User-Agent') || 'Unknown',
        timestamp: new Date(),
        metadata
      });
      
      await logEntry.save();
      console.log(`Activity logged: ${userEmail} performed ${action} on ${resource}`);
    } catch (error) {
      console.error('Failed to log activity:', error);
      // Don't throw - logging shouldn't break the main operation
    }
  }

  // Helper method for login logging
  static async logLogin(user, req, loginMethod = 'username') {
    await this.log({
      userId: user._id,
      userEmail: user.username,
      userRole: user.role,
      action: 'login',
      resource: 'auth',
      details: { loginMethod },
      req
    });
  }

  // Helper method for logout logging
  static async logLogout(user, req) {
    await this.log({
      userId: user._id,
      userEmail: user.username,
      userRole: user.role,
      action: 'logout',
      resource: 'auth',
      req
    });
  }

  // Admin Account Management Actions
  static async logUserCreation(admin, createdUser, req) {
    await this.log({
      userId: admin._id,
      userEmail: admin.username,
      userRole: admin.role,
      action: 'create_user',
      resource: 'user_management',
      resourceId: createdUser._id,
      details: {
        createdUsername: createdUser.username,
        createdUserRole: createdUser.role,
        createdUserEmail: createdUser.email || 'N/A'
      },
      req,
      metadata: { adminAction: true }
    });
  }

  static async logUserUpdate(admin, updatedUser, changes, req) {
    await this.log({
      userId: admin._id,
      userEmail: admin.username,
      userRole: admin.role,
      action: 'update_user',
      resource: 'user_management',
      resourceId: updatedUser._id,
      details: {
        updatedUsername: updatedUser.username,
        changes: changes,
        previousValues: changes.previousValues || {}
      },
      req,
      metadata: { adminAction: true }
    });
  }

  static async logUserDeletion(admin, deletedUser, req) {
    await this.log({
      userId: admin._id,
      userEmail: admin.username,
      userRole: admin.role,
      action: 'delete_user',
      resource: 'user_management',
      resourceId: deletedUser._id,
      details: {
        deletedUsername: deletedUser.username,
        deletedUserRole: deletedUser.role,
        deletedUserEmail: deletedUser.email || 'N/A'
      },
      req,
      metadata: { adminAction: true }
    });
  }

  static async logRoleChange(admin, targetUser, oldRole, newRole, req) {
    await this.log({
      userId: admin._id,
      userEmail: admin.username,
      userRole: admin.role,
      action: 'change_user_role',
      resource: 'user_management',
      resourceId: targetUser._id,
      details: {
        targetUsername: targetUser.username,
        oldRole: oldRole,
        newRole: newRole
      },
      req,
      metadata: { adminAction: true, critical: true }
    });
  }

  static async logPasswordReset(admin, targetUser, req) {
    await this.log({
      userId: admin._id,
      userEmail: admin.username,
      userRole: admin.role,
      action: 'reset_user_password',
      resource: 'user_management',
      resourceId: targetUser._id,
      details: {
        targetUsername: targetUser.username
      },
      req,
      metadata: { adminAction: true, security: true }
    });
  }

  static async logAccountStatus(admin, targetUser, status, reason, req) {
    await this.log({
      userId: admin._id,
      userEmail: admin.username,
      userRole: admin.role,
      action: status === 'active' ? 'activate_user' : 'deactivate_user',
      resource: 'user_management',
      resourceId: targetUser._id,
      details: {
        targetUsername: targetUser.username,
        newStatus: status,
        reason: reason
      },
      req,
      metadata: { adminAction: true, security: true }
    });
  }

  // User Profile Actions
  static async logProfileUpdate(user, changes, req) {
    await this.log({
      userId: user._id,
      userEmail: user.username,
      userRole: user.role,
      action: 'update_profile',
      resource: 'user_profile',
      resourceId: user._id,
      details: {
        changes: changes,
        fieldsUpdated: Object.keys(changes)
      },
      req
    });
  }

  static async logPasswordChange(user, req) {
    await this.log({
      userId: user._id,
      userEmail: user.username,
      userRole: user.role,
      action: 'change_password',
      resource: 'user_profile',
      resourceId: user._id,
      details: {},
      req,
      metadata: { security: true }
    });
  }

  // System Access and Security
  static async logUnauthorizedAccess(user, attemptedAction, resource, req) {
    await this.log({
      userId: user._id,
      userEmail: user.username,
      userRole: user.role,
      action: 'unauthorized_access_attempt',
      resource: resource,
      details: {
        attemptedAction: attemptedAction
      },
      req,
      metadata: { security: true, alert: true }
    });
  }

  static async logLoginFailure(username, reason, req) {
    await this.log({
      userId: null,
      userEmail: username,
      userRole: 'unknown',
      action: 'login_failure',
      resource: 'auth',
      details: {
        reason: reason,
        attemptedUsername: username
      },
      req,
      metadata: { security: true }
    });
  }

  // Data Access and Modifications
  static async logDataAccess(user, resource, resourceId, req) {
    await this.log({
      userId: user._id,
      userEmail: user.username,
      userRole: user.role,
      action: 'view_data',
      resource: resource,
      resourceId: resourceId,
      details: {},
      req
    });
  }

  static async logDataModification(user, action, resource, resourceId, changes, req) {
    await this.log({
      userId: user._id,
      userEmail: user.username,
      userRole: user.role,
      action: action, // 'create', 'update', 'delete'
      resource: resource,
      resourceId: resourceId,
      details: {
        changes: changes
      },
      req
    });
  }

  // Bulk Operations
  static async logBulkOperation(user, action, resource, affectedCount, details, req) {
    await this.log({
      userId: user._id,
      userEmail: user.username,
      userRole: user.role,
      action: `bulk_${action}`,
      resource: resource,
      details: {
        affectedCount: affectedCount,
        ...details
      },
      req,
      metadata: { bulkOperation: true }
    });
  }

  // System Configuration Changes
  static async logSystemConfigChange(admin, configKey, oldValue, newValue, req) {
    await this.log({
      userId: admin._id,
      userEmail: admin.username,
      userRole: admin.role,
      action: 'update_system_config',
      resource: 'system_settings',
      details: {
        configKey: configKey,
        oldValue: oldValue,
        newValue: newValue
      },
      req,
      metadata: { adminAction: true, systemChange: true }
    });
  }

  // Get activity logs with filtering and pagination
  static async getActivityLogs(filters = {}, options = {}) {
    try {
      const {
        page = 1,
        limit = 50,
        sortBy = 'timestamp',
        sortOrder = 'desc'
      } = options;

      const query = {};
      
      // Apply filters
      if (filters.userId) query.userId = filters.userId;
      if (filters.userRole) query.userRole = filters.userRole;
      if (filters.action) query.action = filters.action;
      if (filters.resource) query.resource = filters.resource;
      if (filters.startDate || filters.endDate) {
        query.timestamp = {};
        if (filters.startDate) query.timestamp.$gte = new Date(filters.startDate);
        if (filters.endDate) query.timestamp.$lte = new Date(filters.endDate);
      }
      if (filters.adminActions) query['metadata.adminAction'] = true;
      if (filters.securityEvents) query['metadata.security'] = true;

      const skip = (page - 1) * limit;
      const sort = { [sortBy]: sortOrder === 'desc' ? -1 : 1 };

      const [logs, totalCount] = await Promise.all([
        ActivityLog.find(query)
          .sort(sort)
          .skip(skip)
          .limit(limit)
          .lean(),
        ActivityLog.countDocuments(query)
      ]);

      return {
        logs,
        pagination: {
          currentPage: page,
          totalPages: Math.ceil(totalCount / limit),
          totalCount,
          hasNext: page < Math.ceil(totalCount / limit),
          hasPrev: page > 1
        }
      };
    } catch (error) {
      console.error('Failed to fetch activity logs:', error);
      throw error;
    }
  }

  // Get activity summary statistics
  static async getActivitySummary(dateRange = {}) {
    try {
      const matchStage = {};
      
      if (dateRange.startDate || dateRange.endDate) {
        matchStage.timestamp = {};
        if (dateRange.startDate) matchStage.timestamp.$gte = new Date(dateRange.startDate);
        if (dateRange.endDate) matchStage.timestamp.$lte = new Date(dateRange.endDate);
      }

      const summary = await ActivityLog.aggregate([
        { $match: matchStage },
        {
          $group: {
            _id: null,
            totalActivities: { $sum: 1 },
            uniqueUsers: { $addToSet: '$userId' },
            adminActions: {
              $sum: { $cond: [{ $eq: ['$metadata.adminAction', true] }, 1, 0] }
            },
            securityEvents: {
              $sum: { $cond: [{ $eq: ['$metadata.security', true] }, 1, 0] }
            },
            actionBreakdown: {
              $push: '$action'
            }
          }
        },
        {
          $project: {
            totalActivities: 1,
            uniqueUserCount: { $size: '$uniqueUsers' },
            adminActions: 1,
            securityEvents: 1,
            actionBreakdown: 1
          }
        }
      ]);

      return summary[0] || {
        totalActivities: 0,
        uniqueUserCount: 0,
        adminActions: 0,
        securityEvents: 0,
        actionBreakdown: []
      };
    } catch (error) {
      console.error('Failed to get activity summary:', error);
      throw error;
    }
  }
}

export default ActivityLogger;
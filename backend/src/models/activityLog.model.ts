import mongoose, { Document, Schema } from 'mongoose';

// Define enums for better type safety
export enum UserRole {
  USER = 'user',
  ADMIN = 'admin',
  SUPER_ADMIN = 'super_admin'
}

export enum Action {
  LOGIN = 'login',
  LOGOUT = 'logout',
  CREATE = 'create',
  UPDATE = 'update',
  DELETE = 'delete',
  VIEW = 'view'
}

export enum Resource {
  USER = 'user',
  CORN_FIELD = 'corn_field',
  SENSOR_DATA = 'sensor_data',
  ANALYTICS = 'analytics',
  PRESCRIPTION = 'prescription',
  AUTH = 'auth'
}

// Define the document interface
export interface IActivityLog extends Document {
  userId: mongoose.Types.ObjectId;
  userEmail: string;
  userRole: UserRole;
  action: Action;
  resource: Resource;
  resourceId?: mongoose.Types.ObjectId;
  details: Record<string, any>;
  ipAddress: string;
  userAgent: string;
  timestamp: Date;
  createdAt?: Date;
  updatedAt?: Date;
}

const activityLogSchema = new Schema<IActivityLog>({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  userEmail: {
    type: String,
    required: true
  },
  userRole: {
    type: String,
    enum: Object.values(UserRole),
    required: true
  },
  action: {
    type: String,
    required: true,
    enum: Object.values(Action)
  },
  resource: {
    type: String,
    required: true,
    enum: Object.values(Resource)
  },
  resourceId: {
    type: Schema.Types.ObjectId,
    required: false
  },
  details: {
    type: Schema.Types.Mixed,
    default: {}
  },
  ipAddress: {
    type: String,
    required: true
  },
  userAgent: {
    type: String,
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now,
    required: true
  }
}, {
  timestamps: true,
  collection: 'activity_logs'
});

// Add indexes for common queries
activityLogSchema.index({ userId: 1, timestamp: -1 });
activityLogSchema.index({ action: 1, timestamp: -1 });
activityLogSchema.index({ resource: 1, timestamp: -1 });
activityLogSchema.index({ userRole: 1, timestamp: -1 });

const ActivityLog = mongoose.model<IActivityLog>('ActivityLog', activityLogSchema);

export default ActivityLog;
import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import User from '../models/User';
import { AppError, catchAsync } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { HTTP_STATUS, USER_ROLES } from '../utils/constants';
import ActivityLogService from '../services/activityLog.service';
import { Action, Resource, UserRole } from '../models/activityLog.model';
import { extractRegionFromAddress } from '../middleware/auth';

/**
 * @desc    Get all users (Admin only)
 * @route   GET /api/users
 * @access  Private/Admin
 */
export const getUsers = catchAsync(async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 10;
  const search = req.query.search as string;
  const role = req.query.role as string;
  const status = req.query.status as string;
  const currentUser = (req as any).user;

  const skip = (page - 1) * limit;
  const query: any = {};

  // Filter by status (optional)
  if (status) {
    query.isActive = status === 'active';
  }

  // Build search query
  if (search) {
    query.$or = [
      { username: { $regex: search, $options: 'i' } },
      { email: { $regex: search, $options: 'i' } },
      { fullName: { $regex: search, $options: 'i' } }
    ];
  }

  if (role && Object.values(USER_ROLES).includes(role as any)) {
    query.role = role;
  }

  // Apply regional filtering for regional admins
  if (currentUser.role === USER_ROLES.REGIONAL_ADMIN && currentUser.assignedRegion) {
    // Filter users by region - check both object and string address formats
    query.$or = [
      // Object format: address.region matches
      { 'address.region': currentUser.assignedRegion },
      // String format: address contains the region name
      { address: { $regex: currentUser.assignedRegion.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), $options: 'i' } }
    ];
    
    // If there was already a search query, combine it with regional filter
    if (search) {
      query.$and = [
        {
          $or: [
            { 'address.region': currentUser.assignedRegion },
            { address: { $regex: currentUser.assignedRegion.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), $options: 'i' } }
          ]
        },
        {
          $or: [
            { username: { $regex: search, $options: 'i' } },
            { email: { $regex: search, $options: 'i' } },
            { fullName: { $regex: search, $options: 'i' } }
          ]
        }
      ];
      delete query.$or; // Remove the original $or since we're using $and now
    }
  }

  const [users, total] = await Promise.all([
    User.find(query)
      .select('-password -refreshTokens -passwordResetToken -emailVerificationToken -twoFactorSecret')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit),
    User.countDocuments(query)
  ]);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: {
      users,
      pagination: {
        current: page,
        pages: Math.ceil(total / limit),
        total,
        limit
      }
    }
  });
});

/**
 * @desc    Get user by ID
 * @route   GET /api/users/:id
 * @access  Private (Own profile or Admin)
 */
export const getUserById = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;

  // Check if user is accessing their own profile or is admin
  if (currentUser.id !== id && currentUser.role !== USER_ROLES.ADMIN && currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const user = await User.findById(id)
    .select('-password -refreshTokens -passwordResetToken -emailVerificationToken -twoFactorSecret');

  if (!user) {
    throw new AppError('User not found', HTTP_STATUS.NOT_FOUND);
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { user }
  });
});

/**
 * @desc    Create new user (Admin only)
 * @route   POST /api/users
 * @access  Private/Admin
 */
export const createUser = catchAsync(async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map((err: any) => ({
        field: err.param,
        message: err.msg
      }))
    });
  }

  const currentUser = (req as any).user;
  
  // Extract only the fields we need for user creation
  const {
    username,
    email,
    password,
    fullName,
    contactNumber,
    address,
    role
  } = req.body;

  const userData = {
    username,
    email,
    password,
    fullName,
    contactNumber,
    address,
    role: role || 'user',
    isActive: true // Set default values
  };

  logger.info(`Create user request started by admin: ${currentUser.username}`, { userData: { ...userData, password: '[HIDDEN]' } });

  // Check if username already exists
  const existingUser = await User.findOne({ username: userData.username });
  if (existingUser) {
    throw new AppError('Username already exists', HTTP_STATUS.CONFLICT);
  }

  // Check if email already exists (if provided)
  if (userData.email) {
    const existingEmail = await User.findOne({ email: userData.email });
    if (existingEmail) {
      throw new AppError('Email already exists', HTTP_STATUS.CONFLICT);
    }
  }

  // Create new user
  const user = new User(userData);
  await user.save();

  logger.info('User created successfully', {
    userId: user._id,
    username: user.username,
    createdBy: currentUser.id
  });

  // Activity Log: User Creation
  try {
    await ActivityLogService.createLog({
      userId: currentUser.id,
      userEmail: currentUser.email || 'unknown@email.com',
      userRole: (currentUser.role as UserRole) || ('admin' as UserRole),
      action: Action.CREATE,
      resource: Resource.USER,
      resourceId: user._id,
      details: {
        action: 'User Created',
        targetUser: user.username,
        targetEmail: user.email || 'no email',
        targetRole: user.role
      },
      ipAddress: (req as any).ip || req.connection.remoteAddress || 'unknown',
      userAgent: req.get('User-Agent') || 'unknown',
      timestamp: new Date()
    });
  } catch (error) {
    logger.error('Failed to log user creation activity:', error);
  }

  // Return user without sensitive fields
  const userResponse = await User.findById(user._id)
    .select('-password -refreshTokens -passwordResetToken -emailVerificationToken -twoFactorSecret');

  res.status(HTTP_STATUS.CREATED).json({
    success: true,
    message: 'User created successfully',
    data: { user: userResponse }
  });
});

/**
 * @desc    Update user profile
 * @route   PUT /api/users/:id
 * @access  Private (Own profile or Admin)
 */
export const updateUser = catchAsync(async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map((err: any) => ({
        field: err.param,
        message: err.msg
      }))
    });
  }

  const { id } = req.params;
  const currentUser = (req as any).user;
  const updateData = req.body;

  logger.info(`Update user request started for user ID: ${id}`, { updateData });

  // Check if user is updating their own profile or is regional admin and above
  if (currentUser.id !== id && currentUser.role !== USER_ROLES.REGIONAL_ADMIN && currentUser.role !== USER_ROLES.ADMIN && currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  // Prevent non-super-admins from updating to admin or super_admin
  // Regional admins can only assign user/farmer roles
  if (updateData.role && currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    if (updateData.role === USER_ROLES.ADMIN || updateData.role === USER_ROLES.SUPER_ADMIN) {
      throw new AppError('Insufficient permissions to assign this role', HTTP_STATUS.FORBIDDEN);
    }
    // Regional admins cannot assign regional_admin role
    if (updateData.role === USER_ROLES.REGIONAL_ADMIN && currentUser.role !== USER_ROLES.ADMIN) {
      throw new AppError('Insufficient permissions to assign regional admin role', HTTP_STATUS.FORBIDDEN);
    }
  }

  // Prevent username modification - usernames are immutable
  if (updateData.username) {
    delete updateData.username;
    logger.warn('Attempted to modify username, which is not allowed', { userId: id, attemptedBy: currentUser.id });
  }

  // Remove password if it's empty or undefined (password updates should use separate endpoint)
  if (!updateData.password || updateData.password.trim() === '') {
    delete updateData.password;
    logger.info('Empty password removed from update data', { userId: id });
  }

  const user = await User.findByIdAndUpdate(
    id,
    { ...updateData, updatedAt: new Date() },
    { new: true, runValidators: true }
  ).select('-password -refreshTokens -passwordResetToken -emailVerificationToken -twoFactorSecret');

  if (!user) {
    throw new AppError('User not found', HTTP_STATUS.NOT_FOUND);
  }

  logger.info('User profile updated', {
    userId: user._id,
    updatedBy: currentUser.id,
    updatedFields: Object.keys(updateData)
  });

  // Activity Log: User Update
  try {
    await ActivityLogService.createLog({
      userId: currentUser.id,
      userEmail: currentUser.email || 'unknown@email.com',
      userRole: (currentUser.role as UserRole) || ('admin' as UserRole),
      action: Action.UPDATE,
      resource: Resource.USER,
      resourceId: user._id,
      details: {
        action: 'User Updated',
        targetUser: user.username,
        targetEmail: user.email || 'no email',
        updatedFields: Object.keys(updateData)
      },
      ipAddress: (req as any).ip || req.connection.remoteAddress || 'unknown',
      userAgent: req.get('User-Agent') || 'unknown',
      timestamp: new Date()
    });
  } catch (error) {
    logger.error('Failed to log user update activity:', error);
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'User profile updated successfully',
    data: { user }
  });
});

/**
 * @desc    Delete user (Hard delete - permanently removes from database)
 * @route   DELETE /api/users/:id
 * @access  Private/Admin
 */
export const deleteUser = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;

  logger.info(`Delete user request started for user ID: ${id}`);

  // Prevent users from deleting themselves
  if (currentUser.id === id) {
    throw new AppError('Cannot delete your own account', HTTP_STATUS.BAD_REQUEST);
  }

  logger.info(`Finding user by ID: ${id}`);
  const user = await User.findById(id);
  if (!user) {
    throw new AppError('User not found', HTTP_STATUS.NOT_FOUND);
  }

  // Prevent non-super-admins from deleting admins
  if (user.role === USER_ROLES.ADMIN && currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Insufficient permissions to delete admin user', HTTP_STATUS.FORBIDDEN);
  }

  // Prevent deleting super admin
  if (user.role === USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Cannot delete super admin user', HTTP_STATUS.FORBIDDEN);
  }

  // Hard delete - permanently remove from database
  logger.info(`Performing hard delete for user: ${user.username}`);
  
  // Activity Log: User Deletion (log before deletion)
  try {
    await ActivityLogService.createLog({
      userId: currentUser.id,
      userEmail: currentUser.email || 'unknown@email.com',
      userRole: (currentUser.role as UserRole) || ('admin' as UserRole),
      action: Action.DELETE,
      resource: Resource.USER,
      resourceId: user._id,
      details: {
        action: 'User Deleted',
        targetUser: user.username,
        targetEmail: user.email || 'no email',
        targetRole: user.role,
        deletionType: 'PERMANENT'
      },
      ipAddress: (req as any).ip || req.connection.remoteAddress || 'unknown',
      userAgent: req.get('User-Agent') || 'unknown',
      timestamp: new Date()
    });
  } catch (error) {
    logger.error('Failed to log user deletion activity:', error);
  }

  await User.findByIdAndDelete(id);
  logger.info(`User permanently deleted from database: ${user.username}`);

  logger.info('User deleted', {
    userId: user._id,
    deletedBy: currentUser.id,
    username: user.username
  });

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'User deleted successfully'
  });
});

/**
 * @desc    Activate/Deactivate user
 * @route   PATCH /api/users/:id/status
 * @access  Private/Admin
 */
export const toggleUserStatus = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const { isActive } = req.body;
  const currentUser = (req as any).user;

  if (typeof isActive !== 'boolean') {
    throw new AppError('isActive must be a boolean value', HTTP_STATUS.BAD_REQUEST);
  }

  // Prevent users from deactivating themselves
  if (currentUser.id === id && !isActive) {
    throw new AppError('Cannot deactivate your own account', HTTP_STATUS.BAD_REQUEST);
  }

  const user = await User.findById(id);
  if (!user) {
    throw new AppError('User not found', HTTP_STATUS.NOT_FOUND);
  }

  // Prevent non-super-admins from deactivating admins
  if (user.role === USER_ROLES.ADMIN && currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Insufficient permissions to modify admin user status', HTTP_STATUS.FORBIDDEN);
  }

  // Prevent deactivating super admin
  if (user.role === USER_ROLES.SUPER_ADMIN && !isActive) {
    throw new AppError('Cannot deactivate super admin user', HTTP_STATUS.FORBIDDEN);
  }

  user.isActive = isActive;
  await user.save();

  logger.info('User status updated', {
    userId: user._id,
    updatedBy: currentUser.id,
    newStatus: isActive ? 'active' : 'inactive'
  });

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: `User ${isActive ? 'activated' : 'deactivated'} successfully`,
    data: { user: { id: user._id, isActive: user.isActive } }
  });
});

/**
 * @desc    Get user statistics
 * @route   GET /api/users/stats
 * @access  Private/Admin
 */
export const getUserStats = catchAsync(async (req: Request, res: Response) => {
  const stats = await User.aggregate([
    {
      $group: {
        _id: null,
        totalUsers: { $sum: 1 },
        activeUsers: { $sum: { $cond: ['$isActive', 1, 0] } },
        inactiveUsers: { $sum: { $cond: ['$isActive', 0, 1] } },
        verifiedUsers: { $sum: { $cond: ['$emailVerified', 1, 0] } },
        unverifiedUsers: { $sum: { $cond: ['$emailVerified', 0, 1] } },
        users2FAEnabled: { $sum: { $cond: ['$twoFactorEnabled', 1, 0] } }
      }
    }
  ]);

  const roleStats = await User.aggregate([
    {
      $group: {
        _id: '$role',
        count: { $sum: 1 }
      }
    }
  ]);

  const recentUsers = await User.find()
    .select('username email fullName createdAt isActive emailVerified')
    .sort({ createdAt: -1 })
    .limit(10);

  const monthlyRegistrations = await User.aggregate([
    {
      $match: {
        createdAt: {
          $gte: new Date(new Date().getFullYear(), new Date().getMonth() - 11, 1)
        }
      }
    },
    {
      $group: {
        _id: {
          year: { $year: '$createdAt' },
          month: { $month: '$createdAt' }
        },
        count: { $sum: 1 }
      }
    },
    {
      $sort: { '_id.year': 1, '_id.month': 1 }
    }
  ]);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: {
      overview: stats[0] || {
        totalUsers: 0,
        activeUsers: 0,
        inactiveUsers: 0,
        verifiedUsers: 0,
        unverifiedUsers: 0,
        users2FAEnabled: 0
      },
      roleDistribution: roleStats.reduce((acc, item) => {
        acc[item._id] = item.count;
        return acc;
      }, {}),
      recentUsers,
      monthlyRegistrations
    }
  });
});

/**
 * @desc    Update user preferences
 * @route   PUT /api/users/:id/preferences
 * @access  Private (Own profile only)
 */
export const updateUserPreferences = catchAsync(async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map((err: any) => ({
        field: err.param,
        message: err.msg
      }))
    });
  }

  const { id } = req.params;
  const currentUser = (req as any).user;
  const { preferences } = req.body;

  // Users can only update their own preferences
  if (currentUser.id !== id) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const user = await User.findByIdAndUpdate(
    id,
    { preferences, updatedAt: new Date() },
    { new: true, runValidators: true }
  ).select('-password -refreshTokens -passwordResetToken -emailVerificationToken -twoFactorSecret');

  if (!user) {
    throw new AppError('User not found', HTTP_STATUS.NOT_FOUND);
  }

  logger.info('User preferences updated', {
    userId: user._id,
    preferences
  });

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Preferences updated successfully',
    data: { user }
  });
});

/**
 * @desc    Get user activity log
 * @route   GET /api/users/:id/activity
 * @access  Private (Own profile or Admin)
 */
export const getUserActivity = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;

  // Check if user is accessing their own activity or is admin
  if (currentUser.id !== id && currentUser.role !== USER_ROLES.ADMIN && currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const user = await User.findById(id);
  if (!user) {
    throw new AppError('User not found', HTTP_STATUS.NOT_FOUND);
  }

  // For now, return basic user information
  const activity = {
    lastLogin: user.lastLogin,
    loginAttempts: user.loginAttempts,
    accountCreated: user.createdAt,
    lastUpdated: user.updatedAt,
    emailVerified: user.emailVerified,
    twoFactorEnabled: user.twoFactorEnabled
  };

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { activity }
  });
});

/**
 * @desc    Search users
 * @route   GET /api/users/search
 * @access  Private/Admin
 */
export const searchUsers = catchAsync(async (req: Request, res: Response) => {
  const { q, limit = 10 } = req.query;

  if (!q || typeof q !== 'string') {
    throw new AppError('Search query is required', HTTP_STATUS.BAD_REQUEST);
  }

  const users = await User.find({
    $or: [
      { username: { $regex: q, $options: 'i' } },
      { email: { $regex: q, $options: 'i' } },
      { fullName: { $regex: q, $options: 'i' } }
    ],
    isActive: true
  })
    .select('username email fullName role createdAt')
    .limit(parseInt(limit as string))
    .sort({ username: 1 });

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { users }
  });
});

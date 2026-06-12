import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import User from '../models/User';
import { AppError, catchAsync } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { HTTP_STATUS, USER_ROLES } from '../utils/constants';

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

  const skip = (page - 1) * limit;
  const query: any = {};

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

  if (status) {
    query.isActive = status === 'active';
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

  // Check if user is updating their own profile or is admin
  if (currentUser.id !== id && currentUser.role !== USER_ROLES.ADMIN && currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  // Prevent non-admins from updating role
  if (updateData.role && currentUser.role !== USER_ROLES.ADMIN && currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    delete updateData.role;
  }

  // Prevent non-super-admins from updating to admin or super_admin
  if (updateData.role && currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    if (updateData.role === USER_ROLES.ADMIN || updateData.role === USER_ROLES.SUPER_ADMIN) {
      throw new AppError('Insufficient permissions to assign this role', HTTP_STATUS.FORBIDDEN);
    }
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

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'User profile updated successfully',
    data: { user }
  });
});

/**
 * @desc    Delete user (Soft delete)
 * @route   DELETE /api/users/:id
 * @access  Private/Admin
 */
export const deleteUser = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;

  // Prevent users from deleting themselves
  if (currentUser.id === id) {
    throw new AppError('Cannot delete your own account', HTTP_STATUS.BAD_REQUEST);
  }

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

  // Soft delete
  user.isActive = false;
  await user.save();

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
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;

  // Check if user is accessing their own activity or is admin
  if (currentUser.id !== id && currentUser.role !== USER_ROLES.ADMIN && currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const user = await User.findById(id);
  if (!user) {
    throw new AppError('User not found', HTTP_STATUS.NOT_FOUND);
  }

  // This would typically come from a separate activity/audit log collection
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

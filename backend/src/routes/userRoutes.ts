import { Router } from 'express';
import {
  getUsers,
  getUserById,
  updateUser,
  deleteUser,
  toggleUserStatus,
  getUserStats,
  updateUserPreferences,
  getUserActivity,
  searchUsers
} from '../controllers/userController';
import { authenticate, authorize } from '../middleware/auth';
import {
  validateUserUpdate,
  validateObjectId,
  validatePagination
} from '../middleware/validation';
import { USER_ROLES } from '../utils/constants';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Get all users (Admin only)
router.get('/', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), validatePagination, getUsers);

// Search users (Admin only)
router.get('/search', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), searchUsers);

// Get user statistics (Admin only)
router.get('/stats', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), getUserStats);

// Get user by ID
router.get('/:id', validateObjectId, getUserById);

// Update user profile
router.put('/:id', validateObjectId, validateUserUpdate, updateUser);

// Delete user (Admin only)
router.delete('/:id', validateObjectId, authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), deleteUser);

// Toggle user status (Admin only)
router.patch('/:id/status', validateObjectId, authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), toggleUserStatus);

// Update user preferences
router.put('/:id/preferences', validateObjectId, updateUserPreferences);

// Get user activity
router.get('/:id/activity', validateObjectId, getUserActivity);

export default router;

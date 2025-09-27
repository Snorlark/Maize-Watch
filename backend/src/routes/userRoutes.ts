import { Router } from 'express';
import {
  getUsers,
  getUserById,
  createUser,
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
  validateUserRegistration,
  validateUserUpdate,
  validateObjectId,
  validatePagination,
  handleValidationErrors
} from '../middleware/validation';
import { USER_ROLES } from '../utils/constants';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Get all users (Admin only)
router.get('/', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), validatePagination, getUsers);

// Create new user (Admin only)
router.post('/', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), ...validateUserRegistration, handleValidationErrors, createUser);

// Search users (Admin only)
router.get('/search', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), searchUsers);

// Get user statistics (Admin only)
router.get('/stats', authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), getUserStats);

// Get user by ID
router.get('/:id', validateObjectId('id'), getUserById);

// Update user profile
router.put('/:id', validateObjectId('id'), validateUserUpdate, updateUser);

// Delete user (Admin only)
router.delete('/:id', validateObjectId('id'), authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), deleteUser);

// Toggle user status (Admin only)
router.patch('/:id/status', validateObjectId('id'), authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), toggleUserStatus);

// Update user preferences
router.put('/:id/preferences', validateObjectId('id'), updateUserPreferences);

// Get user activity
router.get('/:id/activity', validateObjectId('id'), getUserActivity);

export default router;

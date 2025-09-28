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
import { authenticate, authorize, requireRegionalAdmin } from '../middleware/auth';
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

// Get all users (Regional Admin and above)
router.get('/', requireRegionalAdmin, validatePagination, getUsers);

// Create new user (Regional Admin and above)
router.post('/', authorize(USER_ROLES.REGIONAL_ADMIN, USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), ...validateUserRegistration, handleValidationErrors, createUser);

// Search users (Regional Admin and above)
router.get('/search', authorize(USER_ROLES.REGIONAL_ADMIN, USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), searchUsers);

// Get user statistics (Regional Admin and above)
router.get('/stats', authorize(USER_ROLES.REGIONAL_ADMIN, USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), getUserStats);

// Get user by ID
router.get('/:id', validateObjectId('id'), getUserById);

// Update user profile (Regional Admin and above)
router.put('/:id', validateObjectId('id'), authorize(USER_ROLES.REGIONAL_ADMIN, USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), validateUserUpdate, updateUser);

// Delete user (Regional Admin and above)
router.delete('/:id', validateObjectId('id'), authorize(USER_ROLES.REGIONAL_ADMIN, USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), deleteUser);

// Toggle user status (Regional Admin and above)
router.patch('/:id/status', validateObjectId('id'), authorize(USER_ROLES.REGIONAL_ADMIN, USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), toggleUserStatus);

// Update user preferences
router.put('/:id/preferences', validateObjectId('id'), updateUserPreferences);

// Get user activity
router.get('/:id/activity', validateObjectId('id'), getUserActivity);

export default router;

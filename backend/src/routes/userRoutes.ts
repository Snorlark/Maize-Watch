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
  searchUsers,
  getPendingDeletions,
  approveDeletion,
  rejectDeletion
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

// Create new user (Regional Admin and Super Admin only)
router.post('/', authorize(USER_ROLES.REGIONAL_ADMIN, USER_ROLES.SUPER_ADMIN), ...validateUserRegistration, handleValidationErrors, createUser);

// Search users (Regional Admin and Super Admin only)
router.get('/search', authorize(USER_ROLES.REGIONAL_ADMIN, USER_ROLES.SUPER_ADMIN), searchUsers);

// Get user statistics (Regional Admin and Super Admin only)
router.get('/stats', authorize(USER_ROLES.REGIONAL_ADMIN, USER_ROLES.SUPER_ADMIN), getUserStats);

// Get pending deletion requests (Regional Admin and Super Admin only)
router.get('/pending-deletions', authorize(USER_ROLES.REGIONAL_ADMIN, USER_ROLES.SUPER_ADMIN), getPendingDeletions);

// Get user by ID
router.get('/:id', validateObjectId('id'), getUserById);

// Update user profile (Regional Admin and above)
router.put('/:id', validateObjectId('id'), authorize(USER_ROLES.REGIONAL_ADMIN, USER_ROLES.SUPER_ADMIN), validateUserUpdate, updateUser);

// Delete user (Regional Admin and above)
router.delete('/:id', validateObjectId('id'), authorize(USER_ROLES.REGIONAL_ADMIN, USER_ROLES.SUPER_ADMIN), deleteUser);

// Approve deletion request (Super Admin only)
router.post('/:id/approve-deletion', validateObjectId('id'), authorize(USER_ROLES.SUPER_ADMIN), approveDeletion);

// Reject deletion request (Super Admin only)
router.post('/:id/reject-deletion', validateObjectId('id'), authorize(USER_ROLES.SUPER_ADMIN), rejectDeletion);

// Toggle user status (Regional Admin and above)
router.patch('/:id/status', validateObjectId('id'), authorize(USER_ROLES.REGIONAL_ADMIN, USER_ROLES.SUPER_ADMIN), toggleUserStatus);

// Update user preferences
router.put('/:id/preferences', validateObjectId('id'), updateUserPreferences);

// Get user activity
router.get('/:id/activity', validateObjectId('id'), getUserActivity);

export default router;

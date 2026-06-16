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
import { authenticate, authorize, requireSuperAdmin } from '../middleware/auth';
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

// Get all users (Super Admin only)
router.get('/', requireSuperAdmin, validatePagination, getUsers);

// Create new user (Super Admin only)
router.post('/', requireSuperAdmin, ...validateUserRegistration, handleValidationErrors, createUser);

// Search users (Super Admin only)
router.get('/search', requireSuperAdmin, searchUsers);

// Get user statistics (Super Admin only)
router.get('/stats', requireSuperAdmin, getUserStats);

// Get pending deletion requests (Super Admin only)
router.get('/pending-deletions', requireSuperAdmin, getPendingDeletions);

// Get user by ID
router.get('/:id', validateObjectId('id'), getUserById);

// Update user profile (Super Admin only)
router.put('/:id', validateObjectId('id'), requireSuperAdmin, validateUserUpdate, updateUser);

// Delete user (Super Admin only)
router.delete('/:id', validateObjectId('id'), requireSuperAdmin, deleteUser);

// Approve deletion request (Super Admin only)
router.post('/:id/approve-deletion', validateObjectId('id'), authorize(USER_ROLES.SUPER_ADMIN), approveDeletion);

// Reject deletion request (Super Admin only)
router.post('/:id/reject-deletion', validateObjectId('id'), authorize(USER_ROLES.SUPER_ADMIN), rejectDeletion);

// Toggle user status (Super Admin only)
router.patch('/:id/status', validateObjectId('id'), requireSuperAdmin, toggleUserStatus);

// Update user preferences
router.put('/:id/preferences', validateObjectId('id'), updateUserPreferences);

// Get user activity
router.get('/:id/activity', validateObjectId('id'), getUserActivity);

export default router;

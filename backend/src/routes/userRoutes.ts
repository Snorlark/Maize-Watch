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
  validatePagination,
  handleValidationErrors
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
router.get('/:id', validateObjectId('id'), getUserById);

// Update user profile - using proper validation
router.put('/:id', validateObjectId('id'), (req, res, next) => {
  // Simple validation
  const { fullName, contactNumber, address } = req.body;
  
  if (fullName && (typeof fullName !== 'string' || fullName.length < 2 || fullName.length > 100)) {
    return res.status(400).json({
      success: false,
      message: 'Full name must be between 2 and 100 characters'
    });
  }
  
  if (contactNumber && !/^09\d{9}$/.test(contactNumber)) {
    return res.status(400).json({
      success: false,
      message: 'Please provide a valid Philippine mobile number'
    });
  }
  
  if (address && typeof address === 'object') {
    if (!address.region || !address.province || !address.municipality || !address.barangay) {
      return res.status(400).json({
        success: false,
        message: 'Address must include region, province, municipality, and barangay'
      });
    }
  }
  
  next();
}, updateUser);

// Delete user (Admin only)
router.delete('/:id', validateObjectId('id'), authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), deleteUser);

// Toggle user status (Admin only)
router.patch('/:id/status', validateObjectId('id'), authorize(USER_ROLES.ADMIN, USER_ROLES.SUPER_ADMIN), toggleUserStatus);

// Update user preferences
router.put('/:id/preferences', validateObjectId('id'), updateUserPreferences);

// Get user activity
router.get('/:id/activity', validateObjectId('id'), getUserActivity);

export default router;

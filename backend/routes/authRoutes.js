// authRoutes.js
import express from 'express';
import { login, logout, getUserProfile } from '../authController.js';
import { isAuthenticated as authenticate, isAdmin, isSuperAdmin, authorize, isAdminOrSuperAdmin } from '../middleware/auth.middleware.js';
import { logActivity, autoLogActivity } from '../middleware/activityLogger.js';

const router = express.Router();

// Public routes
router.post('/login', login);
router.post('/logout', logout);

// Protected routes (require authentication)
router.get('/profile', authenticate, getUserProfile);

// Admin routes for user management - Both admin and super_admin can access
router.get('/users', 
  authenticate, 
  isAdminOrSuperAdmin,
  logActivity('view_users', 'user'),
  async (req, res) => {
    try {
      // Your existing users fetching code here
      // Role-based user filtering:
      // For super_admin: fetch all users including admins
      // For admin: fetch only farmers/regular users
      
      let userFilter = {};
      if (req.user.role === 'admin') {
        // Admins can only see farmers and regular users
        userFilter.role = { $in: ['farmer', 'user'] };
      }
      // Super admins can see all users (no filter needed)
      
      res.json({ users: [], message: 'Users fetched successfully' }); // Replace with actual user data
    } catch (error) {
      console.error('Error fetching users:', error);
      res.status(500).json({ message: 'Failed to fetch users' });
    }
  }
);

// Activity logs endpoint - Both admin and super_admin can access
router.get('/activity-logs',
  authenticate,
  isAdminOrSuperAdmin,
  logActivity('view_activity_logs', 'activity_log'),
  async (req, res) => {
    try {
      const { page = 1, limit = 20, userId, action, resource, startDate, endDate, search } = req.query;
      
      // Build query based on filters
      const query = {};
      
      if (userId) query.userId = userId;
      if (action) query.action = { $regex: action, $options: 'i' };
      if (resource) query.resource = { $regex: resource, $options: 'i' };
      if (search) {
        query.$or = [
          { userEmail: { $regex: search, $options: 'i' } },
          { action: { $regex: search, $options: 'i' } },
          { resource: { $regex: search, $options: 'i' } }
        ];
      }
      
      // Date range filter
      if (startDate || endDate) {
        query.timestamp = {};
        if (startDate) query.timestamp.$gte = new Date(startDate);
        if (endDate) query.timestamp.$lte = new Date(endDate);
      }
      
      // Role-based filtering
      if (req.user.role === 'admin') {
        // Admins can only see farmer/user activities
        query.userRole = { $in: ['farmer', 'user'] };
      }
      // Super admins can see all activities (no additional filter needed)
      
      const skip = (parseInt(page) - 1) * parseInt(limit);
      
      // You'll need to import your ActivityLog model
      // const ActivityLog = await import('../models/ActivityLog.js');
      
      // For now, returning mock data - replace with actual database query
      const logs = []; // Replace with: await ActivityLog.find(query).populate('userId').sort({ timestamp: -1 }).skip(skip).limit(parseInt(limit));
      const total = 0; // Replace with: await ActivityLog.countDocuments(query);
      
      res.json({
        logs,
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / parseInt(limit)),
        totalLogs: total
      });
      
    } catch (error) {
      console.error('Error fetching activity logs:', error);
      res.status(500).json({ message: 'Failed to fetch activity logs' });
    }
  }
);

// User CRUD operations - Both admin and super_admin can access
router.post('/', 
  authenticate, 
  isAdminOrSuperAdmin,
  logActivity('create_user', 'user'),
  async (req, res) => {
    try {
      // Role-based user creation restrictions
      const { role: newUserRole } = req.body;
      
      // Admins cannot create other admins or super_admins
      if (req.user.role === 'admin' && ['admin', 'super_admin'].includes(newUserRole)) {
        return res.status(403).json({ 
          message: 'Insufficient privileges to create admin users' 
        });
      }
      
      // Your existing create user logic
      res.json({ message: 'User created successfully' });
    } catch (error) {
      console.error('Error creating user:', error);
      res.status(500).json({ message: 'Failed to create user' });
    }
  }
);

router.put('/:id', 
  authenticate, 
  isAdminOrSuperAdmin,
  logActivity('update_user', 'user'),
  async (req, res) => {
    try {
      const { id } = req.params;
      const { role: newRole } = req.body;
      
      // Role-based update restrictions
      if (req.user.role === 'admin') {
        // Admins cannot update admin or super_admin users
        // You'll need to fetch the target user to check their current role
        // const targetUser = await User.findById(id);
        // if (['admin', 'super_admin'].includes(targetUser.role)) {
        //   return res.status(403).json({ message: 'Cannot modify admin users' });
        // }
        
        // Admins cannot assign admin or super_admin roles
        if (newRole && ['admin', 'super_admin'].includes(newRole)) {
          return res.status(403).json({ 
            message: 'Insufficient privileges to assign admin roles' 
          });
        }
      }
      
      // Your existing update user logic
      res.json({ message: 'User updated successfully' });
    } catch (error) {
      console.error('Error updating user:', error);
      res.status(500).json({ message: 'Failed to update user' });
    }
  }
);

router.delete('/:id',
  authenticate,
  isAdminOrSuperAdmin,
  logActivity('delete_user', 'user'),
  async (req, res) => {
    try {
      const { id } = req.params;
      
      // Role-based deletion restrictions
      if (req.user.role === 'admin') {
        // Admins cannot delete admin or super_admin users
        // You'll need to fetch the target user to check their role
        // const targetUser = await User.findById(id);
        // if (['admin', 'super_admin'].includes(targetUser.role)) {
        //   return res.status(403).json({ message: 'Cannot delete admin users' });
        // }
      }
      
      // Prevent users from deleting themselves
      if (req.user._id.toString() === id) {
        return res.status(400).json({ message: 'Cannot delete your own account' });
      }
      
      // Your existing delete user logic
      res.json({ message: 'User deleted successfully' });
    } catch (error) {
      console.error('Error deleting user:', error);
      res.status(500).json({ message: 'Failed to delete user' });
    }
  }
);

// Additional admin-only routes that both admin and super_admin can access

// Bulk user operations
router.post('/bulk-actions',
  authenticate,
  isAdminOrSuperAdmin,
  logActivity('bulk_user_action', 'user'),
  async (req, res) => {
    try {
      const { action, userIds } = req.body;
      
      // Role-based bulk action restrictions
      if (req.user.role === 'admin') {
        // Admins can only perform bulk actions on farmer/user accounts
        // You'll need to validate that all target users are not admin/super_admin
      }
      
      res.json({ message: `Bulk ${action} completed successfully` });
    } catch (error) {
      console.error('Error performing bulk action:', error);
      res.status(500).json({ message: 'Failed to perform bulk action' });
    }
  }
);

// User status management (activate/deactivate)
router.patch('/:id/status',
  authenticate,
  isAdminOrSuperAdmin,
  logActivity('change_user_status', 'user'),
  async (req, res) => {
    try {
      const { id } = req.params;
      const { status, reason } = req.body;
      
      // Role-based status change restrictions
      if (req.user.role === 'admin') {
        // Admins cannot change status of admin or super_admin users
        // Add validation logic here
      }
      
      res.json({ message: `User status updated to ${status}` });
    } catch (error) {
      console.error('Error updating user status:', error);
      res.status(500).json({ message: 'Failed to update user status' });
    }
  }
);

// Password reset for users
router.post('/:id/reset-password',
  authenticate,
  isAdminOrSuperAdmin,
  logActivity('admin_password_reset', 'user'),
  async (req, res) => {
    try {
      const { id } = req.params;
      
      // Role-based password reset restrictions
      if (req.user.role === 'admin') {
        // Admins cannot reset passwords for admin or super_admin users
        // Add validation logic here
      }
      
      res.json({ message: 'Password reset successfully' });
    } catch (error) {
      console.error('Error resetting password:', error);
      res.status(500).json({ message: 'Failed to reset password' });
    }
  }
);

// Apply activity logging to all routes
router.use('/', authenticate, autoLogActivity('auth'));

export default router;
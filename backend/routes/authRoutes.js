// authRoutes.js
import express from 'express';
import { login, logout, getUserProfile } from '../authController.js';
import { isAuthenticated as authenticate, isAdmin, isSuperAdmin, authorize } from '../middleware/auth.middleware.js';
import { logActivity, autoLogActivity } from '../middleware/activityLogger.js';

const router = express.Router();

// Public routes
router.post('/login', login);
router.post('/logout', logout);

// Protected routes (require authentication)
router.get('/profile', authenticate, getUserProfile);

// Admin-only routes
router.get('/users', isAdmin, async (req, res) => {
  // This is just a placeholder for your existing admin routes
  // You should move your actual users fetching code here
});
router.get('/users', isSuperAdmin, async (req, res) => {
  // This is just a placeholder for your existing admin routes
  // You should move your actual users fetching code here
});

router.post('/', 
  authenticate, 
  authorize(['admin', 'super_admin']),
  logActivity('create_user', 'farmer'),
  async (req, res) => {
    // Your existing create user logic
  }
);

router.put('/:id', 
  authenticate, 
  authorize(['admin', 'super_admin']),
  logActivity('update_user', 'farmer'),
  async (req, res) => {
    // Your existing update user logic
  }
);

router.delete('/:id',
  authenticate,
  authorize(['admin', 'super_admin']),
  logActivity('delete_user', 'farmer'),
  async (req, res) => {
    // Your existing delete user logic
  }
);

// For bulk operations, you can use autoLogActivity
router.use('/', authenticate, autoLogActivity('farmer'));

export default router;
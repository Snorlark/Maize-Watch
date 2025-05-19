// authRoutes.js
import express from 'express';
import { login, logout, getUserProfile } from './authController';
import { isAuthenticated, isAdmin } from './auth.middleware';

const router = express.Router();

// Public routes
router.post('/login', login);
router.post('/logout', logout);

// Protected routes (require authentication)
router.get('/profile', isAuthenticated, getUserProfile);

// Admin-only routes
router.get('/users', isAdmin, async (req, res) => {
  // This is just a placeholder for your existing admin routes
  // You should move your actual users fetching code here
});

export default router;
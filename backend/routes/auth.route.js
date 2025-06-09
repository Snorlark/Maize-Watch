import { Router } from 'express';
import { register, login, logout, refreshToken, verifyPhone, resetPassword, getUserByUsername, updateUser } from '../controllers/auth.controller.js';
import { isAuthenticated } from '../middleware/auth.middleware.js';

const router = Router();

// Basic auth routes
router.post('/register', register);
router.post('/login', login);
router.post('/logout', isAuthenticated, logout);
router.post('/refresh-token', isAuthenticated, refreshToken);

// Password reset routes
router.post('/verify-phone', verifyPhone);
router.post('/reset-password', resetPassword);

// User details routes
router.get('/user/:username', isAuthenticated, getUserByUsername);
router.put('/user/:username', isAuthenticated, updateUser);

export default router; 
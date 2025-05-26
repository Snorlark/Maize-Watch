import { Router } from 'express';
import { register, login, refreshToken, verifyPhone, resetPassword, getUserByUsername } from '../controllers/auth.controller.js';
import { verifyToken, isAuthenticated } from '../middleware/auth.middleware.js';

const router = Router();

// Basic auth routes
router.post('/register', register);
router.post('/login', login);
router.post('/refresh-token', isAuthenticated, refreshToken);

// Password reset routes
router.post('/verify-phone', verifyPhone);
router.post('/reset-password', resetPassword);

// User details route
router.get('/user/:username', getUserByUsername);

export default router; 
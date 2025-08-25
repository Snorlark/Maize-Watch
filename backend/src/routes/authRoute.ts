import { Router } from 'express';
import {
  register,
  login,
  logout,
  logoutAll,
  refreshToken,
  forgotPassword,
  resetPassword,
  changePassword,
  verifyEmail,
  resendVerification,
  setup2FA,
  verify2FA,
  disable2FA,
  getProfile,
} from '../controllers/authController';
import { authenticate, optionalAuth } from '../middleware/auth';
import { authLimiter, passwordResetLimiter } from '../middleware/rateLimiter';
import {
  validateUserRegistration,
  validateUserLogin,
  validatePasswordReset,
  validatePasswordChange,
  validate2FAToken
} from '../middleware/validation';

const router = Router();

// Registration and login routes
router.post('/register', authLimiter, validateUserRegistration, register);
router.post('/login', authLimiter, validateUserLogin, login);

// Token management
router.post('/refresh', refreshToken);
router.post('/logout', authenticate, logout);
router.post('/logout-all', authenticate, logoutAll);

// Password management
router.post('/forgot-password', passwordResetLimiter, validatePasswordReset, forgotPassword);
router.post('/reset-password', validatePasswordReset, resetPassword);
router.put('/change-password', authenticate, validatePasswordChange, changePassword);

// Email verification
router.get('/verify-email/:token', verifyEmail);
router.post('/resend-verification', authenticate, resendVerification);

// Two-factor authentication
router.post('/setup-2fa', authenticate, setup2FA);
router.post('/verify-2fa', authenticate, validate2FAToken, verify2FA);
router.post('/disable-2fa', authenticate, validate2FAToken, disable2FA);

// User profile
router.get('/me', authenticate, getProfile);

export default router;

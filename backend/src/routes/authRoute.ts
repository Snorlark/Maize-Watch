import { Router } from 'express';
import {
  register,
  login,
  refreshToken,
  logout,
  logoutAll,
  forgotPassword,
  resetPassword,
  changePassword,
  verifyEmail,
  resendVerification,
  setup2FA,
  verify2FA,
  disable2FA,
  getProfile,
  updateProfile,
  sendLoginOTP,
  verifyLoginOTP,
  sendForgotPasswordOTP,
  verifyForgotPasswordOTP,
  resetPasswordWithOTP,
} from '../controllers/authController';
import { authenticate, optionalAuth } from '../middleware/auth';
import { authLimiter, passwordResetLimiter } from '../middleware/rateLimiter';
import {
  validateUserRegistration,
  validateUserLogin,
  validatePasswordReset,
  validatePasswordChange,
  validate2FAToken,
  validateUserUpdate,
  validateEmailOTP,
  validateOTPVerification,
  handleValidationErrors
} from '../middleware/validation';

const router = Router();

// Registration and login routes
router.post('/register', authLimiter, ...validateUserRegistration, handleValidationErrors, register);
router.post('/login', authLimiter, ...validateUserLogin, handleValidationErrors, login);

// Email OTP login (Web Admin)
router.post('/send-login-otp', authLimiter, ...validateEmailOTP, handleValidationErrors, sendLoginOTP);
router.post('/verify-login-otp', authLimiter, ...validateOTPVerification, handleValidationErrors, verifyLoginOTP);

// Forgot Password OTP (Web Admin)
router.post('/send-forgot-password-otp', passwordResetLimiter, ...validateEmailOTP, handleValidationErrors, sendForgotPasswordOTP);
router.post('/verify-forgot-password-otp', passwordResetLimiter, ...validateOTPVerification, handleValidationErrors, verifyForgotPasswordOTP);
router.post('/reset-password', passwordResetLimiter, resetPasswordWithOTP);

// Token management
router.post('/refresh', refreshToken);
router.post('/logout', authenticate, logout);
router.post('/logout-all', authenticate, logoutAll);

// Password management (legacy)
router.post('/forgot-password', passwordResetLimiter, validatePasswordReset, forgotPassword);
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
router.put('/me', authenticate, validateUserUpdate, updateProfile);

export default router;

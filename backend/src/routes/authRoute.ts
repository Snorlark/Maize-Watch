import { Router } from 'express';

// 1. Controller Logic (The actual functions that handle the request)
// Double-check if this path should be '../controllers/authController'
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
  resetPasswordWithOTP
} from '../controllers/authController';

// 2. Validation Middleware (The checks that run BEFORE the controller)
import {
  validateUserRegistration,
  validateUserLogin,
  validateUserUpdate,
  validateEmailOTP,
  validateOTPVerification,
  validatePasswordReset,
  validatePasswordChange,
  validate2FAToken,
  handleValidationErrors
} from '../middleware/validation';

// 3. Rate Limiters
import { authLimiter, passwordResetLimiter } from '../middleware/rateLimiter';

// 4. Auth Protection
import { authenticate } from '../middleware/auth';

console.log('--- Debugging Auth Route Imports ---');
console.log('authLimiter:', typeof authLimiter);
console.log('register:', typeof register);
console.log('authenticate:', typeof authenticate);
console.log('validateUserRegistration:', typeof validateUserRegistration);

const router = Router();

// --- Registration and Login Routes ---
router.post('/register', authLimiter, ...validateUserRegistration, handleValidationErrors, register);
router.post('/login', authLimiter, ...validateUserLogin, handleValidationErrors, login);

// --- Email OTP Login (Web Admin) ---
router.post('/send-login-otp', authLimiter, ...validateEmailOTP, handleValidationErrors, sendLoginOTP);
router.post('/verify-login-otp', authLimiter, ...validateOTPVerification, handleValidationErrors, verifyLoginOTP);

// --- Forgot Password OTP (Web Admin) ---
router.post('/send-forgot-password-otp', passwordResetLimiter, ...validateEmailOTP, handleValidationErrors, sendForgotPasswordOTP);
router.post('/verify-forgot-password-otp', passwordResetLimiter, ...validateOTPVerification, handleValidationErrors, verifyForgotPasswordOTP);
router.post('/reset-password', passwordResetLimiter, resetPasswordWithOTP);

// --- Token Management ---
router.post('/refresh', refreshToken);
router.post('/logout', authenticate, logout);
router.post('/logout-all', authenticate, logoutAll);

// --- Password Management (Legacy) ---
router.post('/forgot-password', passwordResetLimiter, validatePasswordReset, forgotPassword);
router.put('/change-password', authenticate, validatePasswordChange, changePassword);

// --- Email Verification ---
router.get('/verify-email/:token', verifyEmail);
router.post('/resend-verification', authenticate, resendVerification);

// --- Two-Factor Authentication ---
router.post('/setup-2fa', authenticate, setup2FA);
router.post('/verify-2fa', authenticate, validate2FAToken, verify2FA);
router.post('/disable-2fa', authenticate, validate2FAToken, disable2FA);

// --- User Profile ---
router.get('/me', authenticate, getProfile);
router.put('/me', authenticate, validateUserUpdate, updateProfile);

export default router;
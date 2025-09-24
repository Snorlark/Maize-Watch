import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import authService from '../services/authService';
import { AppError, catchAsync } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { HTTP_STATUS } from '../utils/constants';
import ActivityLogService from '../services/activityLog.service';
import { Action, Resource, UserRole } from '../models/activityLog.model';

/**
 * @desc    Register a new user
 * @route   POST /api/auth/register
 * @access  Public
 */
export const register = catchAsync(async (req: Request, res: Response) => {
  console.log('🚀 Registration endpoint hit!');
  
  console.log('📋 Checking validation...');
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    console.log('❌ Validation failed:', errors.array());
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map(err => ({
        field: 'path' in err ? err.path : 'unknown',
        message: err.msg
      }))
    });
  }

  console.log('✅ Validation passed, calling service...');

  const {
    username,
    email,
    password,
    fullName,
    contactNumber,
    address,
    deviceType
  } = req.body;

  // For mobile farmers, email is optional; use contactNumber as fallback
  const registrationData = {
    username,
    email: deviceType === 'mobile' ? (email || `${username}@maizewatch.com`) : email,
    password,
    fullName,
    contactNumber,
    address
  };

  console.log('📝 About to call authService.register with:', registrationData);
  
  const result = await authService.register(registrationData);
  
  console.log('✅ Registration successful:', result);

  // Set refresh token as httpOnly cookie
  res.cookie('refreshToken', result.tokens.refreshToken, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
  });

  logger.info('User registered successfully', {
    userId: result.user._id,
    username: result.user.username,
    email: result.user.email
  });

  // Activity Log: Registration
  try {
    await ActivityLogService.createLog({
      userId: result.user._id,
      userEmail: result.user.email,
      userRole: (result.user.role as UserRole) || 'user',
      action: Action.CREATE,
      resource: Resource.AUTH,
      resourceId: null,
      details: {
        method: req.method,
        path: req.path,
        statusCode: HTTP_STATUS.CREATED
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || 'Unknown',
      timestamp: new Date()
    });
  } catch (e) {
    logger.warn('Failed to log registration activity', { error: e instanceof Error ? e.message : String(e) });
  }

  res.status(HTTP_STATUS.CREATED).json({
    success: true,
    message: result.message,
    data: {
      user: result.user,
      accessToken: result.tokens.accessToken,
      expiresIn: result.tokens.expiresIn
    }
  });
});

/**
 * @desc    Authenticate user & get token
 * @route   POST /api/auth/login
 * @access  Public
 */
export const login = catchAsync(async (req: Request, res: Response) => {
  logger.info('🔐 Login attempt received', { 
    body: { ...req.body, password: '[REDACTED]' },
    headers: req.headers,
    ip: req.ip 
  });

  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    logger.warn('❌ Login validation failed', { errors: errors.array() });
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map(err => ({
        field: 'path' in err ? err.path : 'unknown',
        message: err.msg
      }))
    });
  }

  const { email, username, password, totpCode, deviceType } = req.body;
  
  // For mobile devices, use username; for web, use email
  const loginIdentifier = deviceType === 'mobile' ? username : email;
  
  logger.info('🔍 Login processing', { 
    deviceType, 
    loginIdentifier, 
    hasPassword: !!password,
    hasTotpCode: !!totpCode 
  });
  
  if (!loginIdentifier) {
    const errorMsg = deviceType === 'mobile' ? 'Username is required' : 'Email is required';
    logger.warn('❌ Missing login identifier', { deviceType, errorMsg });
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: errorMsg
    });
  }

  try {
    logger.info('🔍 Calling authService.login', { loginIdentifier });
    const result = await authService.login(loginIdentifier, password, totpCode);
    logger.info('✅ Login successful', { userId: result.user._id, username: result.user.username });

    // Set refresh token as httpOnly cookie
    res.cookie('refreshToken', result.tokens.refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
    });

    // Activity Log: Login
    try {
      await ActivityLogService.createLog({
        userId: result.user._id,
        userEmail: result.user.email,
        userRole: (result.user.role as UserRole) || 'user',
        action: Action.LOGIN,
        resource: Resource.AUTH,
        resourceId: null,
        details: {
          method: req.method,
          path: req.path,
          statusCode: HTTP_STATUS.OK
        },
        ipAddress: req.ip,
        userAgent: req.headers['user-agent'] || 'Unknown',
        timestamp: new Date()
      });
    } catch (e) {
      logger.warn('Failed to log login activity', { error: e instanceof Error ? e.message : String(e) });
    }

    res.status(HTTP_STATUS.OK).json({
      success: true,
      message: result.message,
      data: {
        user: result.user,
        accessToken: result.tokens.accessToken,
        expiresIn: result.tokens.expiresIn,
        requiresTwoFactor: result.requiresTwoFactor
      }
    });
  } catch (error) {
    logger.error('❌ Login failed in service', { error: error instanceof Error ? error.message : String(error), loginIdentifier });
    throw error;
  }
});

/**
 * @desc    Refresh access token
 * @route   POST /api/auth/refresh
 * @access  Public
 */
export const refreshToken = catchAsync(async (req: Request, res: Response) => {
  const { refreshToken: token } = req.cookies;

  if (!token) {
    throw new AppError('Refresh token not provided', HTTP_STATUS.UNAUTHORIZED);
  }

  const result = await authService.refreshToken(token);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: result.message,
    data: {
      accessToken: result.accessToken,
      expiresIn: result.expiresIn
    }
  });
});

/**
 * @desc    Logout user
 * @route   POST /api/auth/logout
 * @access  Private
 */
export const logout = catchAsync(async (req: Request, res: Response) => {
  const { refreshToken: token } = req.cookies;
  const userId = (req as any).user?.id;

  if (token && userId) {
    await authService.logout(userId, token);
  }

  // Clear refresh token cookie
  res.clearCookie('refreshToken');

  logger.info('User logged out', { userId });

  // Activity Log: Logout
  try {
    if (userId) {
      await ActivityLogService.createLog({
        userId,
        userEmail: (req as any).user?.email || 'unknown@email.com',
        userRole: ((req as any).user?.role as UserRole) || 'user',
        action: Action.LOGOUT,
        resource: Resource.AUTH,
        resourceId: null,
        details: {
          method: req.method,
          path: req.path,
          statusCode: HTTP_STATUS.OK
        },
        ipAddress: req.ip,
        userAgent: req.headers['user-agent'] || 'Unknown',
        timestamp: new Date()
      });
    }
  } catch (e) {
    logger.warn('Failed to log logout activity', { error: e instanceof Error ? e.message : String(e) });
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Logged out successfully'
  });
});

/**
 * @desc    Logout from all devices
 * @route   POST /api/auth/logout-all
 * @access  Private
 */
export const logoutAll = catchAsync(async (req: Request, res: Response) => {
  const userId = (req as any).user.id;

  await authService.logoutAll(userId);

  // Clear refresh token cookie
  res.clearCookie('refreshToken');

  logger.info('User logged out from all devices', { userId });

  // Activity Log: Logout all
  try {
    await ActivityLogService.createLog({
      userId,
      userEmail: (req as any).user?.email || 'unknown@email.com',
      userRole: ((req as any).user?.role as UserRole) || 'user',
      action: Action.LOGOUT,
      resource: Resource.AUTH,
      resourceId: null,
      details: {
        method: req.method,
        path: req.path,
        statusCode: HTTP_STATUS.OK,
        scope: 'all-devices'
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || 'Unknown',
      timestamp: new Date()
    });
  } catch (e) {
    logger.warn('Failed to log logout-all activity', { error: e instanceof Error ? e.message : String(e) });
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Logged out from all devices successfully'
  });
});

/**
 * @desc    Request password reset
 * @route   POST /api/auth/forgot-password
 * @access  Public
 */
export const forgotPassword = catchAsync(async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map(err => ({
        field: 'path' in err ? err.path : 'unknown',
        message: err.msg
      }))
    });
  }

  const { email } = req.body;

  await authService.requestPasswordReset(email);

  logger.info('Password reset requested', { email });

  // Activity Log: Forgot password
  try {
    await ActivityLogService.createLog({
      userId: (req as any).user?._id || (req as any).user?.id || 'anonymous',
      userEmail: email,
      userRole: ((req as any).user?.role as UserRole) || 'user',
      action: Action.UPDATE,
      resource: Resource.AUTH,
      resourceId: null,
      details: {
        method: req.method,
        path: req.path,
        statusCode: HTTP_STATUS.OK
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || 'Unknown',
      timestamp: new Date()
    });
  } catch (e) {
    logger.warn('Failed to log forgot-password activity', { error: e instanceof Error ? e.message : String(e) });
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Password reset instructions sent to your email'
  });
});

/**
 * @desc    Reset password
 * @route   POST /api/auth/reset-password
 * @access  Public
 */
export const resetPassword = catchAsync(async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map(err => ({
        field: 'path' in err ? err.path : 'unknown',
        message: err.msg
      }))
    });
  }

  const { token, newPassword } = req.body;

  await authService.resetPassword(token, newPassword);

  logger.info('Password reset completed');

  // Activity Log: Reset password
  try {
    await ActivityLogService.createLog({
      userId: (req as any).user?._id || (req as any).user?.id || 'anonymous',
      userEmail: (req as any).user?.email || 'unknown@email.com',
      userRole: ((req as any).user?.role as UserRole) || 'user',
      action: Action.UPDATE,
      resource: Resource.AUTH,
      resourceId: null,
      details: {
        method: req.method,
        path: req.path,
        statusCode: HTTP_STATUS.OK
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || 'Unknown',
      timestamp: new Date()
    });
  } catch (e) {
    logger.warn('Failed to log reset-password activity', { error: e instanceof Error ? e.message : String(e) });
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Password reset successfully'
  });
});

/**
 * @desc    Change password
 * @route   PUT /api/auth/change-password
 * @access  Private
 */
export const changePassword = catchAsync(async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map(err => ({
        field: 'path' in err ? err.path : 'unknown',
        message: err.msg
      }))
    });
  }

  const userId = (req as any).user.id;
  const { currentPassword, newPassword } = req.body;

  await authService.changePassword(userId, currentPassword, newPassword);

  logger.info('Password changed successfully', { userId });

  // Activity Log: Change password
  try {
    await ActivityLogService.createLog({
      userId,
      userEmail: (req as any).user?.email || 'unknown@email.com',
      userRole: ((req as any).user?.role as UserRole) || 'user',
      action: Action.UPDATE,
      resource: Resource.AUTH,
      resourceId: null,
      details: {
        method: req.method,
        path: req.path,
        statusCode: HTTP_STATUS.OK
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || 'Unknown',
      timestamp: new Date()
    });
  } catch (e) {
    logger.warn('Failed to log change-password activity', { error: e instanceof Error ? e.message : String(e) });
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Password changed successfully'
  });
});

/**
 * @desc    Verify email
 * @route   GET /api/auth/verify-email/:token
 * @access  Public
 */
export const verifyEmail = catchAsync(async (req: Request, res: Response) => {
  const { token } = req.params;

  if (!token) {
    throw new AppError('Verification token is required', HTTP_STATUS.BAD_REQUEST);
  }

  await authService.verifyEmail(token);

  logger.info('Email verified successfully');

  // Activity Log: Verify email
  try {
    await ActivityLogService.createLog({
      userId: (req as any).user?._id || (req as any).user?.id || 'anonymous',
      userEmail: (req as any).user?.email || 'unknown@email.com',
      userRole: ((req as any).user?.role as UserRole) || 'user',
      action: Action.UPDATE,
      resource: Resource.AUTH,
      resourceId: null,
      details: {
        method: req.method,
        path: req.path,
        statusCode: HTTP_STATUS.OK
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || 'Unknown',
      timestamp: new Date()
    });
  } catch (e) {
    logger.warn('Failed to log verify-email activity', { error: e instanceof Error ? e.message : String(e) });
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Email verified successfully'
  });
});

/**
 * @desc    Resend email verification
 * @route   POST /api/auth/resend-verification
 * @access  Private
 */
export const resendVerification = catchAsync(async (req: Request, res: Response) => {
  const userId = (req as any).user.id;

  await authService.resendEmailVerification(userId);

  logger.info('Email verification resent', { userId });

  // Activity Log: Resend verification
  try {
    await ActivityLogService.createLog({
      userId,
      userEmail: (req as any).user?.email || 'unknown@email.com',
      userRole: ((req as any).user?.role as UserRole) || 'user',
      action: Action.UPDATE,
      resource: Resource.AUTH,
      resourceId: null,
      details: {
        method: req.method,
        path: req.path,
        statusCode: HTTP_STATUS.OK
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || 'Unknown',
      timestamp: new Date()
    });
  } catch (e) {
    logger.warn('Failed to log resend-verification activity', { error: e instanceof Error ? e.message : String(e) });
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Verification email sent successfully'
  });
});

/**
 * @desc    Setup two-factor authentication
 * @route   POST /api/auth/setup-2fa
 * @access  Private
 */
export const setup2FA = catchAsync(async (req: Request, res: Response) => {
  const userId = (req as any).user.id;

  const result = await authService.setup2FA(userId);

  logger.info('2FA setup initiated', { userId });

  // Activity Log: Setup 2FA
  try {
    await ActivityLogService.createLog({
      userId,
      userEmail: (req as any).user?.email || 'unknown@email.com',
      userRole: ((req as any).user?.role as UserRole) || 'user',
      action: Action.UPDATE,
      resource: Resource.AUTH,
      resourceId: null,
      details: {
        method: req.method,
        path: req.path,
        statusCode: HTTP_STATUS.OK
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || 'Unknown',
      timestamp: new Date()
    });
  } catch (e) {
    logger.warn('Failed to log setup-2fa activity', { error: e instanceof Error ? e.message : String(e) });
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Two-factor authentication setup',
    data: {
      qrCode: result.qrCode,
      secret: result.secret
    }
  });
});

/**
 * @desc    Verify and enable two-factor authentication
 * @route   POST /api/auth/verify-2fa
 * @access  Private
 */
export const verify2FA = catchAsync(async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map(err => ({
        field: 'path' in err ? err.path : 'unknown',
        message: err.msg
      }))
    });
  }

  const userId = (req as any).user.id;
  const { token } = req.body;

  await authService.verify2FA(userId, token);

  logger.info('2FA verified and enabled', { userId });

  // Activity Log: Verify 2FA
  try {
    await ActivityLogService.createLog({
      userId,
      userEmail: (req as any).user?.email || 'unknown@email.com',
      userRole: ((req as any).user?.role as UserRole) || 'user',
      action: Action.UPDATE,
      resource: Resource.AUTH,
      resourceId: null,
      details: {
        method: req.method,
        path: req.path,
        statusCode: HTTP_STATUS.OK
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || 'Unknown',
      timestamp: new Date()
    });
  } catch (e) {
    logger.warn('Failed to log verify-2fa activity', { error: e instanceof Error ? e.message : String(e) });
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Two-factor authentication enabled successfully'
  });
});

/**
 * @desc    Disable two-factor authentication
 * @route   POST /api/auth/disable-2fa
 * @access  Private
 */
export const disable2FA = catchAsync(async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map(err => ({
        field: 'path' in err ? err.path : 'unknown',
        message: err.msg
      }))
    });
  }

  const userId = (req as any).user.id;
  const { token } = req.body;

  await authService.disable2FA(userId, token);

  logger.info('2FA disabled', { userId });

  // Activity Log: Disable 2FA
  try {
    await ActivityLogService.createLog({
      userId,
      userEmail: (req as any).user?.email || 'unknown@email.com',
      userRole: ((req as any).user?.role as UserRole) || 'user',
      action: Action.UPDATE,
      resource: Resource.AUTH,
      resourceId: null,
      details: {
        method: req.method,
        path: req.path,
        statusCode: HTTP_STATUS.OK
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || 'Unknown',
      timestamp: new Date()
    });
  } catch (e) {
    logger.warn('Failed to log disable-2fa activity', { error: e instanceof Error ? e.message : String(e) });
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Two-factor authentication disabled successfully'
  });
});

/**
 * @desc    Get current user profile
 * @route   GET /api/auth/me
 * @access  Private
 */
export const getProfile = catchAsync(async (req: Request, res: Response) => {
  const user = (req as any).user;

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { user }
  });

  // Activity Log: View profile
  try {
    await ActivityLogService.createLog({
      userId: user?._id || user?.id,
      userEmail: user?.email || 'unknown@email.com',
      userRole: (user?.role as UserRole) || 'user',
      action: Action.VIEW,
      resource: Resource.AUTH,
      resourceId: null,
      details: {
        method: req.method,
        path: req.path,
        statusCode: HTTP_STATUS.OK
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || 'Unknown',
      timestamp: new Date()
    });
  } catch (e) {
    logger.warn('Failed to log view-profile activity', { error: e instanceof Error ? e.message : String(e) });
  }
});
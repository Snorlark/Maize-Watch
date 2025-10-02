import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import authService from '../services/authService';
import otpService from '../services/otpService';
import emailService from '../services/emailService';
import User from '../models/User';
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

  
  const result = await authService.register(registrationData);
  


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
      userRole: (result.user.role as UserRole) || ('user' as UserRole),
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
    logger.info('✅ Password validation successful', { userId: result.user._id, username: result.user.username });

    // Check if this is an admin user who needs email OTP verification
    const isAdminUser = ['admin', 'regional_admin', 'super_admin'].includes(result.user.role);
    
    if (isAdminUser && deviceType === 'web' && !totpCode) {
      // For admin users on web, require email OTP as second factor
      logger.info('🔐 Admin user detected, sending OTP for 2FA', { 
        userId: result.user._id, 
        email: result.user.email 
      });

      try {
        // Generate and send OTP
        const emailForOTP = result.user.email || loginIdentifier;
        logger.info('🔐 Generating OTP for sequential 2FA', { 
          userEmail: result.user.email,
          loginIdentifier,
          emailForOTP,
          userId: result.user._id 
        });
        
        const otp = otpService.generateOTP(emailForOTP);
        await emailService.sendLoginOTP(
          emailForOTP, 
          result.user.fullName || result.user.username, 
          otp, 
          5
        );

        // Activity Log: OTP Required
        try {
          await ActivityLogService.createLog({
            userId: result.user._id,
            userEmail: result.user.email || loginIdentifier,
            userRole: (result.user.role as UserRole) || ('user' as UserRole),
            action: Action.LOGIN,
            resource: Resource.AUTH,
            resourceId: null,
            details: {
              action: 'Password Verified - OTP Required',
              method: req.method,
              path: req.path,
              statusCode: HTTP_STATUS.OK
            },
            ipAddress: req.ip,
            userAgent: req.headers['user-agent'] || 'Unknown',
            timestamp: new Date()
          });
        } catch (e) {
          logger.warn('Failed to log OTP requirement activity', { error: e instanceof Error ? e.message : String(e) });
        }

        // Return response indicating OTP is required
        return res.status(HTTP_STATUS.OK).json({
          success: true,
          message: 'Password verified. Please check your email for the verification code.',
          requiresOTP: true,
          data: {
            email: emailForOTP, // Use the same email that was used for OTP generation
            expiresIn: 300 // 5 minutes
          }
        });

      } catch (otpError) {
        logger.error('Failed to send OTP after password verification', { 
          error: otpError instanceof Error ? otpError.message : String(otpError),
          userId: result.user._id 
        });
        throw new AppError('Authentication successful, but failed to send verification code. Please try again.', HTTP_STATUS.INTERNAL_SERVER_ERROR);
      }
    }

    // Complete login (for non-admin users or when OTP is provided)
    // Set refresh token as httpOnly cookie
    res.cookie('refreshToken', result.tokens.refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
    });

    // Activity Log: Complete Login
    try {
      await ActivityLogService.createLog({
        userId: result.user._id,
        userEmail: result.user.email || loginIdentifier,
        userRole: (result.user.role as UserRole) || ('user' as UserRole),
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
        userRole: ((req as any).user?.role as UserRole) || ('user' as UserRole),
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
      userRole: ((req as any).user?.role as UserRole) || ('user' as UserRole),
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
      userRole: ((req as any).user?.role as UserRole) || ('user' as UserRole),
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
      userRole: ((req as any).user?.role as UserRole) || ('user' as UserRole),
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
      userRole: ((req as any).user?.role as UserRole) || ('user' as UserRole),
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
      userRole: ((req as any).user?.role as UserRole) || ('user' as UserRole),
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
      userRole: ((req as any).user?.role as UserRole) || ('user' as UserRole),
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
      userRole: ((req as any).user?.role as UserRole) || ('user' as UserRole),
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
      userRole: ((req as any).user?.role as UserRole) || ('user' as UserRole),
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
      userRole: ((req as any).user?.role as UserRole) || ('user' as UserRole),
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
      userRole: (user?.role as UserRole) || ('user' as UserRole),
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

/**
 * @desc    Update current user profile
 * @route   PUT /api/auth/me
 * @access  Private
 */
export const updateProfile = catchAsync(async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map((err: any) => ({
        field: err.param,
        message: err.msg
      }))
    });
  }

  const currentUser = (req as any).user;
  const updateData = req.body;

  try {
    const updatedUser = await authService.updateUserProfile(currentUser.id, updateData);

    res.status(HTTP_STATUS.OK).json({
      success: true,
      message: 'Profile updated successfully',
      data: updatedUser
    });

    // Activity Log: Update profile
    try {
      await ActivityLogService.createLog({
        userId: currentUser?._id || currentUser?.id,
        userEmail: currentUser?.email || 'unknown@email.com',
        userRole: (currentUser?.role as UserRole) || ('user' as UserRole),
        action: Action.UPDATE,
        resource: Resource.AUTH,
        resourceId: currentUser?.id,
        details: {
          method: req.method,
          path: req.path,
          statusCode: HTTP_STATUS.OK,
          updatedFields: Object.keys(updateData).filter(key => updateData[key] !== currentUser[key])
        },
        ipAddress: req.ip,
        userAgent: req.headers['user-agent'] || 'Unknown',
        timestamp: new Date()
      });
    } catch (e) {
      logger.warn('Failed to log update-profile activity', { error: e instanceof Error ? e.message : String(e) });
    }
  } catch (error: any) {
    logger.error('Profile update failed:', error);
    throw new AppError(error.message || 'Failed to update profile', HTTP_STATUS.INTERNAL_SERVER_ERROR);
  }
});

/**
 * @desc    Send OTP for email-based login (Web Admin)
 * @route   POST /api/auth/send-login-otp
 * @access  Public
 */
export const sendLoginOTP = catchAsync(async (req: Request, res: Response) => {
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

  logger.info('OTP login request received', { email });

  try {
    // Check if user exists and has admin privileges
    const user = await User.findOne({ 
      email: email.toLowerCase(),
      role: { $in: ['admin', 'regional_admin', 'super_admin'] },
      isActive: true
      // Note: Removed emailVerified requirement since user will prove email access via OTP
    });

    if (!user) {
      // Don't reveal if user exists for security
      logger.warn('OTP request for non-existent or unauthorized user', { email });
      return res.status(HTTP_STATUS.OK).json({
        success: true,
        message: 'If an admin account exists with this email, a verification code has been sent.'
      });
    }

    // Check if there's already a valid OTP
    if (otpService.hasValidOTP(email)) {
      const remainingTime = otpService.getRemainingTime(email);
      return res.status(HTTP_STATUS.TOO_MANY_REQUESTS).json({
        success: false,
        message: `Please wait ${Math.ceil(remainingTime / 60)} minutes before requesting a new code.`,
        remainingTime
      });
    }

    // Generate OTP
    const otp = otpService.generateOTP(email);

    // Send OTP email
    await emailService.sendLoginOTP(email, user.fullName, otp, 5);

    logger.info('Login OTP sent successfully', { 
      email,
      userId: user._id,
      fullName: user.fullName
    });

    // Activity Log: OTP Request
    try {
      await ActivityLogService.createLog({
        userId: user._id,
        userEmail: user.email || email,
        userRole: (user.role as UserRole) || ('user' as UserRole),
        action: Action.LOGIN,
        resource: Resource.AUTH,
        resourceId: null,
        details: {
          action: 'OTP Login Request',
          method: req.method,
          path: req.path,
          statusCode: HTTP_STATUS.OK
        },
        ipAddress: req.ip,
        userAgent: req.headers['user-agent'] || 'Unknown',
        timestamp: new Date()
      });
    } catch (e) {
      logger.warn('Failed to log OTP request activity', { error: e instanceof Error ? e.message : String(e) });
    }

    res.status(HTTP_STATUS.OK).json({
      success: true,
      message: 'Verification code sent to your email address.',
      expiresIn: 300 // 5 minutes in seconds
    });

  } catch (error) {
    logger.error('Failed to send login OTP', { error: error instanceof Error ? error.message : String(error), email });
    throw new AppError('Failed to send verification code. Please try again.', HTTP_STATUS.INTERNAL_SERVER_ERROR);
  }
});

/**
 * @desc    Verify OTP and complete login (Web Admin)
 * @route   POST /api/auth/verify-login-otp
 * @access  Public
 */
export const verifyLoginOTP = catchAsync(async (req: Request, res: Response) => {
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

  const { email, otp } = req.body;

  logger.info('OTP verification attempt', { email, otp: otp.substring(0, 2) + '****' });

  try {
    // Check if OTP exists for this email
    const hasValidOTP = otpService.hasValidOTP(email);
    logger.info('OTP existence check', { email, hasValidOTP });

    // Verify OTP
    const otpResult = otpService.verifyOTP(email, otp);
    logger.info('OTP verification result', { 
      email, 
      valid: otpResult.valid, 
      message: otpResult.message,
      attemptsLeft: otpResult.attemptsLeft 
    });

    if (!otpResult.valid) {
      logger.warn('OTP verification failed', { 
        email, 
        message: otpResult.message,
        attemptsLeft: otpResult.attemptsLeft 
      });
      
      return res.status(HTTP_STATUS.UNAUTHORIZED).json({
        success: false,
        message: otpResult.message,
        attemptsLeft: otpResult.attemptsLeft
      });
    }

    // Get user (we know they exist from the OTP generation)
    const emailKey = email.toLowerCase();
    
    // First, let's see what user data exists
    const userCheck = await User.findOne({ email: emailKey });
    logger.info('User lookup during OTP verification', {
      email: emailKey,
      userExists: !!userCheck,
      userRole: userCheck?.role,
      isActive: userCheck?.isActive,
      emailVerified: userCheck?.emailVerified
    });
    
    const user = await User.findOne({ 
      email: emailKey,
      role: { $in: ['admin', 'regional_admin', 'super_admin'] },
      isActive: true
      // Note: Removed emailVerified requirement since user is proving email access via OTP
    });

    if (!user) {
      logger.error('User not found during OTP verification with admin criteria', { 
        email: emailKey,
        foundUser: !!userCheck,
        userRole: userCheck?.role,
        isActive: userCheck?.isActive,
        emailVerified: userCheck?.emailVerified
      });
      throw new AppError('Authentication failed', HTTP_STATUS.UNAUTHORIZED);
    }

    // Update last login
    user.lastLogin = new Date();
    await user.save();

    // Generate tokens
    const accessToken = user.generateAuthToken();
    const refreshToken = user.generateRefreshToken();

    // Add refresh token to user
    user.refreshTokens.push({
      token: refreshToken,
      createdAt: new Date(),
    });
    await user.save();

    const tokens = {
      accessToken,
      refreshToken,
      expiresIn: process.env.JWT_EXPIRE || "1h"
    };

    logger.info('OTP login successful', { 
      userId: user._id, 
      username: user.username,
      email: user.email
    });

    // Set refresh token as httpOnly cookie
    res.cookie('refreshToken', tokens.refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
    });

    // Activity Log: Successful OTP Login
    try {
      await ActivityLogService.createLog({
        userId: user._id,
        userEmail: user.email || email,
        userRole: (user.role as UserRole) || ('user' as UserRole),
        action: Action.LOGIN,
        resource: Resource.AUTH,
        resourceId: null,
        details: {
          action: 'OTP Login Success',
          method: req.method,
          path: req.path,
          statusCode: HTTP_STATUS.OK
        },
        ipAddress: req.ip,
        userAgent: req.headers['user-agent'] || 'Unknown',
        timestamp: new Date()
      });
    } catch (e) {
      logger.warn('Failed to log OTP login activity', { error: e instanceof Error ? e.message : String(e) });
    }

    res.status(HTTP_STATUS.OK).json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          _id: user._id,
          username: user.username,
          email: user.email,
          fullName: user.fullName,
          role: user.role,
          assignedRegion: user.assignedRegion,
          lastLogin: user.lastLogin,
          emailVerified: user.emailVerified,
          twoFactorEnabled: user.twoFactorEnabled
        },
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresIn: tokens.expiresIn
      }
    });

  } catch (error) {
    logger.error('OTP verification failed', { error: error instanceof Error ? error.message : String(error), email });
    throw error;
  }
});

/**
 * @desc    Send forgot password OTP
 * @route   POST /api/auth/send-forgot-password-otp
 * @access  Public
 */
export const sendForgotPasswordOTP = catchAsync(async (req: Request, res: Response) => {
  const { email } = req.body;

  logger.info('Forgot password OTP request received', { email });

  // Check if user exists
  const user = await User.findOne({ email }).select('+password');
  if (!user) {
    logger.warn('Forgot password OTP requested for non-existent email', { email });
    // Don't reveal if email exists or not for security
    return res.status(HTTP_STATUS.OK).json({
      success: true,
      message: 'If an account with that email exists, we have sent a password reset code.'
    });
  }

  // Generate and store OTP
  const otp = await otpService.generateOTP(email, 'forgot-password');
  
  // Send OTP email
  await emailService.sendForgotPasswordOTP(email, otp, user.fullName || user.username);

  logger.info('Forgot password OTP sent successfully', { email });

  // Log activity
  try {
    await ActivityLogService.createLog({
      userId: user._id.toString(),
      userEmail: user.email || email,
      userRole: user.role as UserRole,
      action: Action.FORGOT_PASSWORD_REQUESTED,
      resource: Resource.AUTH,
      resourceId: null,
      details: {
        action: 'Forgot Password OTP Sent',
        method: req.method,
        path: req.path,
        statusCode: HTTP_STATUS.OK
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || 'Unknown',
      timestamp: new Date()
    });
  } catch (e) {
    logger.warn('Failed to log forgot password activity', { error: e instanceof Error ? e.message : String(e) });
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Password reset code sent to your email',
    expiresIn: '5 minutes'
  });
});

/**
 * @desc    Verify forgot password OTP
 * @route   POST /api/auth/verify-forgot-password-otp
 * @access  Public
 */
export const verifyForgotPasswordOTP = catchAsync(async (req: Request, res: Response) => {
  const { email, otp } = req.body;

  logger.info('Forgot password OTP verification attempt', { email, otp });

  // Verify OTP
  const isValid = await otpService.verifyOTP(email, otp, 'forgot-password');
  
  if (!isValid) {
    logger.warn('Invalid forgot password OTP attempt', { email, otp });
    throw new AppError('Invalid or expired verification code', HTTP_STATUS.BAD_REQUEST);
  }

  // Check if user still exists
  const user = await User.findOne({ email });
  if (!user) {
    logger.warn('Forgot password OTP verified but user no longer exists', { email });
    throw new AppError('User account not found', HTTP_STATUS.NOT_FOUND);
  }

  logger.info('Forgot password OTP verified successfully', { email });

  // Log activity
  try {
    await ActivityLogService.createLog({
      userId: user._id.toString(),
      userEmail: user.email || email,
      userRole: user.role as UserRole,
      action: Action.PASSWORD_RESET_VERIFIED,
      resource: Resource.AUTH,
      resourceId: null,
      details: {
        action: 'Forgot Password OTP Verified',
        method: req.method,
        path: req.path,
        statusCode: HTTP_STATUS.OK
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || 'Unknown',
      timestamp: new Date()
    });
  } catch (e) {
    logger.warn('Failed to log OTP verification activity', { error: e instanceof Error ? e.message : String(e) });
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Verification successful. You can now reset your password.'
  });
});

/**
 * @desc    Reset password with OTP
 * @route   POST /api/auth/reset-password
 * @access  Public
 */
export const resetPasswordWithOTP = catchAsync(async (req: Request, res: Response) => {
  const { email, otp, newPassword } = req.body;

  logger.info('Password reset with OTP attempt', { email });

  // Verify OTP one more time
  const isValid = await otpService.verifyOTP(email, otp, 'forgot-password');
  
  if (!isValid) {
    logger.warn('Invalid OTP for password reset', { email, otp });
    throw new AppError('Invalid or expired verification code', HTTP_STATUS.BAD_REQUEST);
  }

  // Find user
  const user = await User.findOne({ email }).select('+password');
  if (!user) {
    logger.warn('Password reset attempted for non-existent user', { email });
    throw new AppError('User account not found', HTTP_STATUS.NOT_FOUND);
  }

  // Update password
  user.password = newPassword;
  await user.save();

  // Clear the OTP after successful password reset
  await otpService.clearOTP(email, 'forgot-password');

  logger.info('Password reset successful', { email });

  // Log activity
  try {
    await ActivityLogService.createLog({
      userId: user._id.toString(),
      userEmail: user.email || email,
      userRole: user.role as UserRole,
      action: Action.PASSWORD_RESET_COMPLETED,
      resource: Resource.AUTH,
      resourceId: null,
      details: {
        action: 'Password Reset Completed',
        method: req.method,
        path: req.path,
        statusCode: HTTP_STATUS.OK
      },
      ipAddress: req.ip,
      userAgent: req.headers['user-agent'] || 'Unknown',
      timestamp: new Date()
    });
  } catch (e) {
    logger.warn('Failed to log password reset activity', { error: e instanceof Error ? e.message : String(e) });
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Password reset successful. You can now login with your new password.'
  });
});
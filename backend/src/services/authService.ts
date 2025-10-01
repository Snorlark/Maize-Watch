import jwt from "jsonwebtoken";
import crypto from "crypto";
import speakeasy from "speakeasy";
import QRCode from "qrcode";
import User, { IUser } from "../models/User";
import { AppError } from "../middleware/errorHandler";
import { logger } from "../utils/logger";
import twilioService from "./twilioService";
import bcrypt from "bcryptjs";
// Lazy import to prevent startup connection
const getEmailService = () => import("../utils/emailService").then(m => m.default);

interface UserRegistrationData {
  username: string;
  email: string;
  password: string;
  fullName: string;
  contactNumber: string;
  address: {
    region: string;
    province: string;
    municipality: string;
    barangay: string;    
  };
}

interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: string;
}

interface AuthResponse {
  user: any;
  tokens: AuthTokens;
  message: string;
  requiresTwoFactor?: boolean;
}

class AuthService {
  /**
   * Register a new user
   * @param {Object} userData - User registration data
   * @returns {Object} Created user and tokens
   */
  async register(userData: UserRegistrationData): Promise<AuthResponse> {
    try {
      // Check if user already exists
      const existingUser = await User.findOne({
        $or: [{ username: userData.username }, { email: userData.email }],
      });

      if (existingUser) {
        throw new AppError(
          existingUser.username === userData.username
            ? "Username already exists"
            : "Email already exists",
          400
        );
      }

      // Create new user
      const user = new User(userData);

      // Generate email verification token
      const verificationToken = user.createEmailVerificationToken();
      await user.save();

      // Send verification email (skip for mobile farmers with @farmer.local emails)
      if (!user.email.endsWith('@farmer.local')) {
        try {
          const emailService = await getEmailService();
          await emailService.sendVerificationEmail(
            user.email,
            verificationToken
          );
          logger.info('Verification email sent', { email: user.email });
        } catch (emailError) {
          logger.warn("Failed to send verification email:", emailError);
          // Don't fail registration if email fails
        }
      } else {
        logger.info('Skipping email verification for mobile farmer', { email: user.email });
        // Auto-verify mobile farmers
        user.emailVerified = true;
      }

      // Generate tokens
      const accessToken = user.generateAuthToken();
      const refreshToken = user.generateRefreshToken();

      // Save refresh token
      user.refreshTokens.push({
        token: refreshToken,
        createdAt: new Date(),
      });
      await user.save();

      logger.info(`New user registered: ${user.username}`, {
        userId: user._id,
        email: user.email,
        role: user.role,
      });

      return {
        user: user.toJSON(),
        tokens: {
          accessToken,
          refreshToken,
          expiresIn: process.env.JWT_EXPIRES_IN || "7d",
        },
        message:
          "Registration successful! Please check your email to verify your account.",
      };
    } catch (error) {
      logger.error("Registration error:", error);
      throw error;
    }
  }

  /**
   * Authenticate user login
   * @param {string} login - Username or email
   * @param {string} password - User password
   * @param {string} twoFactorCode - Optional 2FA code
   * @returns {Object} User data and tokens
   */
  async login(login: string, password: string, twoFactorCode?: string): Promise<AuthResponse> {
    try {
      // Find and validate user credentials
      const user = await User.findByCredentials(login, password);

      // Check if 2FA is enabled
      if (user.twoFactorEnabled) {
        if (!twoFactorCode) {
          throw new AppError("Two-factor authentication code required", 400);
        }

        const isValid2FA = speakeasy.totp.verify({
          secret: user.twoFactorSecret!,
          encoding: "base32",
          token: twoFactorCode,
          window: 2, // Allow some time drift
        });

        if (!isValid2FA) {
          throw new AppError("Invalid two-factor authentication code", 400);
        }
      }

      // Generate tokens
      const accessToken = user.generateAuthToken();
      const refreshToken = user.generateRefreshToken();

      // Clean old refresh tokens (keep only last 5)
      if (user.refreshTokens.length > 4) {
        user.refreshTokens.splice(0, user.refreshTokens.length - 4);
      }

      // Add new refresh token
      user.refreshTokens.push({
        token: refreshToken,
        createdAt: new Date(),
      });

      // Update last login
      user.lastLogin = new Date();
      await user.save();

      logger.info(`User logged in: ${user.username}`, {
        userId: user._id,
        loginTime: user.lastLogin,
      });

      return {
        user: user.toJSON(),
        tokens: {
          accessToken,
          refreshToken,
          expiresIn: process.env.JWT_EXPIRES_IN || "7d",
        },
        message: "Login successful",
      };
    } catch (error) {
      logger.error("Login error:", error instanceof Error ? error.message : String(error));
      throw error;
    }
  }

  /**
   * Refresh access token
   * @param {string} refreshToken - Valid refresh token
   * @returns {Object} New access token
   */
  async refreshToken(refreshToken: string) {
    try {
      // Verify refresh token
      const decoded = jwt.verify(
        refreshToken,
        process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET || 'fallback-secret'
      ) as any;

      // Find user with this refresh token
      const user = await User.findOne({
        _id: decoded.id,
        "refreshTokens.token": refreshToken,
        isActive: true,
      });

      if (!user) {
        throw new AppError("Invalid refresh token", 401);
      }

      // Generate new access token
      const newAccessToken = user.generateAuthToken();

      logger.info(`Token refreshed for user: ${user.username}`, {
        userId: user._id,
      });

      return {
        accessToken: newAccessToken,
        expiresIn: process.env.JWT_EXPIRES_IN || "7d",
        message: "Token refreshed successfully",
      };
    } catch (error) {
      if (error instanceof Error) {
        if (error.name === "TokenExpiredError") {
          throw new AppError(
            "Refresh token has expired. Please login again.",
            401
          );
        }
        if (error.name === "JsonWebTokenError") {
          throw new AppError("Invalid refresh token", 401);
        }
      }
      throw error;
    }
  }

  /**
   * Logout user
   * @param {string} userId - User ID
   * @param {string} refreshToken - Token to invalidate
   */
  async logout(userId: string, refreshToken: string) {
    try {
      const user = await User.findById(userId);
      if (!user) {
        throw new AppError("User not found", 404);
      }

      // Remove the specific refresh token
      const tokenIndex = user.refreshTokens.findIndex(
        (tokenObj) => tokenObj.token === refreshToken
      );
      if (tokenIndex > -1) {
        user.refreshTokens.splice(tokenIndex, 1);
      }

      await user.save();

      logger.info(`User logged out: ${user.username}`, {
        userId: user._id,
      });

      return { message: "Logout successful" };
    } catch (error) {
      logger.error("Logout error:", error);
      throw error;
    }
  }

  /**
   * Logout from all devices
   * @param {string} userId - User ID
   */
  async logoutAll(userId: string) {
    try {
      const user = await User.findById(userId);
      if (!user) {
        throw new AppError("User not found", 404);
      }

      // Clear all refresh tokens
      user.refreshTokens.splice(0, user.refreshTokens.length);
      await user.save();

      logger.info(`User logged out from all devices: ${user.username}`, {
        userId: user._id,
      });

      return { message: "Logged out from all devices successfully" };
    } catch (error) {
      logger.error("Logout all error:", error);
      throw error;
    }
  }

  /**
   * Request password reset
   * @param {string} email - User email
   */
  async requestPasswordReset(email: string) {
    try {
      const user = await User.findOne({ email, isActive: true });

      if (!user) {
        // Don't reveal if email exists
        return {
          message:
            "If an account with that email exists, we have sent a password reset link.",
        };
      }

      // Generate reset token
      const resetToken = user.createPasswordResetToken();
      await user.save({ validateBeforeSave: false });

      // Send reset email
      try {
        const emailService = await getEmailService();
        await emailService.sendPasswordResetEmail(
          user.email,
          resetToken
        );
      } catch (emailError) {
        // Reset the token if email fails
        user.passwordResetToken = undefined;
        user.passwordResetExpires = undefined;
        await user.save({ validateBeforeSave: false });

        throw new AppError(
          "There was an error sending the email. Try again later.",
          500
        );
      }

      logger.info(`Password reset requested for: ${user.email}`);

      return {
        message: "Password reset link sent to your email address.",
      };
    } catch (error) {
      logger.error("Password reset request error:", error);
      throw error;
    }
  }

  /**
   * Reset password with token
   * @param {string} token - Reset token
   * @param {string} newPassword - New password
   */
  async resetPassword(token: string, newPassword: string) {
    try {
      // Hash token to compare with database
      const hashedToken = crypto
        .createHash("sha256")
        .update(token)
        .digest("hex");

      // Find user with valid reset token
      const user = await User.findOne({
        passwordResetToken: hashedToken,
        passwordResetExpires: { $gt: Date.now() },
        isActive: true,
      });

      if (!user) {
        throw new AppError("Token is invalid or has expired", 400);
      }

      // Update password and clear reset token
      user.password = newPassword;
      user.passwordResetToken = undefined;
      user.passwordResetExpires = undefined;

      // Clear all refresh tokens for security
      user.refreshTokens.splice(0, user.refreshTokens.length);

      await user.save();

      logger.info(`Password reset completed for: ${user.username}`, {
        userId: user._id,
      });

      return {
        message:
          "Password has been reset successfully. Please log in with your new password.",
      };
    } catch (error) {
      logger.error("Password reset error:", error);
      throw error;
    }
  }

  /**
   * Change password for authenticated user
   * @param {string} userId - User ID
   * @param {string} currentPassword - Current password for verification
   * @param {string} newPassword - New password
   */
  async changePassword(userId: string, currentPassword: string, newPassword: string) {
    try {
      // Find user and include password field for verification
      const user = await User.findById(userId).select("+password");
      if (!user) {
        throw new AppError("User not found", 404);
      }

      // Verify current password
      const isCurrentPasswordValid = await user.comparePassword(currentPassword);
      if (!isCurrentPasswordValid) {
        throw new AppError("Current password is incorrect", 400);
      }

      // Check if new password is different from current
      const isSamePassword = await user.comparePassword(newPassword);
      if (isSamePassword) {
        throw new AppError("New password must be different from current password", 400);
      }

      // Update password
      user.password = newPassword;

      // Clear all refresh tokens for security (force re-login on all devices)
      user.refreshTokens.splice(0, user.refreshTokens.length);

      await user.save();

      logger.info(`Password changed for user: ${user.username}`, {
        userId: user._id,
      });

      return {
        message: "Password changed successfully. Please log in again on all devices.",
      };
    } catch (error) {
      logger.error("Change password error:", error);
      throw error;
    }
  }

  /**
   * Verify email address
   * @param {string} token - Email verification token
   */
  async verifyEmail(token: string) {
    try {
      const hashedToken = crypto
        .createHash("sha256")
        .update(token)
        .digest("hex");

      const user = await User.findOne({
        emailVerificationToken: hashedToken,
        isActive: true,
      });

      if (!user) {
        throw new AppError("Invalid or expired verification token", 400);
      }

      user.emailVerified = true;
      user.emailVerificationToken = undefined;
      await user.save();

      logger.info(`Email verified for user: ${user.username}`, {
        userId: user._id,
      });

      return {
        message: "Email verified successfully!",
        user: user.toJSON(),
      };
    } catch (error) {
      logger.error("Email verification error:", error);
      throw error;
    }
  }

  /**
   * Resend email verification
   * @param {string} userId - User ID
   */
  async resendEmailVerification(userId: string) {
    try {
      const user = await User.findById(userId);
      if (!user) {
        throw new AppError("User not found", 404);
      }

      if (user.emailVerified) {
        throw new AppError("Email is already verified", 400);
      }

      // Generate new verification token
      const verificationToken = user.createEmailVerificationToken();
      await user.save({ validateBeforeSave: false });

      // Send verification email
      try {
        const emailService = await getEmailService();
        await emailService.sendVerificationEmail(
          user.email,
          verificationToken
        );
      } catch (emailError) {
        // Reset the token if email fails
        user.emailVerificationToken = undefined;
        await user.save({ validateBeforeSave: false });

        throw new AppError(
          "There was an error sending the email. Try again later.",
          500
        );
      }

      logger.info(`Email verification resent for user: ${user.username}`, {
        userId: user._id,
      });

      return {
        message: "Verification email sent successfully!",
      };
    } catch (error) {
      logger.error("Resend email verification error:", error);
      throw error;
    }
  }

  /**
   * Setup two-factor authentication
   * @param {string} userId - User ID
   */
  async setup2FA(userId: string) {
    return this.setupTwoFactor(userId);
  }

  /**
   * Setup two-factor authentication
   * @param {string} userId - User ID
   */
  async setupTwoFactor(userId: string) {
    try {
      const user = await User.findById(userId);
      if (!user) {
        throw new AppError("User not found", 404);
      }

      // Generate secret
      const secret = speakeasy.generateSecret({
        name: `Maize Watch (${user.username})`,
        issuer: "Maize Watch",
        length: 32,
      });

      // Generate QR code
      const qrCodeUrl = await QRCode.toDataURL(secret.otpauth_url || '');

      // Save secret (but don't enable 2FA yet)
      user.twoFactorSecret = secret.base32;
      await user.save();

      return {
        secret: secret.base32,
        qrCode: qrCodeUrl,
        manualEntryKey: secret.base32,
        message:
          "Scan the QR code with your authenticator app, then verify to enable 2FA",
      };
    } catch (error) {
      logger.error("2FA setup error:", error);
      throw error;
    }
  }

  /**
   * Verify and enable two-factor authentication (alias)
   * @param {string} userId - User ID
   * @param {string} token - 2FA token from app
   */
  async verify2FA(userId: string, token: string) {
    return this.verifyTwoFactor(userId, token);
  }

  /**
   * Verify and enable two-factor authentication
   * @param {string} userId - User ID
   * @param {string} token - 2FA token from app
   */
  async verifyTwoFactor(userId: string, token: string) {
    try {
      const user = await User.findById(userId).select("+twoFactorSecret");
      if (!user) {
        throw new AppError("User not found", 404);
      }

      if (!user.twoFactorSecret) {
        throw new AppError("Two-factor authentication not set up", 400);
      }

      // Verify token
      const verified = speakeasy.totp.verify({
        secret: user.twoFactorSecret,
        encoding: "base32",
        token: token,
        window: 2,
      });

      if (!verified) {
        throw new AppError("Invalid authentication code", 400);
      }

      // Enable 2FA
      user.twoFactorEnabled = true;
      await user.save();

      logger.info(`2FA enabled for user: ${user.username}`, {
        userId: user._id,
      });

      return {
        message: "Two-factor authentication enabled successfully!",
      };
    } catch (error) {
      logger.error("2FA verification error:", error);
      throw error;
    }
  }

  /**
   * Disable two-factor authentication (alias)
   * @param {string} userId - User ID
   * @param {string} token - 2FA token for confirmation
   */
  async disable2FA(userId: string, token: string) {
    return this.disableTwoFactor(userId, token);
  }

  /**
   * Disable two-factor authentication
   * @param {string} userId - User ID
   * @param {string} token - 2FA token for confirmation
   */
  async disableTwoFactor(userId: string, token: string) {
    try {
      const user = await User.findById(userId).select(
        "+password +twoFactorSecret"
      );
      if (!user) {
        throw new AppError("User not found", 404);
      }

      // Verify 2FA token
      const verified = speakeasy.totp.verify({
        secret: user.twoFactorSecret!,
        encoding: "base32",
        token: token,
        window: 2,
      });

      if (!verified) {
        throw new AppError("Invalid authentication code", 400);
      }

      // Disable 2FA
      user.twoFactorEnabled = false;
      user.twoFactorSecret = undefined;
      await user.save();

      logger.info(`2FA disabled for user: ${user.username}`, {
        userId: user._id,
      });

      return {
        message: "Two-factor authentication disabled successfully!",
      };
    } catch (error) {
      logger.error("2FA disable error:", error);
      throw error;
    }
  }

  /**
   * Get user by phone number
   */
  async getUserByPhoneNumber(phoneNumber: string): Promise<IUser | null> {
    try {
      const user = await User.findOne({ contactNumber: phoneNumber });
      return user;
    } catch (error) {
      logger.error("Error finding user by phone number:", error);
      return null;
    }
  }

  /**
   * Get user by username
   */
  async getUserByUsername(username: string): Promise<IUser | null> {
    try {
      const user = await User.findOne({ username: username });
      return user;
    } catch (error) {
      logger.error("Error finding user by username:", error);
      return null;
    }
  }

  /**
   * Send password reset code via SMS using username
   */
  async sendPasswordResetCode(username: string): Promise<{ success: boolean; message: string; phoneNumber?: string }> {
    try {
      // Check if user exists with this username
      const user = await this.getUserByUsername(username);
      if (!user) {
        return {
          success: false,
          message: 'No account found with this username'
        };
      }

      // Get phone number from user
      const phoneNumber = user.contactNumber;
      if (!phoneNumber) {
        return {
          success: false,
          message: 'No phone number associated with this account'
        };
      }

      // Send SMS code
      const result = await twilioService.sendPasswordResetCode(phoneNumber);
      return {
        ...result,
        phoneNumber: phoneNumber
      };
    } catch (error) {
      logger.error("Error sending password reset code:", error);
      return {
        success: false,
        message: "Failed to send verification code"
      };
    }
  }

  /**
   * Verify password reset code
   */
  async verifyResetCode(phoneNumber: string, code: string): Promise<{ success: boolean; message: string; valid: boolean }> {
    try {
      const result = await twilioService.verifyCode(phoneNumber, code);
      return result;
    } catch (error) {
      logger.error("Error verifying reset code:", error);
      return {
        success: false,
        message: "Failed to verify code",
        valid: false
      };
    }
  }

  /**
   * Send verification code for registration
   */
  async sendVerificationCode(contactNumber: string): Promise<{ success: boolean; message: string }> {
    try {
      const result = await twilioService.sendPasswordResetCode(contactNumber);
      return result;
    } catch (error) {
      logger.error("Error sending verification code:", error);
      return {
        success: false,
        message: "Failed to send verification code"
      };
    }
  }

  /**
   * Verify code for registration
   */
  async verifyCode(contactNumber: string, code: string): Promise<{ success: boolean; message: string; verified: boolean }> {
    try {
      const result = await twilioService.verifyCode(contactNumber, code);
      return {
        success: result.success,
        message: result.message,
        verified: result.valid // Map 'valid' to 'verified'
      };
    } catch (error) {
      logger.error("Error verifying code:", error);
      return {
        success: false,
        message: "Failed to verify code",
        verified: false,
        
      };
    }
  }

  /**
   * Reset password with verification code using username
   */
  async resetPasswordWithCode(username: string, code: string, newPassword: string): Promise<{ success: boolean; message: string }> {
    try {
      // Get user by username first
      const user = await this.getUserByUsername(username);
      if (!user) {
        return {
          success: false,
          message: "User not found"
        };
      }

      // Get phone number from user
      const phoneNumber = user.contactNumber;
      if (!phoneNumber) {
        return {
          success: false,
          message: "No phone number associated with this account"
        };
      }

      // Verify the code with the phone number
      const verificationResult = await this.verifyResetCode(phoneNumber, code);
      
      if (!verificationResult.success || !verificationResult.valid) {
        return {
          success: false,
          message: "Invalid verification code"
        };
      }

      // Hash the new password
      const saltRounds = 12;
      const hashedPassword = await bcrypt.hash(newPassword, saltRounds);

      // Update user password
      await User.findByIdAndUpdate(user._id, { password: hashedPassword });

      logger.info(`Password reset successful for user ${user.username} (${user._id})`);

      return {
        success: true,
        message: "Password reset successfully"
      };
    } catch (error) {
      logger.error("Error resetting password:", error);
      return {
        success: false,
        message: "Failed to reset password"
      };
    }
  }
}

export default new AuthService();


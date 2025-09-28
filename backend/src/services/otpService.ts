import crypto from 'crypto';
import { logger } from '../utils/logger';

interface OTPData {
  code: string;
  email: string;
  expiresAt: Date;
  attempts: number;
  createdAt: Date;
}

class OTPService {
  private otpStorage: Map<string, OTPData> = new Map();
  private readonly OTP_LENGTH = 6;
  private readonly OTP_EXPIRY_MINUTES = 5;
  private readonly MAX_ATTEMPTS = 3;
  private readonly CLEANUP_INTERVAL = 60000; // 1 minute

  constructor() {
    // Clean up expired OTPs every minute
    setInterval(() => {
      this.cleanupExpiredOTPs();
    }, this.CLEANUP_INTERVAL);
  }

  /**
   * Generate a new OTP for email login
   * @param email - User's email address
   * @returns Generated OTP code
   */
  generateOTP(email: string): string {
    // Generate random 6-digit OTP
    const otp = crypto.randomInt(100000, 999999).toString();
    
    // Create expiry time
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + this.OTP_EXPIRY_MINUTES);

    // Store OTP data
    const emailKey = email.toLowerCase();
    const otpData: OTPData = {
      code: otp,
      email: emailKey,
      expiresAt,
      attempts: 0,
      createdAt: new Date()
    };

    // Use email as key (remove any existing OTP for this email)
    this.otpStorage.set(emailKey, otpData);

    logger.info('OTP generated and stored', {
      email: emailKey,
      otp: otp.substring(0, 2) + '****',
      expiresAt: expiresAt.toISOString(),
      otpLength: this.OTP_LENGTH,
      storageSize: this.otpStorage.size,
      storageKeys: Array.from(this.otpStorage.keys())
    });

    return otp;
  }

  /**
   * Verify OTP for email login
   * @param email - User's email address
   * @param providedOTP - OTP provided by user
   * @returns Verification result
   */
  verifyOTP(email: string, providedOTP: string): { 
    valid: boolean; 
    message: string; 
    attemptsLeft?: number;
  } {
    const emailKey = email.toLowerCase();
    const otpData = this.otpStorage.get(emailKey);

    logger.info('OTP verification debug', {
      email: emailKey,
      providedOTP: providedOTP.substring(0, 2) + '****',
      hasOTPData: !!otpData,
      storedOTP: otpData ? otpData.code.substring(0, 2) + '****' : 'none',
      attempts: otpData?.attempts || 0,
      expiresAt: otpData?.expiresAt?.toISOString() || 'none',
      storageSize: this.otpStorage.size,
      allStorageKeys: Array.from(this.otpStorage.keys()),
      lookupKey: emailKey
    });

    if (!otpData) {
      logger.warn('OTP verification failed - no OTP found', { email: emailKey });
      return {
        valid: false,
        message: 'No verification code found. Please request a new code.'
      };
    }

    // Check if OTP has expired
    if (new Date() > otpData.expiresAt) {
      this.otpStorage.delete(emailKey);
      logger.warn('OTP verification failed - expired', { 
        email: emailKey,
        expiredAt: otpData.expiresAt.toISOString()
      });
      return {
        valid: false,
        message: 'Verification code has expired. Please request a new code.'
      };
    }

    // Increment attempt counter
    otpData.attempts++;

    // Check if max attempts exceeded
    if (otpData.attempts > this.MAX_ATTEMPTS) {
      this.otpStorage.delete(emailKey);
      logger.warn('OTP verification failed - max attempts exceeded', { 
        email: emailKey,
        attempts: otpData.attempts
      });
      return {
        valid: false,
        message: 'Too many failed attempts. Please request a new verification code.'
      };
    }

    // Verify OTP code
    const trimmedOTP = providedOTP.trim();
    const isMatch = otpData.code === trimmedOTP;
    
    logger.info('OTP comparison debug', {
      email: emailKey,
      storedCode: otpData.code,
      providedCode: trimmedOTP,
      storedLength: otpData.code.length,
      providedLength: trimmedOTP.length,
      isMatch
    });
    
    if (!isMatch) {
      const attemptsLeft = this.MAX_ATTEMPTS - otpData.attempts;
      logger.warn('OTP verification failed - invalid code', { 
        email: emailKey,
        attempts: otpData.attempts,
        attemptsLeft,
        storedCode: otpData.code,
        providedCode: trimmedOTP
      });
      return {
        valid: false,
        message: `Invalid verification code. ${attemptsLeft} attempt${attemptsLeft !== 1 ? 's' : ''} remaining.`,
        attemptsLeft
      };
    }

    // OTP is valid - remove it from storage
    this.otpStorage.delete(emailKey);
    
    logger.info('OTP verification successful', { 
      email: emailKey,
      attempts: otpData.attempts
    });

    return {
      valid: true,
      message: 'Verification code validated successfully.'
    };
  }

  /**
   * Check if an OTP exists for the given email
   * @param email - User's email address
   * @returns True if OTP exists and is not expired
   */
  hasValidOTP(email: string): boolean {
    const emailKey = email.toLowerCase();
    const otpData = this.otpStorage.get(emailKey);
    
    if (!otpData) {
      return false;
    }

    // Check if expired
    if (new Date() > otpData.expiresAt) {
      this.otpStorage.delete(emailKey);
      return false;
    }

    return true;
  }

  /**
   * Get remaining time for OTP in seconds
   * @param email - User's email address
   * @returns Remaining seconds or 0 if no valid OTP
   */
  getRemainingTime(email: string): number {
    const emailKey = email.toLowerCase();
    const otpData = this.otpStorage.get(emailKey);
    
    if (!otpData) {
      return 0;
    }

    const now = new Date();
    if (now > otpData.expiresAt) {
      this.otpStorage.delete(emailKey);
      return 0;
    }

    return Math.ceil((otpData.expiresAt.getTime() - now.getTime()) / 1000);
  }

  /**
   * Invalidate OTP for the given email (useful for cleanup or security)
   * @param email - User's email address
   */
  invalidateOTP(email: string): void {
    const emailKey = email.toLowerCase();
    const deleted = this.otpStorage.delete(emailKey);
    
    if (deleted) {
      logger.info('OTP invalidated', { email: emailKey });
    }
  }

  /**
   * Clean up expired OTPs from storage
   */
  private cleanupExpiredOTPs(): void {
    const now = new Date();
    let cleanedCount = 0;

    for (const [email, otpData] of this.otpStorage.entries()) {
      if (now > otpData.expiresAt) {
        this.otpStorage.delete(email);
        cleanedCount++;
      }
    }

    if (cleanedCount > 0) {
      logger.debug('Cleaned up expired OTPs', { count: cleanedCount });
    }
  }

  /**
   * Get current OTP storage stats (for monitoring/debugging)
   */
  getStats(): {
    totalOTPs: number;
    expiredOTPs: number;
    validOTPs: number;
  } {
    const now = new Date();
    let expiredCount = 0;
    let validCount = 0;

    for (const otpData of this.otpStorage.values()) {
      if (now > otpData.expiresAt) {
        expiredCount++;
      } else {
        validCount++;
      }
    }

    return {
      totalOTPs: this.otpStorage.size,
      expiredOTPs: expiredCount,
      validOTPs: validCount
    };
  }
}

export default new OTPService();

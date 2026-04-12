import crypto from 'crypto';
import { logger } from '../utils/logger';

interface OTPData {
  code: string;
  email: string;
  type: 'login' | 'forgot-password';
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
   * Generate a new OTP for email login or forgot password
   * @param email - User's email address
   * @param type - Type of OTP (login or forgot-password)
   * @returns Generated OTP code
   */
  generateOTP(email: string, type: 'login' | 'forgot-password' = 'login'): string {
    // Generate random 6-digit OTP
    const otp = crypto.randomInt(100000, 999999).toString();
    
    // Create expiry time
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + this.OTP_EXPIRY_MINUTES);

    // Log OTP to console for testing
    if (process.env.NODE_ENV !== 'production') {
      const timeLeft = Math.ceil((expiresAt.getTime() - Date.now()) / 60000);
      console.log('\n' + '='.repeat(60));
      console.log(`TEST OTP for ${email} (${type})`);
      console.log('='.repeat(60));
      console.log(`OTP: ${otp}`);
      console.log(`Expires in: ${timeLeft} minutes`);
      console.log('='.repeat(60) + '\n');
    }

    // Store OTP data
    const emailKey = email.toLowerCase();
    const storageKey = `${emailKey}:${type}`;
    const otpData: OTPData = {
      code: otp,
      email: emailKey,
      type,
      expiresAt,
      attempts: 0,
      createdAt: new Date()
    };

    // Use email:type as key (remove any existing OTP for this email and type)
    this.otpStorage.set(storageKey, otpData);

    logger.info('OTP generated and stored', {
      email: emailKey,
      type,
      otp: otp.substring(0, 2) + '****',
      expiresAt: expiresAt.toISOString(),
      otpLength: this.OTP_LENGTH,
      storageSize: this.otpStorage.size,
      storageKey
    });

    return otp;
  }

  /**
   * Verify OTP for email login or forgot password
   * @param email - User's email address
   * @param providedOTP - OTP provided by user
   * @param type - Type of OTP (login or forgot-password)
   * @returns Verification result
   */
  verifyOTP(email: string, providedOTP: string, type: 'login' | 'forgot-password' = 'login'): { 
    valid: boolean; 
    message: string; 
    attemptsLeft?: number;
  } {
    const emailKey = email.toLowerCase();
    const storageKey = `${emailKey}:${type}`;
    const otpData = this.otpStorage.get(storageKey);

    logger.info('OTP verification debug', {
      email: emailKey,
      type,
      providedOTP: providedOTP.substring(0, 2) + '****',
      hasOTPData: !!otpData,
      storedOTP: otpData ? otpData.code.substring(0, 2) + '****' : 'none',
      attempts: otpData?.attempts || 0,
      expiresAt: otpData?.expiresAt?.toISOString() || 'none',
      storageSize: this.otpStorage.size,
      allStorageKeys: Array.from(this.otpStorage.keys()),
      lookupKey: storageKey
    });

    if (!otpData) {
      logger.warn('OTP verification failed - no OTP found', { email: emailKey, type, storageKey });
      return {
        valid: false,
        message: 'No verification code found. Please request a new code.'
      };
    }

    // Check if OTP has expired
    if (new Date() > otpData.expiresAt) {
      this.otpStorage.delete(storageKey);
      logger.warn('OTP verification failed - expired', { 
        email: emailKey,
        type,
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
      this.otpStorage.delete(storageKey);
      logger.warn('OTP verification failed - max attempts exceeded', { 
        email: emailKey,
        type,
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
        type,
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
    this.otpStorage.delete(storageKey);
    
    logger.info('OTP verification successful', { 
      email: emailKey,
      type,
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
   * @param type - Type of OTP (login or forgot-password)
   * @returns True if OTP exists and is not expired
   */
  hasValidOTP(email: string, type: 'login' | 'forgot-password' = 'login'): boolean {
    const emailKey = email.toLowerCase();
    const storageKey = `${emailKey}:${type}`;
    const otpData = this.otpStorage.get(storageKey);
    
    if (!otpData) {
      return false;
    }

    // Check if expired
    if (new Date() > otpData.expiresAt) {
      this.otpStorage.delete(storageKey);
      return false;
    }

    return true;
  }

  /**
   * Get remaining time for OTP in seconds
   * @param email - User's email address
   * @param type - Type of OTP (login or forgot-password)
   * @returns Remaining seconds or 0 if no valid OTP
   */
  getRemainingTime(email: string, type: 'login' | 'forgot-password' = 'login'): number {
    const emailKey = email.toLowerCase();
    const storageKey = `${emailKey}:${type}`;
    const otpData = this.otpStorage.get(storageKey);
    
    if (!otpData) {
      return 0;
    }

    const now = new Date();
    if (now > otpData.expiresAt) {
      this.otpStorage.delete(storageKey);
      return 0;
    }

    return Math.ceil((otpData.expiresAt.getTime() - now.getTime()) / 1000);
  }

  /**
   * Invalidate OTP for the given email (useful for cleanup or security)
   * @param email - User's email address
   * @param type - Type of OTP (login or forgot-password)
   */
  invalidateOTP(email: string, type: 'login' | 'forgot-password' = 'login'): void {
    const emailKey = email.toLowerCase();
    const storageKey = `${emailKey}:${type}`;
    const deleted = this.otpStorage.delete(storageKey);
    
    if (deleted) {
      logger.info('OTP invalidated', { email: emailKey, type });
    }
  }

  /**
   * Clear OTP for the given email and type (alias for invalidateOTP)
   * @param email - User's email address
   * @param type - Type of OTP (login or forgot-password)
   */
  clearOTP(email: string, type: 'login' | 'forgot-password' = 'login'): void {
    this.invalidateOTP(email, type);
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

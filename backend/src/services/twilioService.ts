import twilio from 'twilio';
import { logger } from '../utils/logger';

class TwilioService {
  private client: twilio.Twilio;
  private verifyServiceSid: string;

  constructor() {
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const authToken = process.env.TWILIO_AUTH_TOKEN;
    this.verifyServiceSid = process.env.TWILIO_VERIFY_SERVICE_ID || '';

    if (!accountSid || !authToken || !this.verifyServiceSid) {
      throw new Error('Twilio credentials not configured');
    }

    this.client = twilio(accountSid, authToken);
    logger.info('Twilio service initialized');
  }

  /**
   * Send SMS verification code for password reset
   */
  async sendPasswordResetCode(phoneNumber: string): Promise<{ success: boolean; message: string; sid?: string }> {
    // Format phone number to international format if needed
    const formattedNumber = this.formatPhoneNumber(phoneNumber);
    
    try {
      // Development mode: Don't send real SMS, just return success
      if (process.env.NODE_ENV === 'development') {
        logger.info(`Development mode: Simulating SMS send to ${formattedNumber}`);
        return {
          success: true,
          message: 'Verification code sent successfully (development mode - use any 6-digit code)',
          sid: 'dev_' + Date.now()
        };
      }
      
      const verification = await this.client.verify.v2
        .services(this.verifyServiceSid)
        .verifications
        .create({
          to: formattedNumber,
          channel: 'sms'
        });

      logger.info(`Password reset code sent to ${formattedNumber}`);
      
      return {
        success: true,
        message: 'Verification code sent successfully',
        sid: verification.sid
      };
    } catch (error: any) {
      logger.error('Error sending password reset code:', error);
      
      // Fallback to development mode if Twilio fails
      if (process.env.NODE_ENV === 'development') {
        logger.info(`Twilio error, falling back to development mode for ${formattedNumber}`);
        return {
          success: true,
          message: 'Verification code sent successfully (development fallback - use any 6-digit code)',
          sid: 'dev_fallback_' + Date.now()
        };
      }
      
      return {
        success: false,
        message: error.message || 'Failed to send verification code'
      };
    }
  }

  /**
   * Verify the SMS code
   */
  async verifyCode(phoneNumber: string, code: string): Promise<{ success: boolean; message: string; valid: boolean }> {
    try {
      const formattedNumber = this.formatPhoneNumber(phoneNumber);
      
      // Development mode: Accept any 6-digit code for testing
      if (process.env.NODE_ENV === 'development') {
        const isSixDigitCode = /^\d{6}$/.test(code);
        if (isSixDigitCode) {
          logger.info(`Development mode: Accepting 6-digit code ${code} for ${formattedNumber}`);
          return {
            success: true,
            message: 'Code verified successfully (development mode)',
            valid: true
          };
        }
      }
      
      const verificationCheck = await this.client.verify.v2
        .services(this.verifyServiceSid)
        .verificationChecks
        .create({
          to: formattedNumber,
          code: code
        });

      const isValid = verificationCheck.status === 'approved';
      
      logger.info(`Code verification for ${formattedNumber}: ${isValid ? 'valid' : 'invalid'}`);
      
      return {
        success: true,
        message: isValid ? 'Code verified successfully' : 'Invalid verification code',
        valid: isValid
      };
    } catch (error: any) {
      logger.error('Error verifying code:', error);
      
      // Fallback to development mode if Twilio service fails
      if (process.env.NODE_ENV === 'development') {
        const isSixDigitCode = /^\d{6}$/.test(code);
        if (isSixDigitCode) {
          logger.info(`Twilio error, falling back to development mode: Accepting 6-digit code ${code}`);
          return {
            success: true,
            message: 'Code verified successfully (development fallback)',
            valid: true
          };
        }
      }
      
      return {
        success: false,
        message: error.message || 'Failed to verify code',
        valid: false
      };
    }
  }

  /**
   * Format phone number to international format
   */
  private formatPhoneNumber(phoneNumber: string): string {
    // Remove all non-digit characters
    const digits = phoneNumber.replace(/\D/g, '');
    
    // If it starts with 0, replace with +63 (Philippines country code)
    if (digits.startsWith('0')) {
      return `+63${digits.substring(1)}`;
    }
    
    // If it doesn't start with +, add +63
    if (!phoneNumber.startsWith('+')) {
      return `+63${digits}`;
    }
    
    return phoneNumber;
  }
}

export default new TwilioService();

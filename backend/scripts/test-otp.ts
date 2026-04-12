import otpService from '../src/services/otpService';
import { logger } from '../src/utils/logger';

// Test email (replace with the one you use for admin login)
const TEST_EMAIL = 'admin@example.com';

// Generate a new OTP
const otp = otpService.generateOTP(TEST_EMAIL, 'login');

// Log the OTP to console with clear formatting
console.log('\n\n' + '='.repeat(50));
console.log(`TEST OTP for ${TEST_EMAIL}`);
console.log('='.repeat(50));
console.log(`OTP: ${otp}`);
console.log('Valid for: 5 minutes');
console.log('='.repeat(50) + '\n\n');

// Log to file as well
logger.info('TEST OTP GENERATED - FOR TESTING ONLY', {
  email: TEST_EMAIL,
  otp,
  expiresIn: '5 minutes',
  timestamp: new Date().toISOString()
});

// Check remaining time for the OTP
const remainingTime = otpService.getRemainingTime(TEST_EMAIL, 'login');
console.log(`OTP will expire in ${Math.ceil(remainingTime / 60)} minutes`);

// Instructions for testing
console.log('\nTo use this OTP:');
console.log('1. Go to the admin login page');
console.log('2. Enter your email and click "Send OTP"');
console.log('3. Use the OTP shown above to log in');
console.log('\nNote: This OTP is only valid for 5 minutes.\n');

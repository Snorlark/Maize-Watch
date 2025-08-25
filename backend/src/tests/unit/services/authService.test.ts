import AuthService from '../../../services/authService';
import User from '../../../models/User';
import { AppError } from '../../../middleware/errorHandler';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

// Mock dependencies
jest.mock('../../../models/User');
jest.mock('bcrypt');
jest.mock('jsonwebtoken');
jest.mock('../../../utils/emailService', () => ({
  default: {
    sendVerificationEmail: jest.fn(),
    sendPasswordResetEmail: jest.fn(),
  }
}));

describe('AuthService', () => {
  let authService: typeof AuthService;
  const mockUser = {
    _id: 'user123',
    username: 'testuser',
    email: 'test@example.com',
    password: 'hashedpassword',
    role: 'farmer',
    isEmailVerified: false,
    save: jest.fn(),
    createEmailVerificationToken: jest.fn().mockReturnValue('verification-token'),
    createPasswordResetToken: jest.fn().mockReturnValue('reset-token'),
  };

  beforeEach(() => {
    authService = AuthService;
    jest.clearAllMocks();
  });

  describe('Performance Tests', () => {
    it('should register user within acceptable time limit', async () => {
      const startTime = Date.now();
      
      (User.findOne as jest.Mock).mockResolvedValue(null);
      (bcrypt.hash as jest.Mock).mockResolvedValue('hashedpassword');
      (User.prototype.save as jest.Mock).mockResolvedValue(mockUser);

      const userData = {
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Test User',
        contactNumber: '+1234567890',
        address: {
          region: 'Test Region',
          province: 'Test Province',
          municipality: 'Test Municipality',
          barangay: 'Test Barangay',
          zipCode: '12345'
        }
      };

      await authService.register(userData);
      
      const executionTime = Date.now() - startTime;
      expect(executionTime).toBeLessThan(1000); // Should complete within 1 second
    });

    it('should login user within acceptable time limit', async () => {
      const startTime = Date.now();
      
      (User.findOne as jest.Mock).mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      (jwt.sign as jest.Mock).mockReturnValue('jwt-token');

      await authService.login('test@example.com', 'password123');
      
      const executionTime = Date.now() - startTime;
      expect(executionTime).toBeLessThan(500); // Should complete within 500ms
    });
  });

  describe('Security Tests', () => {
    it('should hash passwords before storing', async () => {
      (User.findOne as jest.Mock).mockResolvedValue(null);
      (bcrypt.hash as jest.Mock).mockResolvedValue('hashedpassword');
      (User.prototype.save as jest.Mock).mockResolvedValue(mockUser);

      const userData = {
        username: 'testuser',
        email: 'test@example.com',
        password: 'plainpassword',
        fullName: 'Test User',
        contactNumber: '+1234567890',
        address: {
          region: 'Test Region',
          province: 'Test Province',
          municipality: 'Test Municipality',
          barangay: 'Test Barangay',
          zipCode: '12345'
        }
      };

      await authService.register(userData);

      expect(bcrypt.hash).toHaveBeenCalledWith('plainpassword', 12);
    });

    it('should reject weak passwords', async () => {
      const userData = {
        username: 'testuser',
        email: 'test@example.com',
        password: '123', // Weak password
        fullName: 'Test User',
        contactNumber: '+1234567890',
        address: {
          region: 'Test Region',
          province: 'Test Province',
          municipality: 'Test Municipality',
          barangay: 'Test Barangay',
          zipCode: '12345'
        }
      };

      await expect(authService.register(userData))
        .rejects.toThrow('Password must be at least 8 characters long');
    });

    it('should prevent duplicate email registration', async () => {
      (User.findOne as jest.Mock).mockResolvedValue(mockUser);

      const userData = {
        username: 'testuser2',
        email: 'test@example.com', // Existing email
        password: 'password123',
        fullName: 'Test User 2',
        contactNumber: '+1234567890',
        address: {
          region: 'Test Region',
          province: 'Test Province',
          municipality: 'Test Municipality',
          barangay: 'Test Barangay',
          zipCode: '12345'
        }
      };

      await expect(authService.register(userData))
        .rejects.toThrow('User with this email already exists');
    });

    it('should handle JWT token verification in login process', async () => {
      (User.findOne as jest.Mock).mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      (jwt.sign as jest.Mock).mockReturnValue('jwt-token');

      const result = await authService.login('test@example.com', 'password123');

      expect(result).toHaveProperty('tokens');
      expect(result.tokens).toHaveProperty('accessToken');
    });
  });

  describe('Functionality Tests', () => {
    it('should successfully register a new user', async () => {
      (User.findOne as jest.Mock).mockResolvedValue(null);
      (bcrypt.hash as jest.Mock).mockResolvedValue('hashedpassword');
      (User.prototype.save as jest.Mock).mockResolvedValue(mockUser);

      const userData = {
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Test User',
        contactNumber: '+1234567890',
        address: {
          region: 'Test Region',
          province: 'Test Province',
          municipality: 'Test Municipality',
          barangay: 'Test Barangay',
          zipCode: '12345'
        }
      };

      const result = await authService.register(userData);

      expect(result).toHaveProperty('user');
      expect(result).toHaveProperty('tokens');
      expect(User.findOne).toHaveBeenCalledWith({
        $or: [{ email: 'test@example.com' }, { username: 'testuser' }]
      });
    });

    it('should successfully login with valid credentials', async () => {
      (User.findOne as jest.Mock).mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      (jwt.sign as jest.Mock).mockReturnValue('jwt-token');

      const result = await authService.login('test@example.com', 'password123');

      expect(result).toHaveProperty('user');
      expect(result).toHaveProperty('tokens');
      expect(bcrypt.compare).toHaveBeenCalledWith('password123', 'hashedpassword');
    });

    it('should reject login with invalid credentials', async () => {
      (User.findOne as jest.Mock).mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      await expect(authService.login('test@example.com', 'wrongpassword'))
        .rejects.toThrow('Invalid credentials');
    });

    it('should generate password reset token', async () => {
      (User.findOne as jest.Mock).mockResolvedValue(mockUser);

      const result = await authService.requestPasswordReset('test@example.com');

      expect(result).toHaveProperty('message');
      expect(mockUser.createPasswordResetToken).toHaveBeenCalled();
      expect(mockUser.save).toHaveBeenCalled();
    });
  });

  describe('Error Handling Tests', () => {
    it('should handle database connection errors gracefully', async () => {
      (User.findOne as jest.Mock).mockRejectedValue(new Error('Database connection failed'));

      await expect(authService.login('test@example.com', 'password123'))
        .rejects.toThrow('Database connection failed');
    });

    it('should handle email service failures gracefully', async () => {
      (User.findOne as jest.Mock).mockResolvedValue(null);
      (bcrypt.hash as jest.Mock).mockResolvedValue('hashedpassword');
      (User.prototype.save as jest.Mock).mockResolvedValue(mockUser);

      const userData = {
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Test User',
        contactNumber: '+1234567890',
        address: {
          region: 'Test Region',
          province: 'Test Province',
          municipality: 'Test Municipality',
          barangay: 'Test Barangay',
          zipCode: '12345'
        }
      };

      // Should not throw even if email service fails
      const result = await authService.register(userData);
      expect(result).toHaveProperty('user');
    });
  });
});

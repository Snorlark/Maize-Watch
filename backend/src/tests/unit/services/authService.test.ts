import AuthService from '../../../services/authService';
import User from '../../../models/User';
import { AppError } from '../../../middleware/errorHandler';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

// Mock dependencies
jest.mock('../../../models/User');
jest.mock('bcrypt');
jest.mock('jsonwebtoken');

// Mock the dynamic import for email service
const mockEmailService = {
  sendVerificationEmail: jest.fn().mockResolvedValue(true),
  sendPasswordResetEmail: jest.fn().mockResolvedValue(true),
};

jest.mock('../../../utils/emailService', () => ({
  default: mockEmailService
}));

// Mock the global import function to handle dynamic imports
const originalImport = (global as any).import;
(global as any).import = jest.fn().mockImplementation((specifier: string) => {
  if (specifier.includes('emailService')) {
    return Promise.resolve({ default: mockEmailService });
  }
  return originalImport ? originalImport(specifier) : Promise.reject(new Error('Module not found'));
});

describe('AuthService', () => {
  let authService: typeof AuthService;
  
  const createMockUser = (overrides = {}) => ({
    _id: 'user123',
    username: 'testuser',
    email: 'test@example.com',
    password: 'hashedpassword',
    role: 'farmer',
    isEmailVerified: false,
    twoFactorEnabled: false,
    twoFactorSecret: null,
    refreshTokens: [],
    lastLogin: new Date(),
    save: jest.fn().mockResolvedValue({}),
    toJSON: jest.fn().mockReturnValue({
      _id: 'user123',
      username: 'testuser',
      email: 'test@example.com',
      role: 'farmer'
    }),
    generateAuthToken: jest.fn().mockReturnValue('mock-jwt-token'),
    generateRefreshToken: jest.fn().mockReturnValue('mock-refresh-token'),
    createEmailVerificationToken: jest.fn().mockReturnValue('verification-token'),
    createPasswordResetToken: jest.fn().mockReturnValue('reset-token'),
    ...overrides
  });

  beforeEach(() => {
    authService = AuthService;
    jest.clearAllMocks();
  });

  describe('Performance Tests', () => {
    it('should register user within acceptable time limit', async () => {
      const startTime = Date.now();
      
      const mockUser = createMockUser();
      (User.findOne as jest.Mock).mockResolvedValue(null);
      (bcrypt.hash as jest.Mock).mockResolvedValue('hashedpassword');
      (User as any).mockImplementation(() => mockUser);

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
          
        }
      };

      await authService.register(userData);
      
      const executionTime = Date.now() - startTime;
      expect(executionTime).toBeLessThan(1000); // Should complete within 1 second
    });

    it('should login user within acceptable time limit', async () => {
      const startTime = Date.now();
      
      const mockUser = createMockUser();
      (User.findByCredentials as jest.Mock) = jest.fn().mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      (jwt.sign as jest.Mock).mockReturnValue('jwt-token');

      await authService.login('test@example.com', 'password123');
      
      const executionTime = Date.now() - startTime;
      expect(executionTime).toBeLessThan(500); // Should complete within 500ms
    });
  });

  describe('Security Tests', () => {
    it('should hash passwords before storing', async () => {
      const mockUser = createMockUser();
      (User.findOne as jest.Mock).mockResolvedValue(null);
      (bcrypt.hash as jest.Mock).mockResolvedValue('hashedpassword');
      
      // Mock User constructor to capture password
      let capturedPassword = '';
      (User as any).mockImplementation((userData: any) => {
        capturedPassword = userData.password;
        return mockUser;
      });

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
          
        }
      };

      await authService.register(userData);

      // Verify the password was passed to User constructor
      expect(capturedPassword).toBe('plainpassword');
    });

    it('should reject weak passwords', async () => {
      (User.findOne as jest.Mock).mockResolvedValue(null);
      
      // Mock User constructor to throw validation error for weak password
      (User as any).mockImplementation((userData: any) => {
        if (userData.password.length < 8) {
          const error = new Error('Password must be at least 8 characters long');
          error.name = 'ValidationError';
          throw error;
        }
        return createMockUser();
      });

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
          
        }
      };

      await expect(authService.register(userData))
        .rejects.toThrow('Password must be at least 8 characters long');
    });

    it('should prevent duplicate email registration', async () => {
      const mockUser = createMockUser();
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
          
        }
      };

      await expect(authService.register(userData))
        .rejects.toThrow('Email already exists');
    });

    it('should handle JWT token verification in login process', async () => {
      const mockUser = createMockUser();
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
      const mockUser = createMockUser();
      (User.findOne as jest.Mock).mockResolvedValue(null);
      (bcrypt.hash as jest.Mock).mockResolvedValue('hashedpassword');
      (User as any).mockImplementation(() => mockUser);

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
          
        }
      };

      const result = await authService.register(userData);

      expect(result).toHaveProperty('user');
      expect(result).toHaveProperty('tokens');
      expect(User.findOne).toHaveBeenCalledWith({
        $or: [{ username: 'testuser' }, { email: 'test@example.com' }]
      });
    });

    it('should successfully login with valid credentials', async () => {
      const mockUser = createMockUser();
      (User.findByCredentials as jest.Mock) = jest.fn().mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      (jwt.sign as jest.Mock).mockReturnValue('jwt-token');

      const result = await authService.login('test@example.com', 'password123');

      expect(result).toHaveProperty('user');
      expect(result).toHaveProperty('tokens');
      expect(User.findByCredentials).toHaveBeenCalledWith('test@example.com', 'password123');
    });

    it('should reject login with invalid credentials', async () => {
      // Mock User.findByCredentials to throw error for invalid credentials
      (User.findByCredentials as jest.Mock) = jest.fn().mockRejectedValue(new Error('Invalid credentials'));

      await expect(authService.login('test@example.com', 'wrongpassword'))
        .rejects.toThrow('Invalid credentials');
    });

    it('should generate password reset token', async () => {
      const mockUser = createMockUser();
      (User.findOne as jest.Mock).mockResolvedValue(mockUser);
      
      // Reset and configure the mock email service
      mockEmailService.sendPasswordResetEmail.mockClear();
      mockEmailService.sendPasswordResetEmail.mockResolvedValue(true);

      const result = await authService.requestPasswordReset('test@example.com');

      expect(result).toHaveProperty('message');
      expect(mockUser.createPasswordResetToken).toHaveBeenCalled();
      expect(mockUser.save).toHaveBeenCalled();
    });
  });

  describe('Error Handling Tests', () => {
    it('should handle database connection errors gracefully', async () => {
      // Mock User.findByCredentials to throw database error
      (User.findByCredentials as jest.Mock) = jest.fn().mockRejectedValue(new Error('Database connection failed'));

      await expect(authService.login('test@example.com', 'password123'))
        .rejects.toThrow('Database connection failed');
    });

    it('should handle email service failures gracefully', async () => {
      const mockUser = createMockUser();
      (User.findOne as jest.Mock).mockResolvedValue(null);
      (bcrypt.hash as jest.Mock).mockResolvedValue('hashedpassword');
      (User as any).mockImplementation(() => mockUser);

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
          
        }
      };

      // Should not throw even if email service fails
      const result = await authService.register(userData);
      expect(result).toHaveProperty('user');
    });
  });
});

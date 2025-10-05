import { Request, Response, NextFunction } from 'express';
import multer from 'multer';
import { body, param, query, validationResult, ValidationChain } from 'express-validator';
import { HTTP_STATUS, VALIDATION_RULES, PHILIPPINE_REGIONS, CROP_TYPES } from '../utils/constants';

// Helper function to handle validation results
export const handleValidationErrors = (req: Request, res: Response, next: NextFunction): void => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    res.status(HTTP_STATUS.UNPROCESSABLE_ENTITY).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map(error => ({
        field: error.type === 'field' ? error.path : 'unknown',
        message: error.msg,
        value: error.type === 'field' ? error.value : undefined,
      })),
    });
    return;
  }
  
  next();
};

// User validation rules
export const validateUserRegistration: ValidationChain[] = [
  body('username')
    .isLength({ min: VALIDATION_RULES.USERNAME.MIN_LENGTH, max: VALIDATION_RULES.USERNAME.MAX_LENGTH })
    .withMessage(`Username must be between ${VALIDATION_RULES.USERNAME.MIN_LENGTH} and ${VALIDATION_RULES.USERNAME.MAX_LENGTH} characters`)
    .matches(VALIDATION_RULES.USERNAME.PATTERN)
    .withMessage('Username can only contain letters, numbers, and underscores'),
  
  body('email')
    .if(body('deviceType').not().equals('mobile'))
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),
  
  body('password')
    .isLength({ min: VALIDATION_RULES.PASSWORD.MIN_LENGTH })
    .withMessage(`Password must be at least ${VALIDATION_RULES.PASSWORD.MIN_LENGTH} characters long`),
  
  body('fullName')
    .isLength({ min: 2, max: 100 })
    .withMessage('Full name must be between 2 and 100 characters')
    .trim(),
  
  body('contactNumber')
    .matches(VALIDATION_RULES.PHONE.PATTERN)
    .withMessage('Please provide a valid Philippine mobile number'),
  
  body('address')
    .custom((value, { req }) => {
      // Allow both string and object format for mobile and web
      if (typeof value === 'string') {
        return value.length >= 2 && value.length <= 100;
      } else if (typeof value === 'object') {
        return value.region && 
               value.province && 
               value.municipality && 
               value.barangay;
      }
      return false;
    })
    .withMessage('Address is required'),

  // Validate address fields when address is an object
  body('address.region')
    .if(body('address').isObject())
    .isLength({ min: 2, max: 100 })
    .withMessage('Region is required')
    .trim(),
    
  body('address.province')
    .if(body('address').isObject())
    .isLength({ min: 2, max: 50 })
    .withMessage('Province must be between 2 and 50 characters')
    .trim(),
  
  body('address.municipality')
    .if(body('address').isObject())
    .isLength({ min: 2, max: 50 })
    .withMessage('Municipality must be between 2 and 50 characters')
    .trim(),
  
  body('address.barangay')
    .if(body('address').isObject())
    .isLength({ min: 2, max: 50 })
    .withMessage('Barangay must be between 2 and 50 characters')
    .trim(),

  body('deviceType')
    .optional()
    .isIn(['web', 'mobile'])
    .withMessage('Device type must be either web or mobile'),
];

export const validateUserLogin: ValidationChain[] = [
  body('deviceType')
    .optional()
    .isIn(['web', 'mobile'])
    .withMessage('Device type must be either web or mobile'),

  // For mobile devices, require username
  body('username')
    .if(body('deviceType').equals('mobile'))
    .notEmpty()
    .withMessage('Username is required for mobile login')
    .isLength({ min: 3, max: 30 })
    .withMessage('Username must be between 3 and 30 characters'),

  // For web devices, require email
  body('email')
    .if(body('deviceType').equals('web'))
    .notEmpty()
    .withMessage('Email is required for web login')
    .isEmail()
    .withMessage('Please provide a valid email address'),

  // For devices without deviceType specified, accept either username or email
  body('username')
    .if(body('deviceType').not().exists())
    .optional(),
    
  body('email')
    .if(body('deviceType').not().exists())
    .optional(),

  // Custom validation to ensure either username or email is provided when deviceType is not specified
  body().custom((value, { req }) => {
    if (!req.body.deviceType && !req.body.username && !req.body.email) {
      throw new Error('Either username or email is required');
    }
    return true;
  }),
  
  body('password')
    .notEmpty()
    .withMessage('Password is required'),

  body('totpCode')
    .optional()
    .isLength({ min: 6, max: 6 })
    .withMessage('TOTP code must be 6 digits')
    .isNumeric()
    .withMessage('TOTP code must contain only numbers'),
];

export const validateUserUpdate: ValidationChain[] = [
  body('username')
    .optional()
    .isLength({ min: VALIDATION_RULES.USERNAME.MIN_LENGTH, max: VALIDATION_RULES.USERNAME.MAX_LENGTH })
    .withMessage(`Username must be between ${VALIDATION_RULES.USERNAME.MIN_LENGTH} and ${VALIDATION_RULES.USERNAME.MAX_LENGTH} characters`)
    .matches(VALIDATION_RULES.USERNAME.PATTERN)
    .withMessage('Username can only contain letters, numbers, and underscores'),
  
  body('email')
    .optional()
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),
  
  body('fullName')
    .optional()
    .isLength({ min: 2, max: 100 })
    .withMessage('Full name must be between 2 and 100 characters')
    .trim(),
  
  body('contactNumber')
    .optional()
    .matches(VALIDATION_RULES.PHONE.PATTERN)
    .withMessage('Please provide a valid Philippine mobile number'),
  
  body('password')
    .optional()
    .isLength({ min: VALIDATION_RULES.PASSWORD.MIN_LENGTH })
    .withMessage(`Password must be at least ${VALIDATION_RULES.PASSWORD.MIN_LENGTH} characters long`),
  
  body('address')
    .optional()
    .custom((value, { req }) => {
      // Allow both string and object format for mobile and web
      if (typeof value === 'string') {
        return value.length >= 2 && value.length <= 100;
      } else if (typeof value === 'object') {
        return value.region && 
               value.province && 
               value.municipality && 
               value.barangay;
      }
      return false;
    })
    .withMessage('Address is required'),

  // Validate address fields when address is an object
  body('address.region')
    .if(body('address').isObject())
    .optional()
    .isLength({ min: 2, max: 100 })
    .withMessage('Region is required')
    .trim(),
    
  body('address.province')
    .if(body('address').isObject())
    .optional()
    .isLength({ min: 2, max: 50 })
    .withMessage('Province must be between 2 and 50 characters')
    .trim(),
  
  body('address.municipality')
    .if(body('address').isObject())
    .optional()
    .isLength({ min: 2, max: 50 })
    .withMessage('Municipality must be between 2 and 50 characters')
    .trim(),
  
  body('address.barangay')
    .if(body('address').isObject())
    .optional()
    .isLength({ min: 2, max: 50 })
    .withMessage('Barangay must be between 2 and 50 characters')
    .trim(),
];

// Farm validation rules
export const validateFarmCreation: ValidationChain[] = [
  body('name')
    .isLength({ min: 2, max: 100 })
    .withMessage('Farm name must be between 2 and 100 characters')
    .trim(),
  
  body('description')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Description cannot exceed 500 characters')
    .trim(),
  
  body('location.coordinates')
    .isArray({ min: 2, max: 2 })
    .withMessage('Coordinates must be an array of [longitude, latitude]'),
  
  body('location.coordinates.*')
    .isFloat()
    .withMessage('Coordinates must be valid numbers'),
  
  body('location.address.region')
    .isIn(PHILIPPINE_REGIONS)
    .withMessage('Please select a valid region'),
  
  body('location.address.province')
    .isLength({ min: 2, max: 50 })
    .withMessage('Province must be between 2 and 50 characters')
    .trim(),
  
  body('location.address.municipality')
    .isLength({ min: 2, max: 50 })
    .withMessage('Municipality must be between 2 and 50 characters')
    .trim(),
  
  body('location.address.barangay')
    .isLength({ min: 2, max: 50 })
    .withMessage('Barangay must be between 2 and 50 characters')
    .trim(),
  
  body('area.size')
    .isFloat({ min: 0.01 })
    .withMessage('Farm area must be greater than 0'),
  
  body('area.unit')
    .isIn(['hectares', 'square_meters', 'acres'])
    .withMessage('Area unit must be hectares, square_meters, or acres'),
  
  body('cropType')
    .isIn(CROP_TYPES)
    .withMessage('Please select a valid crop type'),
  
  body('plantingDate')
    .optional()
    .isISO8601()
    .withMessage('Planting date must be a valid date'),
  
  body('expectedHarvestDate')
    .optional()
    .isISO8601()
    .withMessage('Expected harvest date must be a valid date'),
];

// Sensor validation rules
export const validateSensorCreation: ValidationChain[] = [
  body('sensorId')
    .matches(/^[A-Z0-9_-]+$/)
    .withMessage('Sensor ID can only contain uppercase letters, numbers, underscores, and hyphens')
    .isLength({ min: 3, max: 50 })
    .withMessage('Sensor ID must be between 3 and 50 characters'),
  
  body('name')
    .isLength({ min: 2, max: 100 })
    .withMessage('Sensor name must be between 2 and 100 characters')
    .trim(),
  
  body('type')
    .isIn(['DHT11', 'Soil_Moisture', 'LDR', 'pH_Sensor', 'Multi_Sensor'])
    .withMessage('Invalid sensor type'),
  
  body('farm')
    .isMongoId()
    .withMessage('Farm ID must be a valid MongoDB ObjectId'),
  
  body('location.coordinates')
    .isArray({ min: 2, max: 2 })
    .withMessage('Coordinates must be an array of [longitude, latitude]'),
  
  body('location.coordinates.*')
    .isFloat()
    .withMessage('Coordinates must be valid numbers'),
  
  body('specifications.model')
    .isLength({ min: 2, max: 100 })
    .withMessage('Sensor model must be between 2 and 100 characters')
    .trim(),
];

// Sensor reading validation rules
export const validateSensorReading: ValidationChain[] = [
  body('sensor')
    .isMongoId()
    .withMessage('Sensor ID must be a valid MongoDB ObjectId'),
  
  body('farm')
    .isMongoId()
    .withMessage('Farm ID must be a valid MongoDB ObjectId'),
  
  body('timestamp')
    .optional()
    .isISO8601()
    .withMessage('Timestamp must be a valid date'),
  
  body('data.temperature')
    .optional()
    .isFloat({ min: -50, max: 100 })
    .withMessage('Temperature must be between -50°C and 100°C'),
  
  body('data.humidity')
    .optional()
    .isFloat({ min: 0, max: 100 })
    .withMessage('Humidity must be between 0% and 100%'),
  
  body('data.soilMoisture')
    .optional()
    .isFloat({ min: 0, max: 100 })
    .withMessage('Soil moisture must be between 0% and 100%'),
  
  body('data.lightIntensity')
    .optional()
    .isFloat({ min: 0 })
    .withMessage('Light intensity must be a positive number'),
  
  body('data.pH')
    .optional()
    .isFloat({ min: 0, max: 14 })
    .withMessage('pH must be between 0 and 14'),
  
  body('data.batteryLevel')
    .optional()
    .isFloat({ min: 0, max: 100 })
    .withMessage('Battery level must be between 0% and 100%'),
  
  body('data.signalStrength')
    .optional()
    .isFloat({ min: -120, max: 0 })
    .withMessage('Signal strength must be between -120 and 0 dBm'),
];

// Parameter validation
export const validateObjectId = (paramName: string): ValidationChain => 
  param(paramName)
    .isMongoId()
    .withMessage(`${paramName} must be a valid MongoDB ObjectId`);

export const validatePagination: ValidationChain[] = [
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  
  query('sort')
    .optional()
    .isIn(['createdAt', '-createdAt', 'updatedAt', '-updatedAt', 'name', '-name'])
    .withMessage('Invalid sort parameter'),
];

export const validateDateRange: ValidationChain[] = [
  query('startDate')
    .optional()
    .isISO8601()
    .withMessage('Start date must be a valid ISO 8601 date'),
  
  query('endDate')
    .optional()
    .isISO8601()
    .withMessage('End date must be a valid ISO 8601 date'),
];

// Password validation
export const validatePasswordReset: ValidationChain[] = [
  body('email')
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),
];

export const validatePasswordChange: ValidationChain[] = [
  body('currentPassword')
    .notEmpty()
    .withMessage('Current password is required'),
  
  body('newPassword')
    .isLength({ min: VALIDATION_RULES.PASSWORD.MIN_LENGTH })
    .withMessage(`Password must be at least ${VALIDATION_RULES.PASSWORD.MIN_LENGTH} characters long`)
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .withMessage('Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'),
  
  body('confirmPassword')
    .custom((value, { req }) => {
      if (value !== req.body.newPassword) {
        throw new Error('Password confirmation does not match');
      }
      return true;
    }),
];

// 2FA token validation
export const validate2FAToken: ValidationChain[] = [
  body('token')
    .matches(/^\d{6}$/)
    .withMessage('2FA token must be a 6-digit number'),
];

// Email OTP validation
export const validateEmailOTP: ValidationChain[] = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
];

export const validateOTPVerification: ValidationChain[] = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
  body('otp')
    .matches(/^\d{6}$/)
    .withMessage('OTP must be a 6-digit number'),
];

// File upload validation
export const validateFileUpload = (req: Request & { file?: Express.Multer.File; files?: Express.Multer.File[] }, res: Response, next: NextFunction): void => {
  if (!req.file && !req.files) {
    res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'No file uploaded',
    });
    return;
  }

  const file = req.file || (Array.isArray(req.files) ? req.files[0] : undefined);
  
  if (!file) {
    res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Invalid file upload',
    });
    return;
  }

  // Check file size (5MB limit)
  if (file.size > 5 * 1024 * 1024) {
    res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'File size exceeds 5MB limit',
    });
    return;
  }

  // Check file type
  const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'application/pdf'];
  if (!allowedTypes.includes(file.mimetype)) {
    res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Invalid file type. Only JPEG, PNG, WebP, and PDF files are allowed',
    });
    return;
  }

  next();
};

// Custom validation middleware factory
export const createCustomValidation = (validationFn: (value: any, req: Request) => boolean | Promise<boolean>, message: string) => {
  return (field: string) => 
    body(field).custom(async (value, { req }) => {
      const isValid = await validationFn(value, req as Request);
      if (!isValid) {
        throw new Error(message);
      }
      return true;
    });
};

export default {
  handleValidationErrors,
  validateUserRegistration,
  validateUserLogin,
  validateUserUpdate,
  validateFarmCreation,
  validateSensorCreation,
  validateSensorReading,
  validateObjectId,
  validatePagination,
  validateDateRange,
  validatePasswordReset,
  validatePasswordChange,
  validate2FAToken,
  validateFileUpload,
  createCustomValidation,
};

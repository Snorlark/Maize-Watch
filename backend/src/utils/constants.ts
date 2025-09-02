// HTTP Status Codes
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  UNPROCESSABLE_ENTITY: 422,
  TOO_MANY_REQUESTS: 429,
  INTERNAL_SERVER_ERROR: 500,
  SERVICE_UNAVAILABLE: 503,
} as const;

// User Roles
export const USER_ROLES = {
  USER: 'user',
  ADMIN: 'admin',
  SUPER_ADMIN: 'super_admin',
} as const;

// Sensor Types
export const SENSOR_TYPES = {
  DHT11: 'DHT11',
  SOIL_MOISTURE: 'Soil_Moisture',
  LDR: 'LDR',
  PH_SENSOR: 'pH_Sensor',
  MULTI_SENSOR: 'Multi_Sensor',
} as const;

// Sensor Status
export const SENSOR_STATUS = {
  ACTIVE: 'active',
  INACTIVE: 'inactive',
  MAINTENANCE: 'maintenance',
  ERROR: 'error',
} as const;

// Farm Status
export const FARM_STATUS = {
  ACTIVE: 'active',
  INACTIVE: 'inactive',
  HARVESTED: 'harvested',
  PREPARING: 'preparing',
} as const;

// Data Quality Levels
export const DATA_QUALITY = {
  GOOD: 'good',
  FAIR: 'fair',
  POOR: 'poor',
  ERROR: 'error',
} as const;

// Alert Severity Levels
export const ALERT_SEVERITY = {
  LOW: 'low',
  MEDIUM: 'medium',
  HIGH: 'high',
  CRITICAL: 'critical',
} as const;

// Philippine Regions
export const PHILIPPINE_REGIONS = [
  'National Capital Region (NCR)',
  'Cordillera Administrative Region (CAR)',
  'Ilocos Region (Region I)',
  'Cagayan Valley (Region II)',
  'Central Luzon (Region III)',
  'CALABARZON (Region IV-A)',
  'MIMAROPA Region (Region IV-B)',
  'Bicol Region (Region V)',
  'Western Visayas (Region VI)',
  'Central Visayas (Region VII)',
  'Eastern Visayas (Region VIII)',
  'Zamboanga Peninsula (Region IX)',
  'Northern Mindanao (Region X)',
  'Davao Region (Region XI)',
  'SOCCSKSARGEN (Region XII)',
  'Caraga (Region XIII)',
  'Bangsamoro Autonomous Region in Muslim Mindanao (BARMM)',
] as const;

// Crop Types
export const CROP_TYPES = [
  'Corn',
  'Rice',
  'Wheat',
  'Sugarcane',
  'Coconut',
  'Banana',
  'Mango',
  'Vegetables',
  'Other',
] as const;

// File Upload Constants
export const UPLOAD_LIMITS = {
  MAX_FILE_SIZE: 5 * 1024 * 1024, // 5MB
  ALLOWED_IMAGE_TYPES: ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'],
  ALLOWED_DOCUMENT_TYPES: ['application/pdf', 'text/plain'],
  MAX_FILES_PER_UPLOAD: 10,
} as const;

// Rate Limiting
export const RATE_LIMITS = {
  GENERAL: {
    WINDOW_MS: 15 * 60 * 1000, // 15 minutes
    MAX_REQUESTS: 100,
  },
  AUTH: {
    WINDOW_MS: 15 * 60 * 1000, // 15 minutes
    MAX_REQUESTS: 5,
  },
  API: {
    WINDOW_MS: 60 * 1000, // 1 minute
    MAX_REQUESTS: 60,
  },
} as const;

// JWT Constants
export const JWT_CONSTANTS = {
  ACCESS_TOKEN_EXPIRY: '15m',
  REFRESH_TOKEN_EXPIRY: '7d',
  ISSUER: 'maize-watch-api',
  AUDIENCE: 'maize-watch-client',
} as const;

// Cache Keys
export const CACHE_KEYS = {
  USER_PROFILE: (userId: string) => `user:profile:${userId}`,
  FARM_DATA: (farmId: string) => `farm:data:${farmId}`,
  SENSOR_READINGS: (sensorId: string) => `sensor:readings:${sensorId}`,
  ANALYTICS_DATA: (farmId: string, period: string) => `analytics:${farmId}:${period}`,
  WEATHER_DATA: (location: string) => `weather:${location}`,
} as const;

// Cache TTL (Time To Live) in seconds
export const CACHE_TTL = {
  SHORT: 5 * 60, // 5 minutes
  MEDIUM: 30 * 60, // 30 minutes
  LONG: 2 * 60 * 60, // 2 hours
  VERY_LONG: 24 * 60 * 60, // 24 hours
} as const;

// Email Templates
export const EMAIL_TEMPLATES = {
  WELCOME: 'welcome',
  PASSWORD_RESET: 'password-reset',
  EMAIL_VERIFICATION: 'email-verification',
  ALERT_NOTIFICATION: 'alert-notification',
  WEEKLY_REPORT: 'weekly-report',
} as const;

// Notification Types
export const NOTIFICATION_TYPES = {
  SENSOR_ALERT: 'sensor_alert',
  SYSTEM_MAINTENANCE: 'system_maintenance',
  WEATHER_WARNING: 'weather_warning',
  HARVEST_REMINDER: 'harvest_reminder',
  CALIBRATION_DUE: 'calibration_due',
  BATTERY_LOW: 'battery_low',
} as const;

// API Response Messages
export const RESPONSE_MESSAGES = {
  SUCCESS: {
    CREATED: 'Resource created successfully',
    UPDATED: 'Resource updated successfully',
    DELETED: 'Resource deleted successfully',
    RETRIEVED: 'Resource retrieved successfully',
  },
  ERROR: {
    NOT_FOUND: 'Resource not found',
    UNAUTHORIZED: 'Unauthorized access',
    FORBIDDEN: 'Access forbidden',
    VALIDATION_ERROR: 'Validation error',
    INTERNAL_ERROR: 'Internal server error',
    DUPLICATE_ENTRY: 'Resource already exists',
    INVALID_CREDENTIALS: 'Invalid credentials',
    ACCOUNT_LOCKED: 'Account is temporarily locked',
    EMAIL_NOT_VERIFIED: 'Email address not verified',
  },
} as const;

// Validation Rules
export const VALIDATION_RULES = {
  PASSWORD: {
    MIN_LENGTH: 8,
    MAX_LENGTH: 128,
    REQUIRE_UPPERCASE: true,
    REQUIRE_LOWERCASE: true,
    REQUIRE_NUMBERS: true,
    REQUIRE_SPECIAL_CHARS: true,
  },
  USERNAME: {
    MIN_LENGTH: 3,
    MAX_LENGTH: 30,
    PATTERN: /^[a-zA-Z0-9_]+$/,
  },
  PHONE: {
    PATTERN: /^(09\d{9}|\+639\d{9})$/,
  },
  EMAIL: {
    PATTERN: /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/,
  },
} as const;

// ThingSpeak Configuration
export const THINGSPEAK_CONFIG = {
  BASE_URL: 'https://api.thingspeak.com',
  RATE_LIMIT_DELAY: 15000, // 15 seconds between requests
  MAX_RETRIES: 3,
  TIMEOUT: 10000, // 10 seconds
} as const;

// Analytics Intervals
export const ANALYTICS_INTERVALS = {
  HOUR: 'hour',
  DAY: 'day',
  WEEK: 'week',
  MONTH: 'month',
} as const;

// Default Sensor Thresholds
export const DEFAULT_THRESHOLDS = {
  TEMPERATURE: { MIN: 15, MAX: 35 }, // Celsius
  HUMIDITY: { MIN: 40, MAX: 80 }, // Percentage
  SOIL_MOISTURE: { MIN: 30, MAX: 70 }, // Percentage
  PH: { MIN: 6.0, MAX: 7.5 },
  BATTERY_LEVEL: { MIN: 20 }, // Percentage
} as const;

// Environment Types
export const ENVIRONMENTS = {
  DEVELOPMENT: 'development',
  STAGING: 'staging',
  PRODUCTION: 'production',
  TEST: 'test',
} as const;

export default {
  HTTP_STATUS,
  USER_ROLES,
  SENSOR_TYPES,
  SENSOR_STATUS,
  FARM_STATUS,
  DATA_QUALITY,
  ALERT_SEVERITY,
  PHILIPPINE_REGIONS,
  CROP_TYPES,
  UPLOAD_LIMITS,
  RATE_LIMITS,
  JWT_CONSTANTS,
  CACHE_KEYS,
  CACHE_TTL,
  EMAIL_TEMPLATES,
  NOTIFICATION_TYPES,
  RESPONSE_MESSAGES,
  VALIDATION_RULES,
  THINGSPEAK_CONFIG,
  ANALYTICS_INTERVALS,
  DEFAULT_THRESHOLDS,
  ENVIRONMENTS,
};

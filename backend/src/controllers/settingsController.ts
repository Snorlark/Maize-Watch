import { Request, Response } from 'express';
import { catchAsync } from '../middleware/errorHandler';
import { HTTP_STATUS } from '../utils/constants';
import { logger } from '../utils/logger';
import * as fs from 'fs';
import * as path from 'path';

// Function to check if sensors are in sleep mode (8pm-3am PH time)
function checkSensorSleepMode(now: Date): boolean {
  // Convert to Philippines time (UTC+8)
  const phTime = new Date(now.getTime() + (8 * 60 * 60 * 1000));
  const hour = phTime.getUTCHours();
  
  // Sleep mode is active from 8pm (20:00) to 3am (03:00) PH time
  return hour >= 20 || hour < 3;
}

// Mock settings data - in production this would come from database
const defaultSettings = {
  notificationsEnabled: true,
  vibrationOnly: false,
  language: 'en',
  sensorStatus: {
    ldr: false,
    ph: false,
    dht: false,
    soil: false,
  },
  darkMode: false,
  autoSync: true,
  syncInterval: 30,
  dataCollectionEnabled: true,
  analyticsEnabled: true,
};

// File-based storage for user settings (in production, this would be a database)
const SETTINGS_FILE = path.join(__dirname, '../../data/user_settings.json');

// Helper functions for file-based storage
function loadUserSettings(): Record<string, any> {
  try {
    if (fs.existsSync(SETTINGS_FILE)) {
      const data = fs.readFileSync(SETTINGS_FILE, 'utf8');
      return JSON.parse(data);
    }
  } catch (error) {
    logger.error('Error loading user settings:', error);
  }
  return {};
}

function saveUserSettings(settings: Record<string, any>): void {
  try {
    // Ensure directory exists
    const dir = path.dirname(SETTINGS_FILE);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(SETTINGS_FILE, JSON.stringify(settings, null, 2));
  } catch (error) {
    logger.error('Error saving user settings:', error);
  }
}

export const getSettings = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;
  
  logger.info(`Getting settings for user: ${currentUser.id}`);

  // Load all user settings from file
  const allUserSettings = loadUserSettings();
  
  // Get user-specific settings or return default if not found
  const userSettingsData = allUserSettings[currentUser.id] || { ...defaultSettings };
  
  logger.info(`Returning settings for user ${currentUser.id}:`, userSettingsData);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: userSettingsData,
  });
});

export const updateSettings = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;
  const settings = req.body;

  logger.info(`Updating settings for user: ${currentUser.id}`, settings);

  // In production, update in database
  // For now, just return success
  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Settings updated successfully',
    data: settings,
  });
});

export const updateNotificationSettings = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;
  const { enabled, vibrationOnly } = req.body;

  logger.info(`Updating notification settings for user: ${currentUser.id}`, {
    enabled,
    vibrationOnly,
  });

  // Load all user settings from file
  const allUserSettings = loadUserSettings();
  
  // Get current user settings or create new ones
  const currentSettings = allUserSettings[currentUser.id] || { ...defaultSettings };
  
  // Update the notification settings
  currentSettings.notificationsEnabled = enabled;
  currentSettings.vibrationOnly = vibrationOnly;
  
  // Store the updated settings back to file
  allUserSettings[currentUser.id] = currentSettings;
  saveUserSettings(allUserSettings);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Notification settings updated successfully',
  });
});

export const updateLanguage = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;
  const { language } = req.body;

  logger.info(`Updating language for user: ${currentUser.id}`, { language });

  // Load all user settings from file
  const allUserSettings = loadUserSettings();
  
  // Get current user settings or create new ones
  const currentSettings = allUserSettings[currentUser.id] || { ...defaultSettings };
  
  // Update the language
  currentSettings.language = language;
  
  // Store the updated settings back to file
  allUserSettings[currentUser.id] = currentSettings;
  saveUserSettings(allUserSettings);
  
  logger.info(`Language updated for user ${currentUser.id}, new settings:`, currentSettings);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Language updated successfully',
  });
});

export const updateTheme = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;
  const { darkMode } = req.body;

  logger.info(`Updating theme for user: ${currentUser.id}`, { darkMode });

  // In production, update in database
  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Theme updated successfully',
  });
});

export const updateSyncSettings = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;
  const { autoSync, syncInterval } = req.body;

  logger.info(`Updating sync settings for user: ${currentUser.id}`, {
    autoSync,
    syncInterval,
  });

  // In production, update in database
  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Sync settings updated successfully',
  });
});

export const updateDataCollection = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;
  const { enabled } = req.body;

  logger.info(`Updating data collection for user: ${currentUser.id}`, { enabled });

  // In production, update in database
  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Data collection settings updated successfully',
  });
});

export const updateAnalytics = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;
  const { enabled } = req.body;

  logger.info(`Updating analytics for user: ${currentUser.id}`, { enabled });

  // In production, update in database
  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Analytics settings updated successfully',
  });
});

export const getSensorStatus = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;

  logger.info(`Getting sensor status for user: ${currentUser.id}`);

  try {
    // Import ThingSpeak service
    const thingSpeakService = (await import('../services/thingspeakService')).default;
    
    // Get latest data from ThingSpeak
    const latestData = await thingSpeakService.fetchLatestDataFromThingSpeakChannel(process.env.THINGSPEAK_CHANNEL_ID!);
    
    // Define 30 minutes in milliseconds
    const THIRTY_MINUTES = 30 * 60 * 1000;
    const now = new Date();
    
    // Check if sensors are in sleep mode (8pm-3am PH time)
    const isSleepMode = checkSensorSleepMode(now);
    
    // Check if data is recent (within 30 minutes)
    const isDataRecent = latestData && (now.getTime() - latestData.timestamp.getTime()) < THIRTY_MINUTES;
    
    // Determine sensor status based on data availability, recency, and sleep mode
    const sensorStatus = {
      // Temperature - field1
      temperature: !isSleepMode && isDataRecent && latestData && 
                  latestData.temperature !== null,
      
      // Humidity - field2
      humidity: !isSleepMode && isDataRecent && latestData && 
                latestData.humidity !== null,
      
      // Soil Moisture - field3
      soilMoisture: !isSleepMode && isDataRecent && latestData && 
                    latestData.soilMoisture !== null,
      
      // Soil pH - field4
      soilPh: !isSleepMode && isDataRecent && latestData && 
              latestData.soilPh !== null,
      
      // Light Intensity - field5
      lightIntensity: !isSleepMode && isDataRecent && latestData && 
                      latestData.lightIntensity !== null,
      
      // Sleep mode indicator
      sleepMode: isSleepMode,
    };

    logger.info(`Sensor status determined: ${JSON.stringify(sensorStatus)}`);
    logger.info(`Data recent: ${isDataRecent}, Latest data timestamp: ${latestData?.timestamp}`);

    res.status(HTTP_STATUS.OK).json({
      success: true,
      data: sensorStatus,
    });
  } catch (error) {
    logger.error('Error fetching sensor status from ThingSpeak:', error);
    
    // Return all sensors as inactive if ThingSpeak is unavailable
    const isSleepMode = checkSensorSleepMode(new Date());
    const sensorStatus = {
      temperature: false,
      humidity: false,
      soilMoisture: false,
      soilPh: false,
      lightIntensity: false,
      sleepMode: isSleepMode,
    };

    res.status(HTTP_STATUS.OK).json({
      success: true,
      data: sensorStatus,
    });
  }
});

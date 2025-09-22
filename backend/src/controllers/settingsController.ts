import { Request, Response } from 'express';
import { catchAsync } from '../middleware/errorHandler';
import { HTTP_STATUS } from '../utils/constants';
import { logger } from '../utils/logger';

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

export const getSettings = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;
  
  logger.info(`Getting settings for user: ${currentUser.id}`);

  // In production, fetch from database based on user ID
  // For now, return default settings
  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: defaultSettings,
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

  // In production, update in database
  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Notification settings updated successfully',
  });
});

export const updateLanguage = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;
  const { language } = req.body;

  logger.info(`Updating language for user: ${currentUser.id}`, { language });

  // In production, update in database
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

  // In production, fetch real sensor status from database
  // For now, return mock data
  const sensorStatus = {
    ldr: Math.random() > 0.5,
    ph: Math.random() > 0.5,
    dht: Math.random() > 0.5,
    soil: Math.random() > 0.5,
  };

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: sensorStatus,
  });
});

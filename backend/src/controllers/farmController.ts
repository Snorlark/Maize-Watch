import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import farmService from '../services/farmService';
import { AppError, catchAsync } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { HTTP_STATUS, USER_ROLES } from '../utils/constants';

/**
 * @desc    Create a new farm
 * @route   POST /api/farms
 * @access  Private
 */
export const createFarm = catchAsync(async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map((err: any) => ({
        field: err.param,
        message: err.msg
      }))
    });
  }

  const currentUser = (req as any).user;
  const farmData = {
    ...req.body,
    owner: currentUser.id
  };

  const farm = await farmService.createFarm(farmData);

  logger.info('Farm created', {
    farmId: farm._id,
    ownerId: currentUser.id,
    farmName: farm.name
  });

  res.status(HTTP_STATUS.CREATED).json({
    success: true,
    message: 'Farm created successfully',
    data: { farm }
  });
});

/**
 * @desc    Get all farms for current user
 * @route   GET /api/farms
 * @access  Private
 */
export const getFarms = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 10;

  let ownerId = currentUser.id;

  // Admins can view all farms or filter by owner
  if (currentUser.role === USER_ROLES.ADMIN || currentUser.role === USER_ROLES.SUPER_ADMIN) {
    if (req.query.owner) {
      ownerId = req.query.owner as string;
    } else if (req.query.all === 'true') {
      ownerId = undefined; // Get all farms
    }
  }

  const result = await farmService.getFarmsByOwner(ownerId, page, limit);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: {
      farms: result.farms,
      pagination: {
        current: page,
        pages: result.pages,
        total: result.total,
        limit
      }
    }
  });
});

/**
 * @desc    Get farm by ID
 * @route   GET /api/farms/:id
 * @access  Private
 */
export const getFarmById = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;

  const farm = await farmService.getFarmById(id);

  // Check if user owns the farm or is admin
  if (farm.owner._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { farm }
  });
});

/**
 * @desc    Update farm
 * @route   PUT /api/farms/:id
 * @access  Private
 */
export const updateFarm = catchAsync(async (req: Request, res: Response) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map((err: any) => ({
        field: err.param,
        message: err.msg
      }))
    });
  }

  const { id } = req.params;
  const currentUser = (req as any).user;
  const updateData = req.body;

  // Get farm to check ownership
  const existingFarm = await farmService.getFarmById(id);

  // Check if user owns the farm or is admin
  if (existingFarm.owner._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const farm = await farmService.updateFarm(id, updateData);

  logger.info('Farm updated', {
    farmId: farm._id,
    updatedBy: currentUser.id,
    updatedFields: Object.keys(updateData)
  });

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Farm updated successfully',
    data: { farm }
  });
});

/**
 * @desc    Delete farm
 * @route   DELETE /api/farms/:id
 * @access  Private
 */
export const deleteFarm = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;

  // Get farm to check ownership
  const existingFarm = await farmService.getFarmById(id);

  // Check if user owns the farm or is admin
  if (existingFarm.owner._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  await farmService.deleteFarm(id);

  logger.info('Farm deleted', {
    farmId: id,
    deletedBy: currentUser.id,
    farmName: existingFarm.name
  });

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Farm deleted successfully'
  });
});

/**
 * @desc    Get farm analytics
 * @route   GET /api/farms/:id/analytics
 * @access  Private
 */
export const getFarmAnalytics = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;
  const days = parseInt(req.query.days as string) || 7;

  // Get farm to check ownership
  const farm = await farmService.getFarmById(id);

  // Check if user owns the farm or is admin
  if (farm.owner._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const analytics = await farmService.getFarmAnalytics(id, days);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { analytics }
  });
});

/**
 * @desc    Update farm status
 * @route   PATCH /api/farms/:id/status
 * @access  Private
 */
export const updateFarmStatus = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const { status } = req.body;
  const currentUser = (req as any).user;

  if (!status) {
    throw new AppError('Status is required', HTTP_STATUS.BAD_REQUEST);
  }

  // Get farm to check ownership
  const existingFarm = await farmService.getFarmById(id);

  // Check if user owns the farm or is admin
  if (existingFarm.owner._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const farm = await farmService.updateFarmStatus(id, status);

  logger.info('Farm status updated', {
    farmId: farm._id,
    updatedBy: currentUser.id,
    newStatus: status
  });

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Farm status updated successfully',
    data: { farm }
  });
});

/**
 * @desc    Add images to farm
 * @route   POST /api/farms/:id/images
 * @access  Private
 */
export const addFarmImages = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const { imageUrls } = req.body;
  const currentUser = (req as any).user;

  if (!imageUrls || !Array.isArray(imageUrls) || imageUrls.length === 0) {
    throw new AppError('Image URLs are required', HTTP_STATUS.BAD_REQUEST);
  }

  // Get farm to check ownership
  const existingFarm = await farmService.getFarmById(id);

  // Check if user owns the farm or is admin
  if (existingFarm.owner._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const farm = await farmService.addFarmImages(id, imageUrls);

  logger.info('Farm images added', {
    farmId: farm._id,
    addedBy: currentUser.id,
    imageCount: imageUrls.length
  });

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Images added successfully',
    data: { farm }
  });
});

/**
 * @desc    Update farm weather data
 * @route   PUT /api/farms/:id/weather
 * @access  Private
 */
export const updateWeatherData = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const weatherData = req.body;
  const currentUser = (req as any).user;

  // Get farm to check ownership
  const existingFarm = await farmService.getFarmById(id);

  // Check if user owns the farm or is admin
  if (existingFarm.owner._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const farm = await farmService.updateWeatherData(id, weatherData);

  logger.info('Farm weather data updated', {
    farmId: farm._id,
    updatedBy: currentUser.id
  });

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Weather data updated successfully',
    data: { farm }
  });
});

/**
 * @desc    Update farm soil data
 * @route   PUT /api/farms/:id/soil
 * @access  Private
 */
export const updateSoilData = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const soilData = req.body;
  const currentUser = (req as any).user;

  // Get farm to check ownership
  const existingFarm = await farmService.getFarmById(id);

  // Check if user owns the farm or is admin
  if (existingFarm.owner._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const farm = await farmService.updateSoilData(id, soilData);

  logger.info('Farm soil data updated', {
    farmId: farm._id,
    updatedBy: currentUser.id
  });

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Soil data updated successfully',
    data: { farm }
  });
});

/**
 * @desc    Get farms near location
 * @route   GET /api/farms/nearby
 * @access  Private/Admin
 */
export const getFarmsNearby = catchAsync(async (req: Request, res: Response) => {
  const { longitude, latitude, maxDistance = 10000 } = req.query;

  if (!longitude || !latitude) {
    throw new AppError('Longitude and latitude are required', HTTP_STATUS.BAD_REQUEST);
  }

  const farms = await farmService.getFarmsNearLocation(
    parseFloat(longitude as string),
    parseFloat(latitude as string),
    parseInt(maxDistance as string)
  );

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { farms }
  });
});

/**
 * @desc    Get farm statistics
 * @route   GET /api/farms/stats
 * @access  Private/Admin
 */
export const getFarmStats = catchAsync(async (req: Request, res: Response) => {
  const stats = await farmService.getFarmStatistics();

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { stats }
  });
});

/**
 * @desc    Get harvest predictions
 * @route   GET /api/farms/:id/predictions
 * @access  Private
 */
export const getHarvestPredictions = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;

  // Get farm to check ownership
  const farm = await farmService.getFarmById(id);

  // Check if user owns the farm or is admin
  if (farm.owner._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const predictions = await farmService.getHarvestPredictions(id);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: { predictions }
  });
});

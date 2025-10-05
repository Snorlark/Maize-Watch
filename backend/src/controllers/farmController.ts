import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import farmService from '../services/farmService';
import { AppError, catchAsync } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { HTTP_STATUS, USER_ROLES } from '../utils/constants';
import Farm from '../models/Farm';


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
    farmName: farm.fieldName
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
  let regionalFilter: string | undefined;

  // Super admins automatically get access to all farms
  if (currentUser.role === USER_ROLES.SUPER_ADMIN) {
    ownerId = undefined; // Get all farms for super_admin
  } 
  // Regional admins can view farms from their assigned region
  else if (currentUser.role === USER_ROLES.REGIONAL_ADMIN) {
    if (!currentUser.assignedRegion) {
      throw new AppError('Regional admin must have an assigned region', HTTP_STATUS.FORBIDDEN);
    }
    ownerId = undefined; // Get all farms, but filter by region
    regionalFilter = currentUser.assignedRegion;
  }
  // Regular admins can view all farms with query parameter or filter by owner
  else if (currentUser.role === USER_ROLES.ADMIN) {
    if (req.query.owner) {
      ownerId = req.query.owner as string;
    } else if (req.query.all === 'true') {
      ownerId = undefined; // Get all farms
    }
  }

  const farms = await farmService.getFarmsByOwner(ownerId, regionalFilter);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    data: {
      farms,
      pagination: {
        page,
        pages: Math.ceil(farms.length / limit),
        total: farms.length,
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

  logger.info(`GET /api/farms/${id} - Request received from user: ${currentUser.id}, role: ${currentUser.role}`);

  const farm = await farmService.getFarmById(id);
  
  logger.info(`Farm owner: ${farm.userId}, requesting user: ${currentUser.id}`);
  logger.info(`Farm data: ${JSON.stringify(farm, null, 2)}`);

  // Check if user owns the farm or is admin
  const farmUserId = farm.userId._id ? farm.userId._id.toString() : farm.userId.toString();
  logger.info(`Access control check: farmUserId=${farmUserId}, currentUser.id=${currentUser.id}, currentUser.role=${currentUser.role}`);
  
  const isOwner = farmUserId === currentUser.id;
  const isAdmin = currentUser.role === USER_ROLES.ADMIN || currentUser.role === USER_ROLES.SUPER_ADMIN;
  
  logger.info(`Access control: isOwner=${isOwner}, isAdmin=${isAdmin}`);
  
  if (!isOwner && !isAdmin) {
    logger.warn(`Access denied: User ${currentUser.id} cannot access farm ${farm._id}`);
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }
  
  logger.info(`Access granted: User ${currentUser.id} can access farm ${farm._id}`);

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
  const existingFarmUserId = existingFarm.userId._id ? existingFarm.userId._id.toString() : existingFarm.userId.toString();
  if (existingFarmUserId !== currentUser.id && 
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
 * @desc    Get total number of farms
 * @route   GET /api/farms/count
 * @access  Private
 */
export const getTotalFarms = async (req: Request, res: Response) => {
  try {
    const currentUser = (req as any).user;
    let total;
    
    // For regional_admin, filter farms by users in their assigned region
    if (currentUser && currentUser.role === USER_ROLES.REGIONAL_ADMIN && currentUser.assignedRegion) {
      // First get users in the assigned region
      const User = require('../models/User').default;
      const usersInRegion = await User.find({
        $or: [
          { 'address.region': currentUser.assignedRegion },
          { address: { $regex: currentUser.assignedRegion.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), $options: 'i' } }
        ]
      }).select('_id');
      
      const userIds = usersInRegion.map((u: any) => u._id);
      
      // Count farms owned by users in this region
      total = await Farm.countDocuments({ userId: { $in: userIds } });
    } else {
      // For super_admin and admin, count all farms
      total = await Farm.countDocuments();
    }
    
    res.json({ total });
  } catch (err) {
    logger.error('Error fetching total farms:', err);
    res.status(500).json({ message: "Error fetching total farms" });
  }
};


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
  if (existingFarm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  await farmService.deleteFarm(id);

  logger.info('Farm deleted', {
    farmId: id,
    deletedBy: currentUser.id,
    farmName: existingFarm.fieldName
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
  if (farm.userId._id.toString() !== currentUser.id && 
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
  if (existingFarm.userId.toString() !== currentUser.id && 
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
  if (existingFarm.userId.toString() !== currentUser.id && 
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
 * @desc    Link device to farm
 * @route   POST /api/farms/:id/link-device
 * @access  Private
 */
export const linkDeviceToFarm = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const { deviceId, macAddress } = req.body;
  const currentUser = (req as any).user;

  if (!deviceId) {
    throw new AppError('Device ID is required', HTTP_STATUS.BAD_REQUEST);
  }

  // Get farm to check ownership
  const existingFarm = await farmService.getFarmById(id);

  // Check if user owns the farm or is admin
  if (existingFarm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const farm = await farmService.linkDeviceToFarm(id, deviceId, macAddress);

  logger.info('Device linked to farm', {
    farmId: farm._id,
    deviceId,
    linkedBy: currentUser.id
  });

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Device linked successfully',
    data: { farm }
  });
});

/**
 * @desc    Unlink device from farm
 * @route   DELETE /api/farms/:id/unlink-device
 * @access  Private
 */
export const unlinkDeviceFromFarm = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;

  // Get farm to check ownership
  const existingFarm = await farmService.getFarmById(id);

  // Check if user owns the farm or is admin
  if (existingFarm.userId.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const farm = await farmService.unlinkDeviceFromFarm(id);

  logger.info('Device unlinked from farm', {
    farmId: farm._id,
    unlinkedBy: currentUser.id
  });

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Device unlinked successfully',
    data: { farm }
  });
});

/**
 * @desc    Get farm by device ID
 * @route   GET /api/farms/device/:deviceId
 * @access  Private
 */
export const getFarmByDeviceId = catchAsync(async (req: Request, res: Response) => {
  const { deviceId } = req.params;
  const currentUser = (req as any).user;

  const farm = await farmService.getFarmByDeviceId(deviceId);

  if (!farm) {
    throw new AppError('No farm found for this device', HTTP_STATUS.NOT_FOUND);
  }

  // Check if user owns the farm or is admin
  if (farm.userId._id.toString() !== currentUser.id && 
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
 * @desc    Get farms by location (region/province/municipality)
 * @route   GET /api/farms/location
 * @access  Private/Admin
 */
export const getFarmsByLocation = catchAsync(async (req: Request, res: Response) => {
  const { region, province, municipality } = req.query;

  const farms = await farmService.getFarmsByLocation(
    region as string,
    province as string,
    municipality as string
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
 * @desc    Get corn harvest predictions
 * @route   GET /api/farms/:id/predictions
 * @access  Private
 */
export const getHarvestPredictions = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;

  // Get farm to check ownership
  const farm = await farmService.getFarmById(id);

  // Check if user owns the farm or is admin
  if (farm.userId._id.toString() !== currentUser.id && 
      currentUser.role !== USER_ROLES.ADMIN && 
      currentUser.role !== USER_ROLES.SUPER_ADMIN) {
    throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
  }

  const predictions = await farmService.getHarvestPredictions(id);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Corn harvest predictions retrieved successfully',
    data: { predictions }
  });
});

/**
 * @desc    Create simple farm (for mobile registration)
 * @route   POST /api/farms/simple
 * @access  Private
 */
export const createSimpleFarm = catchAsync(async (req: Request, res: Response) => {
  const currentUser = (req as any).user;
  
  // Use user's address from registration
  const farmData = {
    userId: currentUser.id,
    fieldName: req.body.name || req.body.fieldName,
    location: `${req.body.address?.municipality || ''}, ${req.body.address?.province || ''}`.trim(),
    soilType: req.body.soilType || 'Loam',
    plantingDate: req.body.plantingDate,
    growthStage: req.body.growthStage || 'VE',
    deviceId: req.body.deviceId,
    deviceMacAddress: req.body.deviceMacAddress
  };

  const farm = await farmService.createFarm(farmData);

  logger.info('Simple farm created', {
    farmId: farm._id,
    ownerId: currentUser.id,
    farmName: farm.fieldName
  });

  res.status(HTTP_STATUS.CREATED).json({
    success: true,
    message: 'Farm created successfully',
    data: { farm }
  });
});

import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import fieldService from '../services/fieldService';
import farmService from '../services/farmService';
import { AppError, catchAsync } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { HTTP_STATUS, USER_ROLES } from '../utils/constants';

class FieldController {
  /**
   * Create a new field with farm and devices
   */
  createField = catchAsync(async (req: Request, res: Response) => {
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
    const { fieldName, soilType, plantingDate, devices, location, userData } = req.body;

    // First create or get the farm
    let farm;
    try {
      // Try to get existing farm for user
      const existingFarms = await farmService.getFarmsByOwner(currentUser.id);
      
      if (existingFarms && existingFarms.length > 0) {
        farm = existingFarms[0]; // Use first existing farm
      } else {
        // Create new farm
        const farmData = {
          userId: currentUser.id,
          farmName: `${userData?.fullName?.split(' ')[0] || 'User'}'s Farm`,
          location: location || 'Location not specified',
          description: `Farm with field: ${fieldName}`
        };
        farm = await farmService.createFarm(farmData);
      }
    } catch (error) {
      logger.error('Error creating/getting farm:', error);
      throw new AppError('Failed to create farm', HTTP_STATUS.INTERNAL_SERVER_ERROR);
    }

    // Create field data
    const fieldData = {
      farmId: (farm._id as any).toString(),
      fieldName,
      soilType,
      plantingDate: new Date(plantingDate),
      devices: devices?.map((device: any) => ({
        sensorId: device.deviceId,
        name: device.deviceName,
        deviceMacAddress: device.deviceMacAddress || undefined,
        status: 'active' as const,
        registeredAt: new Date(),
        location: {
          coordinates: [121.0244, 14.5995] as [number, number],
          description: 'Field sensor location'
        }
      })) || []
    };

    const field = await fieldService.createField(fieldData);

    logger.info('Field created successfully', {
      fieldId: field._id,
      farmId: farm._id,
      userId: currentUser.id,
      deviceCount: devices?.length || 0
    });

    res.status(HTTP_STATUS.CREATED).json({
      success: true,
      message: 'Field created successfully',
      data: { field, farm }
    });
  });

  /**
   * Get field by ID
   */
  getFieldById = catchAsync(async (req: Request, res: Response) => {
    const { fieldId } = req.params;
    const currentUser = (req as any).user;
    
    const field = await fieldService.getFieldById(fieldId);
    
    // Check if user owns the field's farm or is admin
    const farm = await farmService.getFarmById(field.farmId.toString());
    if (farm.userId._id.toString() !== currentUser.id && 
        currentUser.role !== USER_ROLES.ADMIN && 
        currentUser.role !== USER_ROLES.SUPER_ADMIN) {
      throw new AppError('Access denied', HTTP_STATUS.FORBIDDEN);
    }
    
    res.status(HTTP_STATUS.OK).json({
      success: true,
      data: field
    });
  });

  /**
   * Get fields by farm ID
   */
  async getFieldsByFarmId(req: Request, res: Response): Promise<void> {
    try {
      const { farmId } = req.params;
      const fields = await fieldService.getFieldsByFarmId(farmId);
      
      res.status(200).json({
        success: true,
        data: fields
      });
    } catch (error) {
      logger.error('Error in getFieldsByFarmId controller:', error);
      if (error instanceof AppError) {
        res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      } else {
        res.status(500).json({
          success: false,
          message: 'Internal server error'
        });
      }
    }
  }

  /**
   * Update field
   */
  async updateField(req: Request, res: Response): Promise<void> {
    try {
      const { fieldId } = req.params;
      const updateData = req.body;
      const field = await fieldService.updateField(fieldId, updateData);
      
      res.status(200).json({
        success: true,
        message: 'Field updated successfully',
        data: field
      });
    } catch (error) {
      logger.error('Error in updateField controller:', error);
      if (error instanceof AppError) {
        res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      } else {
        res.status(500).json({
          success: false,
          message: 'Internal server error'
        });
      }
    }
  }

  /**
   * Delete field
   */
  async deleteField(req: Request, res: Response): Promise<void> {
    try {
      const { fieldId } = req.params;
      await fieldService.deleteField(fieldId);
      
      res.status(200).json({
        success: true,
        message: 'Field deleted successfully'
      });
    } catch (error) {
      logger.error('Error in deleteField controller:', error);
      if (error instanceof AppError) {
        res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      } else {
        res.status(500).json({
          success: false,
          message: 'Internal server error'
        });
      }
    }
  }

  /**
   * Get field analytics
   */
  async getFieldAnalytics(req: Request, res: Response): Promise<void> {
    try {
      const { fieldId } = req.params;
      const { days = 7 } = req.query;
      const analytics = await fieldService.getFieldAnalytics(fieldId, Number(days));
      
      res.status(200).json({
        success: true,
        data: analytics
      });
    } catch (error) {
      logger.error('Error in getFieldAnalytics controller:', error);
      if (error instanceof AppError) {
        res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      } else {
        res.status(500).json({
          success: false,
          message: 'Internal server error'
        });
      }
    }
  }

  /**
   * Add device to field
   */
  async addDeviceToField(req: Request, res: Response): Promise<void> {
    try {
      const { fieldId } = req.params;
      const deviceData = req.body;
      const field = await fieldService.addDeviceToField(fieldId, deviceData);
      
      res.status(200).json({
        success: true,
        message: 'Device added to field successfully',
        data: field
      });
    } catch (error) {
      logger.error('Error in addDeviceToField controller:', error);
      if (error instanceof AppError) {
        res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      } else {
        res.status(500).json({
          success: false,
          message: 'Internal server error'
        });
      }
    }
  }

  /**
   * Remove device from field
   */
  async removeDeviceFromField(req: Request, res: Response): Promise<void> {
    try {
      const { fieldId, deviceId } = req.params;
      const field = await fieldService.removeDeviceFromField(fieldId, deviceId);
      
      res.status(200).json({
        success: true,
        message: 'Device removed from field successfully',
        data: field
      });
    } catch (error) {
      logger.error('Error in removeDeviceFromField controller:', error);
      if (error instanceof AppError) {
        res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      } else {
        res.status(500).json({
          success: false,
          message: 'Internal server error'
        });
      }
    }
  }

  /**
   * Get harvest predictions for field
   */
  async getHarvestPredictions(req: Request, res: Response): Promise<void> {
    try {
      const { fieldId } = req.params;
      const predictions = await fieldService.getHarvestPredictions(fieldId);
      
      res.status(200).json({
        success: true,
        data: predictions
      });
    } catch (error) {
      logger.error('Error in getHarvestPredictions controller:', error);
      if (error instanceof AppError) {
        res.status(error.statusCode).json({
          success: false,
          message: error.message
        });
      } else {
        res.status(500).json({
          success: false,
          message: 'Internal server error'
        });
      }
    }
  }
}

const fieldController = new FieldController();
export default fieldController;

import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import { AppError, catchAsync } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { HTTP_STATUS, USER_ROLES } from '../utils/constants';
import Prescription from '../models/Prescription';
import mongoose from 'mongoose';
import PrescriptionSyncService from '../services/prescriptionSyncService';

/**
 * @desc    Get prescriptions for a farm
 * @route   GET /api/prescriptions/farm/:farmId
 * @access  Private
 */
export const getPrescriptions = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const currentUser = (req as any).user;

  try {
    console.log('🔍 Prescription Controller - Fetching prescriptions for farm:', farmId);
    
    // Convert farmId to ObjectId
    const farmObjectId = new mongoose.Types.ObjectId(farmId);
    
    // Try to get prescriptions from database first
    let prescriptions = await Prescription.find({ farmId: farmObjectId }).sort({ createdAt: -1 });
    
    // If no prescriptions in database, generate some sample ones
    if (prescriptions.length === 0) {
      console.log('🔍 No prescriptions in database, generating sample prescriptions');
      
      // Fetch actual farm data to get real field names
      const Farm = require('../models/Farm');
      const farm = await Farm.findById(farmObjectId);
      
      if (!farm || !farm.fields || farm.fields.length === 0) {
        console.log('🔍 No farm or fields found, using fallback field names');
        // Fallback to default field names if no farm data
        const samplePrescriptions = [
          {
            farmId: farmObjectId,
            title: 'Check Soil Moisture',
            description: 'Monitor soil moisture levels and irrigate if needed. Optimal range is 30-70% for most crops.',
            priority: 'high' as const,
            status: 'pending' as const,
            dueDate: new Date(Date.now() + 2 * 60 * 60 * 1000), // 2 hours from now
            category: 'irrigation',
            estimatedDuration: '30 minutes',
            materials: _getMaterialsForCategory('irrigation'),
            instructions: _getInstructionsForCategory('irrigation', 'Check soil moisture levels'),
            urgency: 'HIGH' as const,
            timeline: 'Today',
            parameter: 'soil_moisture',
            fieldName: 'Main Field',
            soilType: 'Loam',
            growthStage: 'V8'
          },
          {
            farmId: farmObjectId,
            title: 'Monitor Weather Conditions',
            description: 'Check current weather and forecast to plan farm activities accordingly.',
            priority: 'medium' as const,
            status: 'pending' as const,
            dueDate: new Date(Date.now() + 4 * 60 * 60 * 1000), // 4 hours from now
            category: 'weather',
            estimatedDuration: '15 minutes',
            materials: _getMaterialsForCategory('weather'),
            instructions: _getInstructionsForCategory('weather', 'Check weather forecast'),
            urgency: 'MEDIUM' as const,
            timeline: 'Today',
            parameter: 'weather',
            fieldName: 'Main Field',
            soilType: 'Loam',
            growthStage: 'V8'
          }
        ];
        
        // Save sample prescriptions to database
        prescriptions = await Prescription.insertMany(samplePrescriptions);
      } else {
        console.log('🔍 Found farm with fields:', farm.fields.map((f: any) => f.fieldName));
        
        // Generate prescriptions for each actual field
        const samplePrescriptions = [];
        
        for (const field of farm.fields) {
          console.log(`🔍 Generating prescriptions for field: ${field.fieldName}`);
          
          // Generate prescriptions for each field
          const fieldPrescriptions = [
            {
              farmId: farmObjectId,
              title: 'Check Soil Moisture',
              description: 'Monitor soil moisture levels and irrigate if needed. Optimal range is 30-70% for most crops.',
              priority: 'high' as const,
              status: 'pending' as const,
              dueDate: new Date(Date.now() + 2 * 60 * 60 * 1000), // 2 hours from now
              category: 'irrigation',
              estimatedDuration: '30 minutes',
              materials: _getMaterialsForCategory('irrigation'),
              instructions: _getInstructionsForCategory('irrigation', 'Check soil moisture levels'),
              urgency: 'HIGH' as const,
              timeline: 'Today',
              parameter: 'soil_moisture',
              fieldName: field.fieldName,
              soilType: field.sensors?.[0]?.soilType || 'Loam',
              growthStage: field.growthStage || 'V8'
            },
            {
              farmId: farmObjectId,
              title: 'Monitor Weather Conditions',
              description: 'Check current weather and forecast to plan farm activities accordingly.',
              priority: 'medium' as const,
              status: 'pending' as const,
              dueDate: new Date(Date.now() + 4 * 60 * 60 * 1000), // 4 hours from now
              category: 'weather',
              estimatedDuration: '15 minutes',
              materials: _getMaterialsForCategory('weather'),
              instructions: _getInstructionsForCategory('weather', 'Check weather forecast'),
              urgency: 'MEDIUM' as const,
              timeline: 'Today',
              parameter: 'weather',
              fieldName: field.fieldName,
              soilType: field.sensors?.[0]?.soilType || 'Loam',
              growthStage: field.growthStage || 'V8'
            }
          ];
          
          samplePrescriptions.push(...fieldPrescriptions);
        }
        
        // Save sample prescriptions to database
        prescriptions = await Prescription.insertMany(samplePrescriptions);
      }
    }

    logger.info(`Retrieved ${prescriptions.length} prescriptions for farm ${farmId}`);

    res.status(HTTP_STATUS.OK).json({
      success: true,
      data: prescriptions
    });
  } catch (error) {
    console.log('🚨 Prescription Controller - Error details:', error);
    logger.error('Error fetching prescriptions:', error);
    
    // Return fallback prescriptions on error
    const fallbackPrescriptions = [
      {
        id: 'error_fallback_1',
        farmId: farmId,
        title: 'System Check Required',
        description: 'Unable to generate recommendations. Please check your farm setup.',
        priority: 'medium',
        status: 'pending',
        dueDate: new Date(Date.now() + 24 * 60 * 60 * 1000),
        createdAt: new Date(),
        updatedAt: new Date(),
        category: 'system',
        estimatedDuration: '1 hour',
        materials: ['System access'],
        instructions: [
          'Check farm configuration',
          'Verify sensor connections',
          'Contact support if needed'
        ],
        urgency: 'MEDIUM',
        timeline: 'Today',
        parameter: 'system',
        fieldName: 'Main Field',
        soilType: 'Unknown',
        growthStage: 'Unknown'
      }
    ];

    res.status(HTTP_STATUS.OK).json({
      success: true,
      data: fallbackPrescriptions
    });
  }
});

// Helper functions
function _getMaterialsForCategory(category: string): string[] {
  switch (category) {
    case 'irrigation':
      return ['Water', 'Irrigation system', 'Timer'];
    case 'soil_treatment':
      return ['Lime or Sulfur', 'Spreader', 'Protective gear'];
    case 'temperature_management':
      return ['Thermal blankets', 'Heating equipment', 'Thermometer'];
    case 'humidity_management':
      return ['Ventilation fans', 'Misting system', 'Hygrometer'];
    case 'light_management':
      return ['LED grow lights', 'Timer', 'Light meter'];
    case 'pest_management':
      return ['Pest traps', 'Pheromone lures', 'Pesticides'];
    case 'fertilization':
      return ['Fertilizer', 'Spreader', 'Protective gear'];
    default:
      return ['Basic tools', 'Safety equipment'];
  }
}

function _getInstructionsForCategory(category: string, details: string): string[] {
  const baseInstructions = details ? [details] : [];
  
  switch (category) {
    case 'irrigation':
      return [
        ...baseInstructions,
        'Check soil moisture levels',
        'Adjust irrigation schedule',
        'Monitor plant response'
      ];
    case 'soil_treatment':
      return [
        ...baseInstructions,
        'Test soil pH levels',
        'Calculate required amount',
        'Apply evenly across field',
        'Water after application'
      ];
    case 'temperature_management':
      return [
        ...baseInstructions,
        'Check current temperature',
        'Install protection measures',
        'Monitor temperature changes'
      ];
    case 'humidity_management':
      return [
        ...baseInstructions,
        'Assess humidity levels',
        'Improve ventilation',
        'Monitor changes'
      ];
    case 'light_management':
      return [
        ...baseInstructions,
        'Measure light levels',
        'Install supplemental lighting',
        'Set proper timer schedule'
      ];
    case 'pest_management':
      return [
        ...baseInstructions,
        'Place traps strategically',
        'Check traps regularly',
        'Record pest counts'
      ];
    case 'fertilization':
      return [
        ...baseInstructions,
        'Test soil nutrients',
        'Select appropriate fertilizer',
        'Apply according to instructions'
      ];
    default:
      return [
        ...baseInstructions,
        'Assess current situation',
        'Gather necessary materials',
        'Follow safety procedures'
      ];
  }
}

/**
 * @desc    Sync analytics prescriptions with database
 * @route   POST /api/prescriptions/sync-analytics
 * @access  Private
 */
export const syncAnalyticsPrescriptions = catchAsync(async (req: Request, res: Response) => {
  const { farmId, prescriptions } = req.body;
  const currentUser = (req as any).user;

  try {
    console.log('🔄 Syncing analytics prescriptions for farm:', farmId);
    console.log('📊 Received prescriptions:', prescriptions.length);

    // Sync analytics prescriptions with database
    const syncedPrescriptions = await PrescriptionSyncService.syncAnalyticsPrescriptions(
      farmId,
      prescriptions
    );

    logger.info(`Synced ${syncedPrescriptions.length} analytics prescriptions for farm ${farmId}`);

    res.status(HTTP_STATUS.OK).json({
      success: true,
      message: 'Analytics prescriptions synced successfully',
      data: {
        prescriptions: syncedPrescriptions,
        count: syncedPrescriptions.length
      }
    });
  } catch (error) {
    logger.error('Error syncing analytics prescriptions:', error);
    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: 'Failed to sync analytics prescriptions'
    });
  }
});

/**
 * @desc    Update prescription status
 * @route   PUT /api/prescriptions/:id/status
 * @access  Private
 */
export const updatePrescriptionStatus = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const { status, fieldId } = req.body;
  const currentUser = (req as any).user;

  try {
    // Update prescription in database
    const updatedPrescription = await Prescription.findByIdAndUpdate(
      id,
      { 
        status,
        updatedAt: new Date(),
        completedBy: status === 'completed' ? currentUser.id : undefined,
        completedAt: status === 'completed' ? new Date() : undefined
      },
      { new: true }
    );

    if (!updatedPrescription) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({
        success: false,
        message: 'Prescription not found'
      });
    }

    logger.info(`Updated prescription ${id} status to ${status} by user ${currentUser.id}`);

    res.status(HTTP_STATUS.OK).json({
      success: true,
      message: 'Prescription status updated successfully',
      data: {
        id: updatedPrescription._id,
        status: updatedPrescription.status,
        updatedAt: updatedPrescription.updatedAt,
        completedBy: updatedPrescription.completedBy,
        completedAt: updatedPrescription.completedAt
      }
    });
  } catch (error) {
    logger.error('Error updating prescription status:', error);
    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: 'Failed to update prescription status'
    });
  }
});

/**
 * @desc    Delete prescription
 * @route   DELETE /api/prescriptions/:id
 * @access  Private
 */
export const deletePrescription = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;

  try {
    const deletedPrescription = await Prescription.findByIdAndDelete(id);
    
    if (!deletedPrescription) {
      return res.status(HTTP_STATUS.NOT_FOUND).json({
        success: false,
        message: 'Prescription not found'
      });
    }

    logger.info(`Deleted prescription ${id} by user ${currentUser.id}`);

    res.status(HTTP_STATUS.OK).json({
      success: true,
      message: 'Prescription deleted successfully'
    });
  } catch (error) {
    logger.error('Error deleting prescription:', error);
    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: 'Failed to delete prescription'
    });
  }
});

/**
 * @desc    Mark all prescriptions as completed
 * @route   PUT /api/prescriptions/mark-all-completed
 * @access  Private
 */
export const markAllAsCompleted = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.body;
  const currentUser = (req as any).user;

  try {
    const farmObjectId = new mongoose.Types.ObjectId(farmId);
    const result = await Prescription.updateMany(
      { farmId: farmObjectId, status: { $in: ['pending', 'in_progress'] } },
      { 
        status: 'completed',
        completedBy: currentUser.id,
        completedAt: new Date(),
        updatedAt: new Date()
      }
    );

    logger.info(`Marked ${result.modifiedCount} prescriptions as completed for farm ${farmId} by user ${currentUser.id}`);

    res.status(HTTP_STATUS.OK).json({
      success: true,
      message: `All prescriptions marked as completed (${result.modifiedCount} updated)`
    });
  } catch (error) {
    logger.error('Error marking prescriptions as completed:', error);
    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: 'Failed to mark prescriptions as completed'
    });
  }
});

/**
 * @desc    Delete completed prescriptions
 * @route   DELETE /api/prescriptions/delete-completed
 * @access  Private
 */
export const deleteCompletedPrescriptions = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.body;
  const currentUser = (req as any).user;

  try {
    const farmObjectId = new mongoose.Types.ObjectId(farmId);
    const result = await Prescription.deleteMany({ farmId: farmObjectId, status: 'completed' });

    logger.info(`Deleted ${result.deletedCount} completed prescriptions for farm ${farmId} by user ${currentUser.id}`);

    res.status(HTTP_STATUS.OK).json({
      success: true,
      message: `Completed prescriptions deleted successfully (${result.deletedCount} deleted)`
    });
  } catch (error) {
    logger.error('Error deleting completed prescriptions:', error);
    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: 'Failed to delete completed prescriptions'
    });
  }
});

/**
 * @desc    Delete all prescriptions
 * @route   DELETE /api/prescriptions/delete-all
 * @access  Private
 */
export const deleteAllPrescriptions = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.body;
  const currentUser = (req as any).user;

  try {
    const farmObjectId = new mongoose.Types.ObjectId(farmId);
    const result = await Prescription.deleteMany({ farmId: farmObjectId });

    logger.info(`Deleted ${result.deletedCount} prescriptions for farm ${farmId} by user ${currentUser.id}`);

    res.status(HTTP_STATUS.OK).json({
      success: true,
      message: `All prescriptions deleted successfully (${result.deletedCount} deleted)`
    });
  } catch (error) {
    logger.error('Error deleting all prescriptions:', error);
    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: 'Failed to delete all prescriptions'
    });
  }
});

/**
 * @desc    Force regenerate prescriptions for all fields
 * @route   POST /api/prescriptions/force-regenerate
 * @access  Private
 */
export const forceRegeneratePrescriptions = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const currentUser = (req as any).user;

  try {
    console.log('🔄 Force regenerating prescriptions for farm:', farmId);
    
    const farmObjectId = new mongoose.Types.ObjectId(farmId);
    
    // Delete all existing prescriptions
    await Prescription.deleteMany({ farmId: farmObjectId });
    console.log('🗑️ Deleted existing prescriptions');
    
    // Fetch farm data to get actual field names
    const Farm = require('../models/Farm');
    const farm = await Farm.findById(farmObjectId);
    
    if (!farm || !farm.fields || farm.fields.length === 0) {
      return res.status(HTTP_STATUS.BAD_REQUEST).json({
        success: false,
        message: 'No farm or fields found'
      });
    }
    
    console.log('🔍 Found farm with fields:', farm.fields.map((f: any) => f.fieldName));
    
    // Generate prescriptions for each actual field
    const samplePrescriptions = [];
    
    for (const field of farm.fields) {
      console.log(`🔍 Generating prescriptions for field: ${field.fieldName}`);
      
      // Generate prescriptions for each field
      const fieldPrescriptions = [
        {
          farmId: farmObjectId,
          title: 'Check Soil Moisture',
          description: 'Monitor soil moisture levels and irrigate if needed. Optimal range is 30-70% for most crops.',
          priority: 'high' as const,
          status: 'pending' as const,
          dueDate: new Date(Date.now() + 2 * 60 * 60 * 1000), // 2 hours from now
          category: 'irrigation',
          estimatedDuration: '30 minutes',
          materials: _getMaterialsForCategory('irrigation'),
          instructions: _getInstructionsForCategory('irrigation', 'Check soil moisture levels'),
          urgency: 'HIGH' as const,
          timeline: 'Today',
          parameter: 'soil_moisture',
          fieldName: field.fieldName,
          soilType: field.sensors?.[0]?.soilType || 'Loam',
          growthStage: field.growthStage || 'V8'
        },
        {
          farmId: farmObjectId,
          title: 'Monitor Weather Conditions',
          description: 'Check current weather and forecast to plan farm activities accordingly.',
          priority: 'medium' as const,
          status: 'pending' as const,
          dueDate: new Date(Date.now() + 4 * 60 * 60 * 1000), // 4 hours from now
          category: 'weather',
          estimatedDuration: '15 minutes',
          materials: _getMaterialsForCategory('weather'),
          instructions: _getInstructionsForCategory('weather', 'Check weather forecast'),
          urgency: 'MEDIUM' as const,
          timeline: 'Today',
          parameter: 'weather',
          fieldName: field.fieldName,
          soilType: field.sensors?.[0]?.soilType || 'Loam',
          growthStage: field.growthStage || 'V8'
        }
      ];
      
      samplePrescriptions.push(...fieldPrescriptions);
    }
    
    // Save new prescriptions to database
    const newPrescriptions = await Prescription.insertMany(samplePrescriptions);
    
    logger.info(`Force regenerated ${newPrescriptions.length} prescriptions for farm ${farmId} with fields: ${farm.fields.map((f: any) => f.fieldName).join(', ')}`);

    res.status(HTTP_STATUS.OK).json({
      success: true,
      message: `Prescriptions force regenerated successfully (${newPrescriptions.length} created)`,
      data: {
        prescriptions: newPrescriptions,
        fields: farm.fields.map((f: any) => f.fieldName)
      }
    });
  } catch (error) {
    logger.error('Error force regenerating prescriptions:', error);
    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: 'Failed to force regenerate prescriptions'
    });
  }
});

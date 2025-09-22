import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import { AppError, catchAsync } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { HTTP_STATUS, USER_ROLES } from '../utils/constants';

/**
 * @desc    Get prescriptions for a farm
 * @route   GET /api/prescriptions/farm/:farmId
 * @access  Private
 */
export const getPrescriptions = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.params;
  const currentUser = (req as any).user;

  try {
    // Temporarily bypass Python analytics service and use direct prescriptions
    // This will be replaced with real analytics data once the Python service is working
    console.log('🔍 Prescription Controller - Generating prescriptions for farm:', farmId);
    
    const prescriptions = [
      {
        id: `prescription_${farmId}_1`,
        farmId: farmId,
        title: 'Check Soil Moisture',
        description: 'Monitor soil moisture levels and irrigate if needed. Optimal range is 30-70% for most crops.',
        priority: 'high',
        status: 'pending',
        dueDate: new Date(Date.now() + 2 * 60 * 60 * 1000), // 2 hours from now
        createdAt: new Date(),
        updatedAt: new Date(),
        category: 'irrigation',
        estimatedDuration: '30 minutes',
        materials: _getMaterialsForCategory('irrigation'),
        instructions: _getInstructionsForCategory('irrigation', 'Check soil moisture levels'),
        urgency: 'HIGH',
        timeline: 'Today',
        parameter: 'soil_moisture',
        fieldName: 'Main Field',
        soilType: 'Loam',
        growthStage: 'V8'
      },
      {
        id: `prescription_${farmId}_2`,
        farmId: farmId,
        title: 'Monitor Weather Conditions',
        description: 'Check current weather and forecast to plan farm activities accordingly.',
        priority: 'medium',
        status: 'pending',
        dueDate: new Date(Date.now() + 4 * 60 * 60 * 1000), // 4 hours from now
        createdAt: new Date(),
        updatedAt: new Date(),
        category: 'weather',
        estimatedDuration: '15 minutes',
        materials: _getMaterialsForCategory('weather'),
        instructions: _getInstructionsForCategory('weather', 'Check weather forecast'),
        urgency: 'MEDIUM',
        timeline: 'Today',
        parameter: 'weather',
        fieldName: 'Main Field',
        soilType: 'Loam',
        growthStage: 'V8'
      },
      {
        id: `prescription_${farmId}_3`,
        farmId: farmId,
        title: 'Inspect Crop Health',
        description: 'Visually inspect crops for signs of disease, pests, or nutrient deficiencies.',
        priority: 'medium',
        status: 'pending',
        dueDate: new Date(Date.now() + 6 * 60 * 60 * 1000), // 6 hours from now
        createdAt: new Date(),
        updatedAt: new Date(),
        category: 'monitoring',
        estimatedDuration: '45 minutes',
        materials: _getMaterialsForCategory('monitoring'),
        instructions: _getInstructionsForCategory('monitoring', 'Inspect crop health'),
        urgency: 'MEDIUM',
        timeline: 'Today',
        parameter: 'crop_health',
        fieldName: 'Main Field',
        soilType: 'Loam',
        growthStage: 'V8'
      }
    ];

    logger.info(`Generated ${prescriptions.length} prescriptions for farm ${farmId}`);

    res.status(HTTP_STATUS.OK).json({
      success: true,
      data: prescriptions
    });
  } catch (error) {
    console.log('🚨 Prescription Controller - Error details:', error);
    logger.error('Error generating prescriptions:', error);
    
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
 * @desc    Update prescription status
 * @route   PUT /api/prescriptions/:id/status
 * @access  Private
 */
export const updatePrescriptionStatus = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const { status } = req.body;
  const currentUser = (req as any).user;

  // Mock update - in production this would update the database
  logger.info(`Updating prescription ${id} status to ${status} by user ${currentUser.id}`);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Prescription status updated successfully',
    data: {
      id,
      status,
      updatedAt: new Date()
    }
  });
});

/**
 * @desc    Delete prescription
 * @route   DELETE /api/prescriptions/:id
 * @access  Private
 */
export const deletePrescription = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const currentUser = (req as any).user;

  // Mock delete - in production this would delete from database
  logger.info(`Deleting prescription ${id} by user ${currentUser.id}`);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Prescription deleted successfully'
  });
});

/**
 * @desc    Mark all prescriptions as completed
 * @route   PUT /api/prescriptions/mark-all-completed
 * @access  Private
 */
export const markAllAsCompleted = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.body;
  const currentUser = (req as any).user;

  // Mock update - in production this would update all pending prescriptions
  logger.info(`Marking all prescriptions as completed for farm ${farmId} by user ${currentUser.id}`);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'All prescriptions marked as completed'
  });
});

/**
 * @desc    Delete completed prescriptions
 * @route   DELETE /api/prescriptions/delete-completed
 * @access  Private
 */
export const deleteCompletedPrescriptions = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.body;
  const currentUser = (req as any).user;

  // Mock delete - in production this would delete completed prescriptions
  logger.info(`Deleting completed prescriptions for farm ${farmId} by user ${currentUser.id}`);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'Completed prescriptions deleted successfully'
  });
});

/**
 * @desc    Delete all prescriptions
 * @route   DELETE /api/prescriptions/delete-all
 * @access  Private
 */
export const deleteAllPrescriptions = catchAsync(async (req: Request, res: Response) => {
  const { farmId } = req.body;
  const currentUser = (req as any).user;

  // Mock delete - in production this would delete all prescriptions
  logger.info(`Deleting all prescriptions for farm ${farmId} by user ${currentUser.id}`);

  res.status(HTTP_STATUS.OK).json({
    success: true,
    message: 'All prescriptions deleted successfully'
  });
});

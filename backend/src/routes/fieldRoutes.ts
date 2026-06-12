import { Router } from 'express';
import fieldController from '../controllers/fieldController';
import { authenticate } from '../middleware/auth';
import { handleValidationErrors } from '../middleware/validation';
import { body, param } from 'express-validator';

const router = Router();

// Field validation rules
const fieldValidation = [
  body('fieldName').trim().isLength({ min: 1, max: 100 }).withMessage('Field name must be 1-100 characters'),
  body('soilType').isIn(['loamy', 'sandy', 'clay', 'silty']).withMessage('Invalid soil type'),
  body('plantingDate').isISO8601().withMessage('Valid planting date is required'),
  body('location').optional().isString().withMessage('Location must be a string'),
  body('userData').optional().isObject().withMessage('User data must be an object'),
  body('devices').optional().isArray().withMessage('Devices must be an array')
];

const fieldUpdateValidation = [
  body('fieldName').optional().trim().isLength({ min: 1, max: 100 }).withMessage('Field name must be 1-100 characters'),
  body('soilType').optional().isIn(['loamy', 'sandy', 'clay', 'silty']).withMessage('Invalid soil type'),
  body('plantingDate').optional().isISO8601().withMessage('Valid planting date is required'),
  body('growthStage').optional().isString().withMessage('Growth stage must be a string'),
  body('devices').optional().isArray().withMessage('Devices must be an array')
];

const paramValidation = [
  param('fieldId').isMongoId().withMessage('Valid field ID is required')
];

const farmParamValidation = [
  param('farmId').isMongoId().withMessage('Valid farm ID is required')
];

// Routes
router.post('/', authenticate, fieldValidation, handleValidationErrors, fieldController.createField);
router.get('/:fieldId', authenticate, paramValidation, handleValidationErrors, fieldController.getFieldById);
router.get('/farm/:farmId', authenticate, farmParamValidation, handleValidationErrors, fieldController.getFieldsByFarmId);
router.put('/:fieldId', authenticate, paramValidation, fieldUpdateValidation, handleValidationErrors, fieldController.updateField);
router.delete('/:fieldId', authenticate, paramValidation, handleValidationErrors, fieldController.deleteField);
router.get('/:fieldId/analytics', authenticate, paramValidation, handleValidationErrors, fieldController.getFieldAnalytics);
router.post('/:fieldId/devices', authenticate, paramValidation, handleValidationErrors, fieldController.addDeviceToField);
router.delete('/:fieldId/devices/:deviceId', authenticate, paramValidation, handleValidationErrors, fieldController.removeDeviceFromField);
router.get('/:fieldId/predictions', authenticate, paramValidation, handleValidationErrors, fieldController.getHarvestPredictions);

export default router;

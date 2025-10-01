import { Router } from 'express';
import { body } from 'express-validator';
import { authenticate } from '../middleware/auth';
import {
  getPrescriptions,
  syncAnalyticsPrescriptions,
  updatePrescriptionStatus,
  deletePrescription,
  markAllAsCompleted,
  deleteCompletedPrescriptions,
  deleteAllPrescriptions
} from '../controllers/prescriptionController';

const router = Router();

// All prescription routes require authentication
router.use(authenticate);

// Get prescriptions for a farm
router.get('/farm/:farmId', getPrescriptions);

// Sync analytics prescriptions with database
router.post('/sync-analytics', [
  body('farmId').isMongoId().withMessage('Valid farm ID is required'),
  body('prescriptions').isArray().withMessage('Prescriptions must be an array')
], syncAnalyticsPrescriptions);

// Update prescription status
router.put('/:id/status', [
  body('status').isIn(['pending', 'in_progress', 'completed', 'cancelled']).withMessage('Invalid status')
], updatePrescriptionStatus);

// Delete a specific prescription
router.delete('/:id', deletePrescription);

// Mark all prescriptions as completed
router.put('/mark-all-completed', [
  body('farmId').isMongoId().withMessage('Valid farm ID is required')
], markAllAsCompleted);

// Delete completed prescriptions
router.delete('/delete-completed', [
  body('farmId').isMongoId().withMessage('Valid farm ID is required')
], deleteCompletedPrescriptions);

// Delete all prescriptions
router.delete('/delete-all', [
  body('farmId').isMongoId().withMessage('Valid farm ID is required')
], deleteAllPrescriptions);

export default router;

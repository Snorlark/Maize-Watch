import express from 'express';
import { getAllAnalysis, getAnalysisByFieldId, getRecentAnalysis } from '../controllers/cornAnalysis.controller.js';
import { getNewPrescriptionsSinceLastCheck, updatePrescriptionStatusController } from '../controllers/prescription.controller.js';
import { isAuthenticated } from '../middleware/auth.middleware.js';

const router = express.Router();

// Debug middleware to log authentication headers
router.use((req, res, next) => {
  console.log(`Corn Analysis API Request: ${req.method} ${req.path}`);
  console.log(`Authorization header present: ${req.headers.authorization ? 'Yes' : 'No'}`);
  next();
});

// Analysis routes
router.get('/all', isAuthenticated, getAllAnalysis);
router.get('/field/:fieldId', isAuthenticated, getAnalysisByFieldId);
router.get('/recent', isAuthenticated, getRecentAnalysis);

// Prescription routes
router.get('/prescriptions/new', isAuthenticated, getNewPrescriptionsSinceLastCheck);
router.post('/prescriptions/status', isAuthenticated, updatePrescriptionStatusController);

export default router;
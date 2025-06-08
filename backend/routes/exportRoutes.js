// routes/exportRoutes.js
import express from 'express';
import { exportSensorData, getDataSummary } from '../controllers/exportController.js';

const router = express.Router();

// Middleware for basic validation (optional)
const validateDateRange = (req, res, next) => {
  const { startDate, endDate } = req.query;
  
  if (startDate && endDate) {
    const start = new Date(startDate);
    const end = new Date(endDate);
    
    // Add parsed dates to request for use in controllers
    req.parsedDates = { start, end };
  }
  
  next();
};

// GET /api/export - Export sensor data
router.get('/', validateDateRange, exportSensorData);

// GET /api/export/summary - Get data summary for date range
router.get('/summary', validateDateRange, getDataSummary);

export default router;
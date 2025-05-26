import express from 'express';
import thingSpeakService from '../services/thingspeak.services.js';
import { isAuthenticated } from '../middleware/auth.middleware.js';

const router = express.Router();

// Get latest sensor data
router.get('/latest', async (req, res) => {
  try {
    const data = await thingSpeakService.getLatestData();
    res.json({
      success: true,
      data: {
        timestamp: data.timestamp,
        temperature: data.temperature,
        humidity: data.humidity,
        soilMoisture: data.soilMoisture,
        soilPh: data.soilPh,
        lightIntensity: data.lightIntensity
      }
    });
  } catch (error) {
    console.error('Error fetching latest sensor data:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch latest sensor data'
    });
  }
});

// Get weekly overview data with proper calendar week support
router.get('/weekly-overview', async (req, res) => {
  try {
    console.log('Fetching weekly overview data...');
    
    let startDate = null;
    let endDate = null;
    
    // Check if specific date range is provided
    if (req.query.startDate && req.query.endDate) {
      startDate = new Date(req.query.startDate);
      endDate = new Date(req.query.endDate);
      
      // Validate dates
      if (isNaN(startDate.getTime()) || isNaN(endDate.getTime())) {
        return res.status(400).json({
          success: false,
          error: 'Invalid date format. Use ISO 8601 format (YYYY-MM-DDTHH:mm:ss.sssZ)'
        });
      }
      
      // Ensure startDate is a Sunday and endDate is a Saturday
      if (startDate.getDay() !== 0) {
        return res.status(400).json({
          success: false,
          error: 'Start date must be a Sunday'
        });
      }
      
      if (endDate.getDay() !== 6) {
        return res.status(400).json({
          success: false,
          error: 'End date must be a Saturday'
        });
      }
    }
    
    // Get weekly data from the service
    const weeklyResult = await thingSpeakService.getWeeklyOverviewData(startDate, endDate);
    
    res.json({
      success: true,
      period: 'weekly',
      data: weeklyResult.data,
      summary: weeklyResult.summary
    });
  } catch (error) {
    console.error('Error fetching weekly overview:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch weekly overview data: ' + error.message
    });
  }
});

// Get historical sensor data
router.get('/historical', isAuthenticated, async (req, res) => {
  try {
    const minutes = parseInt(req.query.minutes) || 60;
    const data = await thingSpeakService.getHistoricalData(minutes);
    res.json({
      success: true,
      data: data
    });
  } catch (error) {
    console.error('Error fetching historical sensor data:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch historical sensor data'
    });
  }
});

// Get data for a specific field directly from ThingSpeak
router.get('/field/:fieldNumber', isAuthenticated, async (req, res) => {
  try {
    const fieldNumber = parseInt(req.params.fieldNumber);
    const results = parseInt(req.query.results) || 10;
    
    if (isNaN(fieldNumber) || fieldNumber < 1 || fieldNumber > 5) {
      return res.status(400).json({
        success: false,
        error: 'Invalid field number. Must be between 1 and 5.'
      });
    }
    
    const data = await thingSpeakService.getThingSpeakFieldData(fieldNumber, results);
    res.json({
      success: true,
      field: fieldNumber,
      results: results,
      data: data
    });
  } catch (error) {
    console.error(`Error fetching field ${req.params.fieldNumber} data:`, error);
    res.status(500).json({
      success: false,
      error: `Failed to fetch data for field ${req.params.fieldNumber}`
    });
  }
});

// Manual sync endpoint (can be used to force a sync with ThingSpeak)
router.post('/sync', isAuthenticated, async (req, res) => {
  try {
    const savedCount = await thingSpeakService.syncDataFromThingSpeak();
    res.json({
      success: true,
      message: `Data synced successfully. Saved ${savedCount} new data points.`,
      savedCount: savedCount
    });
  } catch (error) {
    console.error('Error syncing data:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to sync data: ' + error.message
    });
  }
});



// Get weekly overview data with proper calendar week support
router.get('/weekly-overview', async (req, res) => {
  try {
    console.log('Fetching weekly overview data...');
    console.log('Query params:', req.query);
    
    let startDate = null;
    let endDate = null;
    
    // Check if specific date range is provided
    if (req.query.startDate && req.query.endDate) {
      startDate = new Date(req.query.startDate);
      endDate = new Date(req.query.endDate);
      
      // Validate dates
      if (isNaN(startDate.getTime()) || isNaN(endDate.getTime())) {
        return res.status(400).json({
          success: false,
          error: 'Invalid date format. Use ISO 8601 format (YYYY-MM-DDTHH:mm:ss.sssZ)'
        });
      }
      
      console.log(`Using date range: ${startDate.toISOString()} to ${endDate.toISOString()}`);
    } else {
      console.log('No date range provided, using default (last 7 days)');
    }
    
    // Get weekly data from the service
    const weeklyResult = await thingSpeakService.getWeeklyOverviewData(startDate, endDate);
    
    console.log(`Returning ${weeklyResult.data.length} data points`);
    
    res.json({
      success: true,
      period: 'weekly',
      data: weeklyResult.data,
      summary: weeklyResult.summary
    });
  } catch (error) {
    console.error('Error fetching weekly overview:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch weekly overview data: ' + error.message
    });
  }
});

export default router;
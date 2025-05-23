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

export default router;
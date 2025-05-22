import express from 'express';
import historicalDataService from '../services/historical_data.service.js';

const router = express.Router();

// Get historical data by period (daily, weekly, monthly)
router.get('/:period', async (req, res) => {
  try {
    const { period } = req.params;
    const limit = parseInt(req.query.limit) || 7;
    
    if (!['daily', 'weekly', 'monthly'].includes(period)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid period. Must be daily, weekly, or monthly.'
      });
    }

    const data = await historicalDataService.getHistoricalData(period, limit);
    
    res.json({
      success: true,
      data: data
    });
  } catch (error) {
    console.error('Error fetching historical data:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch historical data'
    });
  }
});

// Manual trigger for calculating averages (admin only)
router.post('/calculate', async (req, res) => {
  try {
    const { period } = req.body;
    
    if (!['daily', 'weekly', 'monthly'].includes(period)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid period. Must be daily, weekly, or monthly.'
      });
    }

    let result;
    switch (period) {
      case 'daily':
        result = await historicalDataService.calculateDailyAverage();
        break;
      case 'weekly':
        result = await historicalDataService.calculateWeeklyAverage();
        break;
      case 'monthly':
        result = await historicalDataService.calculateMonthlyAverage();
        break;
    }

    if (!result) {
      return res.status(404).json({
        success: false,
        error: 'No data available for calculation'
      });
    }

    res.json({
      success: true,
      message: `${period} average calculated successfully`,
      data: result
    });
  } catch (error) {
    console.error('Error calculating averages:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to calculate averages'
    });
  }
});

export default router; 
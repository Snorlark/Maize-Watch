import express from 'express';
import AnalyticsService from '../services/analytics.service.js';
import { isAuthenticated } from '../middleware/auth.middleware.js';
import mongoose from 'mongoose';

const router = express.Router();

// Endpoint to trigger Python analytics process
router.post('/analyze', async (req, res) => {
  try {
    console.log('Received request to run Python analytics');
    await AnalyticsService.runPythonAnalytics();
    
    // After running analytics, get the latest prescription
    const prescription = await AnalyticsService.getLatestPrescription();
    
    if (!prescription) {
      console.log('No prescription found after analysis');
      return res.status(404).json({ message: 'No prescription generated' });
    }
    
    console.log('Analysis and prescription retrieval completed successfully');
    res.status(200).json(prescription);
  } catch (error) {
    console.error('Error in analyze endpoint:', error);
    res.status(500).json({ message: 'Error running analytics', error: error.message });
  }
});

// Endpoint to get the latest prescription
router.get('/latest-prescription', async (req, res) => {
  try {
    console.log('Received request for latest prescription');
    const prescription = await AnalyticsService.getLatestPrescription();
    
    if (!prescription) {
      console.log('No prescription found');
      return res.status(404).json({ message: 'No prescription found' });
    }
    
    console.log('Latest prescription retrieved successfully');
    res.status(200).json(prescription);
  } catch (error) {
    console.error('Error in latest-prescription endpoint:', error);
    res.status(500).json({ message: 'Error fetching latest prescription', error: error.message });
  }
});

// Endpoint to get unnotified prescriptions
router.get('/unnotified-prescriptions', async (req, res) => {
  try {
    console.log('Received request for unnotified prescriptions');
    const prescriptions = await AnalyticsService.getUnnotifiedPrescriptions();
    
    console.log(`Found ${prescriptions.length} unnotified prescriptions`);
    res.status(200).json(prescriptions);
  } catch (error) {
    console.error('Error in unnotified-prescriptions endpoint:', error);
    res.status(500).json({ message: 'Error fetching unnotified prescriptions', error: error.message });
  }
});

// Endpoint to mark a prescription as notified
router.post('/mark-notified/:id', async (req, res) => {
  try {
    console.log(`Received request to mark prescription ${req.params.id} as notified`);
    const prescription = await AnalyticsService.markPrescriptionAsNotified(req.params.id);
    
    if (!prescription) {
      console.log('Prescription not found');
      return res.status(404).json({ message: 'Prescription not found' });
    }
    
    console.log('Prescription marked as notified successfully');
    res.status(200).json(prescription);
  } catch (error) {
    console.error('Error in mark-notified endpoint:', error);
    res.status(500).json({ message: 'Error marking prescription as notified', error: error.message });
  }
});

// Get latest analysis for a user
router.get('/latest/:userId', isAuthenticated, async (req, res) => {
  try {
    const userId = req.params.userId;
    const analysis = await mongoose.connection.db
      .collection('corn_analyses')
      .findOne(
        { userId: userId },
        { sort: { timestamp: -1 } }
      );

    if (!analysis) {
      return res.status(404).json({
        success: false,
        message: 'No analysis found for this user'
      });
    }

    res.json({
      success: true,
      data: analysis
    });
  } catch (error) {
    console.error('Error fetching latest analysis:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching analysis'
    });
  }
});

// Get all analyses for a user with pagination
router.get('/user/:userId', isAuthenticated, async (req, res) => {
  try {
    const userId = req.params.userId;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const analyses = await mongoose.connection.db
      .collection('corn_analyses')
      .find({ userId: userId })
      .sort({ timestamp: -1 })
      .skip(skip)
      .limit(limit)
      .toArray();

    const total = await mongoose.connection.db
      .collection('corn_analyses')
      .countDocuments({ userId: userId });

    res.json({
      success: true,
      data: analyses,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching analyses:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching analyses'
    });
  }
});

// Get analysis by ID
router.get('/:id', isAuthenticated, async (req, res) => {
  try {
    const analysis = await mongoose.connection.db
      .collection('corn_analyses')
      .findOne({ _id: new mongoose.Types.ObjectId(req.params.id) });

    if (!analysis) {
      return res.status(404).json({
        success: false,
        message: 'Analysis not found'
      });
    }

    res.json({
      success: true,
      data: analysis
    });
  } catch (error) {
    console.error('Error fetching analysis:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching analysis'
    });
  }
});

export default router; 
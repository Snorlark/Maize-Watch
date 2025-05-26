import express from 'express';
import AnalyticsService from '../services/analytics.service.js';
import { isAuthenticated } from '../middleware/auth.middleware.js';
import mongoose from 'mongoose';
import { iotConnection } from '../services/cornAnalysis.service.js';

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
    const realtime = req.query.realtime === 'true';
    console.log('Fetching latest analysis for user:', userId, 'realtime:', realtime);
    
    // Use the IoT database connection
    let analysis;
    
    if (realtime) {
      // First try to get the most recent real-time analysis
      analysis = await iotConnection.db
        .collection('corn_analyses')
        .findOne(
          { 
            $or: [
              { user_id: userId },
              { userId: userId }
            ],
            is_realtime: true
          },
          { sort: { timestamp: -1 } }
        );
    }
    
    // If no real-time analysis found or realtime not requested, get the most recent analysis
    if (!analysis) {
      analysis = await iotConnection.db
        .collection('corn_analyses')
        .findOne(
          { 
            $or: [
              { user_id: userId },
              { userId: userId }
            ]
          },
          { sort: { timestamp: -1 } }
        );
    }

    if (!analysis) {
      console.log('No analysis found for user:', userId);
      return res.status(404).json({
        success: false,
        message: 'No analysis found for this user'
      });
    }

    console.log('Found analysis:', analysis._id, 'is_realtime:', analysis.is_realtime);
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
      .find({
        $or: [
          { user_id: userId },
          { userId: userId }
        ]
      })
      .sort({ timestamp: -1 })
      .skip(skip)
      .limit(limit)
      .toArray();

    const total = await mongoose.connection.db
      .collection('corn_analyses')
      .countDocuments({
        $or: [
          { user_id: userId },
          { userId: userId }
        ]
      });

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

// Update prescription status
router.put('/prescription/:prescriptionId/status', isAuthenticated, async (req, res) => {
  try {
    const { prescriptionId } = req.params;
    const { is_completed, updated_at } = req.body;
    
    console.log('Updating prescription status:', {
      prescriptionId,
      is_completed,
      updated_at
    });

    // Use the IoT database connection
    const result = await iotConnection.db
      .collection('corn_analyses')
      .updateOne(
        { _id: new mongoose.Types.ObjectId(prescriptionId) },
        { 
          $set: { 
            is_notified: is_completed,
            updated_at: new Date(updated_at)
          }
        }
      );

    if (result.matchedCount === 0) {
      console.log('No prescription found with ID:', prescriptionId);
      return res.status(404).json({
        success: false,
        message: 'Prescription not found'
      });
    }

    console.log('Successfully updated prescription status');
    res.json({
      success: true,
      message: 'Prescription status updated successfully'
    });
  } catch (error) {
    console.error('Error updating prescription status:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating prescription status'
    });
  }
});

// Get latest analysis for a field
router.get('/latest/field/:fieldId', isAuthenticated, async (req, res) => {
  try {
    const fieldId = req.params.fieldId;
    const realtime = req.query.realtime === 'true';
    console.log('Fetching latest analysis for field:', fieldId, 'realtime:', realtime);
    
    // Debug: Log all analyses in the database
    const allAnalyses = await iotConnection.db
      .collection('corn_analyses')
      .find({})
      .toArray();
    
    console.log('=== DEBUG: All Analyses in Database ===');
    console.log('Total analyses found:', allAnalyses.length);
    allAnalyses.forEach(analysis => {
      console.log(`Field ID: ${analysis.field_id}, Timestamp: ${analysis.timestamp}, Realtime: ${analysis.is_realtime}`);
    });
    console.log('=====================================');

    let analysis;
    if (realtime) {
      analysis = await iotConnection.db
        .collection('corn_analyses')
        .findOne({ field_id: fieldId, is_realtime: true }, { sort: { timestamp: -1 } });
    }
    if (!analysis) {
      analysis = await iotConnection.db
        .collection('corn_analyses')
        .findOne({ field_id: fieldId }, { sort: { timestamp: -1 } });
    }

    if (!analysis) {
      console.log(`No analysis found for field: ${fieldId}`);
      return res.status(404).json({ message: 'No analysis found' });
    }

    res.json(analysis);
  } catch (error) {
    console.error('Error fetching latest analysis:', error);
    res.status(500).json({ message: 'Error fetching analysis' });
  }
});

export default router; 
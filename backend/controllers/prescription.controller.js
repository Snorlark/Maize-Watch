// controllers/prescriptionController.js
import { getNewPrescriptions, updatePrescriptionStatus } from '../services/cornAnalysis.service.js';

// Get new prescriptions since last check
export async function getNewPrescriptionsSinceLastCheck(req, res) {
  try {
    // Get the user ID from authenticated user
    const userId = req.user.id;
    
    // Get the lastCheck timestamp from query params
    const lastCheckTimestamp = req.query.lastCheck || null;
    
    console.log(`Checking for new prescriptions for user ${userId} since ${lastCheckTimestamp || 'beginning'}`);
    
    // Get new prescriptions from the service
    const prescriptionsData = await getNewPrescriptions(userId, lastCheckTimestamp);
    
    // Return the prescriptions data with success flag
    res.json({
      success: true,
      data: prescriptionsData
    });
  } catch (error) {
    console.error('Error in getNewPrescriptionsSinceLastCheck:', error);
    res.status(500).json({ 
      success: false,
      message: error.message 
    });
  }
}

// Update prescription status
export async function updatePrescriptionStatusController(req, res) {
  try {
    // Extract parameters from request body
    const { analysisId, prescriptionId, status } = req.body;
    
    // Validate required parameters
    if (!analysisId || !prescriptionId || !status) {
      return res.status(400).json({
        success: false,
        message: 'Missing required parameters: analysisId, prescriptionId, or status'
      });
    }
    
    // Update the prescription status
    const result = await updatePrescriptionStatus(analysisId, prescriptionId, status);
    
    // Return the result
    res.json({
      success: true,
      message: 'Prescription status updated successfully',
      data: result
    });
  } catch (error) {
    console.error('Error in updatePrescriptionStatusController:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
}
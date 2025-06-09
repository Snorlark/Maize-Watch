// controllers/corn.controller.js
import CornField from '../models/cornField.model.js';
import { Types } from 'mongoose';

// Register a new corn field
export async function registerCornField(req, res) {
  try {
    // Check if the user ID in the token matches the user ID in the request body
    // This ensures users can only register corn fields for themselves
    if (req.user.id !== req.body.userId) {
      return res.status(403).json({
        success: false,
        message: 'You can only register corn fields for your own account'
      });
    }

    // Validate that userId is a valid MongoDB ObjectId
    if (!Types.ObjectId.isValid(req.body.userId)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid user ID format'
      });
    }

    // Create a new corn field with the request data
    const newCornField = new CornField({
      userId: req.body.userId,
      fieldName: req.body.fieldName,
      location: req.body.location,
      soilType: req.body.soilType,
      cornVariety: req.body.cornVariety,
      plantingDate: new Date(req.body.plantingDate),
      growthStage: req.body.growthStage,
      createdAt: req.body.createdAt ? new Date(req.body.createdAt) : new Date()
    });

    // Save the corn field to the database
    const savedCornField = await newCornField.save();

    // Return success response with the saved data
    return res.status(201).json({
      success: true,
      message: 'Corn field registered successfully',
      data: savedCornField
    });
  } catch (error) {
    console.error('Error registering corn field:', error);
    
    // Handle validation errors
    if (error.name === 'ValidationError') {
      const validationErrors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors: validationErrors
      });
    }
    
    // Return general error response
    return res.status(500).json({
      success: false,
      message: 'Server error. Could not register corn field.'
    });
  }
}

// Get all corn fields for a specific user
export async function getCornFieldsByUser(req, res) {
  try {
    const { userId } = req.params;
    
    // Validate that userId is a valid MongoDB ObjectId
    if (!Types.ObjectId.isValid(userId)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid user ID format'
      });
    }
    
    // Check if the user ID in the token matches the requested user ID
    // This ensures users can only view their own corn fields
    if (req.user.id !== userId) {
      return res.status(403).json({
        success: false,
        message: 'You can only view corn fields for your own account'
      });
    }

    // Find all corn fields for the specified user
    const cornFields = await CornField.find({ userId }).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: cornFields.length,
      data: cornFields
    });
  } catch (error) {
    console.error('Error fetching corn fields:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error. Could not retrieve corn fields.'
    });
  }
}

// Get a specific corn field by ID
export async function getCornFieldById(req, res) {
  try {
    const { id } = req.params;
    
    // Validate that the corn field ID is a valid MongoDB ObjectId
    if (!Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid corn field ID format'
      });
    }

    // Find the corn field by ID
    const cornField = await CornField.findById(id);

    // Check if the corn field exists
    if (!cornField) {
      return res.status(404).json({
        success: false,
        message: 'Corn field not found'
      });
    }

    // Check if the user is the owner of the corn field
    if (cornField.userId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. You can only view your own corn fields.'
      });
    }

    return res.status(200).json({
      success: true,
      data: cornField
    });
  } catch (error) {
    console.error('Error fetching corn field:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error. Could not retrieve corn field.'
    });
  }
}

// Update a corn field
export async function updateCornField(req, res) {
  try {
    const { id } = req.params;
    
    // Validate that the corn field ID is a valid MongoDB ObjectId
    if (!Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid corn field ID format'
      });
    }

    // Find the corn field by ID
    const cornField = await CornField.findById(id);

    // Check if the corn field exists
    if (!cornField) {
      return res.status(404).json({
        success: false,
        message: 'Corn field not found'
      });
    }

    // Check if the user is the owner of the corn field
    if (cornField.userId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. You can only update your own corn fields.'
      });
    }

    // Update the corn field
    const updatedCornField = await CornField.findByIdAndUpdate(
      id,
      { 
        fieldName: req.body.fieldName || cornField.fieldName,
        location: req.body.location || cornField.location,
        soilType: req.body.soilType || cornField.soilType,
        cornVariety: req.body.cornVariety || cornField.cornVariety,
        plantingDate: req.body.plantingDate ? new Date(req.body.plantingDate) : cornField.plantingDate,
        growthStage: req.body.growthStage || cornField.growthStage
      },
      { new: true, runValidators: true }
    );

    return res.status(200).json({
      success: true,
      message: 'Corn field updated successfully',
      data: updatedCornField
    });
  } catch (error) {
    console.error('Error updating corn field:', error);
    
    // Handle validation errors
    if (error.name === 'ValidationError') {
      const validationErrors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors: validationErrors
      });
    }
    
    return res.status(500).json({
      success: false,
      message: 'Server error. Could not update corn field.'
    });
  }
}

// Delete a corn field
export async function deleteCornField(req, res) {
  try {
    const { id } = req.params;
    
    // Validate that the corn field ID is a valid MongoDB ObjectId
    if (!Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid corn field ID format'
      });
    }

    // Find the corn field by ID
    const cornField = await CornField.findById(id);

    // Check if the corn field exists
    if (!cornField) {
      return res.status(404).json({
        success: false,
        message: 'Corn field not found'
      });
    }

    // Check if the user is the owner of the corn field
    if (cornField.userId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. You can only delete your own corn fields.'
      });
    }

    // Delete the corn field
    await CornField.findByIdAndDelete(id);

    return res.status(200).json({
      success: true,
      message: 'Corn field deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting corn field:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error. Could not delete corn field.'
    });
  }
}
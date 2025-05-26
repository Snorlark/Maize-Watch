// Get latest analysis for a user
router.get('/latest/:userId', isAuthenticated, async (req, res) => {
  try {
    const userId = req.params.userId;
    console.log('Fetching analyses for user:', userId);
    
    const analyses = await mongoose.connection.db
      .collection('corn_analyses')
      .find(
        { user_id: userId },  // Changed from userId to user_id
        { sort: { timestamp: -1 } }
      )
      .toArray();

    if (!analyses || analyses.length === 0) {
      console.log('No analyses found for user:', userId);
      return res.status(404).json({
        success: false,
        message: 'No analyses found for this user'
      });
    }

    console.log(`Found ${analyses.length} analyses`);
    res.json({
      success: true,
      data: analyses
    });
  } catch (error) {
    console.error('Error fetching analyses:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching analyses'
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

    const result = await mongoose.connection.db
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
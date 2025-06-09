const mongoose = require('mongoose');

const activityLogSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  username: {
    type: String,
    required: true
  },
  action: {
    type: String,
    required: true,
    enum: ['login', 'logout', 'mobile_login']
  },
  timestamp: {
    type: Date,
    default: Date.now
  },
  deviceType: {
    type: String,
    required: true,
    enum: ['web', 'mobile']
  },
  details: {
    type: String,
    required: true
  }
});

// Create index for faster queries
activityLogSchema.index({ timestamp: -1 });
activityLogSchema.index({ username: 1 });
activityLogSchema.index({ action: 1 });

module.exports = mongoose.model('ActivityLog', activityLogSchema); 
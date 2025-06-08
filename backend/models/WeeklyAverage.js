// models/WeeklyAverage.js
import mongoose from 'mongoose';

const weeklyAverageSchema = new mongoose.Schema({
  weekStart: {
    type: Date,
    required: true,
    index: true
  },
  weekEnd: {
    type: Date,
    required: true
  },
  averages: {
    temperature: {
      type: Number,
      min: -50,
      max: 100
    },
    humidity: {
      type: Number,
      min: 0,
      max: 100
    },
    soilMoisture: {
      type: Number,
      min: 0
    },
    soilPh: {
      type: Number,
      min: 0,
      max: 14
    },
    lightIntensity: {
      type: Number,
      min: 0
    }
  },
  count: {
    type: Number,
    required: true,
    min: 1
  }
}, {
  timestamps: false,
  collection: 'weekly_averages'
});

// Index for efficient date range queries
weeklyAverageSchema.index({ weekStart: 1 });

export default mongoose.model('WeeklyAverage', weeklyAverageSchema);
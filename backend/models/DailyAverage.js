// models/DailyAverage.js
import mongoose from 'mongoose';

const dailyAverageSchema = new mongoose.Schema({
  date: {
    type: Date,
    required: true,
    index: true
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
  collection: 'daily_averages'
});

// Index for efficient date range queries
dailyAverageSchema.index({ date: 1 });

export default mongoose.model('DailyAverage', dailyAverageSchema);

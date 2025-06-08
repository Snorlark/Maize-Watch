// models/MonthlyAverage.js
import mongoose from 'mongoose';

const monthlyAverageSchema = new mongoose.Schema({
  monthStart: {
    type: Date,
    required: true,
    index: true
  },
  monthEnd: {
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
    min: 0
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: false,
  collection: 'monthly_averages'
});

// Compound index for efficient date range queries
monthlyAverageSchema.index({ monthStart: 1, monthEnd: 1 });

// Index for date range filtering
monthlyAverageSchema.index({ monthStart: 1 });
monthlyAverageSchema.index({ monthEnd: 1 });

export default mongoose.model('MonthlyAverage', monthlyAverageSchema);
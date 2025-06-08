//SensorReading.js
import mongoose from 'mongoose';

const sensorReadingSchema = new mongoose.Schema({
  timestamp: {
    type: Date,
    required: true,
    index: true // Index for better query performance
  },
  field_id: {
    type: String,
    required: true,
    index: true
  },
  measurements: {
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
    soil_moisture: {
      type: Number,
      min: 0
    },
    soil_ph: {
      type: Number,
      min: 0,
      max: 14
    },
    light_intensity: {
      type: Number,
      min: 0
    }
  }
}, {
  timestamps: false, // We're using our own timestamp field
  collection: 'sensor_readings' // Specify collection name
});

// Compound index for efficient date range queries
sensorReadingSchema.index({ timestamp: 1, field_id: 1 });

// Create a text index for potential search functionality
sensorReadingSchema.index({ field_id: 'text' });

export default mongoose.model('SensorReading', sensorReadingSchema);
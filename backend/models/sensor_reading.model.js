import mongoose from 'mongoose';

const sensorReadingSchema = new mongoose.Schema({
  timestamp: { 
    type: Date, 
    required: true, 
    index: true 
  },
  field_id: { 
    type: String, 
    required: true 
  },
  userId: {
    type: String,
    required: true,
    index: true
  },
  corn_growth_stage: {
    type: String,
    required: true,
    enum: [
      'Emergence (VE)',
      'First Leaf (V1)',
      'Second Leaf (V2)',
      'Third Leaf (V3)',
      'Fourth Leaf (V4)',
      'Fifth Leaf (V5)',
      'Sixth Leaf (V6)',
      'Seventh Leaf (V7)',
      'Eighth Leaf (V8)',
      'Ninth Leaf (V9)',
      'Tenth Leaf (V10)',
      'Eleventh Leaf (V11)',
      'Twelfth Leaf (V12)',
      'Tasseling (VT)',
      'Silking (R1)',
      'Blister (R2)',
      'Milk (R3)',
      'Dough (R4)',
      'Dent (R5)',
      'Physiological Maturity (R6)'
    ],
    default: 'Emergence (VE)'
  },
  measurements: {
    temperature: { 
      type: Number, 
      required: true,
      min: [0, 'Temperature cannot be below 0°C'],
      max: [50, 'Temperature cannot exceed 50°C']
    },
    humidity: { 
      type: Number, 
      required: true,
      min: [0, 'Humidity cannot be below 0%'],
      max: [100, 'Humidity cannot exceed 100%']
    },
    soil_moisture: { 
      type: Number, 
      required: true,
      min: [0, 'Soil moisture cannot be below 0%'],
      max: [100, 'Soil moisture cannot exceed 100%']
    },
    soil_ph: { 
      type: Number, 
      required: true,
      min: [0, 'pH cannot be below 0'],
      max: [14, 'pH cannot exceed 14']
    },
    light_intensity: { 
      type: Number, 
      required: true,
      min: [0, 'Light intensity cannot be below 0 lux'],
      max: [150000, 'Light intensity cannot exceed 150,000 lux']
    }
  }
}, {
  timestamps: true,
  collection: 'sensor_readings'
});

// Add validation middleware
sensorReadingSchema.pre('save', function(next) {
  // Ensure all measurement values are numbers
  const measurements = this.measurements;
  for (const key in measurements) {
    if (measurements.hasOwnProperty(key)) {
      if (typeof measurements[key] !== 'number' || isNaN(measurements[key])) {
        next(new Error(`Invalid measurement value for ${key}: must be a valid number`));
        return;
      }
    }
  }
  next();
});

// Add logging middleware
sensorReadingSchema.pre('save', function(next) {
  console.log('New sensor reading being saved:', {
    timestamp: this.timestamp,
    field_id: this.field_id,
    userId: this.userId,
    corn_growth_stage: this.corn_growth_stage,
    measurements: this.measurements
  });
  next();
});

sensorReadingSchema.pre('find', function() {
  console.log('Querying sensor readings with filter:', this.getFilter());
});

const SensorReading = mongoose.model('SensorReading', sensorReadingSchema);

export default SensorReading; 
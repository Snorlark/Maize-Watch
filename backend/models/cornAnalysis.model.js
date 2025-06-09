import mongoose from 'mongoose';

// Prescription schema
const prescriptionSchema = new mongoose.Schema({
  type: {
    type: String,
    required: true,
    enum: ['fertilizer', 'irrigation', 'pesticide', 'other']
  },
  description: {
    type: String,
    required: true
  },
  recommendedAction: {
    type: String,
    required: true
  },
  status: {
    type: String,
    default: 'pending',
    enum: ['pending', 'read', 'executing', 'completed', 'cancelled']
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, { _id: true });

// Corn analysis schema
const cornAnalysisSchema = new mongoose.Schema({
  fieldId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Field'
  },
  fieldName: {
    type: String
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User'
  },
  soilMoisture: {
    type: Number
  },
  soilNutrients: {
    nitrogen: Number,
    phosphorus: Number,
    potassium: Number
  },
  growthStage: {
    type: String
  },
  healthScore: {
    type: Number
  },
  prescriptions: [prescriptionSchema],
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, { 
  timestamps: true,
  collection: 'corn_analyses' // Explicitly set the collection name
});

// Export the schema only, model will be created with specific connection
export { cornAnalysisSchema };
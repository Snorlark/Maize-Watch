import mongoose from 'mongoose';
const { Schema } = mongoose;

const cornFieldSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  fieldName: {
    type: String,
    required: true
  },
  location: {
    type: String,
    required: true
  },
  soilType: {
    type: String,
    required: true
  },
  cornVariety: {
    type: String,
    required: true
  },
  plantingDate: {
    type: Date,
    required: true
  },
  growthStage: {
    type: String,
    required: true,
    default: 'VE' // Initial growth stage
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

const CornField = mongoose.model('CornField', cornFieldSchema);

export default CornField;
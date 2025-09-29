import mongoose, { Document, Schema } from 'mongoose';

export interface IPrescription extends Document {
  farmId: mongoose.Types.ObjectId;
  title: string;
  description: string;
  priority: 'low' | 'medium' | 'high' | 'urgent';
  status: 'pending' | 'in_progress' | 'completed' | 'cancelled';
  dueDate: Date;
  category: string;
  estimatedDuration: string;
  materials: string[];
  instructions: string[];
  urgency: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT';
  timeline: string;
  parameter: string;
  fieldName: string;
  soilType: string;
  growthStage: string;
  completedBy?: mongoose.Types.ObjectId;
  completedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const prescriptionSchema = new Schema<IPrescription>({
  farmId: {
    type: Schema.Types.ObjectId,
    required: true,
    ref: 'Farm'
  },
  title: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true,
    trim: true
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high', 'urgent'],
    default: 'medium'
  },
  status: {
    type: String,
    enum: ['pending', 'in_progress', 'completed', 'cancelled'],
    default: 'pending'
  },
  dueDate: {
    type: Date,
    required: true
  },
  category: {
    type: String,
    required: true,
    trim: true
  },
  estimatedDuration: {
    type: String,
    required: true,
    trim: true
  },
  materials: [{
    type: String,
    trim: true
  }],
  instructions: [{
    type: String,
    trim: true
  }],
  urgency: {
    type: String,
    enum: ['LOW', 'MEDIUM', 'HIGH', 'URGENT'],
    default: 'MEDIUM'
  },
  timeline: {
    type: String,
    required: true,
    trim: true
  },
  parameter: {
    type: String,
    required: true,
    trim: true
  },
  fieldName: {
    type: String,
    required: true,
    trim: true
  },
  soilType: {
    type: String,
    required: true,
    trim: true
  },
  growthStage: {
    type: String,
    required: true,
    trim: true
  },
  completedBy: {
    type: Schema.Types.ObjectId,
    ref: 'User'
  },
  completedAt: {
    type: Date
  }
}, {
  timestamps: true
});

// Create indexes for better query performance
prescriptionSchema.index({ farmId: 1, status: 1 });
prescriptionSchema.index({ dueDate: 1 });
prescriptionSchema.index({ priority: 1 });
prescriptionSchema.index({ createdAt: -1 });

const Prescription = mongoose.model<IPrescription>('Prescription', prescriptionSchema);

export default Prescription;
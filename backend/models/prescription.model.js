import mongoose from 'mongoose';

const prescriptionSchema = new mongoose.Schema({
  timestamp: {
    type: Date,
    required: true,
    default: Date.now
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
    required: true
  },
  measurements: {
    temperature: {
      type: Number,
      required: true,
      min: 0,
      max: 50
    },
    humidity: {
      type: Number,
      required: true,
      min: 0,
      max: 100
    },
    soil_moisture: {
      type: Number,
      required: true,
      min: 0,
      max: 100
    },
    soil_ph: {
      type: Number,
      required: true,
      min: 0,
      max: 14
    },
    light_intensity: {
      type: Number,
      required: true,
      min: 0,
      max: 150000
    }
  },
  alerts: [{
    type: String
  }],
  severity_level: {
    type: String,
    enum: ['CRITICAL', 'WARNING', 'INFO'],
    required: true
  },
  overall_recommendation: {
    type: String,
    required: true
  },
  is_notified: {
    type: Boolean,
    default: false
  },
  issues: [{
    parameter: {
      type: String,
      required: true
    },
    condition: {
      type: String,
      enum: ['critically_low', 'low', 'normal', 'high', 'critically_high'],
      required: true
    },
    value: {
      type: Number,
      required: true
    },
    optimalRange: {
      min: {
        type: Number,
        required: true
      },
      max: {
        type: Number,
        required: true
      }
    },
    unit: {
      type: String,
      required: true
    }
  }],
  important_issues: [{
    parameter: {
      type: String,
      required: true
    },
    condition: {
      type: String,
      enum: ['critically_low', 'low', 'normal', 'high', 'critically_high'],
      required: true
    },
    value: {
      type: Number,
      required: true
    },
    optimalRange: {
      min: {
        type: Number,
        required: true
      },
      max: {
        type: Number,
        required: true
      }
    },
    unit: {
      type: String,
      required: true
    },
    importanceScore: {
      type: Number,
      required: true,
      min: 0,
      max: 1
    }
  }]
}, {
  timestamps: true,
  collection: 'prescriptions'
});

// Add validation middleware
prescriptionSchema.pre('save', function(next) {
  // Ensure all numeric values are properly converted
  if (this.measurements) {
    Object.keys(this.measurements).forEach(key => {
      if (this.measurements[key] !== null) {
        this.measurements[key] = parseFloat(this.measurements[key]);
      }
    });
  }

  // Validate issues
  if (this.issues) {
    this.issues.forEach(issue => {
      if (issue.value !== null) {
        issue.value = parseFloat(issue.value);
      }
      if (issue.optimalRange) {
        issue.optimalRange.min = parseFloat(issue.optimalRange.min);
        issue.optimalRange.max = parseFloat(issue.optimalRange.max);
      }
    });
  }

  // Validate important issues
  if (this.important_issues) {
    this.important_issues.forEach(issue => {
      if (issue.value !== null) {
        issue.value = parseFloat(issue.value);
      }
      if (issue.optimalRange) {
        issue.optimalRange.min = parseFloat(issue.optimalRange.min);
        issue.optimalRange.max = parseFloat(issue.optimalRange.max);
      }
      if (issue.importanceScore !== null) {
        issue.importanceScore = parseFloat(issue.importanceScore);
      }
    });
  }

  next();
});

const Prescription = mongoose.model('Prescription', prescriptionSchema);

export default Prescription; 
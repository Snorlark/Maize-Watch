import mongoose, { Document, Schema, Model } from 'mongoose';

// Interface for sensor readings
interface ISensorReadings {
  soilMoisture?: number;
  temperature?: number;
  humidity?: number;
  lightIntensity?: number;
  soilPh?: number;
}

// Interface for sensor
interface ISensor {
  deviceID: string;
  sensorName: string;
  description: string;
  soilType: 'loamy' | 'sandy' | 'clay' | 'silty';
  readings: ISensorReadings;
}

// Interface for field
interface IField {
  fieldName: string;
  plantingDate: Date;
  growthStage: 'VE' | 'V3' | 'V8' | 'VT' | 'R1' | 'R6';
  sensors: ISensor[];
}

// Interface for static methods
interface IFarmModel extends Model<IFarm> {
  getStatistics(): Promise<any>;
}

export interface IFarm extends Document {
  userId: mongoose.Types.ObjectId;
  farmName: string;
  location: string;
  fields: IField[];
  images?: string[];
  createdAt: Date;
  updatedAt: Date;
  
  // Instance methods
  addField(fieldData: IField): Promise<IFarm>;
  updateField(fieldName: string, fieldData: Partial<IField>): Promise<IFarm>;
  removeField(fieldName: string): Promise<IFarm>;
  addSensorToField(fieldName: string, sensorData: ISensor): Promise<IFarm>;
  removeSensorFromField(fieldName: string, deviceID: string): Promise<IFarm>;
  updateGrowthStages(): Promise<IFarm>;
}

const farmSchema = new Schema<IFarm>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    farmName: {
      type: String,
      required: true
    },
    location: {
      type: String,
      required: true
    },
    fields: [
      {
        fieldName: {
          type: String,
          required: true
        },
        plantingDate: {
          type: Date,
          required: true
        },
        growthStage: {
          type: String,
          enum: ['VE', 'V3', 'V8', 'VT', 'R1', 'R6'],
          default: 'VE'
        },
        sensors: [
          {
            deviceID: {
              type: String,
              required: true
            },
            sensorName: {
              type: String,
              required: true
            },
            description: {
              type: String,
              required: true
            },
            soilType: {
              type: String,
              enum: ['loamy', 'sandy', 'clay', 'silty'],
              required: true
            },
            readings: {
              soilMoisture: {
                type: Number,
                default: 0
              },
              temperature: {
                type: Number,
                default: 0
              },
              humidity: {
                type: Number,
                default: 0
              },
              lightIntensity: {
                type: Number,
                default: 0
              },
              soilPh: {
                type: Number,
                default: 0
              }
            }
          }
        ]
      }
    ]
  },
  { 
    timestamps: true,
    collection: 'farms'
  }
);

// Compound indexes for performance
farmSchema.index({ userId: 1 });
farmSchema.index({ farmName: 1, userId: 1 }, { unique: true });
farmSchema.index({ 'fields.fieldName': 1 });
farmSchema.index({ 'fields.sensors.deviceID': 1 });
farmSchema.index({ 'fields.growthStage': 1 });

// Pre-save middleware to auto-update growth stages based on planting dates
farmSchema.pre('save', function(next) {
  this.fields.forEach((field: any) => {
    if (field.plantingDate) {
      const now = new Date();
      const diffTime = Math.abs(now.getTime() - field.plantingDate.getTime());
      const daysSincePlanting = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

      if (daysSincePlanting <= 7) field.growthStage = 'VE'; // Emergence (0-7 days)
      else if (daysSincePlanting <= 21) field.growthStage = 'V3'; // 3rd leaf (8-21 days)
      else if (daysSincePlanting <= 42) field.growthStage = 'V8'; // 8th leaf (22-42 days)
      else if (daysSincePlanting <= 65) field.growthStage = 'VT'; // Tasseling (43-65 days)
      else if (daysSincePlanting <= 85) field.growthStage = 'R1'; // Silking (66-85 days)
      else field.growthStage = 'R6'; // Maturity (86+ days)
    }
  });
  next();
});

// Static method to get farm statistics
farmSchema.statics.getStatistics = async function() {
  const stats = await this.aggregate([
    {
      $group: {
        _id: null,
        totalFarms: { $sum: 1 },
        totalFields: { $sum: { $size: '$fields' } },
        farmsWithFields: {
          $sum: { $cond: [{ $gt: [{ $size: '$fields' }, 0] }, 1, 0] }
        },
        totalSensors: {
          $sum: {
            $sum: {
              $map: {
                input: '$fields',
                as: 'field',
                in: { $size: '$$field.sensors' }
              }
            }
          }
        }
      }
    }
  ]);

  return stats[0] || {
    totalFarms: 0,
    totalFields: 0,
    farmsWithFields: 0,
    totalSensors: 0
  };
};

// Instance method to add field
farmSchema.methods.addField = function(fieldData: IField) {
  this.fields.push(fieldData);
  return this.save();
};

// Instance method to update field
farmSchema.methods.updateField = function(fieldName: string, fieldData: Partial<IField>) {
  const fieldIndex = this.fields.findIndex((field: any) => field.fieldName === fieldName);
  if (fieldIndex !== -1) {
    Object.assign(this.fields[fieldIndex], fieldData);
  }
  return this.save();
};

// Instance method to remove field
farmSchema.methods.removeField = function(fieldName: string) {
  this.fields = this.fields.filter((field: any) => field.fieldName !== fieldName);
  return this.save();
};

// Instance method to add sensor to field
farmSchema.methods.addSensorToField = function(fieldName: string, sensorData: ISensor) {
  const field = this.fields.find((field: any) => field.fieldName === fieldName);
  if (field) {
    field.sensors.push(sensorData);
  }
  return this.save();
};

// Instance method to remove sensor from field
farmSchema.methods.removeSensorFromField = function(fieldName: string, deviceID: string) {
  const field = this.fields.find((field: any) => field.fieldName === fieldName);
  if (field) {
    field.sensors = field.sensors.filter((sensor: any) => sensor.deviceID !== deviceID);
  }
  return this.save();
};

// Instance method to update growth stages
farmSchema.methods.updateGrowthStages = function() {
  // Growth stages are automatically updated in pre-save middleware
  return this.save();
};

const Farm = mongoose.model<IFarm, IFarmModel>('Farm', farmSchema);

export default Farm;

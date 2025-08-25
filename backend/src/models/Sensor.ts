import mongoose, { Document, Schema, Model } from 'mongoose';

// Interface for static methods
export interface ISensorModel extends Model<ISensor> {
  findByFarm(farmId: string): Promise<ISensor[]>;
  findByType(type: string): Promise<ISensor[]>;
  findNeedingMaintenance(): Promise<ISensor[]>;
  getStatistics(): Promise<{
    totalSensors: number;
    activeSensors: number;
    sensorsByType: string[];
    sensorsByStatus: string[];
    averageBatteryLevel: number;
  }>;
}

export interface ISensor extends Document {
  sensorId: string;
  name: string;
  type: 'DHT11' | 'Soil_Moisture' | 'LDR' | 'pH_Sensor' | 'Multi_Sensor';
  farm: mongoose.Types.ObjectId;
  location: {
    coordinates: [number, number]; // [longitude, latitude]
    description?: string;
  };
  specifications: {
    model: string;
    manufacturer?: string;
    accuracy?: string;
    range?: string;
    powerRequirement?: string;
  };
  status: 'active' | 'inactive' | 'maintenance' | 'error';
  lastReading: {
    timestamp: Date;
    batteryLevel?: number;
    signalStrength?: number;
  };
  calibration: {
    lastCalibrated?: Date;
    calibrationData?: any;
    nextCalibrationDue?: Date;
  };
  thingspeakConfig: {
    channelId?: string;
    writeApiKey?: string;
    fieldMapping?: {
      temperature?: string;
      humidity?: string;
      soilMoisture?: string;
      lightIntensity?: string;
      pH?: string;
      batteryLevel?: string;
      signalStrength?: string;
    };
  };
  alerts: {
    enabled: boolean;
    thresholds: {
      temperature?: { min?: number; max?: number };
      humidity?: { min?: number; max?: number };
      soilMoisture?: { min?: number; max?: number };
      lightIntensity?: { min?: number; max?: number };
      pH?: { min?: number; max?: number };
      batteryLevel?: { min?: number };
    };
  };
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;

  // Instance methods
  updateLastReading(batteryLevel?: number, signalStrength?: number): Promise<ISensor>;
  needsCalibration(): boolean;
  scheduleCalibration(daysFromNow?: number): Promise<ISensor>;
  checkAlertThresholds(sensorData: any): Array<{
    type: string;
    value: number;
    threshold: number;
  }>;
}

const sensorSchema = new Schema<ISensor>(
  {
    sensorId: {
      type: String,
      required: [true, 'Sensor ID is required'],
      unique: true,
      trim: true,
      uppercase: true,
      match: [/^[A-Z0-9_-]+$/, 'Sensor ID can only contain uppercase letters, numbers, underscores, and hyphens'],
    },
    name: {
      type: String,
      required: [true, 'Sensor name is required'],
      trim: true,
      maxlength: [100, 'Sensor name cannot exceed 100 characters'],
    },
    type: {
      type: String,
      required: [true, 'Sensor type is required'],
      enum: {
        values: ['DHT11', 'Soil_Moisture', 'LDR', 'pH_Sensor', 'Multi_Sensor'],
        message: 'Invalid sensor type',
      },
    },
    farm: {
      type: Schema.Types.ObjectId,
      ref: 'Farm',
      required: [true, 'Farm reference is required'],
    },
    location: {
      coordinates: {
        type: [Number],
        required: [true, 'Sensor coordinates are required'],
        validate: {
          validator: function(coords: number[]) {
            return coords.length === 2 && 
                   coords[0] >= -180 && coords[0] <= 180 && // longitude
                   coords[1] >= -90 && coords[1] <= 90;     // latitude
          },
          message: 'Invalid coordinates format [longitude, latitude]'
        }
      },
      description: {
        type: String,
        trim: true,
        maxlength: [200, 'Location description cannot exceed 200 characters'],
      },
    },
    specifications: {
      model: {
        type: String,
        required: [true, 'Sensor model is required'],
        trim: true,
      },
      manufacturer: {
        type: String,
        trim: true,
      },
      accuracy: {
        type: String,
        trim: true,
      },
      range: {
        type: String,
        trim: true,
      },
      powerRequirement: {
        type: String,
        trim: true,
      },
    },
    status: {
      type: String,
      enum: ['active', 'inactive', 'maintenance', 'error'],
      default: 'active',
    },
    lastReading: {
      timestamp: {
        type: Date,
        default: Date.now,
      },
      batteryLevel: {
        type: Number,
        min: 0,
        max: 100,
      },
      signalStrength: {
        type: Number,
        min: -120,
        max: 0,
      },
    },
    calibration: {
      lastCalibrated: Date,
      calibrationData: Schema.Types.Mixed,
      nextCalibrationDue: Date,
    },
    thingspeakConfig: {
      channelId: String,
      writeApiKey: String,
      fieldMapping: {
        temperature: String,
        humidity: String,
        soilMoisture: String,
        lightIntensity: String,
        pH: String,
        batteryLevel: String,
        signalStrength: String,
      },
    },
    alerts: {
      enabled: {
        type: Boolean,
        default: true,
      },
      thresholds: {
        temperature: {
          min: Number,
          max: Number,
        },
        humidity: {
          min: Number,
          max: Number,
        },
        soilMoisture: {
          min: Number,
          max: Number,
        },
        lightIntensity: {
          min: Number,
          max: Number,
        },
        pH: {
          min: Number,
          max: Number,
        },
        batteryLevel: {
          min: {
            type: Number,
            default: 20,
          },
        },
      },
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
    collection: 'sensors',
    toJSON: {
      transform: function(doc: any, ret: any) {
        delete ret.__v;
        return ret;
      },
    },
  }
);

// Create geospatial index for location-based queries
sensorSchema.index({ 'location.coordinates': '2dsphere' });

// Compound indexes for performance (sensorId already has unique: true in schema)
sensorSchema.index({ farm: 1, isActive: 1 });
sensorSchema.index({ type: 1, status: 1 });
sensorSchema.index({ status: 1, 'lastReading.timestamp': -1 });

// Virtual for sensor age in days
sensorSchema.virtual('ageInDays').get(function() {
  const now = new Date();
  const diffTime = Math.abs(now.getTime() - this.createdAt.getTime());
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
});

// Virtual for time since last reading
sensorSchema.virtual('timeSinceLastReading').get(function() {
  if (!this.lastReading?.timestamp) return null;
  const now = new Date();
  const diffTime = Math.abs(now.getTime() - this.lastReading.timestamp.getTime());
  return Math.floor(diffTime / (1000 * 60)); // in minutes
});

// Virtual for battery status
sensorSchema.virtual('batteryStatus').get(function() {
  const batteryLevel = this.lastReading?.batteryLevel;
  if (!batteryLevel) return 'unknown';
  if (batteryLevel > 50) return 'good';
  if (batteryLevel > 20) return 'medium';
  return 'low';
});

// Static method to find sensors by farm
sensorSchema.statics.findByFarm = function(farmId: string) {
  return this.find({ farm: farmId, isActive: true }).populate('farm');
};

// Static method to find sensors by type
sensorSchema.statics.findByType = function(type: string) {
  return this.find({ type, isActive: true }).populate('farm');
};

// Static method to find sensors needing maintenance
sensorSchema.statics.findNeedingMaintenance = function() {
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
  
  return this.find({
    $or: [
      { status: 'maintenance' },
      { status: 'error' },
      { 'lastReading.timestamp': { $lt: thirtyDaysAgo } },
      { 'lastReading.batteryLevel': { $lt: 20 } },
      { 'calibration.nextCalibrationDue': { $lt: new Date() } }
    ],
    isActive: true
  }).populate('farm');
};

// Static method to get sensor statistics
sensorSchema.statics.getStatistics = async function() {
  const stats = await this.aggregate([
    {
      $group: {
        _id: null,
        totalSensors: { $sum: 1 },
        activeSensors: {
          $sum: { $cond: [{ $eq: ['$status', 'active'] }, 1, 0] }
        },
        sensorsByType: {
          $push: '$type'
        },
        sensorsByStatus: {
          $push: '$status'
        },
        averageBatteryLevel: {
          $avg: '$lastReading.batteryLevel'
        }
      }
    }
  ]);

  return stats[0] || {
    totalSensors: 0,
    activeSensors: 0,
    sensorsByType: [],
    sensorsByStatus: [],
    averageBatteryLevel: 0
  };
};

// Instance method to update last reading
sensorSchema.methods.updateLastReading = function(batteryLevel?: number, signalStrength?: number) {
  this.lastReading = {
    timestamp: new Date(),
    batteryLevel,
    signalStrength
  };
  return this.save();
};

// Instance method to check if sensor needs calibration
sensorSchema.methods.needsCalibration = function() {
  if (!this.calibration?.nextCalibrationDue) return false;
  return this.calibration.nextCalibrationDue < new Date();
};

// Instance method to schedule next calibration
sensorSchema.methods.scheduleCalibration = function(daysFromNow: number = 90) {
  const nextCalibrationDate = new Date();
  nextCalibrationDate.setDate(nextCalibrationDate.getDate() + daysFromNow);
  
  this.calibration = {
    ...this.calibration,
    nextCalibrationDue: nextCalibrationDate
  };
  
  return this.save();
};

// Instance method to check alert thresholds
sensorSchema.methods.checkAlertThresholds = function(sensorData: any) {
  if (!this.alerts?.enabled) return [];
  
  const alerts = [];
  const thresholds = this.alerts.thresholds;
  
  // Check temperature
  if (sensorData.temperature && thresholds.temperature) {
    if (thresholds.temperature.min && sensorData.temperature < thresholds.temperature.min) {
      alerts.push({ type: 'temperature_low', value: sensorData.temperature, threshold: thresholds.temperature.min });
    }
    if (thresholds.temperature.max && sensorData.temperature > thresholds.temperature.max) {
      alerts.push({ type: 'temperature_high', value: sensorData.temperature, threshold: thresholds.temperature.max });
    }
  }
  
  // Check humidity
  if (sensorData.humidity && thresholds.humidity) {
    if (thresholds.humidity.min && sensorData.humidity < thresholds.humidity.min) {
      alerts.push({ type: 'humidity_low', value: sensorData.humidity, threshold: thresholds.humidity.min });
    }
    if (thresholds.humidity.max && sensorData.humidity > thresholds.humidity.max) {
      alerts.push({ type: 'humidity_high', value: sensorData.humidity, threshold: thresholds.humidity.max });
    }
  }
  
  // Check soil moisture
  if (sensorData.soilMoisture && thresholds.soilMoisture) {
    if (thresholds.soilMoisture.min && sensorData.soilMoisture < thresholds.soilMoisture.min) {
      alerts.push({ type: 'soil_moisture_low', value: sensorData.soilMoisture, threshold: thresholds.soilMoisture.min });
    }
    if (thresholds.soilMoisture.max && sensorData.soilMoisture > thresholds.soilMoisture.max) {
      alerts.push({ type: 'soil_moisture_high', value: sensorData.soilMoisture, threshold: thresholds.soilMoisture.max });
    }
  }
  
  // Check battery level
  if (sensorData.batteryLevel && thresholds.batteryLevel?.min) {
    if (sensorData.batteryLevel < thresholds.batteryLevel.min) {
      alerts.push({ type: 'battery_low', value: sensorData.batteryLevel, threshold: thresholds.batteryLevel.min });
    }
  }
  
  return alerts;
};

const Sensor = mongoose.model<ISensor, ISensorModel>('Sensor', sensorSchema);

export default Sensor;

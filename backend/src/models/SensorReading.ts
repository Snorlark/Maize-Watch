import mongoose, { Document, Schema, Model } from 'mongoose';

// Define interface for static methods
export interface ISensorReadingModel extends Model<ISensorReading> {
  findBySensor(sensorId: string, limit?: number): Promise<ISensorReading[]>;
  findByFarm(farmId: string, limit?: number): Promise<ISensorReading[]>;
  findByDateRange(startDate: Date, endDate: Date, sensorId?: string, farmId?: string): Promise<ISensorReading[]>;
  findAnomalies(farmId?: string): Promise<ISensorReading[]>;
  getLatestByFarm(farmId: string): Promise<ISensorReading[]>;
  getAggregatedData(farmId: string, startDate: Date, endDate: Date, interval?: 'hour' | 'day' | 'week' | 'month'): Promise<any[]>;
}

export interface ISensorReading extends Document {
  sensor: mongoose.Types.ObjectId;
  farm: mongoose.Types.ObjectId;
  timestamp: Date;
  data: {
    temperature?: number;
    humidity?: number;
    soilMoisture?: number;
    lightIntensity?: number;
    pH?: number;
    batteryLevel?: number;
    signalStrength?: number;
    customFields?: Record<string, number>;
  };
  metadata: {
    source: 'thingspeak' | 'direct' | 'manual' | 'simulation';
    quality: 'good' | 'fair' | 'poor' | 'error';
    processed: boolean;
    anomaly?: boolean;
    calibrated?: boolean;
  };
  location?: {
    coordinates: [number, number];
  };
  alerts?: Array<{
    type: string;
    severity: 'low' | 'medium' | 'high' | 'critical';
    message: string;
    acknowledged: boolean;
    acknowledgedBy?: mongoose.Types.ObjectId;
    acknowledgedAt?: Date;
  }>;
  createdAt: Date;
  updatedAt: Date;
  
  // Instance methods
  acknowledgeAlerts(userId: string): Promise<ISensorReading>;
  addAlert(type: string, severity: 'low' | 'medium' | 'high' | 'critical', message: string): Promise<ISensorReading>;
  assessDataQuality(): { quality: 'good' | 'fair' | 'poor' | 'error'; qualityScore: number; issues: string[] };
}

const sensorReadingSchema = new Schema<ISensorReading>(
  {
    sensor: {
      type: Schema.Types.ObjectId,
      ref: 'Sensor',
      required: [true, 'Sensor reference is required'],
    },
    farm: {
      type: Schema.Types.ObjectId,
      ref: 'Farm',
      required: [true, 'Farm reference is required'],
    },
    timestamp: {
      type: Date,
      required: [true, 'Timestamp is required'],
      default: Date.now,
    },
    data: {
      temperature: {
        type: Number,
        min: [-50, 'Temperature cannot be below -50°C'],
        max: [100, 'Temperature cannot be above 100°C'],
      },
      humidity: {
        type: Number,
        min: [0, 'Humidity cannot be below 0%'],
        max: [100, 'Humidity cannot be above 100%'],
      },
      soilMoisture: {
        type: Number,
        min: [0, 'Soil moisture cannot be below 0%'],
        max: [100, 'Soil moisture cannot be above 100%'],
      },
      lightIntensity: {
        type: Number,
        min: [0, 'Light intensity cannot be negative'],
        max: [100000, 'Light intensity seems too high'],
      },
      pH: {
        type: Number,
        min: [0, 'pH cannot be below 0'],
        max: [14, 'pH cannot be above 14'],
      },
      batteryLevel: {
        type: Number,
        min: [0, 'Battery level cannot be below 0%'],
        max: [100, 'Battery level cannot be above 100%'],
      },
      signalStrength: {
        type: Number,
        min: [-120, 'Signal strength too low'],
        max: [0, 'Signal strength cannot be positive'],
      },
      customFields: {
        type: Schema.Types.Mixed,
        default: {},
      },
    },
    metadata: {
      source: {
        type: String,
        enum: ['thingspeak', 'direct', 'manual', 'simulation'],
        required: [true, 'Data source is required'],
        default: 'thingspeak',
      },
      quality: {
        type: String,
        enum: ['good', 'fair', 'poor', 'error'],
        default: 'good',
      },
      processed: {
        type: Boolean,
        default: false,
      },
      anomaly: {
        type: Boolean,
        default: false,
      },
      calibrated: {
        type: Boolean,
        default: true,
      },
    },
    location: {
      coordinates: {
        type: [Number],
        validate: {
          validator: function(coords: number[]) {
            return !coords || (coords.length === 2 && 
                   coords[0] >= -180 && coords[0] <= 180 && // longitude
                   coords[1] >= -90 && coords[1] <= 90);     // latitude
          },
          message: 'Invalid coordinates format [longitude, latitude]'
        }
      },
    },
    alerts: [{
      type: {
        type: String,
        required: true,
      },
      severity: {
        type: String,
        enum: ['low', 'medium', 'high', 'critical'],
        required: true,
      },
      message: {
        type: String,
        required: true,
      },
      acknowledged: {
        type: Boolean,
        default: false,
      },
      acknowledgedBy: {
        type: Schema.Types.ObjectId,
        ref: 'User',
      },
      acknowledgedAt: Date,
    }],
  },
  {
    timestamps: true,
    collection: 'sensor_readings',
    toJSON: {
      transform: function(doc, ret) {
        delete (ret as any).__v;
        return ret;
      },
    },
  }
);

// Create indexes for performance
sensorReadingSchema.index({ sensor: 1, timestamp: -1 });
sensorReadingSchema.index({ farm: 1, timestamp: -1 });
sensorReadingSchema.index({ timestamp: -1 });
sensorReadingSchema.index({ 'metadata.source': 1, timestamp: -1 });
sensorReadingSchema.index({ 'metadata.quality': 1 });
sensorReadingSchema.index({ 'metadata.anomaly': 1 });
sensorReadingSchema.index({ 'alerts.acknowledged': 1, 'alerts.severity': 1 });

// Create geospatial index if location is provided
sensorReadingSchema.index({ 'location.coordinates': '2dsphere' });

// TTL index to automatically delete old readings (optional - keep 1 year)
sensorReadingSchema.index({ createdAt: 1 }, { expireAfterSeconds: 365 * 24 * 60 * 60 });

// Virtual for data completeness score
sensorReadingSchema.virtual('completenessScore').get(function() {
  const data = this.data;
  const fields = [
    data.temperature,
    data.humidity,
    data.soilMoisture,
    data.lightIntensity,
    data.pH
  ];
  const presentFields = fields.filter(value => value !== undefined && value !== null);
  return (presentFields.length / fields.length) * 100;
});

// Virtual for alert count
sensorReadingSchema.virtual('alertCount').get(function() {
  return this.alerts?.length || 0;
});

// Virtual for unacknowledged alert count
sensorReadingSchema.virtual('unacknowledgedAlertCount').get(function() {
  return this.alerts?.filter(alert => !alert.acknowledged).length || 0;
});

// Static method to find readings by sensor
sensorReadingSchema.statics.findBySensor = function(sensorId: string, limit: number = 100) {
  return this.find({ sensor: sensorId })
    .sort({ timestamp: -1 })
    .limit(limit)
    .populate('sensor', 'name type sensorId')
    .populate('farm', 'name owner');
};

// Static method to find readings by farm
sensorReadingSchema.statics.findByFarm = function(farmId: string, limit: number = 100) {
  return this.find({ farm: farmId })
    .sort({ timestamp: -1 })
    .limit(limit)
    .populate('sensor', 'name type sensorId')
    .populate('farm', 'name owner');
};

// Static method to find readings within date range
sensorReadingSchema.statics.findByDateRange = function(
  startDate: Date, 
  endDate: Date, 
  sensorId?: string, 
  farmId?: string
) {
  const query: any = {
    timestamp: { $gte: startDate, $lte: endDate }
  };
  
  if (sensorId) query.sensor = sensorId;
  if (farmId) query.farm = farmId;
  
  return this.find(query)
    .sort({ timestamp: -1 })
    .populate('sensor', 'name type sensorId')
    .populate('farm', 'name owner');
};

// Static method to find anomalous readings
sensorReadingSchema.statics.findAnomalies = function(farmId?: string) {
  const query: any = { 'metadata.anomaly': true };
  if (farmId) query.farm = farmId;
  
  return this.find(query)
    .sort({ timestamp: -1 })
    .populate('sensor', 'name type sensorId')
    .populate('farm', 'name owner');
};

// Static method to get latest readings for a farm
sensorReadingSchema.statics.getLatestByFarm = function(farmId: string) {
  return this.aggregate([
    { $match: { farm: new mongoose.Types.ObjectId(farmId) } },
    { $sort: { timestamp: -1 } },
    {
      $group: {
        _id: '$sensor',
        latestReading: { $first: '$$ROOT' }
      }
    },
    {
      $lookup: {
        from: 'sensors',
        localField: '_id',
        foreignField: '_id',
        as: 'sensor'
      }
    },
    { $unwind: '$sensor' },
    {
      $replaceRoot: {
        newRoot: {
          $mergeObjects: ['$latestReading', { sensor: '$sensor' }]
        }
      }
    }
  ]);
};

// Static method to get aggregated data for analytics
sensorReadingSchema.statics.getAggregatedData = function(
  farmId: string,
  startDate: Date,
  endDate: Date,
  interval: 'hour' | 'day' | 'week' | 'month' = 'day'
) {
  const groupBy: any = {
    farm: '$farm',
    sensor: '$sensor'
  };

  // Define grouping based on interval
  switch (interval) {
    case 'hour':
      groupBy.year = { $year: '$timestamp' };
      groupBy.month = { $month: '$timestamp' };
      groupBy.day = { $dayOfMonth: '$timestamp' };
      groupBy.hour = { $hour: '$timestamp' };
      break;
    case 'day':
      groupBy.year = { $year: '$timestamp' };
      groupBy.month = { $month: '$timestamp' };
      groupBy.day = { $dayOfMonth: '$timestamp' };
      break;
    case 'week':
      groupBy.year = { $year: '$timestamp' };
      groupBy.week = { $week: '$timestamp' };
      break;
    case 'month':
      groupBy.year = { $year: '$timestamp' };
      groupBy.month = { $month: '$timestamp' };
      break;
  }

  return this.aggregate([
    {
      $match: {
        farm: new mongoose.Types.ObjectId(farmId),
        timestamp: { $gte: startDate, $lte: endDate },
        'metadata.quality': { $ne: 'error' }
      }
    },
    {
      $group: {
        _id: groupBy,
        avgTemperature: { $avg: '$data.temperature' },
        avgHumidity: { $avg: '$data.humidity' },
        avgSoilMoisture: { $avg: '$data.soilMoisture' },
        avgLightIntensity: { $avg: '$data.lightIntensity' },
        avgPH: { $avg: '$data.pH' },
        minTemperature: { $min: '$data.temperature' },
        maxTemperature: { $max: '$data.temperature' },
        minHumidity: { $min: '$data.humidity' },
        maxHumidity: { $max: '$data.humidity' },
        readingCount: { $sum: 1 },
        alertCount: { $sum: { $size: { $ifNull: ['$alerts', []] } } }
      }
    },
    { $sort: { '_id.year': 1, '_id.month': 1, '_id.day': 1, '_id.hour': 1 } }
  ]);
};

// Instance method to acknowledge alerts
sensorReadingSchema.methods.acknowledgeAlerts = function(userId: string) {
  if (!this.alerts) return this;
  
  this.alerts.forEach((alert: {
    type: string;
    severity: 'low' | 'medium' | 'high' | 'critical';
    message: string;
    acknowledged: boolean;
    acknowledgedBy?: mongoose.Types.ObjectId;
    acknowledgedAt?: Date;
  }) => {
    if (!alert.acknowledged) {
      alert.acknowledged = true;
      alert.acknowledgedBy = new mongoose.Types.ObjectId(userId);
      alert.acknowledgedAt = new Date();
    }
  });
  
  return this.save();
};

// Instance method to add alert
sensorReadingSchema.methods.addAlert = function(
  type: string, 
  severity: 'low' | 'medium' | 'high' | 'critical', 
  message: string
) {
  if (!this.alerts) this.alerts = [];
  
  this.alerts.push({
    type,
    severity,
    message,
    acknowledged: false
  });
  
  return this.save();
};

// Instance method to check data quality
sensorReadingSchema.methods.assessDataQuality = function() {
  const data = this.data;
  let qualityScore = 100;
  const issues = [];

  // Check for missing critical data
  if (data.temperature === undefined || data.temperature === null) {
    qualityScore -= 20;
    issues.push('Missing temperature data');
  }
  
  if (data.humidity === undefined || data.humidity === null) {
    qualityScore -= 20;
    issues.push('Missing humidity data');
  }

  // Check for unrealistic values
  if (data.temperature !== undefined && (data.temperature < -40 || data.temperature > 60)) {
    qualityScore -= 30;
    issues.push('Unrealistic temperature reading');
  }
  
  if (data.humidity !== undefined && (data.humidity < 0 || data.humidity > 100)) {
    qualityScore -= 30;
    issues.push('Invalid humidity reading');
  }

  // Determine quality level
  let quality: 'good' | 'fair' | 'poor' | 'error';
  if (qualityScore >= 80) quality = 'good';
  else if (qualityScore >= 60) quality = 'fair';
  else if (qualityScore >= 30) quality = 'poor';
  else quality = 'error';

  this.metadata.quality = quality;
  
  return { quality, qualityScore, issues };
};

const SensorReading = mongoose.model<ISensorReading, ISensorReadingModel>('SensorReading', sensorReadingSchema);

export default SensorReading;

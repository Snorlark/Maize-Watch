import mongoose, { Document, Schema, Model } from 'mongoose';

// Interface for static methods
interface IFarmModel extends Model<IFarm> {
  getStatistics(): Promise<any>;
}

export interface IFarm extends Document {
  userId: mongoose.Types.ObjectId;
  fieldName: string;
  location: string;
  soilType: string;
  plantingDate: Date;
  growthStage: string;
  // Device linking for prototype security
  deviceId?: string;
  deviceMacAddress?: string;
  deviceRegisteredAt?: Date;
  createdAt: Date;
  updatedAt: Date;
  
  // Instance methods
  linkDevice(deviceId: string, macAddress?: string): Promise<IFarm>;
  unlinkDevice(): Promise<IFarm>;
}

const farmSchema = new Schema<IFarm>(
  {
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
    plantingDate: {
      type: Date,
      required: true
    },
    growthStage: {
      type: String,
      required: true,
      default: 'VE' // Initial growth stage
    },
    deviceId: {
      type: String,
      unique: true,
      sparse: true,
    },
    deviceMacAddress: {
      type: String,
      unique: true,
      sparse: true,
    },
    deviceRegisteredAt: {
      type: Date,
    }
  },
  { 
    timestamps: true,
    collection: 'farms'
  }
);

// Compound indexes for performance
farmSchema.index({ userId: 1 });
farmSchema.index({ deviceId: 1 });
farmSchema.index({ deviceMacAddress: 1 });
farmSchema.index({ growthStage: 1 });

// Virtual for days since planting
farmSchema.virtual('daysSincePlanting').get(function() {
  if (!this.plantingDate) return null;
  const now = new Date();
  const diffTime = Math.abs(now.getTime() - this.plantingDate.getTime());
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
});


// Static method to get farm statistics
farmSchema.statics.getStatistics = async function() {
  const stats = await this.aggregate([
    {
      $group: {
        _id: null,
        totalFarms: { $sum: 1 },
        farmsWithDevices: {
          $sum: { $cond: [{ $ne: ['$deviceId', null] }, 1, 0] }
        },
        farmsByGrowthStage: {
          $push: '$growthStage'
        },
        farmsBySoilType: {
          $push: '$soilType'
        }
      }
    }
  ]);

  return stats[0] || {
    totalFarms: 0,
    farmsWithDevices: 0,
    farmsByGrowthStage: [],
    farmsBySoilType: []
  };
};

// Instance method to link device
farmSchema.methods.linkDevice = function(deviceId: string, macAddress?: string) {
  this.deviceId = deviceId;
  if (macAddress) {
    this.deviceMacAddress = macAddress;
  }
  this.deviceRegisteredAt = new Date();
  return this.save();
};

// Instance method to unlink device
farmSchema.methods.unlinkDevice = function() {
  this.deviceId = undefined;
  this.deviceMacAddress = undefined;
  this.deviceRegisteredAt = undefined;
  return this.save();
};

const Farm = mongoose.model<IFarm, IFarmModel>('Farm', farmSchema);

export default Farm;

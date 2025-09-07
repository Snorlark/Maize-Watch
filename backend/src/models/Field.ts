import mongoose, { Document, Schema, Model } from "mongoose";

// Interface for static methods
interface IFieldModel extends Model<IField> {
  getStatistics(): Promise<any>;
}

export interface IField extends Document {
  farmId: mongoose.Types.ObjectId;
  fieldName: string;
  soilType: string;
  plantingDate: Date;
  growthStage: string;
  // Devices/sensors array for this specific field
  devices: Array<{
    sensorId: string;
    name: string;
    deviceMacAddress?: string;
    status: "active" | "inactive" | "maintenance";
    registeredAt: Date;
    location?: {
      coordinates: [number, number];
      description?: string;
    };
  }>;
  createdAt: Date;
  updatedAt: Date;

  // Instance methods
  addDevice(deviceData: any): Promise<IField>;
  removeDevice(sensorId: string): Promise<IField>;
  updateGrowthStage(): Promise<IField>;
}

const fieldSchema = new Schema<IField>(
  {
    farmId: {
      type: Schema.Types.ObjectId,
      ref: "Farm",
      required: true,
    },
    fieldName: {
      type: String,
      required: true,
    },
    soilType: {
      type: String,
      required: true,
      enum: ["loamy", "sandy", "clay", "silty"],
    },
    plantingDate: {
      type: Date,
      required: true,
    },
    growthStage: {
      type: String,
      required: true,
      default: "VE", // Initial growth stage
    },
    // Devices/sensors array for this field
    devices: [
      {
        sensorId: {
          type: String,
          required: true,
        },
        name: {
          type: String,
          required: true,
        },
        deviceMacAddress: {
          type: String,
        },
        status: {
          type: String,
          enum: ["active", "inactive", "maintenance"],
          default: "active",
        },
        registeredAt: {
          type: Date,
          default: Date.now,
        },
        location: {
          coordinates: {
            type: [Number],
            default: [121.0244, 14.5995], // Default Manila coordinates
          },
          description: {
            type: String,
            default: "Field sensor location",
          },
        },
      },
    ],
  },
  {
    timestamps: true,
    collection: "fields",
  }
);

// Compound indexes for performance
fieldSchema.index({ farmId: 1 });
fieldSchema.index({ fieldName: 1, farmId: 1 }, { unique: true });
fieldSchema.index({ growthStage: 1 });
fieldSchema.index({ "devices.sensorId": 1 });

// Virtual for days since planting
fieldSchema.virtual("daysSincePlanting").get(function () {
  if (!this.plantingDate) return null;
  const now = new Date();
  const diffTime = Math.abs(now.getTime() - this.plantingDate.getTime());
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
});

// Pre-save middleware to auto-update growth stage based on planting date
fieldSchema.pre("save", function (next) {
  if (this.plantingDate) {
    const now = new Date();
    const diffTime = Math.abs(now.getTime() - this.plantingDate.getTime());
    const daysSincePlanting = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    if (daysSincePlanting <= 7)
      this.growthStage = "VE"; // Emergence (0-7 days)
    else if (daysSincePlanting <= 21)
      this.growthStage = "V3"; // 3rd leaf (8-21 days)
    else if (daysSincePlanting <= 42)
      this.growthStage = "V8"; // 8th leaf (22-42 days)
    else if (daysSincePlanting <= 65)
      this.growthStage = "VT"; // Tasseling (43-65 days)
    else if (daysSincePlanting <= 85)
      this.growthStage = "R1"; // Silking (66-85 days)
    else this.growthStage = "R6"; // Maturity (86+ days)
  }
  next();
});

// Static method to get field statistics
fieldSchema.statics.getStatistics = async function () {
  const stats = await this.aggregate([
    {
      $group: {
        _id: null,
        totalFields: { $sum: 1 },
        fieldsWithDevices: {
          $sum: { $cond: [{ $gt: [{ $size: "$devices" }, 0] }, 1, 0] },
        },
        fieldsByGrowthStage: {
          $push: "$growthStage",
        },
        fieldsBySoilType: {
          $push: "$soilType",
        },
      },
    },
  ]);

  return (
    stats[0] || {
      totalFields: 0,
      fieldsWithDevices: 0,
      fieldsByGrowthStage: [],
      fieldsBySoilType: [],
    }
  );
};

// Instance method to add device
fieldSchema.methods.addDevice = function (deviceData: any) {
  this.devices.push({
    sensorId: deviceData.sensorId,
    name: deviceData.name,
    deviceMacAddress: deviceData.deviceMacAddress,
    status: deviceData.status || "active",
    registeredAt: new Date(),
    location: deviceData.location || {
      coordinates: [121.0244, 14.5995],
      description: "Field sensor location",
    },
  });
  return this.save();
};

// Instance method to remove device
fieldSchema.methods.removeDevice = function (sensorId: string) {
  this.devices = this.devices.filter(
    (device: any) => device.sensorId !== sensorId
  );
  return this.save();
};

// Instance method to update growth stage
fieldSchema.methods.updateGrowthStage = function () {
  // Growth stage is automatically updated in pre-save middleware
  return this.save();
};

const Field = mongoose.model<IField, IFieldModel>("Field", fieldSchema);

export default Field;

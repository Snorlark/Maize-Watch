import mongoose, { Document, Schema, Model } from 'mongoose';

export interface IPrototype extends Document {
  prototype_id: string;
  channel_id: string;
  api_key: string;
  thingspeak_url: string;
  isActive: boolean;
  registeredBy?: mongoose.Types.ObjectId;
  registeredAt?: Date;
  measurements: {
    temperature: boolean;
    humidity: boolean;
    soilMoisture: boolean;
    soilPh: boolean;
    lightIntensity: boolean;
  };
  createdAt: Date;
  updatedAt: Date;
}

export interface IPrototypeModel extends Model<IPrototype> {
  findByPrototypeId(prototypeId: string): Promise<IPrototype | null>;
  isAvailable(prototypeId: string): Promise<boolean>;
  registerPrototype(prototypeId: string, userId: string): Promise<IPrototype>;
  getAvailablePrototypes(): Promise<IPrototype[]>;
}

const prototypeSchema = new Schema<IPrototype>(
  {
    prototype_id: {
      type: String,
      required: [true, 'Prototype ID is required'],
      unique: true,
      trim: true,
      uppercase: true,
      match: [/^[A-Z0-9_-]+$/, 'Prototype ID can only contain uppercase letters, numbers, underscores, and hyphens'],
    },
    channel_id: {
      type: String,
      required: [true, 'Channel ID is required'],
      trim: true,
    },
    api_key: {
      type: String,
      required: [true, 'API key is required'],
      trim: true,
    },
    thingspeak_url: {
      type: String,
      required: [true, 'ThingSpeak URL is required'],
      trim: true,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    registeredBy: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: false,
    },
    registeredAt: {
      type: Date,
      required: false,
    },
    measurements: {
      temperature: {
        type: Boolean,
        default: true,
      },
      humidity: {
        type: Boolean,
        default: true,
      },
      soilMoisture: {
        type: Boolean,
        default: true,
      },
      soilPh: {
        type: Boolean,
        default: true,
      },
      lightIntensity: {
        type: Boolean,
        default: true,
      },
    },
  },
  {
    timestamps: true,
    collection: 'prototypes',
    toJSON: {
      transform: function(doc: any, ret: any) {
        delete ret.__v;
        delete ret.api_key; // Don't expose API key in responses
        return ret;
      },
    },
  }
);

// Create indexes
prototypeSchema.index({ prototype_id: 1 }, { unique: true });
prototypeSchema.index({ registeredBy: 1 });
prototypeSchema.index({ isActive: 1 });

// Static method to find prototype by ID
prototypeSchema.statics.findByPrototypeId = function(prototypeId: string) {
  return this.findOne({ prototype_id: prototypeId.toUpperCase(), isActive: true });
};

// Static method to check if prototype is available
prototypeSchema.statics.isAvailable = function(prototypeId: string) {
  return this.findOne({ 
    prototype_id: prototypeId.toUpperCase(), 
    isActive: true,
    registeredBy: { $exists: false }
  }).then((prototype: IPrototype | null) => prototype !== null);
};

// Static method to register prototype to user
prototypeSchema.statics.registerPrototype = function(prototypeId: string, userId: string) {
  return this.findOneAndUpdate(
    { 
      prototype_id: prototypeId.toUpperCase(), 
      isActive: true,
      registeredBy: { $exists: false }
    },
    { 
      registeredBy: new mongoose.Types.ObjectId(userId),
      registeredAt: new Date()
    },
    { new: true }
  );
};

// Static method to get available prototypes
prototypeSchema.statics.getAvailablePrototypes = function() {
  return this.find({ 
    isActive: true,
    registeredBy: { $exists: false }
  }).select('prototype_id channel_id thingspeak_url measurements');
};

const Prototype = mongoose.model<IPrototype, IPrototypeModel>('Prototype', prototypeSchema);

export default Prototype;

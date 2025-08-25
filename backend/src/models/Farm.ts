import mongoose, { Document, Schema, Model } from 'mongoose';

// Interface for static methods
interface IFarmModel extends Model<IFarm> {
  findNearby(longitude: number, latitude: number, maxDistance?: number): Promise<IFarm[]>;
  getStatistics(): Promise<any>;
}

export interface IFarm extends Document {
  name: string;
  description?: string;
  owner: mongoose.Types.ObjectId;
  location: {
    coordinates: [number, number]; // [longitude, latitude]
    address: {
      region: string;
      province: string;
      municipality: string;
      barangay: string;
      zipCode?: string;
    };
  };
  area: {
    size: number;
    unit: 'hectares' | 'square_meters' | 'acres';
  };
  cropType: string;
  plantingDate?: Date;
  expectedHarvestDate?: Date;
  status: 'active' | 'inactive' | 'harvested' | 'preparing';
  sensors: mongoose.Types.ObjectId[];
  weatherData?: {
    lastUpdated: Date;
    temperature: number;
    humidity: number;
    rainfall: number;
    windSpeed: number;
  };
  soilData?: {
    lastUpdated: Date;
    pH: number;
    nitrogen: number;
    phosphorus: number;
    potassium: number;
    organicMatter: number;
  };
  images: string[];
  notes: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  
  // Instance methods
  getAreaInUnit(targetUnit: 'hectares' | 'square_meters' | 'acres'): number;
  updateWeatherData(weatherData: any): Promise<IFarm>;
  updateSoilData(soilData: any): Promise<IFarm>;
}

const farmSchema = new Schema<IFarm>(
  {
    name: {
      type: String,
      required: [true, 'Farm name is required'],
      trim: true,
      maxlength: [100, 'Farm name cannot exceed 100 characters'],
    },
    description: {
      type: String,
      trim: true,
      maxlength: [500, 'Description cannot exceed 500 characters'],
    },
    owner: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Farm owner is required'],
    },
    location: {
      coordinates: {
        type: [Number],
        required: [true, 'Farm coordinates are required'],
        validate: {
          validator: function(coords: number[]) {
            return coords.length === 2 && 
                   coords[0] >= -180 && coords[0] <= 180 && // longitude
                   coords[1] >= -90 && coords[1] <= 90;     // latitude
          },
          message: 'Invalid coordinates format [longitude, latitude]'
        }
      },
      address: {
        region: {
          type: String,
          required: [true, 'Region is required'],
          enum: [
            'National Capital Region (NCR)',
            'Cordillera Administrative Region (CAR)',
            'Ilocos Region (Region I)',
            'Cagayan Valley (Region II)',
            'Central Luzon (Region III)',
            'CALABARZON (Region IV-A)',
            'MIMAROPA Region (Region IV-B)',
            'Bicol Region (Region V)',
            'Western Visayas (Region VI)',
            'Central Visayas (Region VII)',
            'Eastern Visayas (Region VIII)',
            'Zamboanga Peninsula (Region IX)',
            'Northern Mindanao (Region X)',
            'Davao Region (Region XI)',
            'SOCCSKSARGEN (Region XII)',
            'Caraga (Region XIII)',
            'Bangsamoro Autonomous Region in Muslim Mindanao (BARMM)',
          ],
        },
        province: {
          type: String,
          required: [true, 'Province is required'],
          trim: true,
        },
        municipality: {
          type: String,
          required: [true, 'Municipality is required'],
          trim: true,
        },
        barangay: {
          type: String,
          required: [true, 'Barangay is required'],
          trim: true,
        },
        zipCode: {
          type: String,
          match: [/^\d{4}$/, 'Please enter a valid 4-digit zip code'],
        },
      },
    },
    area: {
      size: {
        type: Number,
        required: [true, 'Farm area size is required'],
        min: [0.01, 'Farm area must be greater than 0'],
      },
      unit: {
        type: String,
        enum: ['hectares', 'square_meters', 'acres'],
        default: 'hectares',
      },
    },
    cropType: {
      type: String,
      required: [true, 'Crop type is required'],
      trim: true,
      enum: [
        'Corn',
        'Rice',
        'Wheat',
        'Sugarcane',
        'Coconut',
        'Banana',
        'Mango',
        'Vegetables',
        'Other',
      ],
    },
    plantingDate: {
      type: Date,
    },
    expectedHarvestDate: {
      type: Date,
    },
    status: {
      type: String,
      enum: ['active', 'inactive', 'harvested', 'preparing'],
      default: 'active',
    },
    sensors: [{
      type: Schema.Types.ObjectId,
      ref: 'Sensor',
    }],
    weatherData: {
      lastUpdated: Date,
      temperature: Number,
      humidity: Number,
      rainfall: Number,
      windSpeed: Number,
    },
    soilData: {
      lastUpdated: Date,
      pH: {
        type: Number,
        min: 0,
        max: 14,
      },
      nitrogen: Number,
      phosphorus: Number,
      potassium: Number,
      organicMatter: Number,
    },
    images: [{
      type: String,
    }],
    notes: {
      type: String,
      maxlength: [1000, 'Notes cannot exceed 1000 characters'],
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
    collection: 'farms',
    toJSON: {
      transform: function(doc, ret) {
        delete (ret as any).__v;
        return ret;
      },
    },
  }
);

// Create geospatial index for location-based queries
farmSchema.index({ 'location.coordinates': '2dsphere' });

// Compound indexes for performance
farmSchema.index({ owner: 1, isActive: 1 });
farmSchema.index({ status: 1, isActive: 1 });
farmSchema.index({ cropType: 1, status: 1 });
farmSchema.index({ 'location.address.region': 1, 'location.address.province': 1 });

// Virtual for farm age in days
farmSchema.virtual('ageInDays').get(function() {
  if (!this.plantingDate) return null;
  const now = new Date();
  const diffTime = Math.abs(now.getTime() - this.plantingDate.getTime());
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
});

// Virtual for days until harvest
farmSchema.virtual('daysUntilHarvest').get(function() {
  if (!this.expectedHarvestDate) return null;
  const now = new Date();
  const diffTime = this.expectedHarvestDate.getTime() - now.getTime();
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
});

// Static method to find farms near a location
farmSchema.statics.findNearby = function(longitude: number, latitude: number, maxDistance: number = 10000) {
  return this.find({
    'location.coordinates': {
      $near: {
        $geometry: {
          type: 'Point',
          coordinates: [longitude, latitude]
        },
        $maxDistance: maxDistance // in meters
      }
    },
    isActive: true
  });
};

// Static method to get farm statistics
farmSchema.statics.getStatistics = async function() {
  const stats = await this.aggregate([
    {
      $group: {
        _id: null,
        totalFarms: { $sum: 1 },
        activeFarms: {
          $sum: { $cond: [{ $eq: ['$status', 'active'] }, 1, 0] }
        },
        totalArea: { $sum: '$area.size' },
        farmsByStatus: {
          $push: '$status'
        },
        farmsByCrop: {
          $push: '$cropType'
        },
        farmsByRegion: {
          $push: '$location.address.region'
        }
      }
    }
  ]);

  return stats[0] || {
    totalFarms: 0,
    activeFarms: 0,
    totalArea: 0,
    farmsByStatus: [],
    farmsByCrop: [],
    farmsByRegion: []
  };
};

// Instance method to calculate area in different units
farmSchema.methods.getAreaInUnit = function(targetUnit: 'hectares' | 'square_meters' | 'acres') {
  const { size, unit } = this.area;
  
  // Convert to square meters first
  let sizeInSquareMeters: number;
  switch (unit) {
    case 'hectares':
      sizeInSquareMeters = size * 10000;
      break;
    case 'acres':
      sizeInSquareMeters = size * 4046.86;
      break;
    default:
      sizeInSquareMeters = size;
  }
  
  // Convert to target unit
  switch (targetUnit) {
    case 'hectares':
      return sizeInSquareMeters / 10000;
    case 'acres':
      return sizeInSquareMeters / 4046.86;
    default:
      return sizeInSquareMeters;
  }
};

// Instance method to update weather data
farmSchema.methods.updateWeatherData = function(weatherData: any) {
  this.weatherData = {
    ...weatherData,
    lastUpdated: new Date()
  };
  return this.save();
};

// Instance method to update soil data
farmSchema.methods.updateSoilData = function(soilData: any) {
  this.soilData = {
    ...soilData,
    lastUpdated: new Date()
  };
  return this.save();
};

const Farm = mongoose.model<IFarm, IFarmModel>('Farm', farmSchema);

export default Farm;

const mongoose = require('mongoose');
require('dotenv').config();

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/maize-watch');
    console.log('MongoDB connected successfully');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
};

// Prototype schema (simplified for seeding)
const prototypeSchema = new mongoose.Schema({
  prototype_id: { type: String, required: true, unique: true, uppercase: true },
  channel_id: { type: String, required: true },
  api_key: { type: String, required: true },
  thingspeak_url: { type: String, required: true },
  isActive: { type: Boolean, default: true },
  measurements: {
    temperature: { type: Boolean, default: true },
    humidity: { type: Boolean, default: true },
    soilMoisture: { type: Boolean, default: true },
    soilPh: { type: Boolean, default: true },
    lightIntensity: { type: Boolean, default: true }
  }
}, {
  timestamps: true,
  collection: 'prototypes'
});

const Prototype = mongoose.model('Prototype', prototypeSchema);

// Sample prototype data based on the image
const samplePrototypes = [
  {
    prototype_id: 'PROTO_001',
    channel_id: '3062750',
    api_key: 'TFISWV8UFLL0NRL3',
    thingspeak_url: 'https://api.thingspeak.com/channels/3062750/feeds.json?api_key=TFISWV8UFLL0NRL3&results=2',
    measurements: {
      temperature: true,
      humidity: true,
      soilMoisture: true,
      soilPh: true,
      lightIntensity: true
    }
  },
  {
    prototype_id: 'PROTO_002',
    channel_id: '3083651',
    api_key: 'I33WO1DMIHVA0EQY',
    thingspeak_url: 'https://api.thingspeak.com/channels/3083651/feeds.json?api_key=I33WO1DMIHVA0EQY&results=2',
    measurements: {
      temperature: true,
      humidity: true,
      soilMoisture: true,
      soilPh: true,
      lightIntensity: true
    }
  },
  {
    prototype_id: 'SENSOR_001',
    channel_id: '3062750',
    api_key: 'TFISWV8UFLL0NRL3',
    thingspeak_url: 'https://api.thingspeak.com/channels/3062750/feeds.json?api_key=TFISWV8UFLL0NRL3&results=2',
    measurements: {
      temperature: true,
      humidity: true,
      soilMoisture: true,
      soilPh: false,
      lightIntensity: true
    }
  },
  {
    prototype_id: 'SENSOR_002',
    channel_id: '3083651',
    api_key: 'I33WO1DMIHVA0EQY',
    thingspeak_url: 'https://api.thingspeak.com/channels/3083651/feeds.json?api_key=I33WO1DMIHVA0EQY&results=2',
    measurements: {
      temperature: true,
      humidity: true,
      soilMoisture: true,
      soilPh: true,
      lightIntensity: false
    }
  }
];

const seedPrototypes = async () => {
  try {
    await connectDB();
    
    // Clear existing prototypes
    await Prototype.deleteMany({});
    console.log('Cleared existing prototypes');
    
    // Insert sample prototypes
    const insertedPrototypes = await Prototype.insertMany(samplePrototypes);
    console.log(`Successfully seeded ${insertedPrototypes.length} prototypes`);
    
    // Display seeded prototypes
    console.log('\nSeeded prototypes:');
    insertedPrototypes.forEach(prototype => {
      console.log(`- ${prototype.prototype_id} (Channel: ${prototype.channel_id})`);
    });
    
    process.exit(0);
  } catch (error) {
    console.error('Error seeding prototypes:', error);
    process.exit(1);
  }
};

seedPrototypes();

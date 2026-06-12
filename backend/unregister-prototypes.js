const mongoose = require('mongoose');
const dotenv = require('dotenv');

dotenv.config();

// MongoDB connection string (you'll need to replace this with your actual connection string)
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/maize-watch';

// Connect to MongoDB
mongoose.connect(MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Prototype schema (simplified)
const prototypeSchema = new mongoose.Schema({
  prototype_id: String,
  channel_id: String,
  api_key: String,
  thingspeak_url: String,
  isActive: Boolean,
  registeredBy: mongoose.Schema.Types.ObjectId,
  registeredAt: Date,
  measurements: {
    temperature: Boolean,
    humidity: Boolean,
    soilMoisture: Boolean,
    soilPh: Boolean,
    lightIntensity: Boolean,
  },
}, {
  timestamps: true,
  collection: 'prototypes',
});

const Prototype = mongoose.model('Prototype', prototypeSchema);

async function unregisterPrototypes() {
  try {
    console.log('Connecting to MongoDB...');
    
    // Unregister PROTO_001
    console.log('Unregistering PROTO_001...');
    const result1 = await Prototype.updateOne(
      { prototype_id: 'PROTO_001' },
      { 
        $unset: { 
          registeredBy: 1, 
          registeredAt: 1 
        } 
      }
    );
    console.log('PROTO_001 unregister result:', result1);

    // Unregister PROTO_002
    console.log('Unregistering PROTO_002...');
    const result2 = await Prototype.updateOne(
      { prototype_id: 'PROTO_002' },
      { 
        $unset: { 
          registeredBy: 1, 
          registeredAt: 1 
        } 
      }
    );
    console.log('PROTO_002 unregister result:', result2);

    // Unregister PROTO_001
    console.log('Unregistering SENSOR_001...');
    const result3 = await Prototype.updateOne(
      { prototype_id: 'SENSOR_001' },
      { 
        $unset: { 
          registeredBy: 1, 
          registeredAt: 1 
        } 
      }
    );
    console.log('SENSOR_001 unregister result:', result3);

        // Unregister PROTO_001
        console.log('Unregistering SENSOR_002...');
        const result4 = await Prototype.updateOne(
          { prototype_id: 'SENSOR_002' },
          { 
            $unset: { 
              registeredBy: 1, 
              registeredAt: 1 
            } 
          }
        );
        console.log('SENSOR_002 unregister result:', result4);

    // Verify they are now available
    console.log('\nVerifying prototypes are now available...');
    const proto1 = await Prototype.findOne({ prototype_id: 'PROTO_001' });
    const proto2 = await Prototype.findOne({ prototype_id: 'PROTO_002' });
    const proto3 = await Prototype.findOne({ prototype_id: 'SENSOR_001' }); 
    const proto4 = await Prototype.findOne({ prototype_id: 'SENSOR_002' });
    
    console.log('PROTO_001 available:', !proto1.registeredBy);
    console.log('PROTO_002 available:', !proto2.registeredBy);
    console.log('SENSOR_001 available:', !proto3.registeredBy);
    console.log('SENSOR_002 available:', !proto4.registeredBy);     
    console.log('\n✅ Prototypes successfully unregistered!');
    
  } catch (error) {
    console.error('❌ Error unregistering prototypes:', error);
  } finally {
    mongoose.connection.close();
  }
}

unregisterPrototypes();

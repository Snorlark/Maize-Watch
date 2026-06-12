const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const Farm = require('../dist/models/Farm').default;
const Sensor = require('../dist/models/Sensor').default;

async function createPrototypeSensors() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/maizewatch');
    console.log('Connected to MongoDB');

    // Find Kevin's Farm
    const farm = await Farm.findOne({ farmName: "Kevin's Farm" });
    if (!farm) {
      console.log('Kevin\'s Farm not found');
      return;
    }
    
    console.log(`Found farm: ${farm.farmName} (${farm._id})`);

    // Create PROTO_001 sensor
    const proto001 = await Sensor.findOne({
      sensorId: 'PROTO_001',
      farm: farm._id
    });
    
    if (!proto001) {
      const sensor1 = new Sensor({
        sensorId: 'PROTO_001',
        name: 'Temperature & Humidity Sensor',
        type: 'Multi_Sensor',
        farm: farm._id,
        fieldId: farm.fields[0]._id,
        fieldName: farm.fields[0].fieldName,
        location: {
          coordinates: [0, 0],
          description: `${farm.farmName} - ${farm.fields[0].fieldName}`
        },
        specifications: {
          model: 'DHT22',
          manufacturer: 'Maize Watch',
          version: '1.0',
          accuracy: 0.1,
          range: '0-100'
        },
        status: 'active',
        lastReading: new Date(),
        readings: {
          temperature: 0,
          humidity: 0,
          soilMoisture: 0,
          lightIntensity: 0,
          soilPh: 0
        },
        alerts: {
          enabled: true,
          thresholds: {
            temperature: { min: 10, max: 40 },
            humidity: { min: 30, max: 90 },
            soilMoisture: { min: 20, max: 80 },
            lightIntensity: { min: 0, max: 100000 },
            soilPh: { min: 5.5, max: 8.5 }
          }
        },
        metadata: {
          createdBy: 'system',
          source: 'prototype_creation',
          notes: 'Created for PROTO_001 prototype'
        }
      });
      
      await sensor1.save();
      console.log('✅ Created PROTO_001 sensor');
    } else {
      console.log('PROTO_001 sensor already exists');
    }

    // Create PROTO_002 sensor
    const proto002 = await Sensor.findOne({
      sensorId: 'PROTO_002',
      farm: farm._id
    });
    
    if (!proto002) {
      const sensor2 = new Sensor({
        sensorId: 'PROTO_002',
        name: 'Soil Moisture & pH Sensor',
        type: 'Multi_Sensor',
        farm: farm._id,
        fieldId: farm.fields[0]._id,
        fieldName: farm.fields[0].fieldName,
        location: {
          coordinates: [0, 0],
          description: `${farm.farmName} - ${farm.fields[0].fieldName}`
        },
        specifications: {
          model: 'Soil Sensor Pro',
          manufacturer: 'Maize Watch',
          version: '1.0',
          accuracy: 0.1,
          range: '0-100'
        },
        status: 'active',
        lastReading: new Date(),
        readings: {
          temperature: 0,
          humidity: 0,
          soilMoisture: 0,
          lightIntensity: 0,
          soilPh: 0
        },
        alerts: {
          enabled: true,
          thresholds: {
            temperature: { min: 10, max: 40 },
            humidity: { min: 30, max: 90 },
            soilMoisture: { min: 20, max: 80 },
            lightIntensity: { min: 0, max: 100000 },
            soilPh: { min: 5.5, max: 8.5 }
          }
        },
        metadata: {
          createdBy: 'system',
          source: 'prototype_creation',
          notes: 'Created for PROTO_002 prototype'
        }
      });
      
      await sensor2.save();
      console.log('✅ Created PROTO_002 sensor');
    } else {
      console.log('PROTO_002 sensor already exists');
    }
    
    console.log('\n✅ Prototype sensor creation completed');
    
  } catch (error) {
    console.error('❌ Error creating prototype sensors:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  }
}

// Run the script
createPrototypeSensors();

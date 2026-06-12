const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const Farm = require('../dist/models/Farm').default;
const Sensor = require('../dist/models/Sensor').default;

async function fixMissingSensors() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/maizewatch');
    console.log('Connected to MongoDB');

    // Get all farms
    const farms = await Farm.find({});
    console.log(`Found ${farms.length} farms`);

    for (const farm of farms) {
      console.log(`\nProcessing farm: ${farm.farmName} (${farm._id})`);
      
      // Get all fields for this farm
      for (const field of farm.fields) {
        console.log(`  Processing field: ${field.fieldName}`);
        
        // Get all sensors in this field
        for (const sensorData of field.sensors) {
          console.log(`    Processing sensor: ${sensorData.deviceID}`);
          
          // Check if sensor already exists in Sensor collection
          const existingSensor = await Sensor.findOne({
            sensorId: sensorData.deviceID,
            farm: farm._id
          });
          
          if (existingSensor) {
            console.log(`      Sensor ${sensorData.deviceID} already exists in Sensor collection`);
            continue;
          }
          
          // Create sensor in Sensor collection
          try {
            const newSensor = new Sensor({
              sensorId: sensorData.deviceID,
              name: sensorData.sensorName,
              type: 'Multi_Sensor', // Default type for now
              farm: farm._id,
              fieldId: field._id,
              fieldName: field.fieldName,
              location: {
                coordinates: [0, 0], // Default coordinates
                description: `${farm.farmName} - ${field.fieldName}`
              },
              specifications: {
                model: 'Maize Watch Sensor',
                manufacturer: 'Maize Watch',
                version: '1.0',
                accuracy: 0.1,
                range: '0-100'
              },
              status: 'active',
              lastReading: new Date(),
              readings: sensorData.readings,
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
                source: 'farm_import',
                notes: 'Imported from farm setup'
              }
            });
            
            await newSensor.save();
            console.log(`      ✅ Created sensor ${sensorData.deviceID} in Sensor collection`);
            
          } catch (error) {
            console.error(`      ❌ Error creating sensor ${sensorData.deviceID}:`, error.message);
          }
        }
      }
    }
    
    console.log('\n✅ Sensor creation completed');
    
  } catch (error) {
    console.error('❌ Error fixing missing sensors:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  }
}

// Run the script
fixMissingSensors();

const mongoose = require('mongoose');
const MONGODB_URI = 'mongodb://localhost:27017/maize_watch';

async function seedSensorData() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('MongoDB connected successfully');

    const db = mongoose.connection.db;
    const sensorReadings = db.collection('sensor_readings');

    // Clear existing sensor readings
    await sensorReadings.deleteMany({});
    console.log('Cleared existing sensor readings');

    // Create different sensor data for each prototype
    const sensorData = [
      // PROTO_001 data - Channel 3062750 (real data)
      {
        prototype_id: 'PROTO_001',
        temperature: 32.9,
        humidity: 76,
        soilMoisture: 100,
        soilPh: 7,
        lightIntensity: 0,
        timestamp: new Date(),
        createdAt: new Date(),
        updatedAt: new Date()
      },
      // PROTO_002 data - Channel 3083651 (different data)
      {
        prototype_id: 'PROTO_002',
        temperature: 28.5,
        humidity: 65,
        soilMoisture: 45,
        soilPh: 6.8,
        lightIntensity: 850,
        timestamp: new Date(),
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ];

    // Insert sensor data
    await sensorReadings.insertMany(sensorData);
    console.log('Successfully seeded sensor data');

    // Verify the data
    const readings = await sensorReadings.find({}).toArray();
    console.log('\nSeeded sensor readings:');
    readings.forEach(reading => {
      console.log(`- ${reading.prototype_id}: Temp=${reading.temperature}°C, Humidity=${reading.humidity}%, SoilMoisture=${reading.soilMoisture}%, pH=${reading.soilPh}, Light=${reading.lightIntensity}`);
    });

    await mongoose.disconnect();
    console.log('\nDisconnected from MongoDB');
  } catch (error) {
    console.error('Error seeding sensor data:', error);
    process.exit(1);
  }
}

seedSensorData();

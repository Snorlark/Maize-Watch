// Add this to server.js or index.js (or whatever your main file is) to seed initial data

// Only add this for development purposes - remove in production
import mongoose from 'mongoose';
import SensorReading from './models/sensorReading.model.js';

// Function to seed test data
export const seedTestData = async () => {
  try {
    // Check if we already have data
    const count = await SensorReading.countDocuments();
    
    if (count === 0) {
      console.log('No sensor readings found. Seeding test data...');
      
      // Create some sample fields
      const fieldIds = ['field_001', 'field_002', 'field_003'];
      const now = new Date();
      
      // Create some sample readings over the past week
      const testData = [];
      
      for (const fieldId of fieldIds) {
        // Create readings for the past 7 days, one reading every 3 hours
        for (let i = 0; i < 7 * 8; i++) {
          const timestamp = new Date(now);
          timestamp.setHours(now.getHours() - (i * 3));
          
          // Add some variation to the data
          const hourOfDay = timestamp.getHours();
          const isDaytime = hourOfDay >= 6 && hourOfDay <= 18;
          
          testData.push({
            timestamp,
            field_id: fieldId,
            measurements: {
              // Temperature varies by time of day (cooler at night)
              temperature: 22 + Math.sin(i / 4) * 5 + (isDaytime ? 5 : 0) + (Math.random() * 2),
              // Humidity inversely related to temperature
              humidity: 60 - Math.sin(i / 4) * 10 + (isDaytime ? -5 : 5) + (Math.random() * 5),
              // Soil moisture decreases slightly each day until reset (simulating watering)
              soil_moisture: 75 - (i % 8) * 2 + (Math.random() * 5),
              // Soil pH remains relatively stable
              soil_ph: 6.5 + (Math.random() - 0.5) * 0.2,
              // Light intensity follows day/night cycle
              light_intensity: isDaytime ? 800 + (Math.random() * 200) : 10 + (Math.random() * 20)
            }
          });
        }
      }
      
      // Insert the test data
      await SensorReading.insertMany(testData);
      console.log(`✅ Successfully seeded ${testData.length} test readings for ${fieldIds.length} fields`);
    } else {
      console.log(`Found ${count} existing sensor readings. Skipping seed.`);
    }
  } catch (error) {
    console.error('Error seeding test data:', error);
  }
};

// Call this after connecting to the database in your server.js
// startServer() {
//   ...
//   if (process.env.NODE_ENV === 'development') {
//     seedTestData();
//   }
//   ...
// }
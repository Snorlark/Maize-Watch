const mongoose = require('mongoose');
require('dotenv').config();

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const thingSpeakService = require('../dist/services/thingspeakService').default;
const syncService = require('../dist/services/syncService').default;

async function testSync() {
  try {
    console.log('Testing ThingSpeak sync...');
    
    // Test ThingSpeak data fetch
    console.log('1. Fetching latest data from ThingSpeak...');
    const thingSpeakData = await thingSpeakService.getLatestData();
    console.log('ThingSpeak data:', thingSpeakData);
    
    // Test sync for a specific farm
    console.log('2. Syncing data for farm 68c6d7c837722432c5643c7b...');
    await syncService.syncFarmData('68c6d7c837722432c5643c7b');
    
    console.log('Sync test completed successfully!');
  } catch (error) {
    console.error('Sync test failed:', error);
  } finally {
    mongoose.connection.close();
  }
}

testSync();

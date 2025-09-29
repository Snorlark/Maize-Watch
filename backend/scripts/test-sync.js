const syncService = require('../dist/services/syncService.js').default;

async function testSync() {
  try {
    console.log('🔄 Starting sensor data sync...');
    
    // Sync all farms data
    await syncService.syncAllFarmsData();
    
    console.log('✅ Sync completed successfully!');
    
    // Test getting sensor data for analytics
    const farms = await require('../dist/services/farmService.js').default.getFarmsByOwner('');
    if (farms.length > 0) {
      const farmId = farms[0]._id.toString();
      console.log(`🔍 Testing sensor data for farm ${farmId}...`);
      
      const sensorData = await syncService.getSensorDataForAnalytics(farmId);
      console.log('📊 Sensor data:', sensorData);
    }
    
  } catch (error) {
    console.error('❌ Sync failed:', error);
  }
  
  process.exit(0);
}

testSync();
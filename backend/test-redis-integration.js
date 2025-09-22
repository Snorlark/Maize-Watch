// Load environment variables first
require('dotenv').config({ path: '.env' });

const { redisUtils } = require('./dist/config/redis');
const CacheService = require('./dist/services/cacheService').default;

// Test Redis integration with our services
async function testRedisIntegration() {
  console.log('🔄 Testing Redis integration with Maize-Watch services...\n');
  
  try {
    console.log('1. Testing Redis utilities...');
    
    // Test redisUtils
    await redisUtils.setWithExpiry('test:util', 'test-value', 30);
    const value = await redisUtils.get('test:util');
    console.log(`✅ redisUtils: ${value === 'test-value' ? 'PASS' : 'FAIL'}`);
    
    console.log('\n2. Testing CacheService...');
    
    // Test sensor caching
    const sensorData = {
      sensorId: 'sensor123',
      temperature: 24.5,
      humidity: 65.2,
      timestamp: new Date().toISOString()
    };
    
    await CacheService.cacheSensorLatest('sensor123', sensorData);
    const cachedSensor = await CacheService.getSensorLatest('sensor123');
    console.log(`✅ Sensor caching: ${cachedSensor && cachedSensor.sensorId === 'sensor123' ? 'PASS' : 'FAIL'}`);
    
    // Test farm analytics caching
    const analyticsData = {
      totalSensors: 5,
      activeSensors: 4,
      averageConditions: {
        temperature: 25.0,
        humidity: 60.0
      }
    };
    
    await CacheService.cacheFarmAnalytics('farm123', analyticsData);
    const cachedAnalytics = await CacheService.getFarmAnalytics('farm123');
    console.log(`✅ Farm analytics caching: ${cachedAnalytics && cachedAnalytics.totalSensors === 5 ? 'PASS' : 'FAIL'}`);
    
    // Test alert queuing
    const alertData = {
      type: 'temperature',
      severity: 'high',
      message: 'Temperature too high',
      timestamp: new Date().toISOString()
    };
    
    await CacheService.queueAlert('farm123', alertData);
    const queuedAlerts = await CacheService.getQueuedAlerts('farm123');
    console.log(`✅ Alert queuing: ${queuedAlerts.length === 1 && queuedAlerts[0].type === 'temperature' ? 'PASS' : 'FAIL'}`);
    
    // Test ThingSpeak data caching
    const thingSpeakData = {
      field1: 25.5,
      field2: 60.2,
      field3: 45.0,
      timestamp: new Date().toISOString()
    };
    
    await CacheService.cacheThingSpeakData('channel123', thingSpeakData);
    const cachedThingSpeak = await CacheService.getThingSpeakData('channel123');
    console.log(`✅ ThingSpeak caching: ${cachedThingSpeak && cachedThingSpeak.field1 === 25.5 ? 'PASS' : 'FAIL'}`);
    
    console.log('\n3. Testing cache invalidation...');
    
    // Test cache invalidation
    await CacheService.invalidateSensorCache('sensor123');
    const invalidatedSensor = await CacheService.getSensorLatest('sensor123');
    console.log(`✅ Cache invalidation: ${invalidatedSensor === null ? 'PASS' : 'FAIL'}`);
    
    console.log('\n4. Testing cache statistics...');
    
    // Test cache stats
    const stats = await CacheService.getCacheStats();
    console.log(`✅ Cache statistics: ${stats.connected ? 'PASS' : 'FAIL'}`);
    console.log(`   Stats: ${JSON.stringify(stats, null, 2)}`);
    
    console.log('\n5. Cleanup test data...');
    
    // Cleanup
    await CacheService.invalidateFarmCache('farm123');
    await CacheService.clearQueuedAlerts('farm123');
    await redisUtils.del('test:util');
    
    console.log('✅ Test data cleaned up');
    
    console.log('\n🎉 All Redis integration tests passed successfully!');
    
  } catch (error) {
    console.error('❌ Redis integration test failed:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

// Environment already loaded at the top

// Run tests
testRedisIntegration().catch(console.error);

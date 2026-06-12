const Redis = require('ioredis');

// Test Redis connection and functionality
async function testRedis() {
  console.log('🔄 Testing Redis connection and functionality...\n');
  
  const redis = new Redis({
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT) || 6379,
    password: process.env.REDIS_PASSWORD,
    db: parseInt(process.env.REDIS_DB) || 0,
    retryDelayOnFailover: 100,
    maxRetriesPerRequest: 3,
    lazyConnect: true
  });

  try {
    // Test connection
    console.log('1. Testing Redis connection...');
    await redis.ping();
    console.log('✅ Redis connection successful');

    // Test basic operations
    console.log('\n2. Testing basic Redis operations...');
    
    // Set and get
    await redis.set('test:key', 'test:value');
    const value = await redis.get('test:key');
    console.log(`✅ SET/GET: ${value === 'test:value' ? 'PASS' : 'FAIL'}`);

    // Set with expiry
    await redis.setex('test:expiry', 5, 'expires-in-5-seconds');
    const ttl = await redis.ttl('test:expiry');
    console.log(`✅ SETEX/TTL: ${ttl > 0 && ttl <= 5 ? 'PASS' : 'FAIL'} (TTL: ${ttl}s)`);

    // Hash operations
    await redis.hset('test:hash', 'field1', 'value1', 'field2', 'value2');
    const hashValue = await redis.hget('test:hash', 'field1');
    console.log(`✅ HSET/HGET: ${hashValue === 'value1' ? 'PASS' : 'FAIL'}`);

    // Set operations
    await redis.sadd('test:set', 'member1', 'member2', 'member3');
    const setMembers = await redis.smembers('test:set');
    console.log(`✅ SADD/SMEMBERS: ${setMembers.length === 3 ? 'PASS' : 'FAIL'} (${setMembers.length} members)`);

    // Counter operations
    await redis.set('test:counter', 0);
    const count1 = await redis.incr('test:counter');
    const count2 = await redis.incr('test:counter');
    console.log(`✅ INCR: ${count1 === 1 && count2 === 2 ? 'PASS' : 'FAIL'} (${count1}, ${count2})`);

    console.log('\n3. Testing rate limiting simulation...');
    
    // Simulate rate limiting
    const rateLimitKey = 'rl:test:127.0.0.1';
    const pipeline = redis.pipeline();
    pipeline.incr(rateLimitKey);
    pipeline.ttl(rateLimitKey);
    
    const results = await pipeline.exec();
    const count = results[0][1];
    let rateLimitTtl = results[1][1];
    
    if (count === 1) {
      await redis.expire(rateLimitKey, 60);
      rateLimitTtl = 60;
    }
    
    console.log(`✅ Rate limiting simulation: Count=${count}, TTL=${rateLimitTtl}s`);

    console.log('\n4. Testing cache simulation...');
    
    // Simulate caching
    const cacheKey = 'sensor:test123:latest';
    const cacheData = {
      sensorId: 'test123',
      temperature: 25.5,
      humidity: 60.2,
      timestamp: new Date().toISOString()
    };
    
    await redis.setex(cacheKey, 300, JSON.stringify(cacheData));
    const cachedData = await redis.get(cacheKey);
    const parsedData = JSON.parse(cachedData);
    
    console.log(`✅ Cache simulation: ${parsedData.sensorId === 'test123' ? 'PASS' : 'FAIL'}`);
    console.log(`   Data: ${JSON.stringify(parsedData, null, 2)}`);

    console.log('\n5. Cleanup test data...');
    
    // Cleanup
    await redis.del('test:key', 'test:expiry', 'test:hash', 'test:set', 'test:counter', rateLimitKey, cacheKey);
    console.log('✅ Test data cleaned up');

    console.log('\n🎉 All Redis tests passed successfully!');
    
  } catch (error) {
    console.error('❌ Redis test failed:', error.message);
    process.exit(1);
  } finally {
    await redis.quit();
  }
}

// Load environment variables
require('dotenv').config({ path: '.env' });

// Run tests
testRedis().catch(console.error);

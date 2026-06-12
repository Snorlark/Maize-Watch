#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🚀 Setting up Redis for Maize-Watch Backend...\n');

// Check if Redis is running
function checkRedisStatus() {
  try {
    execSync('redis-cli ping', { stdio: 'pipe' });
    console.log('✅ Redis is running');
    return true;
  } catch (error) {
    console.log('❌ Redis is not running');
    return false;
  }
}

// Start Redis if not running
function startRedis() {
  console.log('🔄 Starting Redis...');
  try {
    execSync('redis-server --daemonize yes', { stdio: 'pipe' });
    console.log('✅ Redis started successfully');
    return true;
  } catch (error) {
    console.log('❌ Failed to start Redis:', error.message);
    return false;
  }
}

// Create .env file if it doesn't exist
function createEnvFile() {
  const envPath = path.join(__dirname, '.env');
  
  if (fs.existsSync(envPath)) {
    console.log('✅ .env file already exists');
    return;
  }

  const envContent = `# Database Configuration
MONGODB_URI=mongodb://localhost:27017/maize-watch
IOT_MONGODB_URI=mongodb://localhost:27017/maize-watch-iot

# Redis Configuration
REDIS_URL=redis://localhost:6379
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# Server Configuration
PORT=8080
NODE_ENV=development

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-here-${Date.now()}
JWT_EXPIRES_IN=24h
JWT_REFRESH_EXPIRES_IN=7d

# Email Configuration
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password

# ThingSpeak Configuration
THINGSPEAK_API_KEY=your-thingspeak-api-key
THINGSPEAK_CHANNEL_ID=3062750

# Analytics Configuration
ANALYTICS_PATH=../analytics_v2
PYTHON_PATH=../analytics_v2/venv/bin/python

# CORS Configuration
CORS_ORIGIN=http://localhost:3000,http://localhost:8080

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
`;

  try {
    fs.writeFileSync(envPath, envContent);
    console.log('✅ Created .env file with default configuration');
    console.log('⚠️  Please update the .env file with your actual configuration values');
  } catch (error) {
    console.log('❌ Failed to create .env file:', error.message);
  }
}

// Test Redis connection
async function testRedisConnection() {
  console.log('\n🔄 Testing Redis connection...');
  
  try {
    const Redis = require('ioredis');
    const redis = new Redis({
      host: 'localhost',
      port: 6379,
      retryDelayOnFailover: 100,
      maxRetriesPerRequest: 3,
      lazyConnect: true
    });

    await redis.ping();
    console.log('✅ Redis connection test successful');
    
    // Test basic operations
    await redis.set('test:setup', 'success');
    const value = await redis.get('test:setup');
    await redis.del('test:setup');
    
    if (value === 'success') {
      console.log('✅ Redis operations test successful');
    } else {
      console.log('❌ Redis operations test failed');
    }
    
    await redis.quit();
    return true;
  } catch (error) {
    console.log('❌ Redis connection test failed:', error.message);
    return false;
  }
}

// Main setup function
async function setupRedis() {
  console.log('1. Checking Redis status...');
  let redisRunning = checkRedisStatus();
  
  if (!redisRunning) {
    console.log('2. Starting Redis...');
    redisRunning = startRedis();
    
    if (!redisRunning) {
      console.log('\n❌ Setup failed: Could not start Redis');
      console.log('Please start Redis manually: redis-server');
      process.exit(1);
    }
  }
  
  console.log('3. Creating environment configuration...');
  createEnvFile();
  
  console.log('4. Testing Redis connection...');
  const connectionSuccess = await testRedisConnection();
  
  if (connectionSuccess) {
    console.log('\n🎉 Redis setup completed successfully!');
    console.log('\nNext steps:');
    console.log('1. Update your .env file with actual configuration values');
    console.log('2. Run: npm run dev');
    console.log('3. Test with: node test-redis.js');
  } else {
    console.log('\n❌ Redis setup failed');
    console.log('Please check Redis installation and try again');
    process.exit(1);
  }
}

// Run setup
setupRedis().catch(console.error);

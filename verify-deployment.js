// Quick deployment verification script
const https = require('https');

console.log('🔍 Verifying Maize-Watch Deployment...\n');

// Test 1: Backend Health Check
function testBackendHealth() {
  return new Promise((resolve) => {
    const req = https.request('https://maize-watch.onrender.com/api/', (res) => {
      console.log(`✅ Backend API: ${res.statusCode} ${res.statusMessage}`);
      resolve(res.statusCode < 400);
    });
    
    req.on('error', (err) => {
      console.log(`❌ Backend API: ${err.message}`);
      resolve(false);
    });
    
    req.setTimeout(10000, () => {
      console.log('❌ Backend API: Timeout');
      resolve(false);
    });
    
    req.end();
  });
}

// Test 2: CORS Headers
function testCORS() {
  return new Promise((resolve) => {
    const options = {
      hostname: 'maize-watch.onrender.com',
      path: '/api/auth/login',
      method: 'OPTIONS',
      headers: {
        'Origin': 'https://maize-watch-rdcy.onrender.com',
        'Access-Control-Request-Method': 'POST'
      }
    };
    
    const req = https.request(options, (res) => {
      const corsHeader = res.headers['access-control-allow-origin'];
      if (corsHeader && corsHeader.includes('maize-watch-rdcy.onrender.com')) {
        console.log('✅ CORS: Frontend origin allowed');
        resolve(true);
      } else {
        console.log(`❌ CORS: Missing or incorrect origin header: ${corsHeader}`);
        resolve(false);
      }
    });
    
    req.on('error', (err) => {
      console.log(`❌ CORS: ${err.message}`);
      resolve(false);
    });
    
    req.setTimeout(10000, () => {
      console.log('❌ CORS: Timeout');
      resolve(false);
    });
    
    req.end();
  });
}

// Test 3: Static Files
function testStaticFiles() {
  return new Promise((resolve) => {
    const req = https.request('https://maize-watch.onrender.com/web-public/images/smiley.png', (res) => {
      if (res.statusCode === 200) {
        console.log('✅ Static Files: Images accessible');
        resolve(true);
      } else {
        console.log(`❌ Static Files: ${res.statusCode} ${res.statusMessage}`);
        resolve(false);
      }
    });
    
    req.on('error', (err) => {
      console.log(`❌ Static Files: ${err.message}`);
      resolve(false);
    });
    
    req.setTimeout(10000, () => {
      console.log('❌ Static Files: Timeout');
      resolve(false);
    });
    
    req.end();
  });
}

// Run all tests
async function runTests() {
  console.log('Testing backend health...');
  const healthOk = await testBackendHealth();
  
  console.log('\nTesting CORS configuration...');
  const corsOk = await testCORS();
  
  console.log('\nTesting static file serving...');
  const staticOk = await testStaticFiles();
  
  console.log('\n' + '='.repeat(50));
  console.log('📊 DEPLOYMENT STATUS SUMMARY');
  console.log('='.repeat(50));
  console.log(`Backend Health: ${healthOk ? '✅ OK' : '❌ FAILED'}`);
  console.log(`CORS Config: ${corsOk ? '✅ OK' : '❌ FAILED'}`);
  console.log(`Static Files: ${staticOk ? '✅ OK' : '❌ FAILED'}`);
  
  if (healthOk && corsOk && staticOk) {
    console.log('\n🎉 All tests passed! Deployment looks good.');
  } else {
    console.log('\n⚠️  Some tests failed. Backend needs redeployment with fixes.');
    console.log('\n📋 Next Steps:');
    console.log('1. Ensure all code changes are committed');
    console.log('2. Push to deployment branch');
    console.log('3. Trigger redeploy on Render');
    console.log('4. Wait for build completion');
    console.log('5. Run this script again');
  }
}

runTests().catch(console.error);

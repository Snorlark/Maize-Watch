// Debug deployment issues
const https = require('https');

console.log('🔍 Debugging Maize-Watch Deployment Issues...\n');

// Test different endpoints to understand the deployment structure
const tests = [
  {
    name: 'Health Check',
    url: 'https://maize-watch-rdcy.onrender.com/api/health'
  },
  {
    name: 'Test Endpoint',
    url: 'https://maize-watch-rdcy.onrender.com/api/test'
  },
  {
    name: 'Auth Login',
    url: 'https://maize-watch-rdcy.onrender.com/api/auth/login'
  },
  {
    name: 'Root API',
    url: 'https://maize-watch-rdcy.onrender.com/api/'
  },
  {
    name: 'Static Image',
    url: 'https://maize-watch-rdcy.onrender.com/web-public/images/smiley.png'
  },
  {
    name: 'Root Domain',
    url: 'https://maize-watch-rdcy.onrender.com/'
  }
];

async function testEndpoint(test) {
  return new Promise((resolve) => {
    const req = https.request(test.url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        const status = res.statusCode;
        const contentType = res.headers['content-type'] || 'unknown';
        
        console.log(`${test.name}:`);
        console.log(`  Status: ${status} ${res.statusMessage}`);
        console.log(`  Content-Type: ${contentType}`);
        
        if (status === 200 && data) {
          try {
            const json = JSON.parse(data);
            console.log(`  Response: ${JSON.stringify(json, null, 2).substring(0, 200)}...`);
          } catch (e) {
            console.log(`  Response: ${data.substring(0, 100)}...`);
          }
        } else if (status !== 200) {
          console.log(`  Error: ${data.substring(0, 200)}`);
        }
        
        console.log('');
        resolve({ name: test.name, status, success: status < 400 });
      });
    });
    
    req.on('error', (err) => {
      console.log(`${test.name}:`);
      console.log(`  Error: ${err.message}\n`);
      resolve({ name: test.name, status: 0, success: false, error: err.message });
    });
    
    req.setTimeout(10000, () => {
      console.log(`${test.name}:`);
      console.log(`  Error: Timeout\n`);
      resolve({ name: test.name, status: 0, success: false, error: 'Timeout' });
    });
    
    req.end();
  });
}

async function runTests() {
  console.log('Testing all endpoints...\n');
  
  const results = [];
  for (const test of tests) {
    const result = await testEndpoint(test);
    results.push(result);
  }
  
  console.log('='.repeat(60));
  console.log('📊 SUMMARY');
  console.log('='.repeat(60));
  
  results.forEach(result => {
    const icon = result.success ? '✅' : '❌';
    const status = result.status || 'ERR';
    console.log(`${icon} ${result.name}: ${status}`);
  });
  
  console.log('\n🔍 ANALYSIS:');
  
  const healthCheck = results.find(r => r.name === 'Health Check');
  const authLogin = results.find(r => r.name === 'Auth Login');
  const staticImage = results.find(r => r.name === 'Static Image');
  
  if (!healthCheck?.success) {
    console.log('❌ Backend API is not responding - deployment may have failed');
  } else {
    console.log('✅ Backend API is running');
  }
  
  if (!authLogin?.success) {
    console.log('❌ Auth endpoints not working - check route configuration');
  } else {
    console.log('✅ Auth endpoints accessible');
  }
  
  if (!staticImage?.success) {
    console.log('❌ Static files not served - check static middleware configuration');
  } else {
    console.log('✅ Static files accessible');
  }
}

runTests().catch(console.error);

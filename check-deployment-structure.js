// Check what's actually deployed
const https = require('https');

console.log('🔍 Checking what is actually deployed at maize-watch-rdcy.onrender.com...\n');

async function checkDeployment() {
  // Test root domain
  console.log('Testing root domain...');
  await testUrl('https://maize-watch-rdcy.onrender.com/', 'Root Domain');
  
  // Test if it's serving frontend static files
  console.log('\nTesting frontend files...');
  await testUrl('https://maize-watch-rdcy.onrender.com/index.html', 'Frontend Index');
  await testUrl('https://maize-watch-rdcy.onrender.com/assets/', 'Frontend Assets');
  
  // Test backend endpoints
  console.log('\nTesting backend endpoints...');
  await testUrl('https://maize-watch-rdcy.onrender.com/api/', 'Backend API Root');
  await testUrl('https://maize-watch-rdcy.onrender.com/api/health', 'Backend Health');
  
  // Test static file serving
  console.log('\nTesting static file serving...');
  await testUrl('https://maize-watch-rdcy.onrender.com/web-public/', 'Static Directory');
  await testUrl('https://maize-watch-rdcy.onrender.com/web-public/images/', 'Images Directory');
  
  console.log('\n' + '='.repeat(60));
  console.log('🔍 ANALYSIS:');
  console.log('Based on the responses above, your deployment is likely:');
  console.log('1. Frontend-only (static site) - if only frontend files work');
  console.log('2. Backend-only - if only API endpoints work');
  console.log('3. Misconfigured monorepo - if nothing works properly');
  console.log('4. Build failed - if everything returns 404');
}

async function testUrl(url, name) {
  return new Promise((resolve) => {
    const req = https.request(url, (res) => {
      const contentType = res.headers['content-type'] || 'unknown';
      console.log(`${name}: ${res.statusCode} ${res.statusMessage} (${contentType})`);
      resolve();
    });
    
    req.on('error', (err) => {
      console.log(`${name}: ERROR - ${err.message}`);
      resolve();
    });
    
    req.setTimeout(5000, () => {
      console.log(`${name}: TIMEOUT`);
      resolve();
    });
    
    req.end();
  });
}

checkDeployment().catch(console.error);

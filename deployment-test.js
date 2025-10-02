#!/usr/bin/env node

/**
 * Deployment Test Script for Maize-Watch
 * Tests if all static files and API endpoints are accessible
 */

const https = require('https');
const http = require('http');

const BASE_URL = 'https://maize-watch-rdcy.onrender.com';

// Test endpoints and static files
const testEndpoints = [
  // Health check
  { path: '/health', type: 'API' },
  
  // Static files - Images
  { path: '/images/logo.png', type: 'Static' },
  { path: '/images/background.png', type: 'Static' },
  { path: '/images/loginsignuplogo.png', type: 'Static' },
  
  // API endpoints
  { path: '/api/test', type: 'API' },
  
  // Web-admin static files
  { path: '/web-admin/index.html', type: 'Static' },
];

function testEndpoint(url) {
  return new Promise((resolve) => {
    const protocol = url.startsWith('https:') ? https : http;
    
    const req = protocol.get(url, (res) => {
      resolve({
        url,
        status: res.statusCode,
        success: res.statusCode >= 200 && res.statusCode < 400
      });
    });
    
    req.on('error', (error) => {
      resolve({
        url,
        status: 'ERROR',
        success: false,
        error: error.message
      });
    });
    
    req.setTimeout(10000, () => {
      req.destroy();
      resolve({
        url,
        status: 'TIMEOUT',
        success: false,
        error: 'Request timeout'
      });
    });
  });
}

async function runTests() {
  console.log('🚀 Testing Maize-Watch Deployment...\n');
  console.log(`Base URL: ${BASE_URL}\n`);
  
  const results = [];
  
  for (const endpoint of testEndpoints) {
    const url = `${BASE_URL}${endpoint.path}`;
    console.log(`Testing ${endpoint.type}: ${endpoint.path}`);
    
    const result = await testEndpoint(url);
    results.push({ ...result, type: endpoint.type });
    
    const status = result.success ? '✅' : '❌';
    const statusText = result.status === 'ERROR' || result.status === 'TIMEOUT' 
      ? `${result.status} - ${result.error}` 
      : result.status;
    
    console.log(`  ${status} ${statusText}\n`);
  }
  
  // Summary
  const successful = results.filter(r => r.success).length;
  const total = results.length;
  
  console.log('📊 Test Summary:');
  console.log(`✅ Successful: ${successful}/${total}`);
  console.log(`❌ Failed: ${total - successful}/${total}`);
  
  if (successful === total) {
    console.log('\n🎉 All tests passed! Deployment looks good.');
  } else {
    console.log('\n⚠️  Some tests failed. Check the issues above.');
    
    // Group failures by type
    const failures = results.filter(r => !r.success);
    const apiFailures = failures.filter(r => r.type === 'API');
    const staticFailures = failures.filter(r => r.type === 'Static');
    
    if (apiFailures.length > 0) {
      console.log('\n🔧 API Issues:');
      apiFailures.forEach(f => console.log(`  - ${f.url}`));
    }
    
    if (staticFailures.length > 0) {
      console.log('\n📁 Static File Issues:');
      staticFailures.forEach(f => console.log(`  - ${f.url}`));
      console.log('\n💡 Tip: Static file issues may be resolved after the next deployment with the updated build process.');
    }
  }
}

// Run the tests
runTests().catch(console.error);

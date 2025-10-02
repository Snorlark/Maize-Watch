#!/usr/bin/env node

/**
 * Local Development Image Test
 * Tests if images are being served correctly from localhost:8080
 */

const http = require('http');

const BASE_URL = 'http://localhost:8080';

// Test the images that were failing
const testImages = [
  'smalllogo.png',
  'instagram.png', 
  'menu-green.png',
  'x.png',
  'logo.png',
  'header.png',
  'mainlogo.png',
  'healthycorn.png',
  'github.png',
  'linkedin.png',
  'smiley.png',
  'background.png',
  'loginsignuplogo.png'
];

function testImage(imageName) {
  return new Promise((resolve) => {
    const url = `${BASE_URL}/images/${imageName}`;
    
    const req = http.get(url, (res) => {
      resolve({
        image: imageName,
        status: res.statusCode,
        success: res.statusCode === 200,
        contentType: res.headers['content-type']
      });
    });
    
    req.on('error', (error) => {
      resolve({
        image: imageName,
        status: 'ERROR',
        success: false,
        error: error.message
      });
    });
    
    req.setTimeout(5000, () => {
      req.destroy();
      resolve({
        image: imageName,
        status: 'TIMEOUT',
        success: false,
        error: 'Request timeout'
      });
    });
  });
}

async function testBackendHealth() {
  return new Promise((resolve) => {
    const req = http.get(`${BASE_URL}/health`, (res) => {
      resolve({
        success: res.statusCode === 200,
        status: res.statusCode
      });
    });
    
    req.on('error', (error) => {
      resolve({
        success: false,
        error: error.message
      });
    });
    
    req.setTimeout(5000, () => {
      req.destroy();
      resolve({
        success: false,
        error: 'Backend not responding'
      });
    });
  });
}

async function runTests() {
  console.log('🔍 Testing Local Development Image Serving...\n');
  
  // First test if backend is running
  console.log('Testing backend health...');
  const healthResult = await testBackendHealth();
  
  if (!healthResult.success) {
    console.log('❌ Backend is not running or not responding');
    console.log('💡 Make sure to run: cd backend && npm run dev');
    console.log(`   Error: ${healthResult.error || 'Unknown error'}\n`);
    return;
  }
  
  console.log('✅ Backend is running\n');
  
  // Test images
  console.log('Testing image serving...\n');
  
  const results = [];
  
  for (const imageName of testImages) {
    console.log(`Testing: ${imageName}`);
    const result = await testImage(imageName);
    results.push(result);
    
    const status = result.success ? '✅' : '❌';
    const statusText = result.status === 'ERROR' || result.status === 'TIMEOUT' 
      ? `${result.status} - ${result.error}` 
      : `${result.status} ${result.contentType || ''}`;
    
    console.log(`  ${status} ${statusText}\n`);
  }
  
  // Summary
  const successful = results.filter(r => r.success).length;
  const total = results.length;
  
  console.log('📊 Test Summary:');
  console.log(`✅ Working: ${successful}/${total}`);
  console.log(`❌ Failed: ${total - successful}/${total}`);
  
  if (successful === total) {
    console.log('\n🎉 All images are being served correctly!');
    console.log('💡 If you\'re still seeing 404s in the browser, try:');
    console.log('   1. Hard refresh (Ctrl+F5)');
    console.log('   2. Clear browser cache');
    console.log('   3. Restart the frontend dev server');
  } else {
    console.log('\n⚠️  Some images are not being served correctly.');
    console.log('💡 Troubleshooting steps:');
    console.log('   1. Make sure backend server is running: cd backend && npm run dev');
    console.log('   2. Check if NODE_ENV is set correctly');
    console.log('   3. Verify file paths in server.ts');
  }
}

runTests().catch(console.error);

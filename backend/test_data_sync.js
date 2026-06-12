#!/usr/bin/env node

/**
 * Test script to verify data sync from ThingSpeak to mobile app
 * This script tests the complete data flow and helps debug the delay issue
 */

const axios = require('axios');
require('dotenv').config();

const BASE_URL = 'https://maize-watch-app.onrender.com' || 'http://localhost:5000';
const THINGSPEAK_CHANNEL_001 = '3062750';
const THINGSPEAK_CHANNEL_002 = '3083651';
const API_KEY_001 = 'TFISWV8UFLL0NRL3';
const API_KEY_002 = 'I33WO1DMIHVA0EQY';

async function testThingSpeakData() {
  console.log('🔍 Testing ThingSpeak data...');
  
  try {
    // Test PROTO_001
    const response001 = await axios.get(`https://api.thingspeak.com/channels/${THINGSPEAK_CHANNEL_001}/feeds.json`, {
      params: {
        api_key: API_KEY_001,
        results: 1
      }
    });
    
    if (response001.data.feeds && response001.data.feeds.length > 0) {
      const data001 = response001.data.feeds[0];
      console.log('✅ PROTO_001 Data:');
      console.log(`   Temperature: ${data001.field1}°C`);
      console.log(`   Humidity: ${data001.field2}%`);
      console.log(`   Soil Moisture: ${data001.field3}%`);
      console.log(`   Soil pH: ${data001.field4}`);
      console.log(`   Light Intensity: ${data001.field5} lux`);
      console.log(`   Timestamp: ${data001.created_at}`);
    }
    
    // Test PROTO_002
    const response002 = await axios.get(`https://api.thingspeak.com/channels/${THINGSPEAK_CHANNEL_002}/feeds.json`, {
      params: {
        api_key: API_KEY_002,
        results: 1
      }
    });
    
    if (response002.data.feeds && response002.data.feeds.length > 0) {
      const data002 = response002.data.feeds[0];
      console.log('✅ PROTO_002 Data:');
      console.log(`   Temperature: ${data002.field1}°C`);
      console.log(`   Humidity: ${data002.field2}%`);
      console.log(`   Soil Moisture: ${data002.field3}%`);
      console.log(`   Soil pH: ${data002.field4}`);
      console.log(`   Light Intensity: ${data002.field5} lux`);
      console.log(`   Timestamp: ${data002.created_at}`);
    }
    
  } catch (error) {
    console.error('❌ Error fetching ThingSpeak data:', error.message);
  }
}

async function testBackendSync(farmId) {
  console.log(`\n🔄 Testing backend sync for farm ${farmId}...`);
  
  try {
    // Test force sync endpoint
    const response = await axios.post(`${BASE_URL}/api/analytics/farms/${farmId}/sync`, {}, {
      headers: {
        'Authorization': `Bearer ${process.env.TEST_TOKEN || 'your-test-token'}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (response.status === 200) {
      console.log('✅ Backend sync successful');
      console.log('   Response:', response.data);
    }
    
  } catch (error) {
    console.error('❌ Backend sync failed:', error.response?.data || error.message);
  }
}

async function testAnalyticsData(farmId) {
  console.log(`\n📊 Testing analytics data for farm ${farmId}...`);
  
  try {
    // Test complete analytics endpoint
    const response = await axios.get(`${BASE_URL}/api/analytics/farms/${farmId}/complete`, {
      headers: {
        'Authorization': `Bearer ${process.env.TEST_TOKEN || 'your-test-token'}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (response.status === 200) {
      console.log('✅ Analytics data retrieved');
      const data = response.data.data;
      
      if (data.descriptive && data.descriptive.stress_analysis) {
        const stress = data.descriptive.stress_analysis;
        console.log('   Light Intensity Analysis:');
        if (stress['Light Intensity']) {
          console.log(`     Actual Value: ${stress['Light Intensity'].actual_value} lux`);
          console.log(`     Stress Level: ${stress['Light Intensity'].stress_level}`);
        }
      }
    }
    
  } catch (error) {
    console.error('❌ Analytics data failed:', error.response?.data || error.message);
  }
}

async function main() {
  console.log('🚀 Starting data sync test...\n');
  
  // Test ThingSpeak data
  await testThingSpeakData();
  
  // Test backend sync (replace with your actual farm ID)
  const farmId = process.env.TEST_FARM_ID || 'your-farm-id';
  if (farmId !== 'your-farm-id') {
    await testBackendSync(farmId);
    await testAnalyticsData(farmId);
  } else {
    console.log('\n⚠️  Set TEST_FARM_ID environment variable to test backend sync');
  }
  
  console.log('\n✅ Test completed!');
  console.log('\n📝 Instructions for your presentation:');
  console.log('1. Make sure PROTO_001 and PROTO_002 are sending data to ThingSpeak');
  console.log('2. Use the refresh button in the mobile app to force sync');
  console.log('3. Check the backend logs for sync status');
  console.log('4. The automatic sync runs every 5 minutes');
}

main().catch(console.error);

#!/usr/bin/env node

/**
 * Simple test script to verify ThingSpeak data without external dependencies
 * This script uses Node.js built-in fetch API
 */

const https = require('https');

const THINGSPEAK_CHANNEL_001 = '3062750';
const THINGSPEAK_CHANNEL_002 = '3083651';
const API_KEY_001 = 'TFISWV8UFLL0NRL3';
const API_KEY_002 = 'I33WO1DMIHVA0EQY';

function fetchThingSpeakData(channelId, apiKey) {
  return new Promise((resolve, reject) => {
    const url = `https://api.thingspeak.com/channels/${channelId}/feeds.json?api_key=${apiKey}&results=1`;
    
    https.get(url, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const jsonData = JSON.parse(data);
          resolve(jsonData);
        } catch (error) {
          reject(error);
        }
      });
    }).on('error', (error) => {
      reject(error);
    });
  });
}

async function testThingSpeakData() {
  console.log('🔍 Testing ThingSpeak data...\n');
  
  try {
    // Test PROTO_001
    console.log('📡 Fetching PROTO_001 data...');
    const data001 = await fetchThingSpeakData(THINGSPEAK_CHANNEL_001, API_KEY_001);
    
    if (data001.feeds && data001.feeds.length > 0) {
      const feed = data001.feeds[0];
      console.log('✅ PROTO_001 Data:');
      console.log(`   Temperature: ${feed.field1}°C`);
      console.log(`   Humidity: ${feed.field2}%`);
      console.log(`   Soil Moisture: ${feed.field3}%`);
      console.log(`   Soil pH: ${feed.field4}`);
      console.log(`   Light Intensity: ${feed.field5} lux`);
      console.log(`   Timestamp: ${feed.created_at}`);
      console.log('');
    } else {
      console.log('❌ No data found for PROTO_001');
    }
    
    // Test PROTO_002
    console.log('📡 Fetching PROTO_002 data...');
    const data002 = await fetchThingSpeakData(THINGSPEAK_CHANNEL_002, API_KEY_002);
    
    if (data002.feeds && data002.feeds.length > 0) {
      const feed = data002.feeds[0];
      console.log('✅ PROTO_002 Data:');
      console.log(`   Temperature: ${feed.field1}°C`);
      console.log(`   Humidity: ${feed.field2}%`);
      console.log(`   Soil Moisture: ${feed.field3}%`);
      console.log(`   Soil pH: ${feed.field4}`);
      console.log(`   Light Intensity: ${feed.field5} lux`);
      console.log(`   Timestamp: ${feed.created_at}`);
      console.log('');
    } else {
      console.log('❌ No data found for PROTO_002');
    }
    
  } catch (error) {
    console.error('❌ Error fetching ThingSpeak data:', error.message);
  }
}

async function main() {
  console.log('🚀 Starting simple ThingSpeak test...\n');
  
  await testThingSpeakData();
  
  console.log('✅ Test completed!');
  console.log('\n📝 Next steps:');
  console.log('1. Make sure your backend is running with the 15-second sync');
  console.log('2. Check your mobile app - it should now show real-time data');
  console.log('3. Use the refresh button (🔄) in the farm detail screen if needed');
}

main().catch(console.error);

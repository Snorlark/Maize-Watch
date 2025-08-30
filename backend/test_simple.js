const axios = require('axios');

async function testSimple() {
  try {
    console.log('Testing basic server response...');
    const response = await axios.get('http://localhost:8080/api/', {
      timeout: 3000
    });
    console.log('✅ Server responding:', response.status);
  } catch (error) {
    if (error.code === 'ECONNABORTED') {
      console.log('❌ Server timeout');
    } else if (error.response) {
      console.log('✅ Server responding with error:', error.response.status);
    } else {
      console.log('❌ Connection error:', error.message);
    }
  }
}

testSimple();

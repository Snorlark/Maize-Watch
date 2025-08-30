const axios = require('axios');

async function testRegistration() {
  try {
    const response = await axios.post('http://localhost:8080/api/auth/register', {
      username: "testfarmer3",
      password: "TestPass123!",
      fullName: "Test Farmer 3",
      contactNumber: "+639123456781",
      address: {
        region: "Central Luzon (Region III)",
        province: "Nueva Ecija",
        municipality: "Cabanatuan City",
        barangay: "Barangay Test 3",
        zipCode: "3100"
      },
      deviceType: "mobile"
    }, {
      timeout: 5000
    });
    
    console.log('✅ Registration successful:', response.status);
    console.log('Response:', JSON.stringify(response.data, null, 2));
  } catch (error) {
    if (error.response) {
      console.log('❌ Registration failed:', error.response.status);
      console.log('Error:', JSON.stringify(error.response.data, null, 2));
    } else if (error.code === 'ECONNABORTED') {
      console.log('❌ Request timed out - validation middleware might be hanging');
    } else {
      console.log('❌ Network error:', error.message);
    }
  }
}

testRegistration();

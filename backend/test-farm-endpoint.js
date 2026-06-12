const axios = require('axios');

async function testFarmEndpoints() {
  console.log('Testing farm endpoints...');
  
  try {
    // Test general farms endpoint
    console.log('\n1. Testing general farms endpoint...');
    const generalResponse = await axios.get('http://localhost:8080/api/farms');
    console.log('✅ General endpoint works:', generalResponse.status);
    console.log('Response data keys:', Object.keys(generalResponse.data));
    
    if (generalResponse.data.data && generalResponse.data.data.farms) {
      const farms = generalResponse.data.data.farms;
      console.log(`Found ${farms.length} farms`);
      
      if (farms.length > 0) {
        const firstFarm = farms[0];
        console.log('First farm ID:', firstFarm._id);
        console.log('First farm structure:', Object.keys(firstFarm));
        
        // Test specific farm endpoint
        console.log('\n2. Testing specific farm endpoint...');
        console.log(`Requesting: http://localhost:8080/api/farms/${firstFarm._id}`);
        
        try {
          const specificResponse = await axios.get(`http://localhost:8080/api/farms/${firstFarm._id}`);
          console.log('✅ Specific endpoint works:', specificResponse.status);
          console.log('Specific farm data:', specificResponse.data);
        } catch (specificError) {
          console.log('❌ Specific endpoint failed:');
          console.log('Error code:', specificError.code);
          console.log('Error message:', specificError.message);
          if (specificError.response) {
            console.log('Response status:', specificError.response.status);
            console.log('Response data:', specificError.response.data);
          }
        }
      }
    }
    
  } catch (error) {
    console.log('❌ General endpoint failed:');
    console.log('Error code:', error.code);
    console.log('Error message:', error.message);
    if (error.response) {
      console.log('Response status:', error.response.status);
      console.log('Response data:', error.response.data);
    }
  }
}

testFarmEndpoints();

const mongoose = require('mongoose');
require('dotenv').config();

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/maizewatch');
    console.log('✅ Connected to MongoDB');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
    process.exit(1);
  }
};

// Test force regenerate prescriptions
const testForceRegenerate = async () => {
  try {
    console.log('🧪 Testing force regenerate prescriptions...');
    
    const farmId = '68dc74bcfdba2e4b9a9b8249';
    console.log('🔍 Testing force regenerate for farm ID:', farmId);
    
    // Import the prescription controller
    const { forceRegeneratePrescriptions } = require('./dist/controllers/prescriptionController');
    
    // Create a mock request and response
    const mockReq = {
      params: { farmId: farmId },
      user: { id: '68dc74a3fdba2e4b9a9b8240' } // User ID from logs
    };
    
    const mockRes = {
      status: (code) => ({
        json: (data) => {
          console.log('📊 Response Status:', code);
          console.log('📊 Response Data:', JSON.stringify(data, null, 2));
        }
      })
    };
    
    // Test the force regenerate
    await forceRegeneratePrescriptions(mockReq, mockRes);
    
  } catch (error) {
    console.error('❌ Test error:', error);
  }
};

// Main test function
const runTest = async () => {
  await connectDB();
  await testForceRegenerate();
  await mongoose.disconnect();
  console.log('✅ Test completed');
};

runTest();

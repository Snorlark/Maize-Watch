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

// Test prescription generation with real farm ID
const testPrescriptionGeneration = async () => {
  try {
    console.log('🧪 Testing prescription generation with real farm ID...');
    
    // Use the farm ID from the logs
    const farmId = '68dc74bcfdba2e4b9a9b8249';
    console.log('🔍 Testing with farm ID:', farmId);
    
    // Import the prescription controller
    const { getPrescriptions } = require('./dist/controllers/prescriptionController');
    
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
    
    // Test the prescription generation
    await getPrescriptions(mockReq, mockRes);
    
  } catch (error) {
    console.error('❌ Test error:', error);
  }
};

// Main test function
const runTest = async () => {
  await connectDB();
  await testPrescriptionGeneration();
  await mongoose.disconnect();
  console.log('✅ Test completed');
};

runTest();

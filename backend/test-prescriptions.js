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

// Test prescription generation
const testPrescriptionGeneration = async () => {
  try {
    console.log('🧪 Testing prescription generation...');
    
    // Import the prescription controller
    const { getPrescriptions } = require('./dist/controllers/prescriptionController');
    
    // Create a mock request and response
    const mockReq = {
      params: { farmId: '675ac48c44c44c44c44c44c4' }, // Replace with actual farm ID
      user: { id: '675ac48c44c44c44c44c44c4' }
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

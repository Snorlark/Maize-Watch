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

// Check existing prescriptions
const checkPrescriptions = async () => {
  try {
    console.log('🔍 Checking existing prescriptions...');
    
    const farmId = '68dc74bcfdba2e4b9a9b8249';
    console.log('🔍 Checking prescriptions for farm ID:', farmId);
    
    // Import the Prescription model
    const Prescription = require('./dist/models/Prescription').default;
    
    // Check if there are existing prescriptions
    const existingPrescriptions = await Prescription.find({ farmId: new mongoose.Types.ObjectId(farmId) });
    console.log('📊 Existing prescriptions count:', existingPrescriptions.length);
    
    if (existingPrescriptions.length > 0) {
      console.log('📊 Existing prescriptions:');
      existingPrescriptions.forEach((prescription, index) => {
        console.log(`${index + 1}. ${prescription.title} for ${prescription.fieldName} (${prescription.status})`);
      });
    } else {
      console.log('📊 No existing prescriptions found');
    }
    
    // Check if there's a farm with this ID
    const Farm = require('./dist/models/Farm').default;
    const farm = await Farm.findById(farmId);
    
    if (farm) {
      console.log('✅ Farm found:', farm.farmName);
      console.log('📊 Farm fields:', farm.fields?.map(f => f.fieldName) || 'No fields');
    } else {
      console.log('❌ Farm not found with ID:', farmId);
    }
    
  } catch (error) {
    console.error('❌ Error checking prescriptions:', error);
  }
};

// Main function
const runCheck = async () => {
  await connectDB();
  await checkPrescriptions();
  await mongoose.disconnect();
  console.log('✅ Check completed');
};

runCheck();

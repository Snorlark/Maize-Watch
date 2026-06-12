const mongoose = require('mongoose');
const Farm = require('./backend/dist/models/Farm').default;

async function checkFields() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/maize-watch');
    console.log('Connected to MongoDB');
    
    // Find all farms
    const farms = await Farm.find({}).populate('userId');
    
    for (const farm of farms) {
      console.log(`\n🌾 Farm: ${farm.farmName} (ID: ${farm._id})`);
      console.log(`   User: ${farm.userId ? farm.userId.fullName : 'Unknown'}`);
      console.log(`   Fields:`);
      
      for (const field of farm.fields) {
        console.log(`     - ${field.fieldName} (ID: ${field._id})`);
        console.log(`       Growth Stage: ${field.growthStage}`);
        console.log(`       Sensors: ${field.sensors?.length || 0}`);
      }
    }
    
    await mongoose.disconnect();
  } catch (error) {
    console.error('Error:', error);
  }
}

checkFields();

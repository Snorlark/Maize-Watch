const mongoose = require('mongoose');

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/maize-watch', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

const Farm = require('./backend/src/models/Farm');

async function checkAndCleanFields() {
  try {
    console.log('🔍 Checking farms and fields...');
    
    const farms = await Farm.find({}).populate('userId', 'username');
    console.log(`Found ${farms.length} farms`);
    
    for (const farm of farms) {
      console.log(`\n🏡 Farm ID: ${farm._id}`);
      console.log(`👤 User: ${farm.userId?.username || 'Unknown'}`);
      
      if (farm.fields && farm.fields.length > 0) {
        console.log(`📊 Fields (${farm.fields.length}):`);
        
        // Check for Field 123
        const field123Index = farm.fields.findIndex(field => field.fieldName === 'Field 123');
        if (field123Index !== -1) {
          console.log(`❌ Found "Field 123" at index ${field123Index}`);
          console.log('   Field details:', {
            id: farm.fields[field123Index]._id,
            name: farm.fields[field123Index].fieldName,
            soilType: farm.fields[field123Index].soilType,
            growthStage: farm.fields[field123Index].growthStage
          });
          
          // Remove Field 123
          farm.fields.splice(field123Index, 1);
          await farm.save();
          console.log('✅ Removed "Field 123" from farm');
        }
        
        // Show remaining fields
        farm.fields.forEach((field, index) => {
          console.log(`  ${index + 1}. ${field.fieldName} (ID: ${field._id})`);
        });
      } else {
        console.log('  No fields found');
      }
    }
    
    console.log('\n✅ Database check and cleanup completed');
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

checkAndCleanFields();

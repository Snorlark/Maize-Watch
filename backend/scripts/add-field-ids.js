const mongoose = require('mongoose');
require('dotenv').config();

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const Farm = require('../dist/models/Farm').default;

async function addFieldIds() {
  try {
    console.log('Starting to add field IDs to existing farms...');
    
    const farms = await Farm.find({});
    console.log(`Found ${farms.length} farms to update`);
    
    for (const farm of farms) {
      let updated = false;
      
      for (const field of farm.fields) {
        if (!field._id) {
          field._id = new mongoose.Types.ObjectId();
          updated = true;
          console.log(`Added field ID ${field._id} to field "${field.fieldName}" in farm "${farm.farmName}"`);
        }
      }
      
      if (updated) {
        await farm.save();
        console.log(`Updated farm: ${farm.farmName}`);
      }
    }
    
    console.log('Field ID addition completed successfully!');
  } catch (error) {
    console.error('Error adding field IDs:', error);
  } finally {
    mongoose.connection.close();
  }
}

addFieldIds();

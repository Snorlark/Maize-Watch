import mongoose from 'mongoose';

async function fixRegion() {
  await mongoose.connect('mongodb+srv://larksigmuondbabao:aKO5hHmP0ZZYQPfp@maizewatch-db.snrxrjs.mongodb.net/maizewatch?retryWrites=true&w=majority&appName=maizewatch-db');
  const db = mongoose.connection.db;
  
  await db!.collection('users').updateOne(
    { username: 'Jobert' },
    { $set: { "address.region": "National Capital Region (NCR)" } }
  );
  
  console.log("Jobert region updated successfully to match mongoose schema constraints.");
  
  await mongoose.disconnect();
}
fixRegion().catch(console.error);

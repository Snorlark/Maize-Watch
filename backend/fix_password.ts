import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

async function fixPassword() {
  await mongoose.connect('mongodb+srv://larksigmuondbabao:aKO5hHmP0ZZYQPfp@maizewatch-db.snrxrjs.mongodb.net/maizewatch?retryWrites=true&w=majority&appName=maizewatch-db');
  console.log("Connected to db");
  const db = mongoose.connection.db;
  
  const salt = await bcrypt.genSalt(12);
  const hashedPassword = await bcrypt.hash('Juan.delacruz01', salt);
  
  const result = await db!.collection('users').updateOne(
    { username: 'juandelacruz' },
    { $set: { password: hashedPassword } }
  );
  
  if (result.matchedCount > 0) {
    console.log("Password successfully updated to Juan.delacruz01");
  } else {
    console.log("User juandelacruz not found");
  }
  
  await mongoose.disconnect();
}
fixPassword().catch(console.error);

import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

async function checkUser() {
  await mongoose.connect('mongodb+srv://larksigmuondbabao:aKO5hHmP0ZZYQPfp@maizewatch-db.snrxrjs.mongodb.net/maizewatch?retryWrites=true&w=majority&appName=maizewatch-db');
  console.log("Connected to db");
  const db = mongoose.connection.db;
  const user = await db!.collection('users').findOne({username: 'juandelacruz'});
  if (!user) {
    console.log("User 'juandelacruz' does not exist.");
  } else {
    console.log("User exists.");
    const match = await bcrypt.compare('Juan.delacruz01', user.password);
    console.log("Password matches:", match);
  }
  await mongoose.disconnect();
}
checkUser().catch(console.error);

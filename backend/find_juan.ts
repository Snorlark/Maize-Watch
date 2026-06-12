import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

async function findJuan() {
  await mongoose.connect('mongodb+srv://larksigmuondbabao:aKO5hHmP0ZZYQPfp@maizewatch-db.snrxrjs.mongodb.net/maizewatch?retryWrites=true&w=majority&appName=maizewatch-db');
  const db = mongoose.connection.db;
  
  // Find all users and print out
  const users = await db!.collection('users').find({}).toArray();
  console.log(`Found ${users.length} users`);
  
  for (const user of users) {
    if (user.username === 'Jobert') {
       console.log('Found Jobert, updating password...');
       const salt = await bcrypt.genSalt(12);
       const hashedPassword = await bcrypt.hash('Juan.delacruz01', salt);
       await db!.collection('users').updateOne(
         { _id: user._id },
         { $set: { password: hashedPassword, isActive: true, loginAttempts: 0 } }
       );
       console.log('Jobert password reset to: Juan.delacruz01 and account activated');
    }
  }
  
  const farms = await db!.collection('farms').find({name: "Juan's Farm"}).toArray();
  for (const farm of farms) {
     console.log("Farm:", farm.name, "belongs to user ID:", farm.userId || farm.owner);
     const owner = await db!.collection('users').findOne({_id: farm.userId || farm.owner});
     if (owner) {
         console.log("Owner username:", owner.username, "ID:", owner._id);
         const salt = await bcrypt.genSalt(12);
         const hashedPassword = await bcrypt.hash('Juan.delacruz01', salt);
         await db!.collection('users').updateOne(
           { _id: owner._id },
           { $set: { password: hashedPassword, isActive: true } }
         );
         console.log("Owner password reset to: Juan.delacruz01");
     }
  }
  
  await mongoose.disconnect();
}
findJuan().catch(console.error);

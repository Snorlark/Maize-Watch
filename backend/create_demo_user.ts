import dotenv from 'dotenv';
dotenv.config();

import mongoose from 'mongoose';
import bcrypt from 'bcrypt';

async function main() {
  await mongoose.connect(process.env.MONGO_URI!);

  const db = mongoose.connection.db!;
  const users = db.collection('users');

  const existing = await users.findOne({ username: 'demofarmer' });
  if (existing) {
    console.log('User demofarmer already exists, updating password...');
    const hash = await bcrypt.hash('Demo1234!', 12);
    await users.updateOne({ username: 'demofarmer' }, { $set: { password: hash, isActive: true } });
    console.log('Password updated.');
    await mongoose.disconnect();
    return;
  }

  const hash = await bcrypt.hash('Demo1234!', 12);

  await users.insertOne({
    username: 'demofarmer',
    email: 'demofarmer@maizewatch.local',
    password: hash,
    fullName: 'Demo Farmer',
    contactNumber: '09171234567',
    address: {
      region: 'Central Luzon (Region III)',
      province: 'Bulacan',
      municipality: 'Malolos',
      barangay: 'Bulihan',
    },
    role: 'user',
    isActive: true,
    emailVerified: true,
    twoFactorEnabled: false,
    loginAttempts: 0,
    refreshTokens: [],
    preferences: {
      language: 'en',
      timezone: 'Asia/Manila',
      notifications: { email: true, sms: false, push: true },
    },
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  console.log('✅ Created user:');
  console.log('   Username : demofarmer');
  console.log('   Password : Demo1234!');

  await mongoose.disconnect();
}

main().catch(e => { console.error(e); process.exit(1); });

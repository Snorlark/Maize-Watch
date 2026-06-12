import mongoose from 'mongoose';
import dotenv from 'dotenv';
dotenv.config();

const MONGO_URI = process.env.MONGO_URI || '';
const LARK_FARM_ID = '6a2bb22196994ca22aa613f2';

async function fix() {
  if (!MONGO_URI) { console.error('Set MONGO_URI in .env'); process.exit(1); }
  await mongoose.connect(MONGO_URI);
  const db = mongoose.connection.db!;
  const farmId = new mongoose.Types.ObjectId(LARK_FARM_ID);

  const result = await db.collection('sensors').updateMany(
    { farm: farmId },
    { $set: { isActive: true, status: 'active' } }
  );
  console.log(`Updated ${result.modifiedCount} sensor(s) for farm ${LARK_FARM_ID} → isActive: true`);

  const sensors = await db.collection('sensors').find({ farm: farmId, isActive: true }).toArray();
  console.log('Sensors now findable by getSensorsByFarm:', sensors.map(s => ({ id: s._id, isActive: s.isActive, status: s.status })));

  await mongoose.disconnect();
}

fix().catch(err => { console.error(err); process.exit(1); });

import mongoose from 'mongoose';
import dotenv from 'dotenv';
dotenv.config();

const MONGO_URI = process.env.MONGO_URI || '';
const LARK_FARM_ID = '6a2bb22196994ca22aa613f2';
const SENSOR_ID = '6a2bda251259512bdf43168e';

async function check() {
  if (!MONGO_URI) { process.exit(1); }
  await mongoose.connect(MONGO_URI);
  const db = mongoose.connection.db!;

  const farmId = new mongoose.Types.ObjectId(LARK_FARM_ID);
  const sensorId = new mongoose.Types.ObjectId(SENSOR_ID);

  // Check sensor is findable (getSensorsByFarm condition)
  const sensor = await db.collection('sensors').findOne({ farm: farmId, isActive: true });
  console.log('getSensorsByFarm result:', sensor ? `found: ${sensor._id}` : 'NOT FOUND');

  // Replicate what analyticsController does for weekOffset=-36 from Jun 12, 2026
  // endDate = Oct 4, 2025 Manila = Oct 4 15:59:59 UTC
  // startDate = Sep 28, 2025 Manila 00:00 = Sep 27 16:00 UTC
  const startDate = new Date('2025-09-27T16:00:00.000Z');
  const endDate   = new Date('2025-10-04T15:59:59.999Z');

  const counts = await db.collection('sensor_readings').aggregate([
    {
      $match: {
        sensor: sensorId,
        timestamp: { $gte: startDate, $lte: endDate },
      },
    },
    {
      $group: {
        _id: {
          year:  { $year:  { date: '$timestamp', timezone: 'Asia/Manila' } },
          month: { $month: { date: '$timestamp', timezone: 'Asia/Manila' } },
          day:   { $dayOfMonth: { date: '$timestamp', timezone: 'Asia/Manila' } },
        },
        count: { $sum: 1 },
      },
    },
    { $sort: { '_id.year': 1, '_id.month': 1, '_id.day': 1 } },
  ]).toArray();

  console.log(`\nReadings per day for Sep 28 – Oct 4 (weekOffset=-36 window):`);
  if (counts.length === 0) {
    console.log('  NO DATA FOUND');
  } else {
    counts.forEach(r => console.log(`  ${r._id.year}-${String(r._id.month).padStart(2,'0')}-${String(r._id.day).padStart(2,'0')}: ${r.count} readings`));
  }

  // Also check current week Jun 6-12, 2026
  const startCurrent = new Date('2025-06-05T16:00:00.000Z'); // Jun 6 Manila = Jun 5 16:00 UTC
  const endCurrent   = new Date('2026-06-12T15:59:59.999Z');
  const currentTotal = await db.collection('sensor_readings').countDocuments({
    sensor: sensorId,
    timestamp: { $gte: new Date('2026-06-05T16:00:00.000Z'), $lte: new Date('2026-06-12T15:59:59.999Z') },
  });
  console.log(`\nCurrent week (Jun 6-12, 2026) total readings: ${currentTotal}`);

  await mongoose.disconnect();
}

check().catch(err => { console.error(err); process.exit(1); });

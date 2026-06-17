import mongoose from 'mongoose';
import dotenv from 'dotenv';
dotenv.config();

const MONGO_URI = process.env.MONGO_URI || '';
const LARK_FARM_ID = '6a2bb22196994ca22aa613f2';

async function clearSeededData() {
  if (!MONGO_URI) {
    console.error('MONGO_URI not set in .env');
    process.exit(1);
  }
  await mongoose.connect(MONGO_URI);
  const db = mongoose.connection.db!;

  const farmObjectId = new mongoose.Types.ObjectId(LARK_FARM_ID);

  // Find all sensors for this farm (active and inactive)
  const sensors = await db.collection('sensors').find({ farm: farmObjectId }).toArray();
  const sensorIds = sensors.map(s => s._id);

  console.log(`Found ${sensorIds.length} sensor(s) for farm ${LARK_FARM_ID}`);
  sensors.forEach(s => console.log(`  Sensor: ${s._id} (${s.name || 'unnamed'})`));

  // Count simulation readings before deletion
  const countBefore = await db.collection('sensor_readings').countDocuments({
    sensor: { $in: sensorIds },
    'metadata.source': 'simulation',
  });

  const countTotal = await db.collection('sensor_readings').countDocuments({
    sensor: { $in: sensorIds },
  });

  console.log(`\nTotal readings for farm sensors: ${countTotal}`);
  console.log(`Simulation (seeded) readings to delete: ${countBefore}`);

  if (countBefore === 0) {
    console.log('\nNo simulation data found — nothing to delete.');
    await mongoose.disconnect();
    return;
  }

  // Show date range of simulation data
  const [earliest, latest] = await Promise.all([
    db.collection('sensor_readings').findOne(
      { sensor: { $in: sensorIds }, 'metadata.source': 'simulation' },
      { sort: { timestamp: 1 } }
    ),
    db.collection('sensor_readings').findOne(
      { sensor: { $in: sensorIds }, 'metadata.source': 'simulation' },
      { sort: { timestamp: -1 } }
    ),
  ]);

  console.log(`\nSimulation data spans:`);
  console.log(`  Earliest: ${earliest?.timestamp}`);
  console.log(`  Latest:   ${latest?.timestamp}`);

  // Delete all simulation readings
  const result = await db.collection('sensor_readings').deleteMany({
    sensor: { $in: sensorIds },
    'metadata.source': 'simulation',
  });

  console.log(`\nDeleted ${result.deletedCount} simulation readings.`);

  // Verify
  const countAfter = await db.collection('sensor_readings').countDocuments({
    sensor: { $in: sensorIds },
  });
  const thingspeakCount = await db.collection('sensor_readings').countDocuments({
    sensor: { $in: sensorIds },
    'metadata.source': 'thingspeak',
  });
  console.log(`Real (ThingSpeak) readings remaining: ${thingspeakCount}`);
  console.log(`Total readings remaining: ${countAfter}`);

  await mongoose.disconnect();
  console.log('\nDone.');
}

clearSeededData().catch(err => {
  console.error(err);
  process.exit(1);
});

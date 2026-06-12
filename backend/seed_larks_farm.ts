import mongoose from 'mongoose';
import dotenv from 'dotenv';
dotenv.config();

const MONGO_URI = process.env.MONGO_URI || '';
const LARK_FARM_ID = '6a2bb22196994ca22aa613f2';

function clamp(v: number, min: number, max: number) { return Math.max(min, Math.min(max, v)); }

function smoothNoise(seed: number, amplitude: number) {
  const x = Math.sin(seed * 127.1 + 311.7) * 43758.5453;
  return (x - Math.floor(x) - 0.5) * 2 * amplitude;
}

function diurnal(manilaHour: number) {
  const rad = ((manilaHour - 5) / 24) * 2 * Math.PI;
  return (Math.sin(rad) + 1) / 2;
}

function buildDayReadings(
  sensorId: mongoose.Types.ObjectId,
  farmId: mongoose.Types.ObjectId,
  manilaDay: Date,
  baseline: { temp: number; hum: number; soil: number; light: number; ph: number },
  dayIndex: number
) {
  const MANILA_OFFSET_MS = 8 * 60 * 60 * 1000;
  const utcStart = new Date(manilaDay.getTime() - MANILA_OFFSET_MS);
  const docs: object[] = [];

  for (let slot = 0; slot < 96; slot++) {
    const ts = new Date(utcStart.getTime() + slot * 15 * 60 * 1000);
    const manilaHour = ((ts.getUTCHours() + 8) % 24) + (ts.getUTCMinutes() / 60);
    const d = diurnal(manilaHour);
    const seed = dayIndex * 1000 + slot;

    const temp = clamp(baseline.temp + (d - 0.5) * 8 + smoothNoise(seed, 0.5), 22, 32);
    const hum = clamp(baseline.hum - (d - 0.5) * 12 + smoothNoise(seed + 1, 1.5), 45, 85);
    const soilDrift = -(slot / 96) * 2;
    const soil = clamp(baseline.soil + soilDrift + smoothNoise(seed + 2, 0.8), 40, 75);
    const isDaytime = manilaHour >= 6 && manilaHour <= 18;
    let light = 0;
    if (isDaytime) {
      const noonFraction = 1 - Math.abs(manilaHour - 12) / 6;
      light = clamp(baseline.light * noonFraction + smoothNoise(seed + 3, baseline.light * 0.1), 5, 1200);
    }
    const ph = clamp(baseline.ph + smoothNoise(seed + 4, 0.05), 6.0, 7.0);

    docs.push({
      sensor: sensorId,
      farm: farmId,
      timestamp: ts,
      data: {
        temperature: parseFloat(temp.toFixed(2)),
        humidity: parseFloat(hum.toFixed(2)),
        soilMoisture: parseFloat(soil.toFixed(2)),
        lightIntensity: parseFloat(light.toFixed(1)),
        pH: parseFloat(ph.toFixed(2)),
      },
      metadata: { source: 'simulation', quality: 'good', processed: true, anomaly: false, calibrated: true },
    });
  }
  return docs;
}

async function seed() {
  if (!MONGO_URI) {
    console.error('Set MONGO_URI env var before running');
    process.exit(1);
  }

  await mongoose.connect(MONGO_URI);
  console.log('Connected to DB');
  const db = mongoose.connection.db!;

  const farmId = new mongoose.Types.ObjectId(LARK_FARM_ID);

  const farm = await db.collection('farms').findOne({ _id: farmId });
  if (!farm) {
    console.error(`Farm ${LARK_FARM_ID} not found`);
    process.exit(1);
  }
  console.log(`Farm: ${farm.name}`);

  // Find or create a sensor for this farm
  let sensor = await db.collection('sensors').findOne({ farm: farmId });
  if (!sensor) {
    const newSensorId = new mongoose.Types.ObjectId();
    await db.collection('sensors').insertOne({
      _id: newSensorId,
      farm: farmId,
      name: 'Main Field Sensor',
      type: 'multi',
      status: 'active',
      isActive: true,
      location: { type: 'Point', coordinates: [0, 0] },
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    sensor = await db.collection('sensors').findOne({ _id: newSensorId });
    console.log(`Created sensor: ${sensor!._id}`);
  } else {
    console.log(`Using sensor: ${sensor._id} (${sensor.name})`);
  }

  const MANILA_OFFSET_MS = 8 * 60 * 60 * 1000;
  const nowManila = new Date(Date.now() + MANILA_OFFSET_MS);
  const todayYear = nowManila.getUTCFullYear();
  const todayMonth = nowManila.getUTCMonth();
  const todayDay = nowManila.getUTCDate();

  // Seed the last 35 days so all week-offset views have data
  const DAYS_TO_SEED = 35;
  let baseline = { temp: 27.5, hum: 67, soil: 58, light: 520, ph: 6.4 };

  for (let daysAgo = DAYS_TO_SEED - 1; daysAgo >= 0; daysAgo--) {
    const manilaDay = new Date(Date.UTC(todayYear, todayMonth, todayDay - daysAgo));
    const dayLabel = manilaDay.toISOString().split('T')[0];
    const utcStart = new Date(manilaDay.getTime() - MANILA_OFFSET_MS);
    const utcEnd = new Date(utcStart.getTime() + 24 * 60 * 60 * 1000 - 1);

    const existingCount = await db.collection('sensor_readings').countDocuments({
      farm: farmId,
      timestamp: { $gte: utcStart, $lte: utcEnd },
    });

    if (existingCount >= 50) {
      console.log(`  ${dayLabel}: ${existingCount} readings already — keeping`);
      // Update baseline from real data
      const agg = await db.collection('sensor_readings').aggregate([
        { $match: { farm: farmId, timestamp: { $gte: utcStart, $lte: utcEnd } } },
        { $group: { _id: null, temp: { $avg: '$data.temperature' }, hum: { $avg: '$data.humidity' }, soil: { $avg: '$data.soilMoisture' }, light: { $avg: '$data.lightIntensity' }, ph: { $avg: '$data.pH' } } },
      ]).toArray();
      if (agg.length > 0) {
        baseline = { temp: agg[0].temp ?? baseline.temp, hum: agg[0].hum ?? baseline.hum, soil: agg[0].soil ?? baseline.soil, light: agg[0].light ?? baseline.light, ph: agg[0].ph ?? baseline.ph };
      }
      continue;
    }

    // Remove any stale simulation readings first
    const deleted = await db.collection('sensor_readings').deleteMany({
      farm: farmId,
      timestamp: { $gte: utcStart, $lte: utcEnd },
      'metadata.source': 'simulation',
    });

    const docs = buildDayReadings(sensor!._id, farmId, manilaDay, baseline, daysAgo);
    await db.collection('sensor_readings').insertMany(docs);
    console.log(`  ${dayLabel}: inserted ${docs.length} readings (removed ${deleted.deletedCount} old sim)`);

    // Roll baseline forward
    const avg = docs.reduce(
      (acc: any, d: any) => ({ temp: acc.temp + d.data.temperature, hum: acc.hum + d.data.humidity, soil: acc.soil + d.data.soilMoisture, light: acc.light + d.data.lightIntensity, ph: acc.ph + d.data.pH, cnt: acc.cnt + 1 }),
      { temp: 0, hum: 0, soil: 0, light: 0, ph: 0, cnt: 0 }
    );
    baseline = { temp: avg.temp / avg.cnt, hum: avg.hum / avg.cnt, soil: avg.soil / avg.cnt, light: avg.light / avg.cnt, ph: avg.ph / avg.cnt };
  }

  console.log('\nDone seeding Lark\'s Farm.');
  await mongoose.disconnect();
}

seed().catch(err => { console.error(err); process.exit(1); });

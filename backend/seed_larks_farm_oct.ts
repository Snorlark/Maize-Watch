// Extends Lark's Farm historical data from Oct 13 through Oct 31, 2025.
// This covers weekOffset -33 (Oct 18-24) and -34 (Oct 11-17 remainder).
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
    const soil = clamp(baseline.soil - (slot / 96) * 2 + smoothNoise(seed + 2, 0.8), 40, 75);
    const isDaytime = manilaHour >= 6 && manilaHour <= 18;
    const light = isDaytime
      ? clamp(baseline.light * (1 - Math.abs(manilaHour - 12) / 6) + smoothNoise(seed + 3, baseline.light * 0.1), 5, 1200)
      : 0;
    const ph = clamp(baseline.ph + smoothNoise(seed + 4, 0.05), 6.0, 7.0);
    docs.push({
      sensor: sensorId, farm: farmId, timestamp: ts,
      data: {
        temperature: parseFloat(temp.toFixed(2)), humidity: parseFloat(hum.toFixed(2)),
        soilMoisture: parseFloat(soil.toFixed(2)), lightIntensity: parseFloat(light.toFixed(1)),
        pH: parseFloat(ph.toFixed(2)),
      },
      metadata: { source: 'simulation', quality: 'good', processed: true, anomaly: false, calibrated: true },
    });
  }
  return docs;
}

async function seed() {
  if (!MONGO_URI) { console.error('Set MONGO_URI in .env'); process.exit(1); }
  await mongoose.connect(MONGO_URI);
  const db = mongoose.connection.db!;
  const farmId = new mongoose.Types.ObjectId(LARK_FARM_ID);
  const sensor = await db.collection('sensors').findOne({ farm: farmId, isActive: true });
  if (!sensor) { console.error('No active sensor for farm'); process.exit(1); }
  console.log(`Sensor: ${sensor._id}`);

  // Oct 13 – Oct 31, 2025 (19 days — fills gaps for weekOffset -33 and -34)
  const START_MANILA = new Date('2025-10-13T00:00:00.000Z');
  const TOTAL_DAYS = 19;
  const MANILA_OFFSET_MS = 8 * 60 * 60 * 1000;

  // Get baseline from Oct 12 (last seeded day)
  const oct12Start = new Date('2025-10-11T16:00:00.000Z');
  const oct12End   = new Date('2025-10-12T15:59:59.999Z');
  const baselineAgg = await db.collection('sensor_readings').aggregate([
    { $match: { farm: farmId, timestamp: { $gte: oct12Start, $lte: oct12End } } },
    { $group: { _id: null, temp: { $avg: '$data.temperature' }, hum: { $avg: '$data.humidity' }, soil: { $avg: '$data.soilMoisture' }, light: { $avg: '$data.lightIntensity' }, ph: { $avg: '$data.pH' } } },
  ]).toArray();

  let baseline = baselineAgg.length > 0
    ? { temp: baselineAgg[0].temp ?? 27, hum: baselineAgg[0].hum ?? 68, soil: baselineAgg[0].soil ?? 58, light: baselineAgg[0].light ?? 480, ph: baselineAgg[0].ph ?? 6.4 }
    : { temp: 27, hum: 68, soil: 58, light: 480, ph: 6.4 };

  console.log(`Baseline from Oct 12: temp=${baseline.temp.toFixed(1)} hum=${baseline.hum.toFixed(1)} soil=${baseline.soil.toFixed(1)}`);

  for (let i = 0; i < TOTAL_DAYS; i++) {
    const manilaDay = new Date(START_MANILA.getTime() + i * 24 * 60 * 60 * 1000);
    const dayLabel = manilaDay.toISOString().split('T')[0];
    const utcStart = new Date(manilaDay.getTime() - MANILA_OFFSET_MS);
    const utcEnd = new Date(utcStart.getTime() + 24 * 60 * 60 * 1000 - 1);

    const existing = await db.collection('sensor_readings').countDocuments({ farm: farmId, timestamp: { $gte: utcStart, $lte: utcEnd } });
    if (existing >= 50) { console.log(`  ${dayLabel}: ${existing} readings — keeping`); continue; }

    const deleted = await db.collection('sensor_readings').deleteMany({ farm: farmId, timestamp: { $gte: utcStart, $lte: utcEnd }, 'metadata.source': 'simulation' });
    const docs = buildDayReadings(sensor._id, farmId, manilaDay, baseline, i + 100);
    await db.collection('sensor_readings').insertMany(docs);
    console.log(`  ${dayLabel}: inserted ${docs.length} (removed ${deleted.deletedCount} old)`);

    const avg = docs.reduce((a: any, d: any) => ({ temp: a.temp+d.data.temperature, hum: a.hum+d.data.humidity, soil: a.soil+d.data.soilMoisture, light: a.light+d.data.lightIntensity, ph: a.ph+d.data.pH, cnt: a.cnt+1 }), { temp:0,hum:0,soil:0,light:0,ph:0,cnt:0 });
    baseline = { temp: avg.temp/avg.cnt, hum: avg.hum/avg.cnt, soil: avg.soil/avg.cnt, light: avg.light/avg.cnt, ph: avg.ph/avg.cnt };
  }

  console.log('\nDone.');
  await mongoose.disconnect();
}

seed().catch(err => { console.error(err); process.exit(1); });

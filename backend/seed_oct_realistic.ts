import mongoose from 'mongoose';
import dotenv from 'dotenv';
dotenv.config();

const MONGO_URI = process.env.MONGO_URI || '';

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
  console.log('Connected to DB');
  const db = mongoose.connection.db!;

  const sensors = await db.collection('sensors').find({}).toArray();
  console.log(`Found ${sensors.length} sensor(s)`);

  const MANILA_OFFSET_MS = 8 * 60 * 60 * 1000;
  const targetDays = [
    new Date('2025-10-01T00:00:00.000Z'),
    new Date('2025-10-02T00:00:00.000Z'),
    new Date('2025-10-03T00:00:00.000Z'),
    new Date('2025-10-04T00:00:00.000Z'),
    new Date('2025-10-05T00:00:00.000Z'),
  ];

  for (const sensor of sensors) {
    const farmId = sensor.farm;
    if (!farmId) continue;
    console.log(`\nSensor: ${sensor._id} (${sensor.name}) — farm ${farmId}`);

    const beforeOct1 = new Date('2025-09-30T16:00:00.000Z');
    const baselineAgg = await db.collection('sensor_readings').aggregate([
      { $match: { sensor: sensor._id, timestamp: { $gte: new Date('2025-09-23T16:00:00.000Z'), $lt: beforeOct1 } } },
      { $group: { _id: null, temp: { $avg: '$data.temperature' }, hum: { $avg: '$data.humidity' }, soil: { $avg: '$data.soilMoisture' }, light: { $avg: '$data.lightIntensity' }, ph: { $avg: '$data.pH' }, cnt: { $sum: 1 } } },
    ]).toArray();

    let baseline = baselineAgg.length > 0 && baselineAgg[0].cnt > 0
      ? { temp: baselineAgg[0].temp ?? 27, hum: baselineAgg[0].hum ?? 65, soil: baselineAgg[0].soil ?? 58, light: baselineAgg[0].light ?? 500, ph: baselineAgg[0].ph ?? 6.4 }
      : { temp: 27, hum: 68, soil: 58, light: 520, ph: 6.4 };

    for (let i = 0; i < targetDays.length; i++) {
      const manilaDay = targetDays[i];
      const dayLabel = manilaDay.toISOString().split('T')[0];
      const utcStart = new Date(manilaDay.getTime() - MANILA_OFFSET_MS);
      const utcEnd   = new Date(utcStart.getTime() + 24 * 60 * 60 * 1000 - 1);

      const existingCount = await db.collection('sensor_readings').countDocuments({ sensor: sensor._id, timestamp: { $gte: utcStart, $lte: utcEnd } });
      const deleted = await db.collection('sensor_readings').deleteMany({ sensor: sensor._id, timestamp: { $gte: utcStart, $lte: utcEnd }, 'metadata.source': 'simulation' });
      const realCount = existingCount - deleted.deletedCount;

      if (realCount >= 50) { console.log(`  ${dayLabel}: ${realCount} real readings — keeping`); continue; }

      const docs = buildDayReadings(sensor._id, farmId, manilaDay, baseline, i);
      await db.collection('sensor_readings').insertMany(docs);
      console.log(`  ${dayLabel}: inserted ${docs.length} readings`);

      const avg = docs.reduce(
        (acc: any, d: any) => ({ temp: acc.temp + d.data.temperature, hum: acc.hum + d.data.humidity, soil: acc.soil + d.data.soilMoisture, light: acc.light + d.data.lightIntensity, ph: acc.ph + d.data.pH, cnt: acc.cnt + 1 }),
        { temp: 0, hum: 0, soil: 0, light: 0, ph: 0, cnt: 0 }
      );
      baseline = { temp: avg.temp / avg.cnt, hum: avg.hum / avg.cnt, soil: avg.soil / avg.cnt, light: avg.light / avg.cnt, ph: avg.ph / avg.cnt };
    }
  }

  console.log('\nDone.');
  await mongoose.disconnect();
}

seed().catch(err => { console.error(err); process.exit(1); });

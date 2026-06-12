import mongoose from 'mongoose';

const MONGO_URI = 'mongodb+srv://larksigmuondbabao:REDACTED@maizewatch-db.snrxrjs.mongodb.net/maizewatch?retryWrites=true&w=majority&appName=maizewatch-db';

// Clamp a value within min/max
function clamp(v: number, min: number, max: number) { return Math.max(min, Math.min(max, v)); }

// Seeded deterministic "random" — avoids pure random so values look smooth
function smoothNoise(seed: number, amplitude: number) {
  const x = Math.sin(seed * 127.1 + 311.7) * 43758.5453;
  return (x - Math.floor(x) - 0.5) * 2 * amplitude;
}

// Diurnal curve 0..1: peak at hour 13 Manila, trough at hour 5
function diurnal(manilaHour: number) {
  const rad = ((manilaHour - 5) / 24) * 2 * Math.PI;
  return (Math.sin(rad) + 1) / 2;
}

// Build 96 readings for one Manila calendar day (every 15 min), given a baseline
function buildDayReadings(
  sensorId: mongoose.Types.ObjectId,
  farmId: mongoose.Types.ObjectId,
  manilaDay: Date, // UTC midnight of the Manila calendar date
  baseline: { temp: number; hum: number; soil: number; light: number; ph: number },
  dayIndex: number // 0-based day offset used as noise seed
) {
  const MANILA_OFFSET_MS = 8 * 60 * 60 * 1000;
  // Manila midnight → UTC
  const utcStart = new Date(manilaDay.getTime() - MANILA_OFFSET_MS);
  const docs: object[] = [];

  for (let slot = 0; slot < 96; slot++) {
    const ts = new Date(utcStart.getTime() + slot * 15 * 60 * 1000);
    const manilaHour = ((ts.getUTCHours() + 8) % 24) + (ts.getUTCMinutes() / 60);
    const d = diurnal(manilaHour);
    const seed = dayIndex * 1000 + slot;

    // Temperature: base + diurnal swing ±4°C + small noise
    const temp = clamp(
      baseline.temp + (d - 0.5) * 8 + smoothNoise(seed, 0.5),
      22, 32
    );

    // Humidity: inversely correlated with temperature
    const hum = clamp(
      baseline.hum - (d - 0.5) * 12 + smoothNoise(seed + 1, 1.5),
      45, 85
    );

    // Soil moisture: slow daily decline (evaporation), shallow noise
    const soilDrift = -(slot / 96) * 2; // drops ~2% over the day
    const soil = clamp(
      baseline.soil + soilDrift + smoothNoise(seed + 2, 0.8),
      40, 75
    );

    // Light: bell curve during Manila 6 AM–6 PM, 0 at night
    const isDaytime = manilaHour >= 6 && manilaHour <= 18;
    let light = 0;
    if (isDaytime) {
      const noonFraction = 1 - Math.abs(manilaHour - 12) / 6;
      light = clamp(
        baseline.light * noonFraction + smoothNoise(seed + 3, baseline.light * 0.1),
        5, 1200
      );
    }

    // pH: very stable with tiny drift
    const ph = clamp(
      baseline.ph + smoothNoise(seed + 4, 0.05),
      6.0, 7.0
    );

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
      metadata: {
        source: 'simulation',
        quality: 'good',
        processed: true,
        anomaly: false,
        calibrated: true,
      },
    });
  }
  return docs;
}

async function seed() {
  await mongoose.connect(MONGO_URI);
  console.log('Connected to DB');
  const db = mongoose.connection.db!;

  const sensors = await db.collection('sensors').find({}).toArray();
  console.log(`Found ${sensors.length} sensor(s)`);

  // Days to seed: Oct 1 (Wed) through Oct 5 (Sun) Manila — replacing old simulation data
  // Manila date objects (midnight UTC of that Manila calendar date)
  const targetDays = [
    new Date('2025-10-01T00:00:00.000Z'), // Manila Oct 1
    new Date('2025-10-02T00:00:00.000Z'),
    new Date('2025-10-03T00:00:00.000Z'),
    new Date('2025-10-04T00:00:00.000Z'),
    new Date('2025-10-05T00:00:00.000Z'), // Manila Oct 5 (Sun)
  ];

  for (const sensor of sensors) {
    const farmId = sensor.farm;
    if (!farmId) continue;

    console.log(`\nSensor: ${sensor._id} (${sensor.name}) — farm ${farmId}`);

    // --- Get baseline from last available readings before Oct 1 (Manila) ---
    // Manila Oct 1 starts at UTC Sep 30 16:00
    const beforeOct1 = new Date('2025-09-30T16:00:00.000Z');
    const baselineAgg = await db.collection('sensor_readings').aggregate([
      {
        $match: {
          sensor: sensor._id,
          timestamp: {
            $gte: new Date('2025-09-23T16:00:00.000Z'), // Manila Sept 24
            $lt: beforeOct1,
          },
        },
      },
      {
        $group: {
          _id: null,
          temp: { $avg: '$data.temperature' },
          hum:  { $avg: '$data.humidity' },
          soil: { $avg: '$data.soilMoisture' },
          light: { $avg: '$data.lightIntensity' },
          ph:   { $avg: '$data.pH' },
          cnt:  { $sum: 1 },
        },
      },
    ]).toArray();

    let baseline: { temp: number; hum: number; soil: number; light: number; ph: number };

    if (baselineAgg.length > 0 && baselineAgg[0].cnt > 0) {
      const b = baselineAgg[0];
      baseline = {
        temp:  b.temp  ?? 27,
        hum:   b.hum   ?? 65,
        soil:  b.soil  ?? 58,
        light: b.light ?? 500,
        ph:    b.ph    ?? 6.4,
      };
      console.log(`  Baseline from ${b.cnt} readings: temp=${baseline.temp.toFixed(1)} hum=${baseline.hum.toFixed(1)} soil=${baseline.soil.toFixed(1)} light=${baseline.light.toFixed(0)} ph=${baseline.ph.toFixed(2)}`);
    } else {
      // No prior data — use corn-optimal defaults for Philippines October
      baseline = { temp: 27, hum: 68, soil: 58, light: 520, ph: 6.4 };
      console.log('  No prior data found — using corn-optimal defaults');
    }

    for (let i = 0; i < targetDays.length; i++) {
      const manilaDay = targetDays[i];
      const dayLabel = manilaDay.toISOString().split('T')[0];
      // UTC window for this Manila day
      const MANILA_OFFSET_MS = 8 * 60 * 60 * 1000;
      const utcStart = new Date(manilaDay.getTime() - MANILA_OFFSET_MS);
      const utcEnd   = new Date(utcStart.getTime() + 24 * 60 * 60 * 1000 - 1);

      // Count existing readings
      const existingCount = await db.collection('sensor_readings').countDocuments({
        sensor: sensor._id,
        timestamp: { $gte: utcStart, $lte: utcEnd },
      });

      // Delete simulation readings for this day (keep real ThingSpeak data)
      const deleted = await db.collection('sensor_readings').deleteMany({
        sensor: sensor._id,
        timestamp: { $gte: utcStart, $lte: utcEnd },
        'metadata.source': 'simulation',
      });

      const realCount = existingCount - deleted.deletedCount;

      if (realCount >= 50) {
        // Enough real data — skip seeding this day
        console.log(`  ${dayLabel}: ${realCount} real readings — keeping as-is`);

        // Update baseline from this day's real data before moving to next day
        const dayAgg = await db.collection('sensor_readings').aggregate([
          { $match: { sensor: sensor._id, timestamp: { $gte: utcStart, $lte: utcEnd } } },
          { $group: { _id: null, temp: { $avg: '$data.temperature' }, hum: { $avg: '$data.humidity' }, soil: { $avg: '$data.soilMoisture' }, light: { $avg: '$data.lightIntensity' }, ph: { $avg: '$data.pH' } } },
        ]).toArray();
        if (dayAgg.length > 0) {
          baseline = {
            temp:  dayAgg[0].temp  ?? baseline.temp,
            hum:   dayAgg[0].hum   ?? baseline.hum,
            soil:  dayAgg[0].soil  ?? baseline.soil,
            light: dayAgg[0].light ?? baseline.light,
            ph:    dayAgg[0].ph    ?? baseline.ph,
          };
        }
        continue;
      }

      // Build and insert 96 realistic readings
      const docs = buildDayReadings(sensor._id, farmId, manilaDay, baseline, i);
      await db.collection('sensor_readings').insertMany(docs);
      console.log(`  ${dayLabel}: inserted ${docs.length} readings (had ${realCount} real, removed ${deleted.deletedCount} old sim)`);

      // Roll baseline forward using today's average so each day continues from the last
      const todayAvg = docs.reduce(
        (acc: { temp: number; hum: number; soil: number; light: number; ph: number; cnt: number }, d: any) => ({
          temp:  acc.temp  + d.data.temperature,
          hum:   acc.hum   + d.data.humidity,
          soil:  acc.soil  + d.data.soilMoisture,
          light: acc.light + d.data.lightIntensity,
          ph:    acc.ph    + d.data.pH,
          cnt:   acc.cnt   + 1,
        }),
        { temp: 0, hum: 0, soil: 0, light: 0, ph: 0, cnt: 0 }
      );
      baseline = {
        temp:  todayAvg.temp  / todayAvg.cnt,
        hum:   todayAvg.hum   / todayAvg.cnt,
        soil:  todayAvg.soil  / todayAvg.cnt,
        light: todayAvg.light / todayAvg.cnt,
        ph:    todayAvg.ph    / todayAvg.cnt,
      };
    }
  }

  console.log('\nDone.');
  await mongoose.disconnect();
}

seed().catch(err => { console.error(err); process.exit(1); });

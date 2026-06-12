import mongoose from 'mongoose';

const MONGO_URI = 'mongodb+srv://larksigmuondbabao:aKO5hHmP0ZZYQPfp@maizewatch-db.snrxrjs.mongodb.net/maizewatch?retryWrites=true&w=majority&appName=maizewatch-db';

// Realistic ranges for corn crop readings
function rand(min: number, max: number, decimals = 2) {
  return parseFloat((Math.random() * (max - min) + min).toFixed(decimals));
}

async function seed() {
  await mongoose.connect(MONGO_URI);
  console.log('Connected to DB');
  const db = mongoose.connection.db!;

  // Find all sensors and their associated farms
  const sensors = await db.collection('sensors').find({}).toArray();
  const farms = await db.collection('farms').find({}).toArray();

  if (sensors.length === 0) {
    console.log('No sensors found. Exiting.');
    process.exit(1);
  }

  console.log(`Found ${sensors.length} sensor(s), ${farms.length} farm(s)`);
  sensors.forEach(s => console.log(`  Sensor: ${s._id} | farm: ${s.farm} | name: ${s.name}`));

  // Seed Oct 1–4, 2025 (Wed–Sat) — stored in UTC, Philippines is UTC+8
  // So "Oct 1 Manila" = readings from Sep 30 16:00 UTC to Oct 1 15:59 UTC
  const missingDays: { label: string; manilaDate: string; startUtc: Date; endUtc: Date }[] = [
    {
      label: 'Oct 1 (Wed)',
      manilaDate: '2025-10-01',
      startUtc: new Date('2025-09-30T16:00:00.000Z'),
      endUtc: new Date('2025-10-01T15:59:59.999Z'),
    },
    {
      label: 'Oct 2 (Thu)',
      manilaDate: '2025-10-02',
      startUtc: new Date('2025-10-01T16:00:00.000Z'),
      endUtc: new Date('2025-10-02T15:59:59.999Z'),
    },
    {
      label: 'Oct 3 (Fri)',
      manilaDate: '2025-10-03',
      startUtc: new Date('2025-10-02T16:00:00.000Z'),
      endUtc: new Date('2025-10-03T15:59:59.999Z'),
    },
    {
      label: 'Oct 4 (Sat)',
      manilaDate: '2025-10-04',
      startUtc: new Date('2025-10-03T16:00:00.000Z'),
      endUtc: new Date('2025-10-04T15:59:59.999Z'),
    },
  ];

  const READINGS_PER_DAY = 24; // one per hour

  for (const sensor of sensors) {
    const farmId = sensor.farm;
    if (!farmId) {
      console.log(`  Skipping sensor ${sensor._id} — no farm attached`);
      continue;
    }

    for (const day of missingDays) {
      // Check if data already exists for this sensor+day
      const existing = await db.collection('sensor_readings').countDocuments({
        sensor: sensor._id,
        timestamp: { $gte: day.startUtc, $lte: day.endUtc },
      });
      if (existing > 0) {
        console.log(`  ${day.label}: ${existing} readings already exist for sensor ${sensor._id}, skipping`);
        continue;
      }

      const docs: object[] = [];
      const daySpan = day.endUtc.getTime() - day.startUtc.getTime();

      for (let i = 0; i < READINGS_PER_DAY; i++) {
        // Spread readings evenly through the day
        const fraction = i / READINGS_PER_DAY;
        const ts = new Date(day.startUtc.getTime() + daySpan * fraction);

        // Corn-typical values with realistic variation
        const hourOfDay = (ts.getUTCHours() + 8) % 24; // Manila hour
        const isDaytime = hourOfDay >= 6 && hourOfDay <= 18;

        docs.push({
          sensor: sensor._id,
          farm: farmId,
          timestamp: ts,
          data: {
            temperature: rand(isDaytime ? 25 : 22, isDaytime ? 30 : 26),
            humidity: rand(55, 75),
            soilMoisture: rand(50, 68),
            lightIntensity: isDaytime ? rand(400, 800) : rand(0, 10),
            pH: rand(6.2, 6.9),
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

      await db.collection('sensor_readings').insertMany(docs);
      console.log(`  ${day.label}: inserted ${docs.length} readings for sensor ${sensor._id}`);
    }
  }

  console.log('Done seeding.');
  await mongoose.disconnect();
}

seed().catch(err => {
  console.error(err);
  process.exit(1);
});

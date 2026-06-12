import mongoose from 'mongoose';

async function listProtos() {
  await mongoose.connect('mongodb+srv://larksigmuondbabao:aKO5hHmP0ZZYQPfp@maizewatch-db.snrxrjs.mongodb.net/maizewatch?retryWrites=true&w=majority&appName=maizewatch-db');
  const db = mongoose.connection.db;
  
  const protos = await db!.collection('prototypes').find({}).limit(2).toArray();
  console.log("Prototypes:");
  protos.forEach(p => console.log(Object.keys(p), p.prototype_id, p.status));
  
  const sensors = await db!.collection('sensors').find({}).limit(3).toArray();
  console.log("\nSensors:");
  sensors.forEach(s => console.log(Object.keys(s), s.sensor_id, s.prototype_id));
  
  await mongoose.disconnect();
}
listProtos().catch(console.error);

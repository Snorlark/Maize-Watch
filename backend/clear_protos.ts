import mongoose from 'mongoose';

async function clearProtos() {
  await mongoose.connect('mongodb+srv://larksigmuondbabao:aKO5hHmP0ZZYQPfp@maizewatch-db.snrxrjs.mongodb.net/maizewatch?retryWrites=true&w=majority&appName=maizewatch-db');
  const db = mongoose.connection.db;
  
  await db!.collection('prototypes').updateMany(
    {},
    { $set: { isRegistered: false }, $unset: { registeredBy: "", registeredAt: "", farmId: "", farm: "" } }
  );
  
  const protos = await db!.collection('prototypes').find({}).toArray();
  console.log("All prototypes are now unregistered and ready to use!");
  protos.forEach(p => console.log("- Prototype ID:", p.prototype_id));
  
  await mongoose.disconnect();
}
clearProtos().catch(console.error);

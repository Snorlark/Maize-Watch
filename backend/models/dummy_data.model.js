// models/dummy_data.model.js
import mongoose from 'mongoose';
import dummyDataConnection from '../config/mongoDummyData.js'; // <-- use second connection

const dummyDataSchema = new mongoose.Schema({
  timestamp: { type: Date, required: true },
  field_id: { type: String, required: true },
  measurements: { type: Object, required: true },
});

const DummyData = dummyDataConnection.model('SensorData', dummyDataSchema, 'sensor_data');

export default DummyData;

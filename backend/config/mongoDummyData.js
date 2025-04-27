// config/mongoDummyData.js
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

// Create connection
const dummyDataConnection = mongoose.createConnection(
  process.env.MONGODB_DUMMY_URI
);

// NEW: Wait until connected before exporting
await dummyDataConnection.asPromise();

console.log('Connected to Dummy Data MongoDB');

export default dummyDataConnection;

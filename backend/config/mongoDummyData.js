// config/mongoDummyData.js
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

// Check if the URI is defined
const mongoURI = process.env.MONGODB_DUMMY_URI;

if (!mongoURI) {
  throw new Error('MONGODB_DUMMY_URI is not defined in the environment variables.');
}

// Create connection
const dummyDataConnection = mongoose.createConnection(mongoURI);

// Wait until connected before exporting
await dummyDataConnection.asPromise();

console.log('Connected to Dummy Data MongoDB');

export default dummyDataConnection;

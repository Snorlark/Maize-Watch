import mongoose from 'mongoose';
import dotenv from 'dotenv';

dotenv.config();

const mongooseOptions = {
  serverSelectionTimeoutMS: 30000,
  connectTimeoutMS: 30000,
  socketTimeoutMS: 45000,
  maxPoolSize: 50,
  retryWrites: true,
  retryReads: true,
  w: 'majority'
};

// Main database connection
const mainDbConnection = mongoose.createConnection(process.env.MONGODB_URI, mongooseOptions);

// IoT database connection
const iotDbConnection = mongoose.createConnection(process.env.MONGODB_IOT_URI, mongooseOptions);

// Connection event handlers for main database
mainDbConnection.on('connected', () => {
  console.log('Connected to main MongoDB database');
});

mainDbConnection.on('error', (err) => {
  console.error('Main MongoDB connection error:', err);
});

mainDbConnection.on('disconnected', () => {
  console.log('Disconnected from main MongoDB database');
});

// Connection event handlers for IoT database
iotDbConnection.on('connected', () => {
  console.log('Connected to IoT MongoDB database');
});

iotDbConnection.on('error', (err) => {
  console.error('IoT MongoDB connection error:', err);
});

iotDbConnection.on('disconnected', () => {
  console.log('Disconnected from IoT MongoDB database');
});

// Graceful shutdown handler
process.on('SIGINT', async () => {
  try {
    await mainDbConnection.close();
    console.log('Main MongoDB connection closed through app termination');
    await iotDbConnection.close();
    console.log('IoT MongoDB connection closed through app termination');
    process.exit(0);
  } catch (err) {
    console.error('Error during database disconnection:', err);
    process.exit(1);
  }
});

// Function to ensure proper collection names when creating models
function createModel(connection, modelName, schema, collectionName) {
  return connection.model(modelName, schema, collectionName);
}

// Function to check database connections
async function checkConnections() {
  try {
    await Promise.all([
      mainDbConnection.asPromise(),
      iotDbConnection.asPromise()
    ]);
    console.log('All database connections established successfully');
    return true;
  } catch (err) {
    console.error('Error establishing database connections:', err);
    return false;
  }
}

export { mainDbConnection, iotDbConnection, createModel, checkConnections };
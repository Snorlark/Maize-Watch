import { MongoMemoryServer } from 'mongodb-memory-server';
import mongoose from 'mongoose';
import { config } from 'dotenv';

// Load test environment variables
config({ path: '.env.test' });

let mongod: MongoMemoryServer;

beforeAll(async () => {
  // Start in-memory MongoDB instance
  mongod = await MongoMemoryServer.create();
  const uri = mongod.getUri();
  
  // Connect to the in-memory database
  await mongoose.connect(uri);
});

afterAll(async () => {
  // Cleanup and close connections
  await mongoose.connection.dropDatabase();
  await mongoose.connection.close();
  await mongod.stop();
});

afterEach(async () => {
  // Clean up data after each test
  const collections = mongoose.connection.collections;
  for (const key in collections) {
    const collection = collections[key];
    await collection.deleteMany({});
  }
});

// Global test timeout
jest.setTimeout(30000);

// Mock console methods in test environment
global.console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
};

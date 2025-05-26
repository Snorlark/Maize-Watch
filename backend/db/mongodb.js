import { MongoClient } from 'mongodb';
import dotenv from 'dotenv';

dotenv.config();

const MONGODB_URI = process.env.MONGODB_URI;

export async function connectToDatabase() {
  try {
    const client = await MongoClient.connect(MONGODB_URI);
    const db = client.db('maizewatch');
    console.log('Connected to MongoDB successfully using native driver');
    return { client, db };
  } catch (error) {
    console.error('Error connecting to MongoDB:', error);
    throw error;
  }
} 
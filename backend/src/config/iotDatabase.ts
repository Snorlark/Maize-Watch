import mongoose from 'mongoose';
import { logger } from '../utils/logger';

let iotConnection: mongoose.Connection | null = null;

export const getIotConnection = async (): Promise<mongoose.Connection | null> => {
  try {
    if (iotConnection) return iotConnection;
    const uri = process.env.MONGO_IOT_URI;
    if (!uri) return null;

    const conn = await mongoose.createConnection(uri, {
      maxPoolSize: 5,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
      retryWrites: true,
      writeConcern: { w: 'majority' },
    }).asPromise();

    conn.on('connected', () => logger.info('MongoDB IOT connected successfully'));
    conn.on('error', (err) => logger.error('MongoDB IOT connection error:', err));
    conn.on('disconnected', () => logger.warn('MongoDB IOT disconnected'));

    iotConnection = conn;
    return iotConnection;
  } catch (error) {
    logger.error('Failed to connect to IOT MongoDB:', error);
    return null;
  }
};

export default getIotConnection;



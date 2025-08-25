import mongoose from "mongoose";
import { logger } from "../utils/logger";

interface DatabaseConfig {
  uri: string;
  options: mongoose.ConnectOptions;
}

const getDatabaseConfig = (): DatabaseConfig => {
  const uri = process.env.MONGO_URI;
  if (!uri) {
    throw new Error("MONGO_URI environment variable is required");
  }

  return {
    uri,
    options: {
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
      bufferCommands: false,
      retryWrites: true,
      writeConcern: { w: 'majority' },
    }
  };
};

const connectDB = async (): Promise<void> => {
  try {
    const config = getDatabaseConfig();
    
    // Connection event listeners
    mongoose.connection.on('connected', () => {
      logger.info('MongoDB connected successfully');
    });

    mongoose.connection.on('error', (err: Error) => {
      logger.error('MongoDB connection error:', err);
    });

    mongoose.connection.on('disconnected', () => {
      logger.warn('MongoDB disconnected');
    });

    // Handle application termination
    process.on('SIGINT', async () => {
      await mongoose.connection.close();
      logger.info('MongoDB connection closed due to application termination');
      process.exit(0);
    });

    const conn = await mongoose.connect(config.uri, config.options);
    logger.info(`MongoDB Connected: ${conn.connection.host}:${conn.connection.port}`);
    logger.info(`Database: ${conn.connection.name}`);
  } catch (error) {
    logger.error("Database connection error:", error);
    process.exit(1);
  }
};

export const mongoDisconnect = async (): Promise<void> => {
  try {
    await mongoose.disconnect();
    logger.info("MongoDB Disconnected");
  } catch (error) {
    logger.error("Error disconnecting from MongoDB:", error);
  }
};

export const mongoState = (): number => {
  return mongoose.connection.readyState;
};

export const getConnectionStatus = (): string => {
  const states = ['disconnected', 'connected', 'connecting', 'disconnecting'];
  return states[mongoose.connection.readyState] || 'unknown';
};

export default connectDB;

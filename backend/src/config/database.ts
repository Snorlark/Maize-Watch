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
      serverSelectionTimeoutMS: 10000, // Increased from 5000
      socketTimeoutMS: 60000, // Increased from 45000
      connectTimeoutMS: 10000, // Added explicit connect timeout
      bufferCommands: false,
      retryWrites: true,
      writeConcern: { w: 'majority' },
      // Add retry logic for connection issues
      maxIdleTimeMS: 30000,
      heartbeatFrequencyMS: 10000,
    }
  };
};

const connectDB = async (): Promise<void> => {
  let retryCount = 0;
  const maxRetries = 3;
  
  const attemptConnection = async (): Promise<void> => {
    try {
      const config = getDatabaseConfig();
      
      // Connection event listeners
      mongoose.connection.on('connected', () => {
        logger.info('MongoDB connected successfully');
        retryCount = 0; // Reset retry count on successful connection
      });

      mongoose.connection.on('error', (err: Error) => {
        logger.error('MongoDB connection error:', err);
      });

      mongoose.connection.on('disconnected', () => {
        logger.warn('MongoDB disconnected');
        // Attempt to reconnect after disconnection
        if (retryCount < maxRetries) {
          setTimeout(() => {
            retryCount++;
            logger.info(`Attempting to reconnect to MongoDB (attempt ${retryCount}/${maxRetries})`);
            attemptConnection();
          }, 5000);
        }
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
      
      if (retryCount < maxRetries) {
        retryCount++;
        logger.info(`Retrying database connection (attempt ${retryCount}/${maxRetries}) in 5 seconds...`);
        setTimeout(() => attemptConnection(), 5000);
      } else {
        logger.error('Max database connection retries reached. Exiting...');
        process.exit(1);
      }
    }
  };
  
  await attemptConnection();
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

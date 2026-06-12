import { Server as SocketIOServer } from 'socket.io';
import { Server as HTTPServer } from 'http';
import { createAdapter } from '@socket.io/redis-adapter';
import jwt from 'jsonwebtoken';
import mongoose from 'mongoose';
import User, { IUser } from '../models/User';
import Farm from '../models/Farm';
import { logger } from '../utils/logger';
import { redis } from '../config/redis';
import sensorHandler from './sensorHandler';
import farmHandler from './farmHandler';
import alertHandler from './alertHandler';
import { Socket } from 'socket.io';

interface AuthenticatedSocket extends Socket {
  userId?: string;
  user?: IUser;
}

export const initializeSocket = (server: HTTPServer) => {
  const io = new SocketIOServer(server, {
    cors: {
      origin: process.env.FRONTEND_URL || "http://localhost:3000",
      methods: ["GET", "POST"],
      credentials: true
    },
    transports: ['websocket', 'polling']
  });

  // Setup Redis adapter for scaling across multiple instances
  if (redis) {
    try {
      const pubClient = redis.duplicate();
      const subClient = redis.duplicate();
      io.adapter(createAdapter(pubClient, subClient));
      logger.info('Socket.IO Redis adapter configured successfully');
    } catch (error) {
      logger.warn('Failed to configure Redis adapter for Socket.IO:', error);
      logger.info('Socket.IO will run in single-instance mode');
    }
  } else {
    logger.info('Redis not available - Socket.IO running in single-instance mode');
  }

  // Authentication middleware for socket connections
  io.use(async (socket: AuthenticatedSocket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.headers.authorization?.replace('Bearer ', '');
      
      if (!token) {
        return next(new Error('Authentication token required'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET!) as { id: string };
      const user = await User.findById(decoded.id).select('-password -refreshTokens');
      
      if (!user || !user.isActive) {
        return next(new Error('Invalid or inactive user'));
      }

      socket.userId = (user._id as mongoose.Types.ObjectId).toString();
      socket.user = user;
      next();
    } catch (error) {
      logger.error('Socket authentication error:', error);
      next(new Error('Authentication failed'));
    }
  });

  // Connection handling
  io.on('connection', async (socket: AuthenticatedSocket) => {
    logger.info('User connected via socket', {
      userId: socket.userId,
      socketId: socket.id,
      username: socket.user?.username
    });

    // Join user to their personal room
    socket.join(`user:${socket.userId}`);

    // Join user to their farms' rooms
    try {
      const userFarms = await Farm.find({ owner: socket.userId, isActive: true }).select('_id');
      userFarms.forEach((farm) => {
        socket.join(`farm:${farm._id}`);
      });
    } catch (error) {
      logger.error('Error joining farm rooms:', error);
    }

    // Register event handlers
    sensorHandler(io, socket);
    farmHandler(io, socket);
    alertHandler(io, socket);

    // Handle disconnection
    socket.on('disconnect', (reason) => {
      logger.info('User disconnected from socket', {
        userId: socket.userId,
        socketId: socket.id,
        reason
      });
    });

    // Handle errors
    socket.on('error', (error) => {
      logger.error('Socket error:', {
        userId: socket.userId,
        socketId: socket.id,
        error: error.message
      });
    });

    // Send welcome message
    socket.emit('connected', {
      message: 'Connected to Maize-Watch real-time service',
      userId: socket.userId,
      timestamp: new Date().toISOString()
    });
  });

  // Global error handling
  io.engine.on('connection_error', (err) => {
    logger.error('Socket connection error:', {
      code: err.code,
      message: err.message,
      context: err.context
    });
  });

  logger.info('Socket.IO server initialized');
  return io;
};

// Export function to get the IO instance
let ioInstance: SocketIOServer | null = null;

export const setIO = (io: SocketIOServer) => {
  ioInstance = io;
};

export const getIO = (): SocketIOServer | null => {
  return ioInstance;
};

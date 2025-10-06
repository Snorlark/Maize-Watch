import dotenv from 'dotenv';

dotenv.config({ path: '.env' });
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { createServer } from 'http';
import cron from 'node-cron';

// Import configurations and utilities
import connectDB, { getConnectionStatus } from './config/database';
import { logger } from './utils/logger';
import { initializeSocket } from './sockets/index';
import syncService from './services/syncService';

// Import middleware
import globalErrorHandler, { notFound, catchAsync } from './middleware/errorHandler';
import { requestLogger } from './middleware/logging';
import { generalLimiter } from './middleware/rateLimiter';

// Import routes
import apiRoutes from './routes/index';

const app = express();
const server = createServer(app);

// Initialize Socket.IO
const io = initializeSocket(server);
import { setIO } from './sockets/index';
setIO(io);

// Handle unhandled promise rejections (like Redis connection errors)
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  // Don't exit the process, just log the error
});

// Handle uncaught exceptions (but don't exit for Redis errors)
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  // Only exit for critical errors, not Redis connection issues
  if (error.message && error.message.includes('Redis')) {
    logger.warn('Redis error caught, continuing without Redis...');
    return;
  }
  // For other critical errors, exit
  process.exit(1);
});

// Trust proxy for real client IPs when behind reverse proxies
app.set('trust proxy', 1);

// Security middleware
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  contentSecurityPolicy: process.env.NODE_ENV === 'development' ? {
    useDefaults: true,
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: [
        "'self'",
        process.env.FRONTEND_URL || "http://localhost:8080",
        "ws:",
        "wss:"
      ]
    }
  } : false
}));

// CORS configuration
app.use(cors({
  origin: process.env.FRONTEND_URL || "http://localhost:3000",
  credentials: true
}));

// Compression middleware
app.use(compression());

// Rate limiting
app.use(generalLimiter);

// Request logging - temporarily disabled for debugging
app.use(requestLogger);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ==========================================
// HEALTH CHECK ENDPOINT (REQUIRED!)
// ==========================================
app.get('/health', (req, res) => {
  // Check if server is responding
  const healthcheck = {
    uptime: process.uptime(),
    message: 'Backend is healthy',
    timestamp: Date.now(),
    service: 'backend-api',
    environment: process.env.NODE_ENV || 'development',
    database: getConnectionStatus(),
    memory: {
      rss: `${Math.round(process.memoryUsage().rss / 1024 / 1024)}MB`,
      heapUsed: `${Math.round(process.memoryUsage().heapUsed / 1024 / 1024)}MB`,
      heapTotal: `${Math.round(process.memoryUsage().heapTotal / 1024 / 1024)}MB`
    }
  };
  
  try {
    // You can add more checks here:
    // - Database connection
    // - Redis connection
    // - External API availability
    
    res.status(200).json(healthcheck);
  } catch (error) {
    healthcheck.message = error instanceof Error ? error.message : 'Unknown error';
    (healthcheck as any).error = true;
    res.status(503).json(healthcheck);
  }
});

// API routes
app.use('/api', apiRoutes);

// Error handling middleware (must be last)
app.use(notFound);
app.use(globalErrorHandler);

// ==========================================
// PORT CONFIGURATION (UPDATED!)
// ==========================================
const PORT = process.env.PORT || 3001;

async function startServer() {
  try {
    // Connect to database
    await connectDB();
    logger.info('Database connected successfully');

    // Sync service is already initialized as singleton

    // Start server
    server.listen(Number(PORT), '0.0.0.0', () => {
      logger.info(`🟢 Backend API listening on port ${PORT}`);
      logger.info(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
      logger.info(`⚡ Ready to accept connections`);
      
      // Start automatic data sync from ThingSpeak
      startDataSync(syncService);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Start automatic data synchronization
function startDataSync(syncService: any) {
  logger.info('🔄 Starting automatic data synchronization...');
  
  // Sync every 15 seconds
  cron.schedule('*/15 * * * * *', async () => {
    try {
      logger.info('🔄 Running scheduled ThingSpeak data sync...');
      await syncService.syncAllFarmsData();
      logger.info('✅ Scheduled sync completed successfully');
    } catch (error) {
      logger.error('❌ Scheduled sync failed:', error);
    }
  });
  
  // Also run an immediate sync on startup (after 30 seconds delay)
  setTimeout(async () => {
    try {
      logger.info('🔄 Running initial ThingSpeak data sync...');
      await syncService.syncAllFarmsData();
      logger.info('✅ Initial sync completed successfully');
    } catch (error) {
      logger.error('❌ Initial sync failed:', error);
    }
  }, 30000); // 30 seconds delay
  
  logger.info('⏰ Data sync scheduled every 15 seconds');
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', async () => {
  logger.info('SIGINT received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

// Note: Error handlers are already defined above (lines 32-41)

// Start the server
startServer();

export { app, server };

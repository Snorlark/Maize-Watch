import dotenv from 'dotenv';

dotenv.config({ path: '.env' });
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { createServer } from 'http';

// Import configurations and utilities
import connectDB from './config/database';
import { logger } from './utils/logger';
import { initializeSocket } from './sockets/index';

// Import middleware
import globalErrorHandler, { notFound, catchAsync } from './middleware/errorHandler';
import { requestLogger } from './middleware/logging';
import { generalLimiter } from './middleware/rateLimiter';
import historicalDataRouter from './routes/historical_data.routes';

// Import routes
import apiRoutes from './routes/index';

const app = express();
const server = createServer(app);

// Initialize Socket.IO - temporarily disabled for debugging
// const io = initializeSocket(server);

// Trust proxy for real client IPs when behind reverse proxies
app.set('trust proxy', 1);

// Security middleware
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  contentSecurityPolicy: process.env.NODE_ENV === 'production' ? {
    useDefaults: true,
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: [
        "'self'",
        process.env.FRONTEND_URL || "http://localhost:3000",
        "ws:",
        "wss:"
      ]
    }
  } : false
}));

// CORS configuration
const allowedOrigins = [
  "http://localhost:3000", // React default
  "http://localhost:5173", // Vite default
  "https://maize-watch-rdcy.onrender.com", // Production frontend
  process.env.FRONTEND_URL, // Environment variable for flexibility
].filter((origin): origin is string => Boolean(origin));

app.use(cors({
  origin: allowedOrigins,
  credentials: true
}));


// Compression middleware
app.use(compression());

// Rate limiting - temporarily disabled for debugging
// app.use(generalLimiter);

// Request logging - temporarily disabled for debugging
app.use(requestLogger);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Serve static files from frontend public directories
app.use('/web-public', express.static('frontend/web-src/web-public/public'));
app.use('/web-admin', express.static('frontend/web-src/web-admin/public'));

// API routes
app.use('/api', apiRoutes);

// Error handling middleware (must be last)
app.use(notFound);
app.use(globalErrorHandler);

// Server startup
const PORT = process.env.PORT || 8080;

async function startServer() {
  try {
    // Connect to database
    await connectDB();
    logger.info('Database connected successfully');

    // Start server
    server.listen(PORT, () => {
      logger.info(`Server running on port ${PORT}`);
      logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
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

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

// Start the server
startServer();

export { app, server };

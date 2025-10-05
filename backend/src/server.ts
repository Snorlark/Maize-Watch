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
// Helmet base protections (Express 4, ESM, TypeScript)
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  // Content Security Policy
  contentSecurityPolicy: {
    useDefaults: true,
    directives: {
      defaultSrc: ["'self'"],
      baseUri: ["'self'"],
      objectSrc: ["'none'"],
      formAction: ["'self'"],
      scriptSrc: ["'self'", "https://apis.google.com"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: [
        "'self'",
        process.env.FRONTEND_URL || "http://localhost:3000",
        "ws:",
        "wss:",
        "https:"
      ],
      frameAncestors: ["'self'"],
      upgradeInsecureRequests: process.env.NODE_ENV === 'production' ? [] : null
    }
  },
  // X-Frame-Options
  frameguard: { action: 'sameorigin' },
  // Referrer-Policy
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  // X-Content-Type-Options is enabled by default in helmet
}));

// Permissions-Policy (formerly Feature-Policy) - set explicitly
app.use((req, res, next) => {
  res.setHeader(
    'Permissions-Policy',
    [
      'accelerometer=()',
      'autoplay=(self)',
      'camera=()',
      'clipboard-read=(self)',
      'clipboard-write=(self)',
      'display-capture=()',
      'document-domain=()',
      'encrypted-media=()',
      'fullscreen=(self)',
      'geolocation=()',
      'gyroscope=()',
      'magnetometer=()',
      'microphone=()',
      'payment=()',
      'picture-in-picture=(self)',
      'publickey-credentials-get=(self)',
      'usb=()',
      'xr-spatial-tracking=()'
    ].join(', ')
  );
  next();
});

// Ensure critical security headers are always present (defensive in addition to Helmet)
app.use((req, res, next) => {
  if (!res.getHeader('X-Frame-Options')) {
    res.setHeader('X-Frame-Options', 'SAMEORIGIN');
  }
  if (!res.getHeader('X-Content-Type-Options')) {
    res.setHeader('X-Content-Type-Options', 'nosniff');
  }
  next();
});

// Strict-Transport-Security (HSTS) - only when HTTPS is detected (behind proxy supported)
app.use((req, res, next) => {
  const isHttps = req.secure || req.get('x-forwarded-proto') === 'https';
  if (isHttps) {
    return helmet.hsts({ maxAge: 15552000, includeSubDomains: true, preload: false })(req, res, next);
  }
  return next();
});

// CORS configuration
const allowedOrigins = [
  "http://localhost:3000", // React default
  "http://localhost:5173", // Vite default
  "https://maize-watch-rdcy.onrender.com",
  "https://www.maize-watch.com",
  "https://maize-watch-web-backend.onrender.com", // Production frontend
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
// Paths are relative to backend/ directory in development
const isDevelopment = process.env.NODE_ENV !== 'production';
const frontendPath = isDevelopment ? '../frontend/web-src' : 'frontend/web-src';

app.use('/web-public', express.static(`${frontendPath}/web-public/public`));
app.use('/web-admin', express.static(`${frontendPath}/web-admin/public`));

// Serve built web-admin dist files (for production)
if (!isDevelopment) {
  app.use('/web-admin', express.static(`${frontendPath}/web-admin/dist`));
}

// Serve web-admin images and assets directly under /images path for easier access
app.use('/images', express.static(`${frontendPath}/web-admin/public/images`));
app.use('/footer', express.static(`${frontendPath}/web-admin/public/footer`));

// Debug endpoint to check static file serving
app.get('/debug/images', (req, res) => {
  const path = require('path');
  const fs = require('fs');
  
  const imagePath = path.join(__dirname, isDevelopment ? '../../frontend/web-src/web-admin/public/images' : '../frontend/web-src/web-admin/public/images');
  
  try {
    const files = fs.readdirSync(imagePath);
    res.json({
      success: true,
      isDevelopment,
      frontendPath,
      imagePath,
      imageCount: files.length,
      images: files.slice(0, 10), // First 10 images
      testUrls: [
        `${req.protocol}://${req.get('host')}/images/logo.png`,
        `${req.protocol}://${req.get('host')}/images/background.png`
      ]
    });
  } catch (error: any) {
    res.json({
      success: false,
      error: error.message,
      isDevelopment,
      frontendPath,
      imagePath
    });
  }
});

// Root route
app.get('/', (req, res) => {
  res.status(200).send('✅ Secure Express App');
});

// Security headers test endpoint
app.get('/api/security-headers-test', (req, res) => {
  // Get all response headers that will be sent
  const headers = res.getHeaders();
  
  res.status(200).json({
    success: true,
    message: 'Security headers test endpoint',
    timestamp: new Date().toISOString(),
    protocol: req.protocol,
    isSecure: req.secure,
    forwardedProto: req.get('x-forwarded-proto'),
    headers: {
      'content-security-policy': res.getHeader('content-security-policy'),
      'x-frame-options': res.getHeader('x-frame-options'),
      'referrer-policy': res.getHeader('referrer-policy'),
      'permissions-policy': res.getHeader('permissions-policy'),
      'strict-transport-security': res.getHeader('strict-transport-security'),
      'x-content-type-options': res.getHeader('x-content-type-options'),
      'x-dns-prefetch-control': res.getHeader('x-dns-prefetch-control'),
      'x-download-options': res.getHeader('x-download-options'),
      'x-permitted-cross-domain-policies': res.getHeader('x-permitted-cross-domain-policies')
    },
    allHeaders: headers
  });
});

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
      logger.info(`Environment: ${process.env.NODE_ENV || 'deployment'}`);
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

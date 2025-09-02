import express, { Express } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import rateLimit from 'express-rate-limit';

// Import middleware
import errorHandler from '../../middleware/errorHandler';

export const createTestApp = async (): Promise<Express> => {
  const app = express();

  // Security middleware
  app.use(helmet({
    contentSecurityPolicy: false, // Disable for testing
  }));

  // CORS
  app.use(cors({
    origin: process.env.FRONTEND_URL || 'http://localhost:3001',
    credentials: true,
  }));

  // Compression
  app.use(compression());

  // Rate limiting (more lenient for testing)
  const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 1000, // Higher limit for testing
    message: 'Too many requests from this IP',
    standardHeaders: true,
    legacyHeaders: false,
  });
  app.use(limiter);

  // Body parsing
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true }));

  // Health check
  app.get('/health', (req, res) => {
    res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
  });

  // Mock API endpoints for testing
  app.post('/api/auth/register', (req, res) => {
    res.status(201).json({ 
      user: { id: '123', email: req.body.email, username: req.body.username },
      token: 'mock-jwt-token'
    });
  });

  app.post('/api/auth/login', (req, res) => {
    if (req.body.email === 'test@example.com' && req.body.password === 'password123') {
      res.status(200).json({ 
        user: { id: '123', email: req.body.email },
        token: 'mock-jwt-token'
      });
    } else {
      res.status(401).json({ message: 'Invalid credentials' });
    }
  });

  app.get('/api/auth/profile', (req, res) => {
    const auth = req.headers.authorization;
    if (auth && auth.includes('mock-jwt-token')) {
      res.status(200).json({ id: '123', email: 'test@example.com' });
    } else {
      res.status(401).json({ message: 'Unauthorized' });
    }
  });

  // Error handling
  app.use(errorHandler);

  return app;
};

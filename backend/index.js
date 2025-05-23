// index.js
import { MongoClient, ObjectId } from 'mongodb';
import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import bcrypt from 'bcrypt';
import cron from 'node-cron';


import userRoutes from './routes/user.route.js';
import sensorDataRoutes from './routes/sensor_data.route.js';
import thingSpeakService from './services/thingspeak.service.js';
import { isAdmin, isAuthenticated } from './middleware/auth.middleware.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables from .env file
dotenv.config({ path: path.resolve(__dirname, '../.env') });

// Validate required environment variables
const requiredEnvVars = ['MONGODB_URI', 'MONGODB_IOT_URI', 'JWT_SECRET'];
const missingEnvVars = requiredEnvVars.filter(varName => !process.env[varName]);

if (missingEnvVars.length > 0) {
  console.error(`Missing required environment variables: ${missingEnvVars.join(', ')}`);
  process.exit(1);
}

const app = express();
const port = process.env.PORT || 8080;

// Store database connections
let mainDb; // Native MongoDB driver connection
let userDbConnection; // For user operations

const allowedOrigins = [
  'http://localhost:3000',
  'http://localhost:5173',
  'http://localhost:5174', // Vite's default port
  'https://maize-watch-dev.onrender.com', // Add your production domain
  'https://maize-watch.onrender.com'
];

// Debug middleware - log all requests
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url} from origin: ${req.headers.origin || 'no origin'}`);
  next();
});

// CORS configuration
// Development-friendly CORS options (more permissive)
const corsOptions = {
// CORS configuration
app.use(cors({
  origin: function(origin, callback) {
    // In development, we'll be more permissive with CORS
    // For production, you should restrict this properly
    callback(null, true);
    
    // Original strict checking - uncomment for production
    /*
    if (!origin) return callback(null, true);
    
    if (allowedOrigins.indexOf(origin) === -1) {
      console.warn(`Request from disallowed origin: ${origin}`);
      const msg = 'The CORS policy for this site does not allow access from the specified Origin.';
      return callback(new Error(msg), false);
    }
    return callback(null, true);
    */
  },
  credentials: true, // Allow cookies/authentication
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
};

// Apply CORS middleware
app.use(cors(corsOptions));

// Body parser middleware
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Connect to MongoDB
const connectToMongo = async () => {
  try {
    console.log('Connecting to MongoDB...');
    
    // Connect to MongoDB directly for native driver usage
    const client = new MongoClient(process.env.MONGODB_URI, {
      serverSelectionTimeoutMS: 15000, // Increase from default 10000
    });
    await client.connect();
    mainDb = client.db(); // Set the main database
    
    console.log('Connected to MongoDB successfully using native driver');

    // Also connect with Mongoose for model operations
    mongoose.set('strictQuery', false); // Recommended setting for Mongoose 7
    userDbConnection = await mongoose.connect(process.env.MONGODB_URI, {
      serverSelectionTimeoutMS: 15000,
    });
    console.log('Connected to MongoDB successfully using Mongoose');
    
    // Test the IOT database connection (used by ThingSpeak service)
    const iotConnection = mongoose.createConnection(process.env.MONGODB_IOT_URI, {
      serverSelectionTimeoutMS: 15000,
    });
    await iotConnection.asPromise();
    console.log('Connected to IOT MongoDB successfully');
    
    // Close this test connection as ThingSpeak service will create its own
    await iotConnection.close();
    
    return { client, mainDb };
  } catch (err) {
    console.error('MongoDB connection error:', err);
    throw err; // Let the caller handle the error
  }
};


// Helper function to project fields
const projectFields = (document, fields) => {
  if (!fields) return document;
  
  const fieldArray = fields.split(',');
  const projected = {};
  
  // Always include _id
  projected._id = document._id;
  
  fieldArray.forEach(field => {
    if (document[field] !== undefined) {
      projected[field] = document[field];
    }
  });
  
  return projected;
};

// Initialize MQTT service
let mqttService;
try {
  mqttService = new MqttService(process.env.MQTT_BROKER);
} catch (err) {
  console.error('MQTT service initialization error:', err);
}

// Routes
app.use('/auth', userRoutes);
app.use('/api/sensors', sensorDataRoutes);

// Test route
app.get('/', (req, res) => {
  res.send('Maize Watch API is running');
});

// Health check endpoint
app.get('/health', async (req, res) => {
  // Check MongoDB connections
  const isMongoConnected = mongoose.connection.readyState === 1;
  
  // Also check ThingSpeak connection as part of health check
  let thingSpeakStatus = 'not tested';
  try {
    await thingSpeakService.syncDataFromThingSpeak();
    thingSpeakStatus = 'connected';
  } catch (error) {
    console.error('ThingSpeak connection error during health check:', error);
    thingSpeakStatus = 'error: ' + error.message;
  }
  
  res.status(200).json({
    status: 'ok',
    message: 'Server is running',
    mongodb: isMongoConnected ? 'connected' : 'disconnected',
    thingspeak: thingSpeakStatus,
    timestamp: new Date().toISOString()
  });
});

// API Routes - Protected by admin middleware
// Get all users - admin only
app.get('/api/users', isAdmin, async (req, res) => {
  try {
    const { fields } = req.query;
    const users = await db.collection('users').find({}).toArray();
    
    // Apply field projection if requested
    if (fields) {
      const projectedUsers = users.map(user => projectFields(user, fields));
      return res.json(projectedUsers);
    }
    
    if (!mainDb) {
      return res.status(500).json({ error: 'Database connection not established' });
    }
    const users = await mainDb.collection('users').find({}).toArray();
    res.json(users);
  } catch (err) {
    console.error('Error getting users:', err);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// Create user - admin only
app.post('/api/users', isAdmin, async (req, res) => {
  try {
    // Clone the request body to avoid modifying the original
    const userData = {...req.body};
    
    // Hash password if provided
    if (userData.password) {
      const salt = await bcrypt.genSalt(10);
      userData.password = await bcrypt.hash(userData.password, salt);
    }

    const result = await db.collection('users').insertOne(userData);
    
    // Don't return the password in the response
    const { password, ...userWithoutPassword } = userData;
    
    res.status(201).json({ 
      ...userWithoutPassword, 
      _id: result.insertedId 
    });
    if (!mainDb) {
      return res.status(500).json({ error: 'Database connection not established' });
    }
    const result = await mainDb.collection('users').insertOne(req.body);
    res.status(201).json({ ...req.body, _id: result.insertedId });
  } catch (err) {
    console.error('Error creating user:', err);
    res.status(500).json({ error: 'Failed to create user' });
  }
});

// Get single user - admin only
app.get('/api/users/:id', isAdmin, async (req, res) => {
  try {

    const { fields } = req.query;
    const user = await db.collection('users').findOne({ _id: new ObjectId(req.params.id) });
    
    if (!mainDb) {
      return res.status(500).json({ error: 'Database connection not established' });
    }
    const user = await mainDb.collection('users').findOne({ _id: new ObjectId(req.params.id) });

    if (!user) return res.status(404).json({ error: 'User not found' });
    
    // Apply field projection if requested
    if (fields) {
      const projectedUser = projectFields(user, fields);
      return res.json(projectedUser);
    }
    
    res.json(user);
  } catch (err) {
    console.error('Error getting user:', err);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
});

// Update user - admin only
app.put('/api/users/:id', isAdmin, async (req, res) => {
  try {
    // Add updatedAt timestamp
    const updateData = {
      ...req.body,
      updatedAt: new Date().toISOString()
    };
    
    const result = await db.collection('users').updateOne(

    if (!mainDb) {
      return res.status(500).json({ error: 'Database connection not established' });
    }
    const result = await mainDb.collection('users').updateOne(

      { _id: new ObjectId(req.params.id) },
      { $set: updateData }
    );
    
    if (result.matchedCount === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    // Fetch and return the updated user
    const updatedUser = await db.collection('users').findOne({ _id: new ObjectId(req.params.id) });
    
    // Remove password from response for security
    const { password, ...userWithoutPassword } = updatedUser;
    
    res.json(userWithoutPassword);
  } catch (err) {
    console.error('Error updating user:', err);
    res.status(500).json({ error: 'Failed to update user' });
  }
});

// Add a route to get current user profile (for authenticated users)
app.get('/api/profile', isAuthenticated, async (req, res) => {
  try {
    const user = await db.collection('users').findOne({ _id: new ObjectId(req.user.id) });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    // Remove password from response
    const { password, ...userProfile } = user;
    res.json(userProfile);
  } catch (err) {
    console.error('Error getting user profile:', err);
    res.status(500).json({ error: 'Failed to fetch user profile' });
  }
});

// Update current user profile (for authenticated users)
app.put('/api/profile', isAuthenticated, async (req, res) => {
  try {
    // Prevent users from changing their role
    const { role, ...allowedUpdates } = req.body;
    
    const updateData = {
      ...allowedUpdates,
      updatedAt: new Date().toISOString()
    };
    
    const result = await db.collection('users').updateOne(
      { _id: new ObjectId(req.user.id) },
      { $set: updateData }
    );
    
    if (result.matchedCount === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    // Fetch and return the updated user profile
    const updatedUser = await db.collection('users').findOne({ _id: new ObjectId(req.user.id) });
    const { password, ...userProfile } = updatedUser;
    
    res.json(userProfile);
  } catch (err) {
    console.error('Error updating user profile:', err);
    res.status(500).json({ error: 'Failed to update user profile' });
  }
});

// Delete user - admin only
app.delete('/api/users/:id', isAdmin, async (req, res) => {
  try {
    if (!mainDb) {
      return res.status(500).json({ error: 'Database connection not established' });
    }
    const result = await mainDb.collection('users').deleteOne({ _id: new ObjectId(req.params.id) });
    if (result.deletedCount === 0) return res.status(404).json({ error: 'User not found' });
    res.json({ message: 'User deleted successfully' });
  } catch (err) {
    console.error('Error deleting user:', err);
    res.status(500).json({ error: 'Failed to delete user' });
  }
});

// Create an admin user programmatically (only for initial setup)
app.post('/setup/create-admin', async (req, res) => {
  // Check if admin already exists
  try {
    if (!mainDb) {
      return res.status(500).json({ error: 'Database connection not established' });
    }
    
    const adminExists = await mainDb.collection('users').findOne({ role: 'admin' });
    if (adminExists) {
      return res.status(400).json({ 
        message: 'Admin account already exists',
        info: 'For security reasons, you can only create one admin account'
      });
    }
    
    // Create admin with provided credentials or default ones
    const adminUser = {
      username: req.body.username || 'admin',
      password: req.body.password || 'adminPassword123', // You should hash this in production
      fullName: req.body.fullName || 'System Administrator',
      contactNumber: req.body.contactNumber || '1234567890',
      address: req.body.address || 'Admin Address',
      email: req.body.email || 'admin@example.com',
      role: 'admin', // This is fixed and cannot be changed
      createdAt: new Date().toISOString()
    };
    
    const result = await mainDb.collection('users').insertOne(adminUser);
    
    // For security, don't return the password
    const { password, ...adminWithoutPassword } = adminUser;
    
    res.status(201).json({
      message: 'Admin account created successfully',
      admin: { ...adminWithoutPassword, _id: result.insertedId }
    });
    
  } catch (err) {
    console.error('Error creating admin:', err);
    res.status(500).json({ error: 'Failed to create admin user' });
  }
});

// Schedule data sync with ThingSpeak every 5 minutes
cron.schedule('*/5 * * * *', async () => {
  console.log('Running scheduled ThingSpeak sync...');
  try {
    const savedCount = await thingSpeakService.syncDataFromThingSpeak();
    console.log(`Scheduled sync completed successfully: ${savedCount} records saved`);
  } catch (error) {
    console.error('Error in scheduled ThingSpeak sync:', error);
  }
});

// Error handling middleware - should be after all routes
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    message: 'Internal Server Error',
    error: process.env.NODE_ENV === 'production' ? null : err.message
  });
});

// Start server after connecting to MongoDB
const startServer = async () => {
  let client;
  try {
    const connections = await connectToMongo();
    client = connections.client;
    
    // Initial data sync on startup
    try {
      console.log('Performing initial ThingSpeak data synchronization...');
      const savedCount = await thingSpeakService.syncDataFromThingSpeak();
      console.log(`Initial ThingSpeak sync completed successfully: ${savedCount} records saved`);
    } catch (syncError) {
      console.error('Initial ThingSpeak sync failed:', syncError);
      // Continue starting server despite sync failure
    }
    
    const server = app.listen(port, '0.0.0.0', () => {
      console.log(`✅ Server running on port ${port}`);
      console.log(`Health check available at: http://localhost:${port}/health`);
    });
    
    // Handle application shutdown gracefully
    const gracefulShutdown = async (signal) => {
      console.log(`Received ${signal}. Shutting down gracefully...`);
      server.close(async () => {
        try {
          console.log('Closing database connections...');
          if (mongoose.connection) await mongoose.connection.close();
          if (client) await client.close();
          console.log('MongoDB connections closed.');
          process.exit(0);
        } catch (err) {
          console.error('Error during shutdown:', err);
          process.exit(1);
        }
      });
      
      // Force shutdown after 10 seconds
      setTimeout(() => {
        console.error('Could not close connections in time, forcefully shutting down');
        process.exit(1);
      }, 10000);
    };
    
    // Listen for termination signals
    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));
    
  } catch (err) {
    console.error('Failed to start server:', err);
    if (client) await client.close();
    process.exit(1);
  }
};

// Start the server
startServer();
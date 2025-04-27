import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import mongoose from 'mongoose';

import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

import userRoutes from './routes/user.route.js';
import dummyDataRoutes from './routes/dummy_data.route.js';
import MqttService from './services/mqtt.service.js';


const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables from .env file
dotenv.config({ path: path.resolve(__dirname, '../.env') });

const app = express();
const port = process.env.PORT || 8080;

// Connect to MongoDB using URI from environment
await mongoose.connect(process.env.MONGODB_URI)
.then(() => console.log('Connected to MongoDB successfully'))
.catch(err => console.error('MongoDB connection error:', err));

// Middleware
app.use(cors({
  origin: process.env.CLIENT_URL || '*',
}));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

app.use(express.json());

// Initialize MQTT service
const mqttService = new MqttService(process.env.MQTT_BROKER);

// Routes
app.use('/auth', userRoutes);
app.use('/api', dummyDataRoutes);

// Test route
app.get('/', (req, res) => {
    res.send('Maize Watch API is running');
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        message: 'Internal Server Error',
        error: process.env.NODE_ENV === 'production' ? null : err.message
    });
});

app.get('/health', (req, res) => {
    // Check MongoDB connection
    const isMongoConnected = mongoose.connection.readyState === 1;
    
    res.status(200).json({
      status: 'ok',
      message: 'Server is running',
      mongodb: isMongoConnected ? 'connected' : 'disconnected',
      timestamp: new Date().toISOString()
    });
  });

app.listen(port, '0.0.0.0', () => {
    console.log(`Server running on port ${port}`);
});

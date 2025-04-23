import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import mongoose from 'mongoose';
import userRoutes from './routes/user.route.js';

const app = express();
const port = process.env.PORT || 8080;

// Connect to MongoDB with error handling
mongoose.connect('mongodb://localhost:27017/mydb', {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
.then(() => console.log('Connected to MongoDB successfully'))
.catch(err => console.error('MongoDB connection error:', err));

// Middleware
app.use(cors());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Routes
app.use('/api/auth', userRoutes);  // Prefix all auth routes with /api/auth

// Basic route for testing
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

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
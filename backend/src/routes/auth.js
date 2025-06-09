const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const ActivityLog = require('../models/ActivityLog');

// Middleware to check if user is admin
const isAdmin = async (req, res, next) => {
  try {
    if (!req.user) {
      return res.status(401).json({ message: 'Not authenticated' });
    }

    const user = await User.findById(req.user.id);
    if (!user || user.username !== 'admin1') {
      return res.status(403).json({ message: 'Not authorized' });
    }

    next();
  } catch (error) {
    console.error('Admin check error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Check admin status
router.get('/check-admin', async (req, res) => {
  try {
    if (!req.user) {
      return res.json({ isAdmin: false });
    }

    const user = await User.findById(req.user.id);
    res.json({ isAdmin: user && user.username === 'admin1' });
  } catch (error) {
    console.error('Admin check error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Login route with activity logging
router.post('/login', async (req, res) => {
  try {
    const { username, password, deviceType = 'web' } = req.body;

    // Find user
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Verify password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Create JWT token
    const token = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    // Log the login activity
    await ActivityLog.create({
      userId: user._id,
      username: user.username,
      action: deviceType === 'mobile' ? 'mobile_login' : 'login',
      deviceType,
      details: `User logged in from ${deviceType}`
    });

    res.json({
      token,
      user: {
        id: user._id,
        username: user.username,
        isAdmin: user.username === 'admin1'
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Logout route with activity logging
router.post('/logout', async (req, res) => {
  try {
    if (req.user) {
      const user = await User.findById(req.user.id);
      if (user) {
        await ActivityLog.create({
          userId: user._id,
          username: user.username,
          action: 'logout',
          deviceType: 'web',
          details: 'User logged out'
        });
      }
    }
    res.json({ message: 'Logged out successfully' });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get activity logs (admin only)
router.get('/logs', isAdmin, async (req, res) => {
  try {
    const { dateRange, userFilter, actionFilter } = req.query;
    let query = {};

    // Apply date range filter
    if (dateRange && dateRange !== 'all') {
      const now = new Date();
      const startDate = new Date();
      
      switch (dateRange) {
        case 'today':
          startDate.setHours(0, 0, 0, 0);
          break;
        case 'week':
          startDate.setDate(now.getDate() - 7);
          break;
        case 'month':
          startDate.setMonth(now.getMonth() - 1);
          break;
      }
      
      query.timestamp = { $gte: startDate };
    }

    // Apply user filter
    if (userFilter) {
      query.username = { $regex: userFilter, $options: 'i' };
    }

    // Apply action filter
    if (actionFilter) {
      query.action = actionFilter;
    }

    const logs = await ActivityLog.find(query)
      .sort({ timestamp: -1 })
      .limit(1000);

    res.json(logs);
  } catch (error) {
    console.error('Error fetching logs:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router; 
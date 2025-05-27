import User from '../models/user.model.js';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { connectToDatabase } from '../db/mongodb.js';

// Register new user
export const register = async (req, res) => {
  try {
    const { username, password, fullName, contactNumber, address, email } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Username already exists'
      });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create new user
    const user = new User({
      username,
      password: hashedPassword,
      fullName,
      contactNumber,
      address,
      email,
      role: 'user' // Default role
    });

    await user.save();

    // Remove password from returned user object
    const userObj = user.toObject();
    delete userObj.password;

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: userObj
    });
  } catch (error) {
    console.error('Error in register:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Login user
export const login = async (req, res) => {
  try {
    const { username, password } = req.body;

    // Find user
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Check password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.status(200).json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        username: user.username,
        fullName: user.fullName,
        contactNumber: user.contactNumber,
        address: user.address,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Error in login:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Refresh token
export const refreshToken = async (req, res) => {
  try {
    const { token } = req.body;
    if (!token) {
      return res.status(400).json({
        success: false,
        message: 'Token is required'
      });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id);

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'User not found'
      });
    }

    // Generate new token
    const newToken = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.status(200).json({
      success: true,
      message: 'Token refreshed successfully',
      token: newToken
    });
  } catch (error) {
    console.error('Error in refreshToken:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Verify phone number for password reset
export const verifyPhone = async (req, res) => {
  try {
    const { phoneNumber } = req.body;

    if (!phoneNumber) {
      return res.status(400).json({
        success: false,
        message: 'Phone number is required',
      });
    }

    const { client, db } = await connectToDatabase();
    try {
      const user = await db.collection('users').findOne({ phoneNumber });

      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'Phone number not found',
      });
    }

      return res.status(200).json({
        success: true,
        message: 'Phone number verified',
        data: {
          userId: user._id,
        },
      });
    } finally {
      await client.close();
    }
  } catch (error) {
    console.error('Error verifying phone number:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
};

// Reset password after OTP verification
export const resetPassword = async (req, res) => {
  try {
    const { username, newPassword } = req.body;

    if (!username || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Username and new password are required',
      });
    }

    const { client, db } = await connectToDatabase();
    try {
      // Find user by username
      const user = await db.collection('users').findOne({ username });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

      // Hash the new password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

      // Update the user's password
      await db.collection('users').updateOne(
        { _id: user._id },
        { $set: { password: hashedPassword } }
      );

      return res.status(200).json({
      success: true,
      message: 'Password reset successful',
    });
    } finally {
      await client.close();
    }
  } catch (error) {
    console.error('Error resetting password:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
};

export const getUserByUsername = async (req, res) => {
  try {
    const { username } = req.params;

    if (!username) {
      return res.status(400).json({
        success: false,
        message: 'Username is required'
      });
    }

    const { db } = await connectToDatabase();
    const user = await db.collection('users').findOne({ username });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Return all necessary user details
    const userDetails = {
      id: user._id,
      username: user.username,
      fullName: user.fullName,
      contactNumber: user.contactNumber,
      address: user.address,
      role: user.role
    };

    return res.status(200).json({
      success: true,
      message: 'User details retrieved successfully',
      data: userDetails
    });
  } catch (error) {
    console.error('Error getting user details:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Update user profile
export const updateUser = async (req, res) => {
  try {
    const { username } = req.params;
    const { fullName, contactNumber, address } = req.body;

    if (!username) {
      return res.status(400).json({
        success: false,
        message: 'Username is required'
      });
    }

    const { db } = await connectToDatabase();
    const result = await db.collection('users').updateOne(
      { username },
      { 
        $set: {
          fullName,
          contactNumber,
          address,
          updatedAt: new Date()
        }
      }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        username,
        fullName,
        contactNumber,
        address
      }
    });
  } catch (error) {
    console.error('Error updating user:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};
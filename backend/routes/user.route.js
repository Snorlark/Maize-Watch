//user.route.js
import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import User from '../models/user.model.js';
import ActivityLogger from '../services/ActivityLogger.js'; // Add this import

const router = express.Router();

// Simple isAuthenticated middleware (update with your real auth system if different)
const isAuthenticated = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ message: 'No token provided' });
  }
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // { userId, role }
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Invalid token' });
  }
};

// Updated admin middleware to include super_admin
const isAdmin = async (req, res, next) => {
  if (req.user && (req.user.role === 'admin' || req.user.role === 'super_admin')) {
    return next();
  }
  return res.status(403).json({ message: 'Access denied. Admin privileges required.' });
};

// Super admin only middleware
const isSuperAdmin = async (req, res, next) => {
  if (req.user && req.user.role === 'super_admin') {
    return next();
  }
  return res.status(403).json({ message: 'Access denied. Super Admin privileges required.' });
};

// Check if user has admin or super_admin role
const hasAdminAccess = (role) => {
  return role === 'admin' || role === 'super_admin';
};

// Check if user has super_admin role
const hasSuperAdminAccess = (role) => {
  return role === 'super_admin';
};

// Register a new user
router.post('/register', async (req, res) => {
  try {
    const { username, password, fullName, contactNumber, address } = req.body;

    if (!username || !password || !fullName || !contactNumber || !address) {
      return res.status(400).json({
        success: false,
        message: 'All fields are required'
      });
    }

    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Username is already taken'
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters'
      });
    }

    const phoneRegex = /^(09\d{9}|\+639\d{9})$/;
    if (!phoneRegex.test(contactNumber)) {
      return res.status(400).json({
        success: false,
        message: 'Please enter a valid Philippine mobile number'
      });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = new User({
      username,
      password: hashedPassword,
      fullName,
      contactNumber,
      address,
      role: 'farmer', 
      createdAt: new Date().toISOString()
    });

    const savedUser = await newUser.save();
    const userResponse = savedUser.toObject();
    delete userResponse.password;

    const payload = {
      userId: savedUser._id,
      role: savedUser.role
    };

    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '24h' });

    res.status(201).json({
      success: true,
      message: 'Registration successful',
      data: {
        user: userResponse,
        token
      }
    });
  } catch (err) {
    console.log(err);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: err.message
    });
  }
});

// Login with Activity Logging
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    // Check if required fields are provided
    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Username and password are required'
      });
    }
    
    // Find user using Mongoose
    const user = await User.findOne({ username });
    if (!user) {
      // Log failed login attempt - user not found
      await ActivityLogger.log({
        userId: null,
        userEmail: username,
        userRole: 'unknown',
        action: 'login_failed',
        resource: 'auth',
        details: { reason: 'user_not_found' },
        req
      });
      
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }
    
    // Check password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      // Log failed login attempt - invalid password
      await ActivityLogger.log({
        userId: user._id || null,
        userEmail: username,
        userRole: user.role || 'unknown',
        action: 'login_failed',
        resource: 'auth',
        details: { reason: 'invalid_password' },
        req
      });
      
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }
    
    // Create token
    const payload = {
      userId: user._id.toString(),
      role: user.role
    };
    
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '24h' });
    
    // Log successful login
    await ActivityLogger.logLogin(user, req);
    
    // Return success without sending password
    const userObject = user.toObject();
    const { password: _, ...userWithoutPassword } = userObject;
    
    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        user: userWithoutPassword,
        token
      }
    });
    
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during login'
    });
  }
});

// Add logout route with Activity Logging
router.post('/logout', isAuthenticated, async (req, res) => {
  try {
    // Get user details for logging
    const user = await User.findById(req.user.userId);
    
    // Log logout
    await ActivityLogger.logLogout(user, req);
    
    res.json({ 
      success: true,
      message: 'Logged out successfully' 
    });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({ 
      success: false,
      message: 'Logout failed' 
    });
  }
});

// Admin-only: Get all users (accessible by both admin and super_admin)
router.get('/admin', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const users = await User.find().select('-password');
    res.status(200).json({
      success: true,
      data: users
    });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Get current logged-in user profile
router.get('/profile', isAuthenticated, async (req, res) => {
  try {
    const user = await User.findById(req.user.userId).select('-password');
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    res.status(200).json({
      success: true,
      data: user
    });
  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching profile'
    });
  }
});

// Update own profile
router.put('/profile', isAuthenticated, async (req, res) => {
  try {
    const { password, role, ...updateData } = req.body; // prevent changing password/role here
        const updatedUser = await User.findByIdAndUpdate(
      req.user.userId,
      { $set: updateData },
      { new: true, runValidators: true }
    ).select('-password');

    if (!updatedUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: updatedUser,
    });

  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating profile',
    });
  }
});

// Change password
router.put('/change-password', isAuthenticated, async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Current password and new password are required'
      });
    }

    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Current password is incorrect'
      });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    user.password = hashedPassword;
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Password changed successfully'
    });
  } catch (error) {
    console.error('Error changing password:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while changing password'
    });
  }
});

// Admin: List all users (accessible by both admin and super_admin)
router.get('/users', isAuthenticated, isAdmin, async (req, res) => {
  try {
    let query = {};
    
    // If user is admin (not super_admin), they can only see non-admin users
    if (req.user.role === 'admin') {
      query = { role: { $nin: ['admin', 'super_admin'] } };
    }
    // If user is super_admin, they can see all users including other admins
    
    const users = await User.find(query).select('-password');
    res.json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Admin: Get user by ID (with role-based restrictions)
router.get('/:id', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const targetUser = await User.findById(req.params.id).select('-password');
    if (!targetUser) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // If current user is admin (not super_admin), prevent access to admin/super_admin users
    if (req.user.role === 'admin' && hasAdminAccess(targetUser.role)) {
      return res.status(403).json({ message: 'Access denied. Cannot view admin users.' });
    }
    
    res.json(targetUser);
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Admin: Create new user (with role restrictions)
router.post('/', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const existingUser = await User.findOne({ username: req.body.username });
    if (existingUser) {
      return res.status(400).json({ message: 'Username already exists' });
    }

    // Role validation: only super_admin can create admin or super_admin users
    if (req.body.role && hasAdminAccess(req.body.role) && req.user.role !== 'super_admin') {
      return res.status(403).json({ message: 'Access denied. Cannot create admin users.' });
    }

    // Hash password before saving
    if (req.body.password) {
      const salt = await bcrypt.genSalt(10);
      req.body.password = await bcrypt.hash(req.body.password, salt);
    }

    const newUser = new User({
      ...req.body,
      createdAt: new Date().toISOString()
    });
    await newUser.save();

    const userResponse = newUser.toObject();
    delete userResponse.password;

    res.status(201).json(userResponse);
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Admin: Update user (with role-based restrictions)
router.put('/:id', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const targetUser = await User.findById(req.params.id);
    if (!targetUser) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // If current user is admin (not super_admin), prevent modification of admin/super_admin users
    if (req.user.role === 'admin' && hasAdminAccess(targetUser.role)) {
      return res.status(403).json({ message: 'Access denied. Cannot modify admin users.' });
    }
    
    // Role validation: only super_admin can change roles to admin or super_admin
    if (req.body.role && hasAdminAccess(req.body.role) && req.user.role !== 'super_admin') {
      return res.status(403).json({ message: 'Access denied. Cannot assign admin roles.' });
    }
    
    // Hash password if provided
    if (req.body.password) {
      const salt = await bcrypt.genSalt(10);
      req.body.password = await bcrypt.hash(req.body.password, salt);
    }
    
    // Add updatedAt timestamp
    const updateData = {
      ...req.body,
      updatedAt: new Date().toISOString()
    };
    
    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      { $set: updateData },
      { new: true, runValidators: true }
    ).select('-password');
    
    res.json(updatedUser);
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Admin: Delete user (with role-based restrictions)
router.delete('/:id', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const targetUser = await User.findById(req.params.id);
    if (!targetUser) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Prevent deletion of admin/super_admin users by regular admins
    if (req.user.role === 'admin' && hasAdminAccess(targetUser.role)) {
      return res.status(403).json({ message: 'Access denied. Cannot delete admin users.' });
    }
    
    // Prevent super_admin from deleting themselves
    if (req.user.userId === req.params.id) {
      return res.status(403).json({ message: 'Cannot delete your own account.' });
    }

    await User.findByIdAndDelete(req.params.id);
    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Super Admin only: Get all admin users
router.get('/admin/users', isAuthenticated, isSuperAdmin, async (req, res) => {
  try {
    const adminUsers = await User.find({ 
      role: { $in: ['admin', 'super_admin'] } 
    }).select('-password');
    res.json(adminUsers);
  } catch (error) {
    console.error('Error fetching admin users:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Super Admin only: Promote user to admin
router.put('/:id/promote', isAuthenticated, isSuperAdmin, async (req, res) => {
  try {
    const { role } = req.body; // 'admin' or 'super_admin'
    
    if (!['admin', 'super_admin'].includes(role)) {
      return res.status(400).json({ message: 'Invalid role. Must be admin or super_admin.' });
    }
    
    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      { 
        role,
        updatedAt: new Date().toISOString()
      },
      { new: true, runValidators: true }
    ).select('-password');
    
    if (!updatedUser) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.json({
      message: `User promoted to ${role} successfully`,
      user: updatedUser
    });
  } catch (error) {
    console.error('Error promoting user:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Super Admin only: Demote admin user
router.put('/:id/demote', isAuthenticated, isSuperAdmin, async (req, res) => {
  try {
    const targetUser = await User.findById(req.params.id);
    if (!targetUser) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    if (!hasAdminAccess(targetUser.role)) {
      return res.status(400).json({ message: 'User is not an admin.' });
    }
    
    // Prevent super_admin from demoting themselves
    if (req.user.userId === req.params.id) {
      return res.status(403).json({ message: 'Cannot demote yourself.' });
    }
    
    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      { 
        role: 'farmer', // or whatever default role you want
        updatedAt: new Date().toISOString()
      },
      { new: true, runValidators: true }
    ).select('-password');
    
    res.json({
      message: 'Admin user demoted successfully',
      user: updatedUser
    });
  } catch (error) {
    console.error('Error demoting user:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

export default router;
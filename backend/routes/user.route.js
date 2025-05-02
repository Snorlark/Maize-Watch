// import express from 'express';
// import bcrypt from 'bcrypt';
// import User from '../models/user.model.js';

// const router = express.Router();

// const isAdmin = async (req, res, next) => {
//   try {
//     // This assumes you have authentication middleware that sets req.user
//     // You can adjust according to your authentication system
//     if (req.user && req.user.role === 'admin') {
//       return next();
//     }
//     return res.status(403).json({ message: 'Access denied. Admin privileges required.' });
//   } catch (error) {
//     return res.status(500).json({ message: 'Server error' });
//   }
// };
// // /**
// //  * @route POST /api/auth/register
// //  * @desc Register a new user
// //  * @access Public
// //  */
// // router.post('/register', async (req, res) => {
// //     try {
// //         // Validate required fields
// //         const { username, password, fullName, contactNumber, address } = req.body;
        
// //         if (!username || !password || !fullName || !contactNumber || !address) {
// //             return res.status(400).json({
// //                 success: false,
// //                 message: 'All fields are required'
// //             });
// //         }
        
// //         // Check if username already exists
// //         const existingUser = await User.findOne({ username });
        
// //         if (existingUser) {
// //             return res.status(400).json({
// //                 success: false,
// //                 message: 'Username is already taken'
// //             });
// //         }

// //         // Validate password length
// //         if (password.length < 6) {
// //             return res.status(400).json({
// //                 success: false,
// //                 message: 'Password must be at least 6 characters'
// //             });
// //         }

// //         // Validate phone number format
// //         const phoneRegex = /^(09\d{9}|\+639\d{9})$/;
// //         if (!phoneRegex.test(contactNumber)) {
// //             return res.status(400).json({
// //                 success: false,
// //                 message: 'Please enter a valid Philippine mobile number'
// //             });
// //         }

// //         // Hash password
// //         const salt = await bcrypt.genSalt(10);
// //         const hashedPassword = await bcrypt.hash(password, salt);
        
// //         // Create new user
// //         const newUser = new User({
// //             username,
// //             password: hashedPassword,
// //             fullName,
// //             contactNumber,
// //             address,
// //             role: 'farmer' // Default role
// //         });
        
// //         // Save the new user
// //         const savedUser = await newUser.save();
        
// //         // Don't send password back in response
// //         // const userResponse = savedUser.toObject();
// //         // delete userResponse.password;
        
// //         // res.status(201).json({
// //         //     success: true,
// //         //     message: 'Registration successful',
// //         //     data: userResponse
// //         // });
// //     } catch (err) {
// //         console.log(err);
// //         res.status(500).json({ 
// //             success: false,
// //             message: 'Server error', 
// //             error: err.message 
// //         });
// //     }
// // });

// // /**
// //  * @route POST /api/auth/login
// //  * @desc Authenticate user & get token
// //  * @access Public
// //  */
// // router.post('/login', async (req, res) => {
// //     try {
// //         const { username, password } = req.body;
        
// //         if (!username || !password) {
// //             return res.status(400).json({
// //                 success: false,
// //                 message: 'Username and password are required'
// //             });
// //         }
        
// //         // Find user by username
// //         const user = await User.findOne({ username });
        
// //         if (!user) {
// //             return res.status(401).json({
// //                 success: false,
// //                 message: 'Invalid username or password'
// //             });
// //         }
           
// //         const isPasswordValid = await bcrypt.compare(password, user.password);
              
// //         if (!isPasswordValid) {
// //             return res.status(401).json({
// //                 success: false,
// //                 message: 'Invalid username or password'
// //             });
// //         }
        
// //         // Don't send password back in response
// //         const userResponse = user.toObject();
// //         delete userResponse.password;
        
// //         // Success response
// //         res.json({
// //             success: true,
// //             message: 'Login successful',
// //             data: {
// //                 user: userResponse,
// //                 token: 'jwt-token-would-go-here' // In a real app, generate JWT token
// //             }
// //         });
// //     } catch (err) {
// //         console.log(err);
// //         res.status(500).json({
// //             success: false,
// //             message: 'Server error',
// //             error: err.message
// //         });
// //     }
// // });

// // export default router;


// router.post('/register', async (req, res) => {
//     try {
//         // Validate required fields
//         const { username, password, fullName, contactNumber, address } = req.body;
        
//         if (!username || !password || !fullName || !contactNumber || !address) {
//             return res.status(400).json({
//                 success: false,
//                 message: 'All fields are required'
//             });
//         }
        
//         // Check if username already exists
//         const existingUser = await User.findOne({ username });
        
//         if (existingUser) {
//             return res.status(400).json({
//                 success: false,
//                 message: 'Username is already taken'
//             });
//         }

//         // Validate password length
//         if (password.length < 6) {
//             return res.status(400).json({
//                 success: false,
//                 message: 'Password must be at least 6 characters'
//             });
//         }

//         // Validate phone number format
//         const phoneRegex = /^(09\d{9}|\+639\d{9})$/;
//         if (!phoneRegex.test(contactNumber)) {
//             return res.status(400).json({
//                 success: false,
//                 message: 'Please enter a valid Philippine mobile number'
//             });
//         }

//         // Hash password
//         const salt = await bcrypt.genSalt(10);
//         const hashedPassword = await bcrypt.hash(password, salt);
        
//         // Create new user
//         const newUser = new User({
//             username,
//             password: hashedPassword,
//             fullName,
//             contactNumber,
//             address,
//             role: 'farmer' // Default role
//         });
        
//         // Save the new user
//         const savedUser = await newUser.save();
        
//         // Don't send password back in response
//         const userResponse = savedUser.toObject();
//         delete userResponse.password;
        
//         // Add this response that was missing in your original code
//         res.status(201).json({
//             success: true,
//             message: 'Registration successful',
//             data: userResponse
//         });
//     } catch (err) {
//         console.log(err);
//         res.status(500).json({ 
//             success: false,
//             message: 'Server error', 
//             error: err.message 
//         });
//     }
// });

// router.post('/login', async (req, res) => {
//     try {
//         const { username, password } = req.body;

//         if (!username || !password) {
//             return res.status(400).json({
//                 success: false,
//                 message: 'Username and password are required'
//             });
//         }

//         const user = await User.findOne({ username });

//         if (!user) {
//             return res.status(400).json({
//                 success: false,
//                 message: 'Invalid username or password'
//             });
//         }

//         const isMatch = await bcrypt.compare(password, user.password);

//         if (!isMatch) {
//             return res.status(400).json({
//                 success: false,
//                 message: 'Invalid username or password'
//             });
//         }

//         // (Optional) Generate a token if you have JWT setup
//         // const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });

//         const userResponse = user.toObject();
//         delete userResponse.password;

//         res.status(200).json({
//             success: true,
//             message: 'Login successful',
//             data: {
//                 user: userResponse,
//                 token: 'dummy-token-for-now' // replace with real JWT token later
//             }
//         });

//     } catch (err) {
//         console.error(err);
//         res.status(500).json({
//             success: false,
//             message: 'Server error',
//             error: err.message
//         });
//     }
// });

// router.get('/', async (req, res) => {
//   try {
//     const users = await User.find().select('-password');
//     res.json(users);
//   } catch (error) {
//     console.error('Error fetching users:', error);
//     res.status(500).json({ message: 'Server error' });
//   }
// });

// // Get user by ID
// router.get('/:id', async (req, res) => {
//   try {
//     const user = await User.findById(req.params.id).select('-password');
//     if (!user) {
//       return res.status(404).json({ message: 'User not found' });
//     }
//     res.json(user);
//   } catch (error) {
//     console.error('Error fetching user:', error);
//     res.status(500).json({ message: 'Server error' });
//   }
// });

// // Create new user
// router.post('/', async (req, res) => {
//   try {
//     // Check if username already exists
//     const existingUser = await User.findOne({ username: req.body.username });
//     if (existingUser) {
//       return res.status(400).json({ message: 'Username already exists' });
//     }

//     // Create new user
//     const newUser = new User(req.body);
//     await newUser.save();
    
//     // Return user without password
//     const userResponse = newUser.toObject();
//     delete userResponse.password;
    
//     res.status(201).json(userResponse);
//   } catch (error) {
//     console.error('Error creating user:', error);
//     res.status(500).json({ message: 'Server error' });
//   }
// });

// // Update user
// router.put('/:id', async (req, res) => {
//   try {
//     // If password is empty, remove it from the update object
//     if (req.body.password === '') {
//       delete req.body.password;
//     }

//     // Find user and update
//     const updatedUser = await User.findByIdAndUpdate(
//       req.params.id,
//       { $set: req.body },
//       { new: true }
//     ).select('-password');

//     if (!updatedUser) {
//       return res.status(404).json({ message: 'User not found' });
//     }

//     res.json(updatedUser);
//   } catch (error) {
//     console.error('Error updating user:', error);
//     res.status(500).json({ message: 'Server error' });
//   }
// });

// // Delete user
// router.delete('/:id', async (req, res) => {
//   try {
//     const user = await User.findById(req.params.id);
//     if (!user) {
//       return res.status(404).json({ message: 'User not found' });
//     }

//     await User.findByIdAndDelete(req.params.id);
//     res.json({ message: 'User deleted successfully' });
//   } catch (error) {
//     console.error('Error deleting user:', error);
//     res.status(500).json({ message: 'Server error' });
//   }
// });
  

// export default router;

import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import User from '../models/user.model.js';

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

const isAdmin = async (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    return next();
  }
  return res.status(403).json({ message: 'Access denied. Admin privileges required.' });
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
      role: 'user', // Default role (you had 'farmer' before; adjust as needed)
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

// Login
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
    
    // Create token
    const payload = {
      userId: user._id.toString(),
      role: user.role
    };
    
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '24h' });
    
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
      { new: true }
    ).select('-password');

    if (!updatedUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: updatedUser
    });
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating profile'
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

// Admin: List users
router.get('/', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const users = await User.find().select('-password');
    res.json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Admin: Get user by ID
router.get('/:id', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(user);
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Admin: Create new user
router.post('/', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const existingUser = await User.findOne({ username: req.body.username });
    if (existingUser) {
      return res.status(400).json({ message: 'Username already exists' });
    }

    const newUser = new User(req.body);
    await newUser.save();

    const userResponse = newUser.toObject();
    delete userResponse.password;

    res.status(201).json(userResponse);
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Admin: Update user
router.put('/:id', isAuthenticated, isAdmin, async (req, res) => {
  try {
    if (req.body.password === '') {
      delete req.body.password;
    }

    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true }
    ).select('-password');

    if (!updatedUser) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json(updatedUser);
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Admin: Delete user
router.delete('/:id', isAuthenticated, isAdmin, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    await User.findByIdAndDelete(req.params.id);
    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

export default router;

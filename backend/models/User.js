const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const UserSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  password: {
    type: String,
    required: true
  },
  fullName: {
    type: String,
    required: true
  },
  contactNumber: {
    type: String,
    required: true
  },
  address: {
    type: String,
    required: true
  },
  role: {
    type: String,
    enum: ['admin', 'farmer', 'user'],
    default: 'farmer'
  },
  email: {
    type: String,
    trim: true
  },
  lot: {
    type: Number
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Hash password before saving
UserSchema.pre('save', async function(next) {
  // Only hash the password if it's modified (or new)
  if (!this.isModified('password')) return next();
  
  try {
    // Generate salt
    const salt = await bcrypt.genSalt(10);
    // Hash password
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Update password hash when updating user
UserSchema.pre('findOneAndUpdate', async function(next) {
  const update = this.getUpdate();
  
  // Only hash the password if it's being modified
  if (update.password) {
    try {
      const salt = await bcrypt.genSalt(10);
      update.password = await bcrypt.hash(update.password, salt);
      next();
    } catch (error) {
      next(error);
    }
  } else {
    next();
  }
});

// Method to compare passwords
UserSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', UserSchema);
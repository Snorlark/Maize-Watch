import mongoose, { Document, Model } from "mongoose";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import crypto from "crypto";

// Interface for User document
interface IUser extends Document {
  _id: mongoose.Types.ObjectId;
  username: string;
  email?: string;
  password: string;
  fullName: string;
  contactNumber: string;
  address: {
    region: string;
    province: string;
    municipality: string;
    barangay: string;
  } | string; // Support both object and string formats for backward compatibility
  role: "user" | "admin" | "regional_admin" | "super_admin";
  assignedRegion?: string; // For regional_admin users - the region they manage
  isActive: boolean;
  lastLogin?: Date;
  loginAttempts: number;
  lockUntil?: Date;
  passwordResetToken?: string;
  passwordResetExpires?: Date;
  emailVerificationToken?: string;
  emailVerified: boolean;
  twoFactorSecret?: string;
  twoFactorEnabled: boolean;
  refreshTokens: mongoose.Types.DocumentArray<{
    token: string;
    createdAt: Date;
  }>;
  preferences?: {
    language: "en" | "tl";
    timezone: string;
    notifications: {
      email: boolean;
      sms: boolean;
      push: boolean;
    };
  };
  createdAt: Date;
  updatedAt: Date;
  
  // Virtual properties
  isLocked: boolean;
  
  // Instance methods
  comparePassword(candidatePassword: string): Promise<boolean>;
  generateAuthToken(): string;
  generateRefreshToken(): string;
  incLoginAttempts(): Promise<any>;
  resetLoginAttempts(): Promise<any>;
  createPasswordResetToken(): string;
  createEmailVerificationToken(): string;
}

// Interface for User model (static methods)
interface IUserModel extends Model<IUser> {
  findByCredentials(login: string, password: string): Promise<IUser>;
  getStatistics(): Promise<any>;
}

const userSchema = new mongoose.Schema(
  {
    username: {
      type: String,
      required: [true, "Username is required"],
      unique: true,
      trim: true,
      minlength: [3, "Username must be at least 3 characters long"],
      maxlength: [30, "Username cannot exceed 30 characters"],
      match: [
        /^[a-zA-Z0-9_]+$/,
        "Username can only contain letters, numbers, and underscores",
      ],
    },
    email: {
      type: String,
      required: false, // Made optional for backward compatibility
      unique: true,
      sparse: true, // Allow multiple null values
      lowercase: true,
      trim: true,
      match: [
        /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/,
        "Please enter a valid email address",
      ],
    },
    password: {
      type: String,
      required: [true, "Password is required"],
      minlength: [8, "Password must be at least 8 characters long"],
      select: false, // Don't return password by default
    },
    fullName: {
      type: String,
      required: [true, "Full name is required"],
      trim: true,
      maxlength: [100, "Full name cannot exceed 100 characters"],
    },
    contactNumber: {
      type: String,
      required: [true, "Contact number is required"],
      match: [
        /^(09\d{9}|\+639\d{9})$/,
        "Please enter a valid Philippine mobile number",
      ],
    },
    address: {
      type: mongoose.Schema.Types.Mixed, // Allow both string and object
      required: true,
      validate: {
        validator: function(value: any) {
          // Accept string format for backward compatibility
          if (typeof value === 'string') {
            return value.length > 0;
          }
          // Accept object format with required fields
          if (typeof value === 'object' && value !== null) {
            return value.region && value.province && value.municipality && value.barangay;
          }
          return false;
        },
        message: 'Address must be a non-empty string or an object with region, province, municipality, and barangay'
      }
    },
    role: {
      type: String,
      enum: {
        values: ["user", "admin", "regional_admin", "super_admin"],
        message: "Role must be user, admin, regional_admin, or super_admin",
      },
      default: "user",
    },
    assignedRegion: {
      type: String,
      required: function(this: any) {
        // Only require for new regional_admin users, not existing ones
        return this.role === 'regional_admin' && this.isNew;
      },
      validate: {
        validator: function(this: any, value: string) {
          // Skip validation if not a regional_admin or if value is empty/undefined
          if (this.role !== 'regional_admin' || !value) return true;
          
          const regions = [
            'National Capital Region (NCR)',
            'Cordillera Administrative Region (CAR)',
            'Ilocos Region (Region I)',
            'Cagayan Valley (Region II)',
            'Central Luzon (Region III)',
            'CALABARZON (Region IV-A)',
            'MIMAROPA Region (Region IV-B)',
            'Bicol Region (Region V)',
            'Western Visayas (Region VI)',
            'Central Visayas (Region VII)',
            'Eastern Visayas (Region VIII)',
            'Zamboanga Peninsula (Region IX)',
            'Northern Mindanao (Region X)',
            'Davao Region (Region XI)',
            'SOCCSKSARGEN (Region XII)',
            'Caraga (Region XIII)',
            'Bangsamoro Autonomous Region in Muslim Mindanao (BARMM)'
          ];
          return regions.includes(value);
        },
        message: 'Assigned region must be a valid Philippine region'
      }
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    lastLogin: {
      type: Date,
    },
    loginAttempts: {
      type: Number,
      default: 0,
    },
    lockUntil: {
      type: Date,
    },
    passwordResetToken: String,
    passwordResetExpires: Date,
    emailVerificationToken: String,
    emailVerified: {
      type: Boolean,
      default: false,
    },
    twoFactorSecret: {
      type: String,
      select: false,
    },
    twoFactorEnabled: {
      type: Boolean,
      default: false,
    },
    refreshTokens: [
      {
        token: {
          type: String,
          required: true,
        },
        createdAt: {
          type: Date,
          default: Date.now,
          expires: 604800, // 7 days in seconds
        },
      },
    ],
    preferences: {
      language: {
        type: String,
        enum: ["en", "tl"],
        default: "en",
      },
      timezone: {
        type: String,
        default: "Asia/Manila",
      },
      notifications: {
        email: {
          type: Boolean,
          default: true,
        },
        sms: {
          type: Boolean,
          default: false,
        },
        push: {
          type: Boolean,
          default: true,
        },
      },
    },
  },
  {
    timestamps: true,
    collection: "users",
    toJSON: {
      transform: function (doc: any, ret: any) {
        delete ret.password;
        delete ret.passwordResetToken;
        delete ret.passwordResetExpires;
        delete ret.emailVerificationToken;
        delete ret.twoFactorSecret;
        delete ret.refreshTokens;
        delete ret.__v;
        return ret;
      },
    },
  }
);

// Compound indexes for performance (username and email already have unique: true in schema)
userSchema.index({ role: 1, isActive: 1 });
userSchema.index({ "address.region": 1, "address.province": 1 });

// Virtual for account locked status
userSchema.virtual("isLocked").get(function () {
  return !!(this.lockUntil && this.lockUntil > Date.now());
});

// Pre-save middleware to hash password
userSchema.pre("save", async function (next) {
  // Only hash the password if it has been modified (or is new)
  if (!this.isModified("password")) return next();

  try {
    // Hash password with cost of 12
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error as Error);
  }
});

// Instance method to check password
userSchema.methods.comparePassword = async function (candidatePassword: string) {
  if (!this.password) return false;
  return await bcrypt.compare(candidatePassword, this.password);
};

// Instance method to generate JWT token
userSchema.methods.generateAuthToken = function () {
  const jwtSecret = process.env.JWT_SECRET;
  if (!jwtSecret) {
    throw new Error('JWT_SECRET environment variable is required');
  }

  const payload = {
    id: this._id,
    username: this.username,
    role: this.role,
    isActive: this.isActive,
  };

  return jwt.sign(payload, jwtSecret, {
    expiresIn: process.env.JWT_EXPIRE || "1h",
    issuer: "maize-watch-api",
    audience: "maize-watch-client",
  } as jwt.SignOptions);
};

// Instance method to generate refresh token
userSchema.methods.generateRefreshToken = function () {
  const refreshSecret = process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET;
  if (!refreshSecret) {
    throw new Error('JWT_REFRESH_SECRET or JWT_SECRET environment variable is required');
  }

  return jwt.sign(
    { id: this._id },
    refreshSecret,
    { expiresIn: "7d" }
  );
};

// Instance method to handle login attempts
userSchema.methods.incLoginAttempts = function () {
  // If we have a previous lock that has expired, restart at 1
  if (this.lockUntil && this.lockUntil < Date.now()) {
    return this.updateOne({
      $unset: { lockUntil: 1 },
      $set: { loginAttempts: 1 },
    });
  }

  const updates: any = { $inc: { loginAttempts: 1 } };

  // After 5 failed attempts, lock account for 2 hours
  if (this.loginAttempts + 1 >= 5 && !this.isLocked) {
    updates.$set = { lockUntil: Date.now() + 2 * 60 * 60 * 1000 }; // 2 hours
  }

  return this.updateOne(updates);
};

// Instance method to reset login attempts
userSchema.methods.resetLoginAttempts = function () {
  return this.updateOne({
    $unset: { loginAttempts: 1, lockUntil: 1 },
  });
};

// Instance method to generate password reset token
userSchema.methods.createPasswordResetToken = function () {
  const resetToken = crypto.randomBytes(32).toString("hex");

  this.passwordResetToken = crypto
    .createHash("sha256")
    .update(resetToken)
    .digest("hex");

  this.passwordResetExpires = Date.now() + 10 * 60 * 1000; // 10 minutes

  return resetToken;
};

// Instance method to generate email verification token
userSchema.methods.createEmailVerificationToken = function () {
  const verificationToken = crypto.randomBytes(32).toString("hex");

  this.emailVerificationToken = crypto
    .createHash("sha256")
    .update(verificationToken)
    .digest("hex");

  return verificationToken;
};

// Static method to find user by credentials
userSchema.statics.findByCredentials = async function (login, password) {
  // Import AppError at the top of the file if not already imported
  const { AppError } = require('../middleware/errorHandler');
  
  // Allow login with either username or email
  const user = await this.findOne({
    $or: [{ username: login }, { email: login }],
    isActive: true,
  }).select("+password");

  if (!user) {
    throw new AppError("Incorrect email or password. Please try again.", 401);
  }

  if (user.isLocked) {
    throw new AppError(
      "Account is temporarily locked due to too many failed login attempts. Please try again later.",
      403
    );
  }

  const isMatch = await user.comparePassword(password);

  if (!isMatch) {
    await user.incLoginAttempts();
    throw new AppError("Incorrect email or password. Please try again.", 401);
  }

  // Reset login attempts on successful login
  if (user.loginAttempts > 0) {
    await user.resetLoginAttempts();
  }

  // Update last login
  user.lastLogin = new Date();
  await user.save();

  return user;
};

// Static method to get user statistics
userSchema.statics.getStatistics = async function () {
  const stats = await this.aggregate([
    {
      $group: {
        _id: null,
        totalUsers: { $sum: 1 },
        activeUsers: {
          $sum: { $cond: [{ $eq: ["$isActive", true] }, 1, 0] },
        },
        verifiedUsers: {
          $sum: { $cond: [{ $eq: ["$emailVerified", true] }, 1, 0] },
        },
        usersByRole: {
          $push: "$role",
        },
        usersByRegion: {
          $push: "$address.region",
        },
      },
    },
  ]);

  return (
    stats[0] || {
      totalUsers: 0,
      activeUsers: 0,
      verifiedUsers: 0,
      usersByRole: [],
      usersByRegion: [],
    }
  );
};

const User = mongoose.model<IUser, IUserModel>("User", userSchema);

export default User;
export { IUser, IUserModel };

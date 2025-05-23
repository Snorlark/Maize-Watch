import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        minlength: 3
    },
    password: {
        type: String,
        required: true,
        minlength: 6
    },
    fullName: {
        type: String,
        required: true,
        trim: true
    },
    contactNumber: {
        type: String,
        required: true,
        match: [/^(09\d{9}|\+639\d{9})$/, 'Please enter a valid Philippine mobile number']
    },
    address: {
        type: String,
        required: true
    },
    role: {
        type: String,
        enum: ['user', 'admin'],
        default: 'user'
    }
}, {
    timestamps: true,
    collection: 'users'
});

// Add index on username
userSchema.index({ username: 1 }, { unique: true });

const User = mongoose.model('User', userSchema);

export default User;
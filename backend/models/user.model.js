import mongoose from 'mongoose';

const { Schema, model } = mongoose;

// Enhanced user schema to match Flutter registration form
const userSchema = new Schema({
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
        enum: ['farmer', 'admin', 'user'],
        default: 'farmer'
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

export default model('User', userSchema);
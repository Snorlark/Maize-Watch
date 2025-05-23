import express from 'express';
import { login, register, refreshToken } from '../controllers/auth.controller.js';

const router = express.Router();

// Authentication routes
router.post('/login', login);
router.post('/register', register);
router.post('/refresh-token', refreshToken);

export default router; 
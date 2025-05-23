// routes/corn.route.js
import { Router } from 'express';
import { 
  registerCornField, 
  getCornFieldsByUser, 
  getCornFieldById, 
  updateCornField, 
  deleteCornField 
} from '../controllers/corn.controller.js';
import { authenticateToken } from '../middleware/auth.middleware.js';

const router = Router();

// Register a new corn field - requires authentication
router.post('/register', authenticateToken, registerCornField);

// Get all corn fields for a specific user
router.get('/user/:userId', authenticateToken, getCornFieldsByUser);

// Get a specific corn field by ID
router.get('/:id', authenticateToken, getCornFieldById);

// Update a corn field
router.put('/:id', authenticateToken, updateCornField);

// Delete a corn field
router.delete('/:id', authenticateToken, deleteCornField);

export default router;
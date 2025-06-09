// routes/corn.route.js
import { Router } from 'express';
import { 
  registerCornField, 
  getCornFieldsByUser, 
  getCornFieldById, 
  updateCornField, 
  deleteCornField 
} from '../controllers/corn.controller.js';
import { isAuthenticated } from '../middleware/auth.middleware.js';

const router = Router();

// Register a new corn field - requires authentication
router.post('/register', isAuthenticated, registerCornField);

// Get all corn fields for a user - requires authentication
router.get('/user/:userId', isAuthenticated, getCornFieldsByUser);

// Get a specific corn field by ID - requires authentication
router.get('/:id', isAuthenticated, getCornFieldById);

// Update a corn field - requires authentication
router.put('/:id', isAuthenticated, updateCornField);

// Delete a corn field - requires authentication
router.delete('/:id', isAuthenticated, deleteCornField);

export default router;
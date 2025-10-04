import { Router } from 'express';
import { PrototypeController } from '../controllers/prototypeController';
import { authenticate } from '../middleware/auth';

const router = Router();

// Public routes (no authentication required)
router.post('/validate', PrototypeController.validatePrototype);
router.get('/available', PrototypeController.getAvailablePrototypes);

// Protected routes (authentication required)
router.post('/register', authenticate, PrototypeController.registerPrototype);
router.get('/user', authenticate, PrototypeController.getUserPrototypes);

// Admin routes (no authentication for testing purposes)
router.post('/unregister', PrototypeController.unregisterPrototype);

export default router;

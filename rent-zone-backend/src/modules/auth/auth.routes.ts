import { Router } from 'express';
import * as authController from './auth.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

// Public
router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/oauth', authController.oauthLogin);
router.post('/refresh', authController.refresh);

// Protected
router.post('/logout', authenticate, authController.logout);
router.get('/me', authenticate, authController.getMe);

export default router;

import { Router } from 'express';
import * as notifController from './notification.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

router.use(authenticate);

router.get('/', notifController.getNotifications);
router.patch('/read-all', notifController.markAllRead);
router.patch('/:id/read', notifController.markRead);

export default router;

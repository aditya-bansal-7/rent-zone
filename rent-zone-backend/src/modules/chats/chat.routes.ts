import { Router } from 'express';
import * as chatController from './chat.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

router.use(authenticate);

router.get('/', chatController.getConversations);
router.post('/', chatController.startConversation);
router.get('/:id/messages', chatController.getMessages);
router.post('/:id/messages', chatController.sendMessage);

export default router;

import { Router } from 'express';
import * as chatController from './chat.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

router.use(authenticate);

router.get('/', chatController.getConversations);
router.get('/search', chatController.searchConversations);
router.post('/', chatController.startConversation);
router.get('/:id/messages', chatController.getMessages);
router.post('/:id/messages', chatController.sendMessage);
router.post('/:id/messages/image', chatController.upload.single('image'), chatController.sendImageMessage);
router.post('/:id/messages/location', chatController.sendLocationMessage);
router.put('/:id/read', chatController.markAsRead);
router.delete('/:id', chatController.deleteConversation);

export default router;

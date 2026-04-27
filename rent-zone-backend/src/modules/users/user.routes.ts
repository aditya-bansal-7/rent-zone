import { Router } from 'express';
import * as userController from './user.controller';
import { authenticate } from '../../middleware/auth.middleware';
import { upload } from '../../middleware/upload.middleware';

const router = Router();

router.get('/:id', userController.getUser);

router.patch('/me', authenticate, userController.updateMe);
router.post('/me/avatar', authenticate, upload.single('avatar'), userController.uploadAvatar);
router.get('/me/favourites', authenticate, userController.getFavourites);
router.post('/me/favourites/:productId', authenticate, userController.addFavourite);
router.delete('/me/favourites/:productId', authenticate, userController.removeFavourite);

export default router;

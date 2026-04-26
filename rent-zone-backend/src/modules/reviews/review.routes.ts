import { Router } from 'express';
import * as reviewController from './review.controller';
import { authenticate } from '../../middleware/auth.middleware';
import { upload } from '../../middleware/upload.middleware';

const router = Router();

router.get('/product/:productId', reviewController.getProductReviews);
router.post('/', authenticate, upload.array('images', 5), reviewController.createReview);
router.delete('/:id', authenticate, reviewController.deleteReview);

export default router;

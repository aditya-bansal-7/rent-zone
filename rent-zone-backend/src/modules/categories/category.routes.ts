import { Router } from 'express';
import * as categoryController from './category.controller';
import { authenticate } from '../../middleware/auth.middleware';
import { upload } from '../../middleware/upload.middleware';

const router = Router();

router.get('/', categoryController.listCategories);
router.post('/', authenticate, upload.single('image'), categoryController.createCategory);
router.get('/:id/products', categoryController.getCategoryProducts);

export default router;

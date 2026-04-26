import { Router } from 'express';
import * as categoryController from './category.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

router.get('/', categoryController.listCategories);
router.post('/', authenticate, categoryController.createCategory);
router.get('/:id/products', categoryController.getCategoryProducts);

export default router;

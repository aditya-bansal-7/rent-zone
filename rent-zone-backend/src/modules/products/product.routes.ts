import { Router } from 'express';
import * as productController from './product.controller';
import { authenticate } from '../../middleware/auth.middleware';
import { upload } from '../../middleware/upload.middleware';

const router = Router();

router.get('/', productController.listProducts);
router.get('/:id', productController.getProduct);
router.get('/:id/booked-dates', productController.getBookedDates);

router.post('/', authenticate, productController.createProduct);
router.patch('/:id', authenticate, productController.updateProduct);
router.delete('/:id', authenticate, productController.deleteProduct);
router.post('/:id/images', authenticate, upload.array('images', 10), productController.uploadImages);

export default router;

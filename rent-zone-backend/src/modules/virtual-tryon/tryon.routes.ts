import { Router } from 'express';
import * as tryonController from './tryon.controller';
import { authenticate } from '../../middleware/auth.middleware';
import { upload } from '../../middleware/upload.middleware';

const router = Router();

router.use(authenticate);

router.post('/', upload.single('image'), tryonController.submitTryOn);
router.get('/me', tryonController.getMyTryOns);

export default router;

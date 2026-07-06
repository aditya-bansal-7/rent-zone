import { Router } from 'express';
import * as tryonController from './tryon.controller';
import { authenticate } from '../../middleware/auth.middleware';
import { upload } from '../../middleware/upload.middleware';

const router = Router();

router.use(authenticate);

// POST /api/tryon
// multipart/form-data: image (person photo) + productId (text)
// The controller handles:
//   1. Upload person photo → Cloudinary (rentzone/tryon-persons)
//   2. Call YCE AI API with Cloudinary URL of person + product garment URL
//   3. Upload YCE result → Cloudinary (rentzone/tryon)
//   4. Save to DB and return result
router.post('/', upload.single('image'), tryonController.submitTryOn);

// GET /api/tryon/me
router.get('/me', tryonController.getMyTryOns);

export default router;

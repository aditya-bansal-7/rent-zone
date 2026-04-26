import { Router } from 'express';
import * as reportController from './report.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();
router.post('/', authenticate, reportController.createReport);
export default router;

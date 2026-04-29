import { Router } from 'express';
import * as rentalController from './rental.controller';
import { authenticate } from '../../middleware/auth.middleware';

const router = Router();

router.use(authenticate);

router.post('/', rentalController.requestRental);
router.get('/me', rentalController.getMyRentals);
router.get('/mine', rentalController.getMyRentals);
router.get('/:id', rentalController.getRental);
router.patch('/:id/status', rentalController.updateStatus);

export default router;

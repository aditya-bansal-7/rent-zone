import { Request, Response } from 'express';
import { z } from 'zod';
import { RentalStatus } from '@prisma/client';
import * as rentalService from './rental.service';
import { sendSuccess, sendError } from '../../utils/response.utils';

const createSchema = z.object({
  productId: z.string(),
  startDate: z.coerce.date(),
  endDate: z.coerce.date(),
  totalPrice: z.coerce.number().positive(),
});

export const requestRental = async (req: Request, res: Response) => {
  try {
    const data = createSchema.parse(req.body);
    const rental = await rentalService.createRental(
      req.user!.userId, data.productId, data.startDate, data.endDate, data.totalPrice
    );
    sendSuccess(res, rental, 201, 'Rental requested');
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const getMyRentals = async (req: Request, res: Response) => {
  try {
    const role = (req.query.role as 'renter' | 'owner') || 'renter';
    const rentals = await rentalService.getMyRentals(req.user!.userId, role);
    sendSuccess(res, rentals);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const getRental = async (req: Request, res: Response) => {
  try {
    const rental = await rentalService.getRentalById(req.params.id);
    if (!rental) return sendError(res, 'Rental not found', 404);
    sendSuccess(res, rental);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const updateStatus = async (req: Request, res: Response) => {
  try {
    const { status } = req.body;
    if (!status) return sendError(res, 'status is required', 400);
    const rental = await rentalService.updateRentalStatus(req.params.id, req.user!.userId, status as RentalStatus);
    sendSuccess(res, rental, 200, `Rental ${status}`);
  } catch (err: any) {
    const code = err.message === 'Forbidden' ? 403 : err.message === 'Rental not found' ? 404 : 400;
    sendError(res, err.message, code);
  }
};

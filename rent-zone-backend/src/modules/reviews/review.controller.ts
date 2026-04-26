import { Request, Response } from 'express';
import { z } from 'zod';
import * as reviewService from './review.service';
import { uploadToCloudinary } from '../../utils/cloudinary.utils';
import { sendSuccess, sendError } from '../../utils/response.utils';

const createSchema = z.object({
  productId: z.string(),
  rating: z.coerce.number().int().min(1).max(5),
  content: z.string().min(1),
});

export const createReview = async (req: Request, res: Response) => {
  try {
    const data = createSchema.parse(req.body);
    const files = req.files as Express.Multer.File[] | undefined;
    const imageURLs = files?.length
      ? await Promise.all(files.map((f) => uploadToCloudinary(f.buffer, 'rentzone/reviews')))
      : [];
    const review = await reviewService.createReview(
      req.user!.userId, data.productId, data.rating, data.content, imageURLs
    );
    sendSuccess(res, review, 201, 'Review submitted');
  } catch (err: any) {
    const code = err.message?.includes('already') ? 409 : 400;
    sendError(res, err.message, code);
  }
};

export const getProductReviews = async (req: Request, res: Response) => {
  try {
    const reviews = await reviewService.getProductReviews(req.params.productId);
    sendSuccess(res, reviews);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const deleteReview = async (req: Request, res: Response) => {
  try {
    await reviewService.deleteReview(req.params.id, req.user!.userId);
    sendSuccess(res, null, 200, 'Review deleted');
  } catch (err: any) {
    const code = err.message === 'Forbidden' ? 403 : err.message === 'Review not found' ? 404 : 400;
    sendError(res, err.message, code);
  }
};

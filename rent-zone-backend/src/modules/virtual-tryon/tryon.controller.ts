import { Request, Response } from 'express';
import * as tryonService from './tryon.service';
import { uploadToCloudinary } from '../../utils/cloudinary.utils';
import { sendSuccess, sendError } from '../../utils/response.utils';

// POST /api/tryon
// Accepts multipart form: image (person photo file) + productId (text field)
// 1. Uploads person photo to Cloudinary
// 2. Passes Cloudinary URL + productId to tryonService (which calls YCE)
export const submitTryOn = async (req: Request, res: Response) => {
  try {
    const { productId } = req.body;

    if (!productId) return sendError(res, 'productId is required', 400);
    if (!req.file) return sendError(res, 'Person image file is required', 400);

    // Step 1: Upload person photo to Cloudinary
    // Doing this on the backend keeps Cloudinary credentials server-side.
    const personImageURL = await uploadToCloudinary(req.file.buffer, 'rentzone/tryon-persons');
    console.log(`[TryOn] Person image uploaded to Cloudinary: ${personImageURL}`);

    // Step 2: Call YCE service with the Cloudinary URL
    const result = await tryonService.createTryOn(
      req.user!.userId,
      productId,
      personImageURL
    );

    sendSuccess(res, result, 201, 'Virtual try-on created');
  } catch (err: any) {
    console.error('[TryOn] Controller error:', err.message);
    sendError(res, err.message);
  }
};

export const getMyTryOns = async (req: Request, res: Response) => {
  try {
    const tryons = await tryonService.getMyTryOns(req.user!.userId);
    sendSuccess(res, tryons);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

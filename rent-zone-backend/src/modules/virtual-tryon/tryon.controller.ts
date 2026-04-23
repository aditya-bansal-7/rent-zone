import { Request, Response } from 'express';
import * as tryonService from './tryon.service';
import { sendSuccess, sendError } from '../../utils/response.utils';

export const submitTryOn = async (req: Request, res: Response) => {
  try {
    const { productId } = req.body;
    if (!productId) return sendError(res, 'productId is required', 400);
    if (!req.file) return sendError(res, 'Image file is required', 400);
    const result = await tryonService.createTryOn(req.user!.userId, productId, req.file.buffer);
    sendSuccess(res, result, 201, 'Virtual try-on created');
  } catch (err: any) {
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

import { Request, Response, NextFunction } from 'express';
import { sendError } from '../utils/response.utils';

export const errorHandler = (
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
): void => {
  console.error(`[Error] ${err.message}`);
  sendError(res, err.message || 'Internal Server Error', 500);
};

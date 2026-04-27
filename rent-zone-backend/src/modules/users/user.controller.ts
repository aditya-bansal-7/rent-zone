import { Request, Response } from 'express';
import * as userService from './user.service';
import { uploadToCloudinary } from '../../utils/cloudinary.utils';
import { sendSuccess, sendError } from '../../utils/response.utils';

export const getUser = async (req: Request, res: Response) => {
  try {
    const user = await userService.getUserById(req.params.id);
    if (!user) return sendError(res, 'User not found', 404);
    sendSuccess(res, user);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const updateMe = async (req: Request, res: Response) => {
  try {
    const { name, location } = req.body;
    const user = await userService.updateUser(req.user!.userId, { name, location });
    sendSuccess(res, user, 200, 'Profile updated');
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const uploadAvatar = async (req: Request, res: Response) => {
  try {
    if (!req.file) return sendError(res, 'No file uploaded', 400);
    const url = await uploadToCloudinary(req.file.buffer, 'rentzone/avatars');
    const user = await userService.updateUser(req.user!.userId, { profileImage: url });
    sendSuccess(res, user, 200, 'Avatar updated');
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const getFavourites = async (req: Request, res: Response) => {
  try {
    const products = await userService.getFavourites(req.user!.userId);
    sendSuccess(res, products);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const addFavourite = async (req: Request, res: Response) => {
  try {
    const user = await userService.addFavourite(req.user!.userId, req.params.productId);
    sendSuccess(res, user, 200, 'Added to favourites');
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const removeFavourite = async (req: Request, res: Response) => {
  try {
    const user = await userService.removeFavourite(req.user!.userId, req.params.productId);
    sendSuccess(res, user, 200, 'Removed from favourites');
  } catch (err: any) {
    sendError(res, err.message);
  }
};

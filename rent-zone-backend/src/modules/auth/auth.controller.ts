import { Request, Response } from 'express';
import { z } from 'zod';
import { AccountProvider } from '@prisma/client';
import * as authService from './auth.service';
import { sendSuccess, sendError } from '../../utils/response.utils';
import { uploadToCloudinary } from '../../utils/cloudinary.utils';

const registerSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  password: z.string().min(6),
  location: z.string().optional().default(''),
  university: z.string().optional(),
  phoneNumber: z.string().optional(),
  preferredCategory: z.enum(['men', 'women']).optional(),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

const updateProfileSchema = z.object({
  name: z.string().min(2).optional(),
  location: z.string().optional(),
  university: z.string().optional().nullable(),
  phoneNumber: z.string().optional().nullable(),
  profileImage: z.string().optional().nullable(),
  preferredCategory: z.enum(['men', 'women']).optional().nullable(),
});

export const register = async (req: Request, res: Response) => {
  try {
    const data = registerSchema.parse(req.body);
    const result = await authService.registerUser(
      data.name,
      data.email,
      data.password,
      data.location,
      data.university,
      data.phoneNumber,
      data.preferredCategory
    );
    sendSuccess(res, result, 201, 'User registered successfully');
  } catch (err: any) {
    const status = err.message?.includes('already') ? 409 : 400;
    sendError(res, err.message, status);
  }
};

export const login = async (req: Request, res: Response) => {
  try {
    const data = loginSchema.parse(req.body);
    const result = await authService.loginUser(data.email, data.password);
    sendSuccess(res, result, 200, 'Login successful');
  } catch (err: any) {
    sendError(res, err.message, 401);
  }
};

export const oauthLogin = async (req: Request, res: Response) => {
  try {
    const { name, provider, location, idToken } = req.body;
    if (!provider || !idToken) {
      return sendError(res, 'provider and idToken are required', 400);
    }
    const result = await authService.oauthLogin(provider as AccountProvider, idToken, name, location);
    sendSuccess(res, result, 200, 'OAuth login successful');
  } catch (err: any) {
    sendError(res, err.message, 400);
  }
};

export const refresh = async (req: Request, res: Response) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) return sendError(res, 'Refresh token required', 400);
    const tokens = await authService.refreshTokens(refreshToken);
    sendSuccess(res, tokens);
  } catch (err: any) {
    sendError(res, 'Invalid or expired refresh token', 401);
  }
};

export const logout = async (req: Request, res: Response) => {
  try {
    await authService.logoutUser(req.user!.userId);
    sendSuccess(res, {}, 200, 'Logged out successfully');
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const getMe = async (req: Request, res: Response) => {
  try {
    const user = await authService.getCurrentUser(req.user!.userId);
    if (!user) return sendError(res, 'User not found', 404);
    sendSuccess(res, user);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const updateProfile = async (req: Request, res: Response) => {
  try {
    const data = updateProfileSchema.parse(req.body);
    const user = await authService.updateProfile(req.user!.userId, data);
    sendSuccess(res, user, 200, 'Profile updated successfully');
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const sendOtp = async (req: Request, res: Response) => {
  try {
    const { email } = req.body;
    if (!email) return sendError(res, 'Email is required', 400);
    await authService.sendOtp(email);
    sendSuccess(res, {}, 200, 'OTP sent successfully');
  } catch (err: any) {
    sendError(res, err.message, 500);
  }
};

export const verifyOtp = async (req: Request, res: Response) => {
  try {
    const { email, code } = req.body;
    if (!email || !code) return sendError(res, 'Email and code are required', 400);
    const result = await authService.verifyOtp(email, code);
    sendSuccess(res, result, 200, 'OTP verified successfully');
  } catch (err: any) {
    sendError(res, err.message, 400);
  }
};

export const uploadProfileImage = async (req: Request, res: Response) => {
  try {
    const file = req.file;
    if (!file) return sendError(res, 'No file uploaded', 400);
    const url = await uploadToCloudinary(file.buffer, 'rentzone/profiles');
    const user = await authService.updateProfile(req.user!.userId, { profileImage: url });
    sendSuccess(res, user, 200, 'Profile image uploaded');
  } catch (err: any) {
    sendError(res, err.message);
  }
};

import { Request, Response } from 'express';
import { z } from 'zod';
import { AccountProvider } from '@prisma/client';
import * as authService from './auth.service';
import { sendSuccess, sendError } from '../../utils/response.utils';

const registerSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  password: z.string().min(6),
  location: z.string().optional().default(''),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

export const register = async (req: Request, res: Response) => {
  try {
    const data = registerSchema.parse(req.body);
    const result = await authService.registerUser(data.name, data.email, data.password, data.location);
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
    const { name, email, provider, location } = req.body;
    if (!name || !email || !provider) {
      return sendError(res, 'name, email, and provider are required', 400);
    }
    const result = await authService.oauthLogin(name, email, provider as AccountProvider, location);
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
    sendSuccess(res, null, 200, 'Logged out successfully');
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

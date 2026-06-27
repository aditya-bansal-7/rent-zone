import { Response, NextFunction } from 'express';
import prisma from '../config/db';
import { sendError } from '../utils/response.utils';
import { AdminRequest } from '../modules/admin/admin.types';

export const requireAdmin = async (req: AdminRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    if (!req.user || !req.user.userId) {
      sendError(res, 'Unauthorized: No user session', 401);
      return;
    }

    const account = await prisma.account.findUnique({
      where: { userId: req.user.userId },
      include: { user: true }
    });

    if (!account || !account.isAdmin) {
      sendError(res, 'Forbidden: Admin access required', 403);
      return;
    }

    req.admin = {
      userId: account.userId,
      email: account.email,
      name: account.user?.name || 'Admin',
    };

    next();
  } catch (err) {
    sendError(res, 'Internal server error checking admin access', 500);
  }
};

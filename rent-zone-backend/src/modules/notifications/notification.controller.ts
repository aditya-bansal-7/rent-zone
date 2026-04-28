import { Request, Response } from 'express';
import * as notifService from './notification.service';
import { sendSuccess, sendError } from '../../utils/response.utils';

export const getNotifications = async (req: Request, res: Response) => {
  try {
    const notifications = await notifService.getMyNotifications(req.user!.userId);
    sendSuccess(res, notifications);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const markRead = async (req: Request, res: Response) => {
  try {
    const notif = await notifService.markAsRead(req.params.id, req.user!.userId);
    sendSuccess(res, notif, 200, 'Marked as read');
  } catch (err: any) {
    const code = err.message === 'Forbidden' ? 403 : err.message === 'Notification not found' ? 404 : 400;
    sendError(res, err.message, code);
  }
};

export const markAllRead = async (req: Request, res: Response) => {
  try {
    await notifService.markAllAsRead(req.user!.userId);
    sendSuccess(res, {}, 200, 'All notifications marked as read');
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const respondToRequest = async (req: Request, res: Response) => {
  try {
    const { action } = req.params;
    await notifService.respondToRequest(req.params.id, req.user!.userId, action === 'accept');
    sendSuccess(res, {}, 200, `Request ${action}ed`);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

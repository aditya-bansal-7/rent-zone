import { Response } from 'express';
import { sendSuccess, sendError } from '../../utils/response.utils';
import * as adminService from './admin.service';
import { AdminRequest } from './admin.types';

// Helper for audit logs
const logAction = (req: AdminRequest, action: string, entity: string, entityId?: string, entityName?: string, metadata?: any) => {
  if (!req.admin) return;
  adminService.createAuditLog({
    adminId: req.admin.userId,
    adminName: req.admin.name,
    action,
    entity,
    entityId,
    entityName,
    metadata
  }).catch(console.error);
};

// ── Auth & Dashboard ─────────────────────────────────────────────────────────
export const getMe = async (req: AdminRequest, res: Response) => {
  try {
    if (!req.admin) throw new Error('Not authenticated');
    sendSuccess(res, req.admin);
  } catch (err: any) {
    sendError(res, err.message, 401);
  }
};

export const getDashboardStats = async (req: AdminRequest, res: Response) => {
  try {
    const stats = await adminService.getDashboardStats();
    sendSuccess(res, stats);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

// ── Users ───────────────────────────────────────────────────────────────────
export const getUsers = async (req: AdminRequest, res: Response) => {
  try {
    const { page, limit, search, status, isVerified } = req.query;
    const users = await adminService.getUsers({
      page: Number(page) || 1,
      limit: Number(limit) || 20,
      search: search as string,
      status: status as string,
      isVerified: isVerified ? isVerified === 'true' : undefined
    });
    sendSuccess(res, users);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const getUserById = async (req: AdminRequest, res: Response) => {
  try {
    const user = await adminService.getUserById(req.params.id);
    sendSuccess(res, user);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const updateUser = async (req: AdminRequest, res: Response) => {
  try {
    const user = await adminService.updateUser(req.params.id, req.body);
    logAction(req, 'user_updated', 'user', user.id, user.name, req.body);
    sendSuccess(res, user);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

// ── Products ────────────────────────────────────────────────────────────────
export const getProducts = async (req: AdminRequest, res: Response) => {
  try {
    const { page, limit, search, categoryId } = req.query;
    const products = await adminService.getProducts({
      page: Number(page) || 1,
      limit: Number(limit) || 20,
      search: search as string,
      categoryId: categoryId as string,
    });
    sendSuccess(res, products);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const getProductById = async (req: AdminRequest, res: Response) => {
  try {
    const product = await adminService.getProductById(req.params.id);
    sendSuccess(res, product);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const updateProduct = async (req: AdminRequest, res: Response) => {
  try {
    // Note: status update handles approve, hide, feature, archive
    const product = await adminService.getProductById(req.params.id);
    const updated = await adminService.updateProduct(req.params.id, req.admin!.userId, req.body);
    logAction(req, 'product_updated', 'product', product.id, product.name, req.body);
    sendSuccess(res, updated);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const deleteProduct = async (req: AdminRequest, res: Response) => {
  try {
    const product = await adminService.getProductById(req.params.id);
    await adminService.deleteProduct(req.params.id);
    logAction(req, 'product_deleted', 'product', req.params.id, product.name);
    sendSuccess(res, { success: true });
  } catch (err: any) {
    sendError(res, err.message);
  }
};

// ── Rentals ─────────────────────────────────────────────────────────────────
export const getRentals = async (req: AdminRequest, res: Response) => {
  try {
    const { page, limit, status } = req.query;
    const rentals = await adminService.getRentals({
      page: Number(page) || 1,
      limit: Number(limit) || 20,
      status: status as string
    });
    sendSuccess(res, rentals);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const getRentalById = async (req: AdminRequest, res: Response) => {
  try {
    const rental = await adminService.getRentalById(req.params.id);
    sendSuccess(res, rental);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const updateRentalStatus = async (req: AdminRequest, res: Response) => {
  try {
    const { status } = req.body;
    const rental = await adminService.updateRental(req.params.id, { status });
    logAction(req, `rental_${status}`, 'rental', rental.id, `Rental ${rental.id}`);
    sendSuccess(res, rental);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

// ── Reports ─────────────────────────────────────────────────────────────────
export const getReports = async (req: AdminRequest, res: Response) => {
  try {
    const { page, limit, status, reason } = req.query;
    const reports = await adminService.getReports({
      page: Number(page) || 1,
      limit: Number(limit) || 20,
      status: status as string,
      reason: reason as string
    });
    sendSuccess(res, reports);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const getReportById = async (req: AdminRequest, res: Response) => {
  try {
    const report = await adminService.getReportById(req.params.id);
    sendSuccess(res, report);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const updateReport = async (req: AdminRequest, res: Response) => {
  try {
    const report = await adminService.updateReport(req.params.id, req.body);
    logAction(req, 'report_updated', 'report', report.id, `Report ${report.id}`, req.body);
    sendSuccess(res, report);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

// ── Reviews ─────────────────────────────────────────────────────────────────
export const getReviews = async (req: AdminRequest, res: Response) => {
  try {
    const { page, limit, isFlagged } = req.query;
    const reviews = await adminService.getReviews({
      page: Number(page) || 1,
      limit: Number(limit) || 20,
      isFlagged: isFlagged ? isFlagged === 'true' : undefined
    });
    sendSuccess(res, reviews);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const updateReview = async (req: AdminRequest, res: Response) => {
  try {
    const review = await adminService.updateReview(req.params.id, req.body);
    logAction(req, 'review_updated', 'review', review.id, `Review ${review.id}`, req.body);
    sendSuccess(res, review);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

// ── Chats ───────────────────────────────────────────────────────────────────
export const getChats = async (req: AdminRequest, res: Response) => {
  try {
    const { page, limit } = req.query;
    const chats = await adminService.getChats({
      page: Number(page) || 1,
      limit: Number(limit) || 20
    });
    sendSuccess(res, chats);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const getChatMessages = async (req: AdminRequest, res: Response) => {
  try {
    const messages = await adminService.getChatMessages(req.params.id);
    sendSuccess(res, messages);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

// ── Notifications ───────────────────────────────────────────────────────────
export const getNotifications = async (req: AdminRequest, res: Response) => {
  try {
    const { page, limit } = req.query;
    const notifications = await adminService.getNotifications({
      page: Number(page) || 1,
      limit: Number(limit) || 20
    });
    sendSuccess(res, notifications);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const broadcastNotification = async (req: AdminRequest, res: Response) => {
  try {
    const { title, content } = req.body;
    const result = await adminService.broadcastNotification(title, content);
    logAction(req, 'notification_broadcast', 'notification', undefined, title);
    sendSuccess(res, result);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

// ── Categories ──────────────────────────────────────────────────────────────
export const getCategories = async (req: AdminRequest, res: Response) => {
  try {
    const categories = await adminService.getCategories();
    sendSuccess(res, categories);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const createCategory = async (req: AdminRequest, res: Response) => {
  try {
    const category = await adminService.createCategory(req.body);
    logAction(req, 'category_created', 'category', category.id, category.name);
    sendSuccess(res, category);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const updateCategory = async (req: AdminRequest, res: Response) => {
  try {
    const category = await adminService.updateCategory(req.params.id, req.body);
    logAction(req, 'category_updated', 'category', category.id, category.name);
    sendSuccess(res, category);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

export const deleteCategory = async (req: AdminRequest, res: Response) => {
  try {
    await adminService.deleteCategory(req.params.id);
    logAction(req, 'category_deleted', 'category', req.params.id);
    sendSuccess(res, { success: true });
  } catch (err: any) {
    sendError(res, err.message);
  }
};

// ── Try-Ons ─────────────────────────────────────────────────────────────────
export const getTryOns = async (req: AdminRequest, res: Response) => {
  try {
    const { page, limit } = req.query;
    const tryOns = await adminService.getTryOns({
      page: Number(page) || 1,
      limit: Number(limit) || 20
    });
    sendSuccess(res, tryOns);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

// ── Audit Logs ──────────────────────────────────────────────────────────────
export const getAuditLogs = async (req: AdminRequest, res: Response) => {
  try {
    const { page, limit, search } = req.query;
    const logs = await adminService.getAuditLogs({
      page: Number(page) || 1,
      limit: Number(limit) || 20,
      search: search as string
    });
    sendSuccess(res, logs);
  } catch (err: any) {
    sendError(res, err.message);
  }
};

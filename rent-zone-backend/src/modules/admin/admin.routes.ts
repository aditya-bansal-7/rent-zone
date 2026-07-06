import { Router } from 'express';
import * as adminController from './admin.controller';
import { authenticate } from '../../middleware/auth.middleware';
import { requireAdmin } from '../../middleware/admin.middleware';
import { upload } from '../../middleware/upload.middleware';

const router = Router();

// Apply auth and admin check to all admin routes
router.use(authenticate);
router.use(requireAdmin);

// Dashboard
router.get('/me', adminController.getMe);
router.get('/dashboard', adminController.getDashboardStats);

// Users
router.get('/users', adminController.getUsers);
router.get('/users/:id', adminController.getUserById);
router.patch('/users/:id', adminController.updateUser);
// Helper routes mapping to update
router.patch('/users/:id/verify', (req, res) => { req.body = { isVerified: true }; adminController.updateUser(req, res); });
router.patch('/users/:id/suspend', (req, res) => { req.body = { status: 'suspended' }; adminController.updateUser(req, res); });
router.patch('/users/:id/ban', (req, res) => { req.body = { status: 'banned' }; adminController.updateUser(req, res); });
router.patch('/users/:id/restore', (req, res) => { req.body = { status: 'active' }; adminController.updateUser(req, res); });

// Products
router.get('/products', adminController.getProducts);
router.get('/products/:id', adminController.getProductById);
router.patch('/products/:id', adminController.updateProduct);
router.delete('/products/:id', adminController.deleteProduct);

// Categories
router.get('/categories', adminController.getCategories);
router.post('/categories', upload.single('image'), adminController.createCategory);
router.patch('/categories/:id', upload.single('image'), adminController.updateCategory);
router.delete('/categories/:id', adminController.deleteCategory);

// Rentals
router.get('/rentals', adminController.getRentals);
router.get('/rentals/:id', adminController.getRentalById);
router.patch('/rentals/:id/status', adminController.updateRentalStatus);

// Reports
router.get('/reports', adminController.getReports);
router.get('/reports/:id', adminController.getReportById);
router.patch('/reports/:id', adminController.updateReport);
router.patch('/reports/:id/resolve', (req, res) => { req.body = { status: 'valid' }; adminController.updateReport(req, res); });
router.patch('/reports/:id/reject', (req, res) => { req.body = { status: 'invalid' }; adminController.updateReport(req, res); });

// Reviews
router.get('/reviews', adminController.getReviews);
router.patch('/reviews/:id', adminController.updateReview);
router.patch('/reviews/:id/flag', (req, res) => { req.body = { isFlagged: true }; adminController.updateReview(req, res); });
router.delete('/reviews/:id', (req, res) => { req.body = { isDeleted: true }; adminController.updateReview(req, res); });

// Chats
router.get('/chats', adminController.getChats);
router.get('/chats/:id/messages', adminController.getChatMessages);

// Notifications
router.get('/notifications', adminController.getNotifications);
router.post('/notifications/broadcast', adminController.broadcastNotification);

// Try-Ons
router.get('/tryons', adminController.getTryOns);

// Audit Logs
router.get('/audit-logs', adminController.getAuditLogs);

// YCE API Keys
router.get('/yce-keys', adminController.getYceKeys);
router.post('/yce-keys', adminController.createYceKey);
router.patch('/yce-keys/:id', adminController.updateYceKey);
router.delete('/yce-keys/:id', adminController.deleteYceKey);

export default router;

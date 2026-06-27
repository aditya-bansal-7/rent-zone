import { Request } from 'express';

// Extend request to include admin info
export interface AdminRequest extends Request {
  admin?: {
    userId: string;
    email: string;
    name: string;
  };
}

// Pagination
export interface PaginationParams {
  page?: number;
  limit?: number;
  search?: string;
  sort?: string;
  order?: 'asc' | 'desc';
}

// User admin
export interface AdminUserFilters extends PaginationParams {
  status?: string;
  isVerified?: boolean;
  provider?: string;
}

// Product admin
export interface AdminProductFilters extends PaginationParams {
  status?: string;
  categoryId?: string;
  condition?: string;
}

// Rental admin
export interface AdminRentalFilters extends PaginationParams {
  status?: string;
  productId?: string;
  userId?: string;
}

// Report admin
export interface AdminReportFilters extends PaginationParams {
  status?: string;
  reason?: string;
}

// Review admin
export interface AdminReviewFilters extends PaginationParams {
  isFlagged?: boolean;
  productId?: string;
}

// Audit log
export interface AuditLogEntry {
  adminId: string;
  adminName: string;
  action: string;
  entity: string;
  entityId?: string;
  entityName?: string;
  metadata?: Record<string, unknown>;
}

// Dashboard stats
export interface DashboardStats {
  totalUsers: number;
  activeUsers: number;
  totalProducts: number;
  totalRentals: number;
  activeRentals: number;
  completedRentals: number;
  pendingReports: number;
  totalReviews: number;
  totalChats: number;
  totalTryOns: number;
  monthlyRevenue: number;
  recentMonths: MonthlyAnalytics[];
  categoryBreakdown: CategoryStats[];
  revenueByMonth: RevenueByMonth[];
}

export interface MonthlyAnalytics {
  date: string;
  users: number;
  products: number;
  rentals: number;
  reports: number;
  reviews: number;
  tryOns: number;
}

export interface CategoryStats {
  name: string;
  value: number;
}

export interface RevenueByMonth {
  date: string;
  revenue: number;
}

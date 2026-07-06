import { Prisma } from '@prisma/client';
import prisma from '../../config/db';
import { 
  AdminUserFilters, AdminProductFilters, AdminRentalFilters, 
  AdminReportFilters, AdminReviewFilters, AuditLogEntry,
  DashboardStats, PaginationParams 
} from './admin.types';

// ── Dashboard ────────────────────────────────────────────────────────────────
export const getDashboardStats = async (): Promise<DashboardStats> => {
  const [
    totalUsers,
    activeUsers,
    totalProducts,
    totalRentals,
    activeRentals,
    completedRentals,
    pendingReports,
    totalReviews,
    totalChats,
    totalTryOns,
  ] = await Promise.all([
    prisma.user.count(),
    prisma.user.count({ where: { status: 'active' } }),
    prisma.product.count(),
    prisma.rental.count(),
    prisma.rental.count({ where: { status: 'active' } }),
    prisma.rental.count({ where: { status: 'returned' } }),
    prisma.report.count({ where: { status: 'pending' } }),
    prisma.review.count(),
    prisma.chatConversation.count(),
    prisma.virtualTryOn.count(),
  ]);

  const rentals = await prisma.rental.findMany({
    where: { status: 'returned' },
    select: { totalPrice: true }
  });
  
  const monthlyRevenue = rentals.reduce((sum, r) => sum + r.totalPrice, 0);

  // For a real app we'd aggregate these properly, but for the MVP:
  const categories = await prisma.category.findMany({
    include: { _count: { select: { products: true } } }
  });
  
  const categoryBreakdown = categories.map(c => ({
    name: c.name,
    value: c._count.products
  }));

  // Simplified recent months data
  const recentMonths = [
    { date: "Current", users: totalUsers, products: totalProducts, rentals: totalRentals, reports: pendingReports, reviews: totalReviews, tryOns: totalTryOns }
  ];

  const revenueByMonth = [
    { date: "Current", revenue: monthlyRevenue }
  ];

  return {
    totalUsers, activeUsers, totalProducts, totalRentals,
    activeRentals, completedRentals, pendingReports, totalReviews,
    totalChats, totalTryOns, monthlyRevenue,
    recentMonths, categoryBreakdown, revenueByMonth
  };
};

// ── Users ───────────────────────────────────────────────────────────────────
export const getUsers = async (filters: AdminUserFilters) => {
  const { page = 1, limit = 20, search, status, isVerified, sort = 'createdAt', order = 'desc' } = filters;
  
  const where: Prisma.UserWhereInput = {
    ...(search && {
      OR: [
        { name: { contains: search, mode: 'insensitive' } },
        { location: { contains: search, mode: 'insensitive' } }
      ]
    }),
    ...(status && status !== 'all' && { status }),
    ...(isVerified !== undefined && { isVerified }),
  };

  const [users, total] = await Promise.all([
    prisma.user.findMany({
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { [sort]: order },
      include: {
        account: { select: { provider: true, email: true, isAdmin: true } },
        _count: { select: { products: true, reviews: true, rentalsAsRenter: true, reportsReceived: true } }
      }
    }),
    prisma.user.count({ where })
  ]);

  return { users, total, page, limit, totalPages: Math.ceil(total / limit) };
};

export const getUserById = async (id: string) => {
  const user = await prisma.user.findUnique({
    where: { id },
    include: {
      account: { select: { provider: true, email: true, isAdmin: true } },
      _count: { select: { products: true, reviews: true, rentalsAsRenter: true, reportsReceived: true } }
    }
  });
  if (!user) throw new Error('User not found');
  return user;
};

export const updateUser = (id: string, data: Partial<Prisma.UserUpdateInput>) => 
  prisma.user.update({ where: { id }, data });

// ── Products ────────────────────────────────────────────────────────────────
export const getProducts = async (filters: AdminProductFilters) => {
  const { page = 1, limit = 20, search, status, categoryId, sort = 'createdAt', order = 'desc' } = filters;
  
  const where: Prisma.ProductWhereInput = {
    ...(search && { name: { contains: search, mode: 'insensitive' } }),
    ...(categoryId && { categoryId }),
  };

  const [products, total] = await Promise.all([
    prisma.product.findMany({
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { [sort]: order },
      include: {
        category: true,
        listedBy: { select: { id: true, name: true, profileImage: true, isVerified: true } },
        _count: { select: { reviews: true, rentals: true } }
      }
    }),
    prisma.product.count({ where })
  ]);

  return { products, total, page, limit, totalPages: Math.ceil(total / limit) };
};

export const getProductById = async (id: string) => {
  const product = await prisma.product.findUnique({
    where: { id },
    include: {
      category: true,
      listedBy: { select: { id: true, name: true, profileImage: true, isVerified: true } },
      _count: { select: { reviews: true, rentals: true } }
    }
  });
  if (!product) throw new Error('Product not found');
  return product;
};

export const updateProduct = (id: string, _adminId: string, data: any) =>
  prisma.product.update({ where: { id }, data });

export const deleteProduct = (id: string) => prisma.product.delete({ where: { id } });

// ── Rentals ────────────────────────────────────────────────────────────────
export const getRentals = async (filters: AdminRentalFilters) => {
  const { page = 1, limit = 20, search, status, sort = 'createdAt', order = 'desc' } = filters;
  
  const where: Prisma.RentalWhereInput = {
    ...(status && status !== 'all' && { status: status as any }),
  };

  const [rentals, total] = await Promise.all([
    prisma.rental.findMany({
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { [sort]: order },
      include: {
        product: { select: { id: true, name: true, imageURLs: true, rentPricePerDay: true } },
        rentedBy: { select: { id: true, name: true } },
        rentedFrom: { select: { id: true, name: true } }
      }
    }),
    prisma.rental.count({ where })
  ]);

  return { rentals, total, page, limit, totalPages: Math.ceil(total / limit) };
};

export const getRentalById = async (id: string) => {
  const rental = await prisma.rental.findUnique({
    where: { id },
    include: {
      product: true,
      rentedBy: true,
      rentedFrom: true
    }
  });
  if (!rental) throw new Error('Rental not found');
  return rental;
};

export const updateRental = (id: string, data: Partial<Prisma.RentalUpdateInput>) =>
  prisma.rental.update({ where: { id }, data });

// ── Reports ────────────────────────────────────────────────────────────────
export const getReports = async (filters: AdminReportFilters) => {
  const { page = 1, limit = 20, search, status, reason, sort = 'createdAt', order = 'desc' } = filters;
  
  const where: Prisma.ReportWhereInput = {
    ...(status && status !== 'all' && { status }),
    ...(reason && reason !== 'all' && { reason }),
  };

  const [reports, total] = await Promise.all([
    prisma.report.findMany({
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { [sort]: order },
      include: {
        reportedBy: { select: { id: true, name: true } },
        reportedUser: { select: { id: true, name: true } },
      }
    }),
    prisma.report.count({ where })
  ]);

  return { reports, total, page, limit, totalPages: Math.ceil(total / limit) };
};

export const getReportById = async (id: string) => {
  const report = await prisma.report.findUnique({
    where: { id },
    include: {
      reportedBy: true,
      reportedUser: true,
    }
  });
  if (!report) throw new Error('Report not found');
  return report;
};

export const updateReport = (id: string, data: Partial<Prisma.ReportUpdateInput>) =>
  prisma.report.update({ where: { id }, data });

// ── Audit Logs ─────────────────────────────────────────────────────────────
export const getAuditLogs = async (filters: PaginationParams) => {
  const { page = 1, limit = 20, search, sort = 'createdAt', order = 'desc' } = filters;
  
  const where: Prisma.AuditLogWhereInput = {
    ...(search && {
      OR: [
        { adminName: { contains: search, mode: 'insensitive' } },
        { action: { contains: search, mode: 'insensitive' } },
        { entityName: { contains: search, mode: 'insensitive' } }
      ]
    })
  };

  const [logs, total] = await Promise.all([
    prisma.auditLog.findMany({
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { [sort]: order },
    }),
    prisma.auditLog.count({ where })
  ]);

  return { logs, total, page, limit, totalPages: Math.ceil(total / limit) };
};

// ==========================================
// YCE API Keys
// ==========================================

export const getYceKeys = async (query: any) => {
  const { page = 1, limit = 10, isActive } = query;
  const skip = (Number(page) - 1) * Number(limit);

  const where: any = {};
  if (isActive !== undefined) {
    where.isActive = isActive === 'true';
  }

  const keys = await prisma.yceApiKey.findMany({
    where,
    skip,
    take: Number(limit),
    orderBy: { createdAt: 'desc' },
  });

  const total = await prisma.yceApiKey.count({ where });

  // Get aggregated stats
  const activeKeys = await prisma.yceApiKey.count({ where: { isActive: true } });
  
  const stats = await prisma.yceApiKey.aggregate({
    where: { isActive: true },
    _sum: { credits: true },
  });
  
  const totalCredits = stats._sum.credits || 0;

  return { 
    keys, 
    total, 
    page: Number(page), 
    limit: Number(limit),
    stats: {
      activeKeys,
      totalCredits,
      estimatedTryOns: Math.floor(totalCredits / 2)
    }
  };
};

export const createYceKey = async (data: { key: string; name?: string; credits?: number; isActive?: boolean }, adminInfo: any) => {
  const newKey = await prisma.yceApiKey.create({
    data: {
      key: data.key,
      name: data.name,
      credits: data.credits ?? 540,
      isActive: data.isActive ?? true,
    }
  });

  await createAuditLog({
    adminId: adminInfo.id,
    adminName: adminInfo.name,
    action: 'CREATE',
    entity: 'YCE_KEY',
    entityId: newKey.id,
    entityName: newKey.name || 'Unnamed Key'
  });
  return newKey;
};

export const updateYceKey = async (id: string, data: { credits?: number; isActive?: boolean; name?: string }, adminInfo: any) => {
  const key = await prisma.yceApiKey.update({
    where: { id },
    data
  });

  await createAuditLog({
    adminId: adminInfo.id,
    adminName: adminInfo.name,
    action: 'UPDATE',
    entity: 'YCE_KEY',
    entityId: key.id,
    entityName: key.name || 'Unnamed Key'
  });
  return key;
};

export const deleteYceKey = async (id: string, adminInfo: any) => {
  const key = await prisma.yceApiKey.findUnique({ where: { id } });
  if (!key) throw new Error('Key not found');

  await prisma.yceApiKey.delete({ where: { id } });
  
  await createAuditLog({
    adminId: adminInfo.id,
    adminName: adminInfo.name,
    action: 'DELETE',
    entity: 'YCE_KEY',
    entityId: id,
    entityName: key.name || 'Unnamed Key'
  });
  return { message: 'Key deleted successfully' };
};

export const createAuditLog = (data: AuditLogEntry) => 
  prisma.auditLog.create({ data: data as any });

// ── Categories ─────────────────────────────────────────────────────────────
export const getCategories = async () => {
  return prisma.category.findMany({
    where: { 
      OR: [
        { isDeleted: false },
        { isDeleted: { isSet: false } }
      ]
    },
    include: { _count: { select: { products: true } } }
  });
};

export const createCategory = (data: Prisma.CategoryCreateInput) => prisma.category.create({ data });
export const updateCategory = (id: string, data: Prisma.CategoryUpdateInput) => prisma.category.update({ where: { id }, data });
export const deleteCategory = (id: string) => prisma.category.update({ where: { id }, data: { isDeleted: true } });

// ── Reviews ────────────────────────────────────────────────────────────────
export const getReviews = async (filters: AdminReviewFilters) => {
  const { page = 1, limit = 20, isFlagged, sort = 'createdAt', order = 'desc' } = filters;
  
  const where: Prisma.ReviewWhereInput = {
    isDeleted: false,
    ...(isFlagged !== undefined && { isFlagged }),
  };

  const [reviews, total] = await Promise.all([
    prisma.review.findMany({
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { [sort]: order },
      include: {
        user: { select: { id: true, name: true, profileImage: true } },
        product: { select: { id: true, name: true } },
      }
    }),
    prisma.review.count({ where })
  ]);

  return { reviews, total, page, limit, totalPages: Math.ceil(total / limit) };
};

export const updateReview = (id: string, data: Partial<Prisma.ReviewUpdateInput>) =>
  prisma.review.update({ where: { id }, data });

// ── Chats ────────────────────────────────────────────────────────────────
export const getChats = async (filters: PaginationParams) => {
  const { page = 1, limit = 20, sort = 'updatedAt', order = 'desc' } = filters;
  
  const [chats, total] = await Promise.all([
    prisma.chatConversation.findMany({
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { [sort]: order },
      include: {
        participants: { include: { user: { select: { id: true, name: true, profileImage: true } } } },
        _count: { select: { messages: true } }
      }
    }),
    prisma.chatConversation.count()
  ]);

  return { chats, total, page, limit, totalPages: Math.ceil(total / limit) };
};

export const getChatMessages = async (id: string) => {
  return prisma.chatMessage.findMany({
    where: { conversationId: id },
    orderBy: { createdAt: 'asc' }
  });
};

// ── Notifications ──────────────────────────────────────────────────────────
export const getNotifications = async (filters: PaginationParams) => {
  const { page = 1, limit = 20, sort = 'createdAt', order = 'desc' } = filters;
  
  const [notifications, total] = await Promise.all([
    prisma.notification.findMany({
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { [sort]: order },
      include: { user: { select: { id: true, name: true } } }
    }),
    prisma.notification.count()
  ]);

  return { notifications, total, page, limit, totalPages: Math.ceil(total / limit) };
};

export const broadcastNotification = async (title: string, content: string) => {
  const users = await prisma.user.findMany({ select: { id: true } });
  const data = users.map(u => ({
    userId: u.id,
    title,
    content,
    icon: 'bell.fill',
    type: 'general' as const,
  }));
  
  await prisma.notification.createMany({ data });

  // Broadcast to all active WebSocket clients
  const { broadcastToAllUsers } = require('../../socket');
  broadcastToAllUsers({
    title,
    content,
    icon: 'bell.fill',
    type: 'general',
    createdAt: new Date().toISOString()
  });

  return { success: true, count: users.length };
};

// ── Virtual Try-Ons ────────────────────────────────────────────────────────
export const getTryOns = async (filters: PaginationParams) => {
  const { page = 1, limit = 20, sort = 'createdAt', order = 'desc' } = filters;
  
  const [tryOns, total] = await Promise.all([
    prisma.virtualTryOn.findMany({
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { [sort]: order },
      include: {
        user: { select: { id: true, name: true } },
        product: { select: { id: true, name: true, imageURLs: true } }
      }
    }),
    prisma.virtualTryOn.count()
  ]);

  return { tryOns, total, page, limit, totalPages: Math.ceil(total / limit) };
};

export const deleteTryOn = (id: string) => prisma.virtualTryOn.delete({ where: { id } });

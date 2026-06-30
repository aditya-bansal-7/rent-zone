// ── User Types ────────────────────────────────────────────────────────────────
export type UserStatus = 'active' | 'suspended' | 'banned';
export type CategoryType = 'men' | 'women';
export type AccountProvider = 'email' | 'google' | 'apple';

export interface User {
  id: string;
  name: string;
  email: string;
  profileImage?: string;
  location: string;
  university?: string;
  phoneNumber?: string;
  preferredCategory?: CategoryType;
  isVerified: boolean;
  status: UserStatus;
  provider: AccountProvider;
  createdAt: string;
  updatedAt: string;
  _count: {
    products: number;
    reviews: number;
    rentals: number;
    reports: number;
  };
}

// ── Product Types ─────────────────────────────────────────────────────────────
export type ProductCondition = 'new' | 'like_new' | 'good' | 'fair';
export type ProductStatus = 'active' | 'hidden' | 'archived' | 'featured';

export interface Product {
  id: string;
  name: string;
  description: string;
  imageURLs: string[];
  size: string;
  condition: ProductCondition;
  occasion?: string;
  rentPricePerDay: number;
  rating: number;
  status: ProductStatus;
  categoryId: string;
  category: { id: string; name: string; type: CategoryType };
  listedByUserId: string;
  listedBy: { id: string; name: string; profileImage?: string; isVerified: boolean };
  bookedDates: string[];
  createdAt: string;
  _count: { reviews: number; rentals: number };
}

// ── Category Types ────────────────────────────────────────────────────────────
export interface Category {
  id: string;
  name: string;
  type: CategoryType;
  imageURL?: string;
  order: number;
  createdAt: string;
  _count: { products: number };
}

// ── Rental Types ──────────────────────────────────────────────────────────────
export type RentalStatus = 'requested' | 'approved' | 'active' | 'returned' | 'cancelled';

export interface Rental {
  id: string;
  productId: string;
  product: { id: string; name: string; imageURLs: string[]; rentPricePerDay: number };
  rentedByUserId: string;
  rentedBy: { id: string; name: string; profileImage?: string };
  rentedFromUserId: string;
  rentedFrom: { id: string; name: string; profileImage?: string };
  startDate: string;
  endDate: string;
  totalPrice: number;
  status: RentalStatus;
  createdAt: string;
  updatedAt: string;
}

// ── Report Types ──────────────────────────────────────────────────────────────
export type ReportReason = 'spam' | 'inappropriate' | 'fake' | 'harassment' | 'scam' | 'other';
export type ReportStatus = 'pending' | 'valid' | 'invalid' | 'escalated';

export interface Report {
  id: string;
  reason: ReportReason;
  description?: string;
  reporterId: string;
  reporter: { id: string; name: string; profileImage?: string };
  reportedUserId?: string;
  reportedUser?: { id: string; name: string; profileImage?: string };
  reportedProductId?: string;
  reportedProduct?: { id: string; name: string };
  status: ReportStatus;
  moderationNote?: string;
  createdAt: string;
}

// ── Review Types ──────────────────────────────────────────────────────────────
export interface Review {
  id: string;
  rating: number;
  comment: string;
  imageURLs?: string[];
  isFlagged: boolean;
  productId: string;
  product: { id: string; name: string };
  userId: string;
  user: { id: string; name: string; profileImage?: string };
  createdAt: string;
}

// ── Chat Types ────────────────────────────────────────────────────────────────
export interface ChatMessage {
  id: string;
  content: string;
  senderId: string;
  createdAt: string;
}

export interface Chat {
  id: string;
  participants: { id: string; name: string; profileImage?: string }[];
  productId?: string;
  product?: { id: string; name: string };
  lastMessage?: ChatMessage;
  messageCount: number;
  isFlagged: boolean;
  isArchived: boolean;
  createdAt: string;
  messages?: ChatMessage[];
}

// ── Notification Types ────────────────────────────────────────────────────────
export type NotificationType = 'rentalRequest' | 'rentalApproved' | 'rentalReturned' | 'review' | 'report' | 'system' | 'broadcast';

export interface Notification {
  id: string;
  title: string;
  content: string;
  type: NotificationType;
  userId?: string;
  user?: { id: string; name: string };
  isRead: boolean;
  isArchived: boolean;
  isBroadcast: boolean;
  targetSegment?: string;
  createdAt: string;
}

// ── Virtual Try-On Types ──────────────────────────────────────────────────────
export type TryOnStatus = 'pending' | 'completed' | 'failed' | 'flagged';

export interface TryOn {
  id: string;
  userId: string;
  user: { id: string; name: string; profileImage?: string };
  productId: string;
  product: { id: string; name: string; imageURLs: string[] };
  resultImageURL?: string;
  modelUsed: string;
  status: TryOnStatus;
  createdAt: string;
}

// ── Analytics Types ───────────────────────────────────────────────────────────
export interface AnalyticsData {
  date: string;
  users: number;
  products: number;
  rentals: number;
  reports: number;
  reviews: number;
  tryOns: number;
}

// ── Audit Log Types ───────────────────────────────────────────────────────────
export type AuditAction =
  | 'user_suspended' | 'user_banned' | 'user_restored' | 'user_deleted'
  | 'product_approved' | 'product_hidden' | 'product_featured' | 'product_deleted'
  | 'rental_cancelled' | 'rental_escalated' | 'rental_marked_returned'
  | 'report_marked_valid' | 'report_marked_invalid' | 'report_escalated'
  | 'review_deleted' | 'review_flagged'
  | 'category_created' | 'category_updated' | 'category_deleted'
  | 'notification_sent' | 'settings_updated';

export interface AuditLog {
  id: string;
  action: AuditAction;
  adminId: string;
  adminName: string;
  targetType: string;
  targetId: string;
  targetName: string;
  details?: string;
  createdAt: string;
}

// ── Admin Session Types ───────────────────────────────────────────────────────
export interface AdminUser {
  id: string;
  name: string;
  email: string;
  role: 'super_admin' | 'moderator' | 'support';
  avatar?: string;
}

// ── KPI Types ─────────────────────────────────────────────────────────────────
export interface KpiData {
  totalUsers: number;
  activeListings: number;
  totalRentals: number;
  pendingReports: number;
  unreadChats: number;
  totalReviews: number;
  tryOnRequests: number;
  monthlyRevenue: number;
}

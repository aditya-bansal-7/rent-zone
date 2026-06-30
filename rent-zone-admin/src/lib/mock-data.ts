import type { User, Product, Category, Rental, Report, Review, Chat, Notification, TryOn, AuditLog, KpiData, AnalyticsData } from "@/types";

// ── Mock Users ────────────────────────────────────────────────────────────────
export const mockUsers: User[] = [
  { id: "u1", name: "Aanya Sharma", email: "aanya@example.com", location: "Mumbai, MH", university: "IIT Bombay", phoneNumber: "+91 98765 43210", preferredCategory: "women", isVerified: true, status: "active", provider: "email", createdAt: "2024-01-15T08:00:00Z", updatedAt: "2024-06-01T10:00:00Z", profileImage: undefined, _count: { products: 12, reviews: 8, rentals: 15, reports: 0 } },
  { id: "u2", name: "Rahul Verma", email: "rahul@example.com", location: "Delhi, DL", university: "Delhi University", phoneNumber: "+91 87654 32109", preferredCategory: "men", isVerified: true, status: "active", provider: "google", createdAt: "2024-02-20T09:00:00Z", updatedAt: "2024-06-10T11:00:00Z", profileImage: undefined, _count: { products: 5, reviews: 12, rentals: 8, reports: 1 } },
  { id: "u3", name: "Priya Nair", email: "priya@example.com", location: "Bangalore, KA", university: "Christ University", phoneNumber: "+91 76543 21098", preferredCategory: "women", isVerified: false, status: "active", provider: "apple", createdAt: "2024-03-10T10:00:00Z", updatedAt: "2024-06-15T12:00:00Z", profileImage: undefined, _count: { products: 3, reviews: 5, rentals: 20, reports: 0 } },
  { id: "u4", name: "Karan Mehta", email: "karan@example.com", location: "Pune, MH", university: "COEP", phoneNumber: "+91 65432 10987", preferredCategory: "men", isVerified: true, status: "suspended", provider: "email", createdAt: "2024-01-25T07:00:00Z", updatedAt: "2024-05-20T09:00:00Z", profileImage: undefined, _count: { products: 2, reviews: 3, rentals: 4, reports: 3 } },
  { id: "u5", name: "Sneha Gupta", email: "sneha@example.com", location: "Hyderabad, TS", phoneNumber: "+91 54321 09876", preferredCategory: "women", isVerified: false, status: "active", provider: "google", createdAt: "2024-04-05T11:00:00Z", updatedAt: "2024-06-20T13:00:00Z", profileImage: undefined, _count: { products: 8, reviews: 6, rentals: 11, reports: 0 } },
  { id: "u6", name: "Arjun Patel", email: "arjun@example.com", location: "Ahmedabad, GJ", university: "NIT Surat", phoneNumber: "+91 43210 98765", preferredCategory: "men", isVerified: true, status: "banned", provider: "email", createdAt: "2024-02-01T06:00:00Z", updatedAt: "2024-04-10T08:00:00Z", profileImage: undefined, _count: { products: 1, reviews: 0, rentals: 2, reports: 5 } },
  { id: "u7", name: "Meera Krishnan", email: "meera@example.com", location: "Chennai, TN", university: "Anna University", phoneNumber: "+91 32109 87654", preferredCategory: "women", isVerified: true, status: "active", provider: "google", createdAt: "2024-03-18T08:00:00Z", updatedAt: "2024-06-25T14:00:00Z", profileImage: undefined, _count: { products: 15, reviews: 22, rentals: 30, reports: 0 } },
  { id: "u8", name: "Vikram Singh", email: "vikram@example.com", location: "Jaipur, RJ", phoneNumber: "+91 21098 76543", preferredCategory: "men", isVerified: false, status: "active", provider: "apple", createdAt: "2024-05-01T09:00:00Z", updatedAt: "2024-06-28T10:00:00Z", profileImage: undefined, _count: { products: 4, reviews: 7, rentals: 6, reports: 0 } },
];

// ── Mock Categories ───────────────────────────────────────────────────────────
export const mockCategories: Category[] = [
  { id: "cat1", name: "Ethnic Wear", type: "women", imageURL: undefined, order: 1, createdAt: "2024-01-01T00:00:00Z", _count: { products: 145 } },
  { id: "cat2", name: "Western Wear", type: "women", imageURL: undefined, order: 2, createdAt: "2024-01-01T00:00:00Z", _count: { products: 98 } },
  { id: "cat3", name: "Party Wear", type: "women", imageURL: undefined, order: 3, createdAt: "2024-01-01T00:00:00Z", _count: { products: 76 } },
  { id: "cat4", name: "Formal Wear", type: "men", imageURL: undefined, order: 4, createdAt: "2024-01-01T00:00:00Z", _count: { products: 112 } },
  { id: "cat5", name: "Casual Wear", type: "men", imageURL: undefined, order: 5, createdAt: "2024-01-01T00:00:00Z", _count: { products: 89 } },
  { id: "cat6", name: "Ethnic Wear", type: "men", imageURL: undefined, order: 6, createdAt: "2024-01-01T00:00:00Z", _count: { products: 67 } },
  { id: "cat7", name: "Bridal Wear", type: "women", imageURL: undefined, order: 7, createdAt: "2024-01-01T00:00:00Z", _count: { products: 34 } },
  { id: "cat8", name: "Accessories", type: "women", imageURL: undefined, order: 8, createdAt: "2024-01-01T00:00:00Z", _count: { products: 55 } },
];

// ── Mock Products ─────────────────────────────────────────────────────────────
export const mockProducts: Product[] = [
  { id: "p1", name: "Royal Blue Lehenga", description: "Stunning royal blue bridal lehenga with intricate zari work.", imageURLs: [], size: "M", condition: "like_new", occasion: "Wedding", rentPricePerDay: 1200, rating: 4.8, status: "featured", categoryId: "cat7", category: { id: "cat7", name: "Bridal Wear", type: "women" }, listedByUserId: "u1", listedBy: { id: "u1", name: "Aanya Sharma", isVerified: true }, bookedDates: [], createdAt: "2024-02-01T00:00:00Z", _count: { reviews: 12, rentals: 8 } },
  { id: "p2", name: "Charcoal 3-Piece Suit", description: "Classic charcoal grey three-piece suit, perfect for formal events.", imageURLs: [], size: "L", condition: "good", occasion: "Formal", rentPricePerDay: 800, rating: 4.5, status: "active", categoryId: "cat4", category: { id: "cat4", name: "Formal Wear", type: "men" }, listedByUserId: "u2", listedBy: { id: "u2", name: "Rahul Verma", isVerified: true }, bookedDates: [], createdAt: "2024-02-10T00:00:00Z", _count: { reviews: 8, rentals: 12 } },
  { id: "p3", name: "Pink Anarkali Set", description: "Beautiful pink anarkali with heavy embroidery, perfect for festivals.", imageURLs: [], size: "S", condition: "new", occasion: "Festival", rentPricePerDay: 600, rating: 4.9, status: "active", categoryId: "cat1", category: { id: "cat1", name: "Ethnic Wear", type: "women" }, listedByUserId: "u3", listedBy: { id: "u3", name: "Priya Nair", isVerified: false }, bookedDates: [], createdAt: "2024-03-05T00:00:00Z", _count: { reviews: 15, rentals: 20 } },
  { id: "p4", name: "Navy Blue Sherwani", description: "Elegant navy blue sherwani with gold buttons for grooms.", imageURLs: [], size: "XL", condition: "like_new", occasion: "Wedding", rentPricePerDay: 1500, rating: 4.7, status: "active", categoryId: "cat6", category: { id: "cat6", name: "Ethnic Wear", type: "men" }, listedByUserId: "u7", listedBy: { id: "u7", name: "Meera Krishnan", isVerified: true }, bookedDates: [], createdAt: "2024-03-15T00:00:00Z", _count: { reviews: 6, rentals: 5 } },
  { id: "p5", name: "Red Sequin Gown", description: "Stunning red sequin floor-length gown for parties and events.", imageURLs: [], size: "M", condition: "good", occasion: "Party", rentPricePerDay: 900, rating: 4.3, status: "hidden", categoryId: "cat3", category: { id: "cat3", name: "Party Wear", type: "women" }, listedByUserId: "u5", listedBy: { id: "u5", name: "Sneha Gupta", isVerified: false }, bookedDates: [], createdAt: "2024-04-01T00:00:00Z", _count: { reviews: 3, rentals: 2 } },
  { id: "p6", name: "Ivory Linen Blazer", description: "Smart casual ivory linen blazer for summer events.", imageURLs: [], size: "M", condition: "new", occasion: "Casual", rentPricePerDay: 400, rating: 4.6, status: "active", categoryId: "cat5", category: { id: "cat5", name: "Casual Wear", type: "men" }, listedByUserId: "u8", listedBy: { id: "u8", name: "Vikram Singh", isVerified: false }, bookedDates: [], createdAt: "2024-05-10T00:00:00Z", _count: { reviews: 5, rentals: 7 } },
];

// ── Mock Rentals ──────────────────────────────────────────────────────────────
export const mockRentals: Rental[] = [
  { id: "r1", productId: "p1", product: { id: "p1", name: "Royal Blue Lehenga", imageURLs: [], rentPricePerDay: 1200 }, rentedByUserId: "u3", rentedBy: { id: "u3", name: "Priya Nair" }, rentedFromUserId: "u1", rentedFrom: { id: "u1", name: "Aanya Sharma" }, startDate: "2024-07-01T00:00:00Z", endDate: "2024-07-03T00:00:00Z", totalPrice: 3600, status: "active", createdAt: "2024-06-25T10:00:00Z", updatedAt: "2024-06-26T12:00:00Z" },
  { id: "r2", productId: "p2", product: { id: "p2", name: "Charcoal 3-Piece Suit", imageURLs: [], rentPricePerDay: 800 }, rentedByUserId: "u5", rentedBy: { id: "u5", name: "Sneha Gupta" }, rentedFromUserId: "u2", rentedFrom: { id: "u2", name: "Rahul Verma" }, startDate: "2024-07-05T00:00:00Z", endDate: "2024-07-06T00:00:00Z", totalPrice: 800, status: "approved", createdAt: "2024-06-28T09:00:00Z", updatedAt: "2024-06-29T10:00:00Z" },
  { id: "r3", productId: "p3", product: { id: "p3", name: "Pink Anarkali Set", imageURLs: [], rentPricePerDay: 600 }, rentedByUserId: "u7", rentedBy: { id: "u7", name: "Meera Krishnan" }, rentedFromUserId: "u3", rentedFrom: { id: "u3", name: "Priya Nair" }, startDate: "2024-06-15T00:00:00Z", endDate: "2024-06-17T00:00:00Z", totalPrice: 1800, status: "returned", createdAt: "2024-06-10T08:00:00Z", updatedAt: "2024-06-18T09:00:00Z" },
  { id: "r4", productId: "p4", product: { id: "p4", name: "Navy Blue Sherwani", imageURLs: [], rentPricePerDay: 1500 }, rentedByUserId: "u2", rentedBy: { id: "u2", name: "Rahul Verma" }, rentedFromUserId: "u7", rentedFrom: { id: "u7", name: "Meera Krishnan" }, startDate: "2024-07-10T00:00:00Z", endDate: "2024-07-12T00:00:00Z", totalPrice: 4500, status: "requested", createdAt: "2024-06-30T11:00:00Z", updatedAt: "2024-06-30T11:00:00Z" },
  { id: "r5", productId: "p6", product: { id: "p6", name: "Ivory Linen Blazer", imageURLs: [], rentPricePerDay: 400 }, rentedByUserId: "u1", rentedBy: { id: "u1", name: "Aanya Sharma" }, rentedFromUserId: "u8", rentedFrom: { id: "u8", name: "Vikram Singh" }, startDate: "2024-06-01T00:00:00Z", endDate: "2024-06-02T00:00:00Z", totalPrice: 400, status: "cancelled", createdAt: "2024-05-28T10:00:00Z", updatedAt: "2024-05-29T08:00:00Z" },
];

// ── Mock Reports ──────────────────────────────────────────────────────────────
export const mockReports: Report[] = [
  { id: "rep1", reason: "scam", description: "This user never returned the item and blocked me.", reporterId: "u1", reporter: { id: "u1", name: "Aanya Sharma" }, reportedUserId: "u4", reportedUser: { id: "u4", name: "Karan Mehta" }, status: "valid", moderationNote: "User suspended pending investigation.", createdAt: "2024-06-15T10:00:00Z" },
  { id: "rep2", reason: "fake", description: "The product images don't match the actual item.", reporterId: "u3", reporter: { id: "u3", name: "Priya Nair" }, reportedProductId: "p5", reportedProduct: { id: "p5", name: "Red Sequin Gown" }, status: "pending", createdAt: "2024-06-20T14:00:00Z" },
  { id: "rep3", reason: "harassment", description: "This user sent abusive messages.", reporterId: "u5", reporter: { id: "u5", name: "Sneha Gupta" }, reportedUserId: "u6", reportedUser: { id: "u6", name: "Arjun Patel" }, status: "escalated", createdAt: "2024-06-22T09:00:00Z" },
  { id: "rep4", reason: "spam", description: "Multiple duplicate listings for the same product.", reporterId: "u7", reporter: { id: "u7", name: "Meera Krishnan" }, reportedUserId: "u8", reportedUser: { id: "u8", name: "Vikram Singh" }, status: "invalid", moderationNote: "Listings were unique variants.", createdAt: "2024-06-25T16:00:00Z" },
  { id: "rep5", reason: "inappropriate", description: "Product photos are inappropriate.", reporterId: "u2", reporter: { id: "u2", name: "Rahul Verma" }, reportedProductId: "p5", reportedProduct: { id: "p5", name: "Red Sequin Gown" }, status: "pending", createdAt: "2024-06-27T11:00:00Z" },
];

// ── Mock Reviews ──────────────────────────────────────────────────────────────
export const mockReviews: Review[] = [
  { id: "rev1", rating: 5, comment: "Absolutely stunning lehenga! Fitted perfectly and received so many compliments.", imageURLs: [], isFlagged: false, productId: "p1", product: { id: "p1", name: "Royal Blue Lehenga" }, userId: "u3", user: { id: "u3", name: "Priya Nair" }, createdAt: "2024-06-18T10:00:00Z" },
  { id: "rev2", rating: 4, comment: "Good quality suit. Minor creasing but overall excellent.", imageURLs: [], isFlagged: false, productId: "p2", product: { id: "p2", name: "Charcoal 3-Piece Suit" }, userId: "u5", user: { id: "u5", name: "Sneha Gupta" }, createdAt: "2024-06-19T12:00:00Z" },
  { id: "rev3", rating: 2, comment: "Not as shown in photos. Very different shade of pink.", imageURLs: [], isFlagged: true, productId: "p3", product: { id: "p3", name: "Pink Anarkali Set" }, userId: "u7", user: { id: "u7", name: "Meera Krishnan" }, createdAt: "2024-06-20T09:00:00Z" },
  { id: "rev4", rating: 5, comment: "Perfect sherwani for my brother's wedding!", imageURLs: [], isFlagged: false, productId: "p4", product: { id: "p4", name: "Navy Blue Sherwani" }, userId: "u2", user: { id: "u2", name: "Rahul Verma" }, createdAt: "2024-06-22T14:00:00Z" },
  { id: "rev5", rating: 1, comment: "Seller was rude and product was damaged.", imageURLs: [], isFlagged: true, productId: "p5", product: { id: "p5", name: "Red Sequin Gown" }, userId: "u1", user: { id: "u1", name: "Aanya Sharma" }, createdAt: "2024-06-25T16:00:00Z" },
];

// ── Mock Chats ────────────────────────────────────────────────────────────────
export const mockChats: Chat[] = [
  { id: "c1", participants: [{ id: "u1", name: "Aanya Sharma" }, { id: "u3", name: "Priya Nair" }], productId: "p1", product: { id: "p1", name: "Royal Blue Lehenga" }, lastMessage: { id: "m1", content: "Is the lehenga available on July 1st?", senderId: "u3", createdAt: "2024-06-25T10:00:00Z" }, messageCount: 12, isFlagged: false, isArchived: false, createdAt: "2024-06-24T09:00:00Z", messages: [{ id: "m1", content: "Is the lehenga available on July 1st?", senderId: "u3", createdAt: "2024-06-25T10:00:00Z" }, { id: "m2", content: "Yes, it's available! Would you like to book it?", senderId: "u1", createdAt: "2024-06-25T10:05:00Z" }] },
  { id: "c2", participants: [{ id: "u4", name: "Karan Mehta" }, { id: "u5", name: "Sneha Gupta" }], productId: "p2", product: { id: "p2", name: "Charcoal 3-Piece Suit" }, lastMessage: { id: "m3", content: "I'll report you if you don't refund me!", senderId: "u4", createdAt: "2024-06-22T14:00:00Z" }, messageCount: 8, isFlagged: true, isArchived: false, createdAt: "2024-06-20T10:00:00Z", messages: [{ id: "m3", content: "I'll report you if you don't refund me!", senderId: "u4", createdAt: "2024-06-22T14:00:00Z" }] },
  { id: "c3", participants: [{ id: "u2", name: "Rahul Verma" }, { id: "u7", name: "Meera Krishnan" }], productId: "p4", product: { id: "p4", name: "Navy Blue Sherwani" }, lastMessage: { id: "m4", content: "What are the measurements for the sherwani?", senderId: "u2", createdAt: "2024-06-28T09:00:00Z" }, messageCount: 5, isFlagged: false, isArchived: false, createdAt: "2024-06-27T08:00:00Z", messages: [{ id: "m4", content: "What are the measurements for the sherwani?", senderId: "u2", createdAt: "2024-06-28T09:00:00Z" }] },
];

// ── Mock Notifications ────────────────────────────────────────────────────────
export const mockNotifications: Notification[] = [
  { id: "n1", title: "New Rental Request", content: "Priya Nair wants to rent Royal Blue Lehenga", type: "rentalRequest", userId: "u1", user: { id: "u1", name: "Aanya Sharma" }, isRead: false, isArchived: false, isBroadcast: false, createdAt: "2024-06-25T10:00:00Z" },
  { id: "n2", title: "Platform Maintenance", content: "Scheduled maintenance on July 1st from 2-4 AM IST.", type: "broadcast", isRead: true, isArchived: false, isBroadcast: true, targetSegment: "all", createdAt: "2024-06-24T12:00:00Z" },
  { id: "n3", title: "Rental Approved", content: "Your rental for Pink Anarkali Set has been approved.", type: "rentalApproved", userId: "u7", user: { id: "u7", name: "Meera Krishnan" }, isRead: false, isArchived: false, isBroadcast: false, createdAt: "2024-06-23T09:00:00Z" },
  { id: "n4", title: "New Review Received", content: "Aanya Sharma left a 5-star review on Royal Blue Lehenga.", type: "review", userId: "u1", user: { id: "u1", name: "Aanya Sharma" }, isRead: true, isArchived: false, isBroadcast: false, createdAt: "2024-06-22T14:00:00Z" },
  { id: "n5", title: "Safety Announcement", content: "Please verify your ID to continue renting on Rent Zone.", type: "system", isRead: false, isArchived: false, isBroadcast: true, targetSegment: "unverified", createdAt: "2024-06-20T08:00:00Z" },
];

// ── Mock Try-Ons ──────────────────────────────────────────────────────────────
export const mockTryOns: TryOn[] = [
  { id: "t1", userId: "u3", user: { id: "u3", name: "Priya Nair" }, productId: "p1", product: { id: "p1", name: "Royal Blue Lehenga", imageURLs: [] }, resultImageURL: undefined, modelUsed: "StableDiffusion-v2", status: "completed", createdAt: "2024-06-25T10:00:00Z" },
  { id: "t2", userId: "u5", user: { id: "u5", name: "Sneha Gupta" }, productId: "p3", product: { id: "p3", name: "Pink Anarkali Set", imageURLs: [] }, resultImageURL: undefined, modelUsed: "IDM-VTON", status: "pending", createdAt: "2024-06-27T11:00:00Z" },
  { id: "t3", userId: "u7", user: { id: "u7", name: "Meera Krishnan" }, productId: "p5", product: { id: "p5", name: "Red Sequin Gown", imageURLs: [] }, resultImageURL: undefined, modelUsed: "StableDiffusion-v2", status: "flagged", createdAt: "2024-06-22T09:00:00Z" },
  { id: "t4", userId: "u1", user: { id: "u1", name: "Aanya Sharma" }, productId: "p2", product: { id: "p2", name: "Charcoal 3-Piece Suit", imageURLs: [] }, resultImageURL: undefined, modelUsed: "IDM-VTON", status: "failed", createdAt: "2024-06-20T14:00:00Z" },
];

// ── Mock Audit Logs ───────────────────────────────────────────────────────────
export const mockAuditLogs: AuditLog[] = [
  { id: "al1", action: "user_suspended", adminId: "admin1", adminName: "Super Admin", targetType: "user", targetId: "u4", targetName: "Karan Mehta", details: "Suspended for scam report", createdAt: "2024-06-15T10:30:00Z" },
  { id: "al2", action: "product_hidden", adminId: "admin1", adminName: "Super Admin", targetType: "product", targetId: "p5", targetName: "Red Sequin Gown", details: "Hidden pending investigation", createdAt: "2024-06-20T14:15:00Z" },
  { id: "al3", action: "report_marked_valid", adminId: "admin1", adminName: "Super Admin", targetType: "report", targetId: "rep1", targetName: "Report #rep1", details: "Confirmed scam activity", createdAt: "2024-06-15T11:00:00Z" },
  { id: "al4", action: "user_banned", adminId: "admin1", adminName: "Super Admin", targetType: "user", targetId: "u6", targetName: "Arjun Patel", details: "Permanently banned for harassment", createdAt: "2024-06-22T10:00:00Z" },
  { id: "al5", action: "review_flagged", adminId: "admin1", adminName: "Super Admin", targetType: "review", targetId: "rev3", targetName: "Review by Meera Krishnan", details: "Flagged for investigation", createdAt: "2024-06-20T09:30:00Z" },
  { id: "al6", action: "category_created", adminId: "admin1", adminName: "Super Admin", targetType: "category", targetId: "cat7", targetName: "Bridal Wear", details: "New category added", createdAt: "2024-06-01T08:00:00Z" },
  { id: "al7", action: "notification_sent", adminId: "admin1", adminName: "Super Admin", targetType: "notification", targetId: "n2", targetName: "Platform Maintenance", details: "Broadcast to all users", createdAt: "2024-06-24T12:05:00Z" },
];

// ── Mock KPI Data ─────────────────────────────────────────────────────────────
export const mockKpiData: KpiData = {
  totalUsers: 1248,
  activeListings: 587,
  totalRentals: 3241,
  pendingReports: 12,
  unreadChats: 34,
  totalReviews: 892,
  tryOnRequests: 178,
  monthlyRevenue: 284500,
};

// ── Mock Analytics Data ───────────────────────────────────────────────────────
export const mockAnalyticsData: AnalyticsData[] = [
  { date: "Jan", users: 120, products: 45, rentals: 88, reports: 3, reviews: 62, tryOns: 12 },
  { date: "Feb", users: 180, products: 72, rentals: 134, reports: 5, reviews: 98, tryOns: 18 },
  { date: "Mar", users: 245, products: 98, rentals: 189, reports: 8, reviews: 142, tryOns: 27 },
  { date: "Apr", users: 312, products: 125, rentals: 256, reports: 6, reviews: 198, tryOns: 35 },
  { date: "May", users: 398, products: 162, rentals: 334, reports: 9, reviews: 265, tryOns: 48 },
  { date: "Jun", users: 487, products: 198, rentals: 412, reports: 12, reviews: 334, tryOns: 62 },
  { date: "Jul", users: 523, products: 231, rentals: 478, reports: 7, reviews: 389, tryOns: 78 },
];

export const mockRevenueData = [
  { date: "Jan", revenue: 48000 },
  { date: "Feb", revenue: 72000 },
  { date: "Mar", revenue: 95000 },
  { date: "Apr", revenue: 118000 },
  { date: "May", revenue: 156000 },
  { date: "Jun", revenue: 198000 },
  { date: "Jul", revenue: 284500 },
];

export const mockCategoryData = [
  { name: "Ethnic Wear (W)", value: 145 },
  { name: "Western Wear (W)", value: 98 },
  { name: "Party Wear (W)", value: 76 },
  { name: "Formal Wear (M)", value: 112 },
  { name: "Casual Wear (M)", value: 89 },
  { name: "Ethnic Wear (M)", value: 67 },
];

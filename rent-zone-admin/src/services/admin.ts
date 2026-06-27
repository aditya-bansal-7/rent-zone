import { api } from '../lib/api';

interface PaginatedResponse<T> {
  [key: string]: any; // The main array key (e.g., users, products)
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

const toQueryString = (params: any) => {
  const query = new URLSearchParams();
  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== '') {
      query.append(key, String(value));
    }
  });
  return query.toString();
};

export const adminService = {
  dashboard: {
    getStats: () => api.get<any>('/admin/dashboard'),
  },

  users: {
    list: (params: any = {}) => api.get<PaginatedResponse<any>>(`/admin/users?${toQueryString(params)}`),
    get: (id: string) => api.get<any>(`/admin/users/${id}`),
    update: (id: string, data: any) => api.patch<any>(`/admin/users/${id}`, data),
    verify: (id: string) => api.patch<any>(`/admin/users/${id}/verify`),
    suspend: (id: string) => api.patch<any>(`/admin/users/${id}/suspend`),
    ban: (id: string) => api.patch<any>(`/admin/users/${id}/ban`),
    restore: (id: string) => api.patch<any>(`/admin/users/${id}/restore`),
  },

  products: {
    list: (params: any = {}) => api.get<PaginatedResponse<any>>(`/admin/products?${toQueryString(params)}`),
    get: (id: string) => api.get<any>(`/admin/products/${id}`),
    update: (id: string, data: any) => api.patch<any>(`/admin/products/${id}`, data),
    approve: (id: string) => api.patch<any>(`/admin/products/${id}`, { status: 'active' }),
    hide: (id: string) => api.patch<any>(`/admin/products/${id}`, { status: 'hidden' }),
    feature: (id: string) => api.patch<any>(`/admin/products/${id}`, { status: 'featured' }),
    archive: (id: string) => api.patch<any>(`/admin/products/${id}`, { status: 'archived' }),
    delete: (id: string) => api.delete<any>(`/admin/products/${id}`),
  },

  categories: {
    list: () => api.get<any[]>('/admin/categories'),
    create: (data: any) => api.post<any>('/admin/categories', data),
    update: (id: string, data: any) => api.patch<any>(`/admin/categories/${id}`, data),
    delete: (id: string) => api.delete<any>(`/admin/categories/${id}`),
  },

  rentals: {
    list: (params: any = {}) => api.get<PaginatedResponse<any>>(`/admin/rentals?${toQueryString(params)}`),
    get: (id: string) => api.get<any>(`/admin/rentals/${id}`),
    updateStatus: (id: string, status: string) => api.patch<any>(`/admin/rentals/${id}/status`, { status }),
  },

  reports: {
    list: (params: any = {}) => api.get<PaginatedResponse<any>>(`/admin/reports?${toQueryString(params)}`),
    get: (id: string) => api.get<any>(`/admin/reports/${id}`),
    resolve: (id: string) => api.patch<any>(`/admin/reports/${id}/resolve`),
    reject: (id: string) => api.patch<any>(`/admin/reports/${id}/reject`),
  },

  reviews: {
    list: (params: any = {}) => api.get<PaginatedResponse<any>>(`/admin/reviews?${toQueryString(params)}`),
    flag: (id: string) => api.patch<any>(`/admin/reviews/${id}/flag`),
    delete: (id: string) => api.delete<any>(`/admin/reviews/${id}`),
  },

  chats: {
    list: (params: any = {}) => api.get<PaginatedResponse<any>>(`/admin/chats?${toQueryString(params)}`),
    getMessages: (id: string) => api.get<any[]>(`/admin/chats/${id}/messages`),
  },

  notifications: {
    list: (params: any = {}) => api.get<PaginatedResponse<any>>(`/admin/notifications?${toQueryString(params)}`),
    broadcast: (data: any) => api.post<any>('/admin/notifications/broadcast', data),
  },

  tryons: {
    list: (params: any = {}) => api.get<PaginatedResponse<any>>(`/admin/tryons?${toQueryString(params)}`),
  },

  auditLogs: {
    list: (params: any = {}) => api.get<PaginatedResponse<any>>(`/admin/audit-logs?${toQueryString(params)}`),
  },
};

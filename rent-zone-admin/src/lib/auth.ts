import { api } from './api';

export const auth = {
  login: async (email: string, password: string) => {
    const res = await api.post<{ user: any; accessToken: string; refreshToken: string }>('/auth/login', { email, password });
    
    if (res.accessToken) {
      localStorage.setItem('admin_token', res.accessToken);
      // Set a cookie so the Next.js middleware knows we are logged in
      document.cookie = `admin_session=${res.accessToken}; max-age=86400; path=/`;
    }
    
    return res;
  },

  logout: () => {
    localStorage.removeItem('admin_token');
    document.cookie = "admin_session=; max-age=0; path=/";
  },

  getToken: () => {
    if (typeof window === 'undefined') return null;
    return localStorage.getItem('admin_token');
  },

  getMe: async () => {
    return await api.get<{ userId: string; email: string; name: string }>('/admin/me');
  }
};

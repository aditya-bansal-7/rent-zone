import { api } from './api';

interface LoginResponse {
  user: {
    id: string;
    name: string;
    email?: string;
  };
  accessToken: string;
  refreshToken: string;
}

export const auth = {
  login: async (email: string, password: string) => {
    const res = await api.post<LoginResponse>('/auth/login', { email, password });

    if (!res.accessToken) {
      throw new Error('The server did not return an access token.');
    }

    localStorage.setItem('admin_token', res.accessToken);
    const secure = window.location.protocol === 'https:' ? '; Secure' : '';
    document.cookie = `admin_session=${res.accessToken}; Max-Age=900; Path=/; SameSite=Lax${secure}`;

    return res;
  },

  logout: () => {
    localStorage.removeItem('admin_token');
    document.cookie = "admin_session=; Max-Age=0; Path=/; SameSite=Lax";
  },

  getToken: () => {
    if (typeof window === 'undefined') return null;
    return localStorage.getItem('admin_token');
  },

  getMe: async () => {
    return await api.get<{ userId: string; email: string; name: string }>('/admin/me');
  },
};

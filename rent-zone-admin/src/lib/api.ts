const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api';

class ApiError extends Error {
  constructor(public message: string, public status?: number, public data?: any) {
    super(message);
    this.name = 'ApiError';
  }
}

async function fetchWithAuth<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
  const token = typeof window !== 'undefined' ? localStorage.getItem('admin_token') : null;
  
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string>),
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    headers,
  });

  let data;
  try {
    data = await response.json();
  } catch (err) {
    // If not JSON
    if (!response.ok) {
      throw new ApiError('An error occurred while communicating with the server.', response.status);
    }
    return {} as T;
  }

  if (!response.ok || data.success === false) {
    if (response.status === 401 && typeof window !== 'undefined') {
      // Auto logout on unauthorized
      localStorage.removeItem('admin_token');
      document.cookie = "admin_session=; max-age=0; path=/";
      window.location.href = '/login';
    }
    throw new ApiError(data.message || 'API Error', response.status, data.error);
  }

  return data.data;
}

export const api = {
  get: <T>(endpoint: string, options?: RequestInit) => fetchWithAuth<T>(endpoint, { ...options, method: 'GET' }),
  post: <T>(endpoint: string, body?: any, options?: RequestInit) => fetchWithAuth<T>(endpoint, { ...options, method: 'POST', body: JSON.stringify(body) }),
  patch: <T>(endpoint: string, body?: any, options?: RequestInit) => fetchWithAuth<T>(endpoint, { ...options, method: 'PATCH', body: JSON.stringify(body) }),
  put: <T>(endpoint: string, body?: any, options?: RequestInit) => fetchWithAuth<T>(endpoint, { ...options, method: 'PUT', body: JSON.stringify(body) }),
  delete: <T>(endpoint: string, body?: any, options?: RequestInit) => fetchWithAuth<T>(endpoint, { ...options, method: 'DELETE', body: JSON.stringify(body) }),
};

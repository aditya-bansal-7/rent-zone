const API_BASE_URL = (process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000/api").replace(/\/+$/, "");

class ApiError extends Error {
  constructor(message: string, public status?: number, public data?: unknown) {
    super(message);
    this.name = "ApiError";
  }
}

interface ApiEnvelope<T> {
  success?: boolean;
  message?: string;
  data?: T;
  error?: unknown;
}

function serializeBody(body: unknown): BodyInit | undefined {
  if (typeof FormData !== "undefined" && body instanceof FormData) {
    return body;
  }

  return body === undefined ? undefined : JSON.stringify(body);
}

async function fetchWithAuth<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
  const token = typeof window !== "undefined" ? localStorage.getItem("admin_token") : null;
  const headers: Record<string, string> = {
    ...(options.headers as Record<string, string>),
  };
  const isFormData = typeof FormData !== "undefined" && options.body instanceof FormData;

  if (!isFormData) {
    headers["Content-Type"] = "application/json";
  }

  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }

  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...options,
    headers,
  });

  let data: ApiEnvelope<T>;
  try {
    data = await response.json() as ApiEnvelope<T>;
  } catch {
    throw new ApiError("The server returned an invalid response.", response.status);
  }

  if (!response.ok || data.success === false) {
    if (response.status === 401 && token && typeof window !== "undefined") {
      localStorage.removeItem("admin_token");
      document.cookie = "admin_session=; Max-Age=0; Path=/; SameSite=Lax";
      if (window.location.pathname !== "/login") {
        window.location.href = "/login";
      }
    }

    throw new ApiError(data.message || "API Error", response.status, data.error);
  }

  if (data.data === undefined) {
    throw new ApiError("The server response did not include data.", response.status);
  }

  return data.data;
}

export const api = {
  get: <T>(endpoint: string, options?: RequestInit) =>
    fetchWithAuth<T>(endpoint, { ...options, method: "GET" }),
  post: <T>(endpoint: string, body?: unknown, options?: RequestInit) =>
    fetchWithAuth<T>(endpoint, { ...options, method: "POST", body: serializeBody(body) }),
  patch: <T>(endpoint: string, body?: unknown, options?: RequestInit) =>
    fetchWithAuth<T>(endpoint, { ...options, method: "PATCH", body: serializeBody(body) }),
  put: <T>(endpoint: string, body?: unknown, options?: RequestInit) =>
    fetchWithAuth<T>(endpoint, { ...options, method: "PUT", body: serializeBody(body) }),
  delete: <T>(endpoint: string, body?: unknown, options?: RequestInit) =>
    fetchWithAuth<T>(endpoint, { ...options, method: "DELETE", body: serializeBody(body) }),
};

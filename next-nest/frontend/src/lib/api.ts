const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_URL || "/api/v1";

export interface ApiResponse<T = any> {
  statusCode: number;
  data: T;
  message?: string;
  error?: string;
}

export async function fetchFromBackend<T = any>(
  endpoint: string,
  options: RequestInit = {},
): Promise<ApiResponse<T>> {
  const url = `${API_BASE_URL}${endpoint.startsWith("/") ? endpoint : `/${endpoint}`}`;

  try {
    const response = await fetch(url, {
      ...options,
      headers: {
        "Content-Type": "application/json",
        ...options.headers,
      },
    });

    const data = await response.json();
    return {
      statusCode: response.status,
      data,
    };
  } catch (error: any) {
    return {
      statusCode: 500,
      data: null as any,
      error: error?.message || "Failed to communicate with backend service",
    };
  }
}

export async function checkBackendHealth() {
  return fetchFromBackend("/health");
}

export function getImageUrl(url?: string | null): string {
  if (!url) return "";
  let cleanUrl = url.trim();
  // Strip hardcoded localhost:3000 if present from database legacy records
  if (cleanUrl.includes("localhost:3000")) {
    cleanUrl = cleanUrl.replace(/^https?:\/\/localhost:3000/, "");
  }
  if (cleanUrl.startsWith("/")) {
    const base = (process.env.NEXT_PUBLIC_API_URL || "https://allgujaratvankarsamaj.com/api/v1").replace(/\/api\/v1\/?$/, "");
    return `${base}${cleanUrl}`;
  }
  return cleanUrl;
}


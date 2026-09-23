const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000/api/v1";

function getAuthHeaders() {
  const token = typeof window !== "undefined" ? localStorage.getItem("adminToken") || localStorage.getItem("token") : null;
  return {
    "Content-Type": "application/json",
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  };
}

export interface DashboardStats {
  totalUsers: number;
  totalProfiles: number;
  totalMatches: number;
  totalMessages: number;
  monthlyGrowth: Array<{ month: string; users: number; profiles: number }>;
  parganaBreakdown: Array<{ name: string; count: number; percentage: number }>;
  recentActivities: Array<{ id: string; icon: string; title: string; user: string; time: string; status: string }>;
  recentUsers: Array<{ id: string; name: string; email: string; phone: string; pargana: string; status: string; role: string; createdAt: string }>;
  recentVerifications: Array<{ id: string; name: string; type: string; status: string; date: string }>;
}

export interface AdminUserItem {
  id: string;
  name: string;
  email: string;
  phone?: string;
  pargana: string;
  status: string;
  role: string;
  createdAt: string;
}

export interface AdminProfileItem {
  id: string;
  userId: string;
  name: string;
  age: number;
  gender: string;
  pargana: string;
  city: string;
  education: string;
  occupation: string;
  status: string;
  isVerified: boolean;
  isFeatured: boolean;
  createdAt: string;
}

export interface ParganaItem {
  id: string;
  name: string;
  gujaratiName?: string;
  code?: string;
  description?: string;
  villageCount?: string;
  computedVillageCount?: string;
  districtRegion?: string;
  leaderName?: string;
  contactPhone?: string;
  totalCount: number;
  isActive?: boolean;
}

export interface StateItem {
  id: string;
  name: string;
  gujaratiName?: string;
  code: string;
  isActive: boolean;
  _count?: { districts: number };
}

export interface DistrictItem {
  id: string;
  stateId: string;
  name: string;
  gujaratiName?: string;
  code?: string;
  isActive: boolean;
  state?: { id: string; name: string; gujaratiName?: string };
  _count?: { talukas: number };
}

export interface TalukaItem {
  id: string;
  districtId: string;
  name: string;
  gujaratiName?: string;
  code?: string;
  isActive: boolean;
  district?: { id: string; name: string; gujaratiName?: string };
  _count?: { villages: number };
}

export interface VillageItem {
  id: string;
  parganaId?: string;
  talukaId?: string;
  name: string;
  gujaratiName?: string;
  code?: string;
  pincode?: string;
  isActive: boolean;
  pargana?: { id: string; name: string; gujaratiName?: string };
  taluka?: { id: string; name: string; gujaratiName?: string };
}

export interface SiteSettings {
  siteTitle: string;
  bannerText: string;
  contactEmail: string;
  contactPhone: string;
  registrationEnabled: boolean;
  maintenanceMode: boolean;
}

export interface SamajServiceItem {
  id: string;
  title: string;
  category?: string;
  icon?: string;
  contactPhone?: string;
  contactPerson?: string;
  description?: string;
  isActive: boolean;
  createdAt?: string;
  _count?: {
    persons: number;
  };
}

export interface SamajServicePersonItem {
  id: string;
  serviceId: string;
  name: string;
  gujaratiName?: string;
  photoUrl?: string;
  phone: string;
  address?: string;
  city?: string;
  description?: string;
  experience?: string;
  isActive: boolean;
  createdAt?: string;
  service?: {
    id: string;
    title: string;
    category?: string;
    icon?: string;
  };
}

export const adminApi = {
  async login(email: string, password: string): Promise<{ accessToken: string; user: any }> {
    const res = await fetch(`${API_BASE_URL}/auth/login`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ email, password }),
    });
    if (!res.ok) {
      const errorData = await res.json().catch(() => ({}));
      throw new Error(errorData.message || `HTTP error! status: ${res.status}`);
    }
    return await res.json();
  },

  async getDashboardStats(): Promise<DashboardStats> {
    try {
      const res = await fetch(`${API_BASE_URL}/admin/statistics/dashboard`, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) { throw error; }
  },

  async getVerifications(): Promise<any[]> {
    try {
      const res = await fetch(`${API_BASE_URL}/admin/verifications`, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) { throw error; }
  },

  async updateVerificationStatus(id: string, action: string, reason?: string) {
    const res = await fetch(`${API_BASE_URL}/admin/verifications/${id}/verify`, {
      method: "PATCH",
      headers: getAuthHeaders(),
      body: JSON.stringify({ action, reason }),
    });
    if (!res.ok) {
      const errorData = await res.json().catch(() => ({}));
      throw new Error(errorData.message || `HTTP error! status: ${res.status}`);
    }
    return await res.json();
  },

  async getUsers(): Promise<AdminUserItem[]> {
    try {
      const res = await fetch(`${API_BASE_URL}/admin/users`, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) { throw error; }
  },

  async updateUserStatus(userId: string, status: string) {
    const res = await fetch(`${API_BASE_URL}/admin/users/${userId}/status`, {
      method: "PATCH",
      headers: getAuthHeaders(),
      body: JSON.stringify({ status }),
    });
    return res.json();
  },

  async getProfiles(): Promise<AdminProfileItem[]> {
    try {
      const res = await fetch(`${API_BASE_URL}/admin/profiles`, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) { throw error; }
  },

  async updateProfileStatus(profileId: string, status: string) {
    const res = await fetch(`${API_BASE_URL}/admin/profiles/${profileId}/status`, {
      method: "PATCH",
      headers: getAuthHeaders(),
      body: JSON.stringify({ status }),
    });
    return res.json();
  },

  async toggleProfileFeatured(profileId: string, isFeatured: boolean) {
    const res = await fetch(`${API_BASE_URL}/admin/profiles/${profileId}/feature`, {
      method: "PATCH",
      headers: getAuthHeaders(),
      body: JSON.stringify({ isFeatured }),
    });
    return res.json();
  },

  async getParganas(): Promise<ParganaItem[]> {
    try {
      const res = await fetch(`${API_BASE_URL}/admin/parganas`, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) { throw error; }
  },

  async createPargana(data: Partial<ParganaItem>) {
    const res = await fetch(`${API_BASE_URL}/admin/parganas`, {
      method: "POST",
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    });
    return res.json();
  },

  async updatePargana(id: string, data: Partial<ParganaItem>) {
    const res = await fetch(`${API_BASE_URL}/admin/parganas/${id}`, {
      method: "PATCH",
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    });
    return res.json();
  },

  async deletePargana(id: string) {
    const res = await fetch(`${API_BASE_URL}/admin/parganas/${id}`, {
      method: "DELETE",
      headers: getAuthHeaders(),
    });
    return res.json();
  },

  // ==================== SAMAJ SERVICES API ====================
  async getSamajServices(): Promise<SamajServiceItem[]> {
    try {
      const res = await fetch(`${API_BASE_URL}/admin/samaj-services`, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) { throw error; }
  },

  async createSamajService(data: Partial<SamajServiceItem>) {
    const res = await fetch(`${API_BASE_URL}/admin/samaj-services`, {
      method: "POST",
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    });
    return res.json();
  },

  async updateSamajService(id: string, data: Partial<SamajServiceItem>) {
    const res = await fetch(`${API_BASE_URL}/admin/samaj-services/${id}`, {
      method: "PATCH",
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    });
    return res.json();
  },

  async deleteSamajService(id: string) {
    const res = await fetch(`${API_BASE_URL}/admin/samaj-services/${id}`, {
      method: "DELETE",
      headers: getAuthHeaders(),
    });
    return res.json();
  },

  // ==================== SAMAJ SERVICE PERSONS API ====================
  async getSamajServicePersons(serviceId?: string): Promise<SamajServicePersonItem[]> {
    try {
      const url = serviceId
        ? `${API_BASE_URL}/admin/samaj-services/persons?serviceId=${encodeURIComponent(serviceId)}`
        : `${API_BASE_URL}/admin/samaj-services/persons`;
      const res = await fetch(url, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) { throw error; }
  },

  async createSamajServicePerson(data: Partial<SamajServicePersonItem>) {
    const res = await fetch(`${API_BASE_URL}/admin/samaj-services/persons`, {
      method: "POST",
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    });
    return res.json();
  },

  async updateSamajServicePerson(id: string, data: Partial<SamajServicePersonItem>) {
    const res = await fetch(`${API_BASE_URL}/admin/samaj-services/persons/${id}`, {
      method: "PATCH",
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    });
    return res.json();
  },

  async deleteSamajServicePerson(id: string) {
    const res = await fetch(`${API_BASE_URL}/admin/samaj-services/persons/${id}`, {
      method: "DELETE",
      headers: getAuthHeaders(),
    });
    return res.json();
  },

  async getSettings(): Promise<SiteSettings> {
    try {
      const res = await fetch(`${API_BASE_URL}/admin/settings`, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) { throw error; }
  },

  async updateSettings(settings: Partial<SiteSettings>) {
    const res = await fetch(`${API_BASE_URL}/admin/settings`, {
      method: "PUT",
      headers: getAuthHeaders(),
      body: JSON.stringify(settings),
    });
    return res.json();
  },

  async getVerifications() {
    try {
      const res = await fetch(`${API_BASE_URL}/admin/verifications`, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) { throw error; }
  },

  async updateVerificationStatus(id: string, status: string, rejectionReason?: string) {
    const res = await fetch(`${API_BASE_URL}/admin/verifications/${id}`, {
      method: "PATCH",
      headers: getAuthHeaders(),
      body: JSON.stringify({ status, rejectionReason }),
    });
    return res.json();
  },

  async getReports() {
    try {
      const res = await fetch(`${API_BASE_URL}/admin/reports`, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) { throw error; }
  },

  async getMatches() {
    try {
      const res = await fetch(`${API_BASE_URL}/admin/matches`, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) { throw error; }
  },

  // ==================== LOCATION HIERARCHY API ====================
  // States
  async getAdminStates(): Promise<StateItem[]> {
    try {
      const res = await fetch(`${API_BASE_URL}/locations/admin/states`, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) { throw error; }
  },
  async createState(data: Partial<StateItem>) {
    const res = await fetch(`${API_BASE_URL}/locations/admin/states`, {
      method: "POST",
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    });
    return res.json();
  },
  async updateState(id: string, data: Partial<StateItem>) {
    const res = await fetch(`${API_BASE_URL}/locations/admin/states/${id}`, {
      method: "PATCH",
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    });
    return res.json();
  },
  async deleteState(id: string) {
    const res = await fetch(`${API_BASE_URL}/locations/admin/states/${id}`, {
      method: "DELETE",
      headers: getAuthHeaders(),
    });
    return res.json();
  },

  // Districts
  async getAdminDistricts(stateId?: string): Promise<DistrictItem[]> {
    try {
      const url = stateId
        ? `${API_BASE_URL}/locations/admin/districts?stateId=${encodeURIComponent(stateId)}`
        : `${API_BASE_URL}/locations/admin/districts`;
      const res = await fetch(url, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) { throw error; }
  },
  async createDistrict(data: Partial<DistrictItem>) {
    const res = await fetch(`${API_BASE_URL}/locations/admin/districts`, {
      method: "POST",
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    });
    return res.json();
  },
  async updateDistrict(id: string, data: Partial<DistrictItem>) {
    const res = await fetch(`${API_BASE_URL}/locations/admin/districts/${id}`, {
      method: "PATCH",
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    });
    return res.json();
  },
  async deleteDistrict(id: string) {
    const res = await fetch(`${API_BASE_URL}/locations/admin/districts/${id}`, {
      method: "DELETE",
      headers: getAuthHeaders(),
    });
    return res.json();
  },

  // Talukas
  async getAdminTalukas(districtId?: string): Promise<TalukaItem[]> {
    try {
      const url = districtId
        ? `${API_BASE_URL}/locations/admin/talukas?districtId=${encodeURIComponent(districtId)}`
        : `${API_BASE_URL}/locations/admin/talukas`;
      const res = await fetch(url, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) { throw error; }
  },
  async createTaluka(data: Partial<TalukaItem>) {
    const res = await fetch(`${API_BASE_URL}/locations/admin/talukas`, {
      method: "POST",
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    });
    return res.json();
  },
  async updateTaluka(id: string, data: Partial<TalukaItem>) {
    const res = await fetch(`${API_BASE_URL}/locations/admin/talukas/${id}`, {
      method: "PATCH",
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    });
    return res.json();
  },
  async deleteTaluka(id: string) {
    const res = await fetch(`${API_BASE_URL}/locations/admin/talukas/${id}`, {
      method: "DELETE",
      headers: getAuthHeaders(),
    });
    return res.json();
  },

  // Villages
  async getAdminVillages(params?: { parganaId?: string; talukaId?: string; search?: string }): Promise<VillageItem[]> {
    try {
      const searchParams = new URLSearchParams();
      if (params?.parganaId) searchParams.append("parganaId", params.parganaId);
      if (params?.talukaId) searchParams.append("talukaId", params.talukaId);
      if (params?.search) searchParams.append("search", params.search);

      const url = `${API_BASE_URL}/locations/admin/villages?${searchParams.toString()}`;
      const res = await fetch(url, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) { throw error; }
  },
  async createVillage(data: Partial<VillageItem>) {
    const res = await fetch(`${API_BASE_URL}/locations/admin/villages`, {
      method: "POST",
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    });
    return res.json();
  },
  async updateVillage(id: string, data: Partial<VillageItem>) {
    const res = await fetch(`${API_BASE_URL}/locations/admin/villages/${id}`, {
      method: "PATCH",
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    });
    return res.json();
  },
  async deleteVillage(id: string) {
    const res = await fetch(`${API_BASE_URL}/locations/admin/villages/${id}`, {
      method: "DELETE",
      headers: getAuthHeaders(),
    });
    return res.json();
  },
};

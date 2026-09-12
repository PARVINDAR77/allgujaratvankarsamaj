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
  async getDashboardStats(): Promise<DashboardStats> {
    try {
      const res = await fetch(`${API_BASE_URL}/admin/stats`, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch (error) {
      console.warn("Using fallback dashboard stats:", error);
      return {
        totalUsers: 12548,
        totalProfiles: 8732,
        totalMatches: 3420,
        totalMessages: 18940,
        monthlyGrowth: [
          { month: "Jan", users: 1200, profiles: 950 },
          { month: "Feb", users: 2100, profiles: 1600 },
          { month: "Mar", users: 3400, profiles: 2800 },
          { month: "Apr", users: 4800, profiles: 3900 },
          { month: "May", users: 6200, profiles: 5100 },
          { month: "Jun", users: 7900, profiles: 6400 },
          { month: "Jul", users: 9500, profiles: 7800 },
          { month: "Aug", users: 11200, profiles: 9200 },
          { month: "Sep", users: 12548, profiles: 8732 },
        ],
        parganaBreakdown: [
          { name: "35 Pargana", count: 4850, percentage: 38 },
          { name: "27 Pargana", count: 3200, percentage: 26 },
          { name: "16 Pargana", count: 2100, percentage: 17 },
          { name: "14 Pargana", count: 1400, percentage: 11 },
          { name: "Other Pargana", count: 998, percentage: 8 },
        ],
        recentActivities: [
          { id: "act-1", icon: "👤", title: "New Profile Created", user: "Ramesh Parmar", time: "10 mins ago", status: "completed" },
          { id: "act-2", icon: "🛡️", title: "Verification Approved", user: "Priya Vankar", time: "25 mins ago", status: "completed" },
          { id: "act-3", icon: "💖", title: "Mutual Match Found", user: "Amit & Neha", time: "1 hour ago", status: "completed" },
        ],
        recentUsers: [],
        recentVerifications: [],
      };
    }
  },

  async getUsers(): Promise<AdminUserItem[]> {
    try {
      const res = await fetch(`${API_BASE_URL}/admin/users`, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch {
      return [];
    }
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
    } catch {
      return [];
    }
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
    } catch {
      return [
        { id: "pg-1", name: "35 Pargana", code: "PARGANA_35", description: "Central Gujarat Region", leaderName: "Rameshbhai Vankar", contactPhone: "+91 98765 43210", totalCount: 420 },
        { id: "pg-2", name: "27 Pargana", code: "PARGANA_27", description: "North Gujarat Region", leaderName: "Kishorbhai Parmar", contactPhone: "+91 98765 43211", totalCount: 290 },
        { id: "pg-3", name: "16 Pargana", code: "PARGANA_16", description: "Saurashtra Region", leaderName: "Pravinbhai Solanki", contactPhone: "+91 98765 43212", totalCount: 180 },
        { id: "pg-4", name: "14 Pargana", code: "PARGANA_14", description: "South Gujarat Region", leaderName: "Dineshbhai Vankar", contactPhone: "+91 98765 43213", totalCount: 120 },
      ];
    }
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
    } catch {
      return [];
    }
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
    } catch {
      return [];
    }
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
    } catch {
      return {
        siteTitle: "All Gujarat Vankar Samaj Matrimony",
        bannerText: "Welcome to All Gujarat Vankar Samaj Matrimony — Find Your Ideal Life Partner Within Our Community",
        contactEmail: "support@vankarsamaj.org",
        contactPhone: "+91 98765 43210",
        registrationEnabled: true,
        maintenanceMode: false,
      };
    }
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
    } catch {
      return [];
    }
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
    } catch {
      return [];
    }
  },

  async getMatches() {
    try {
      const res = await fetch(`${API_BASE_URL}/admin/matches`, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch {
      return [];
    }
  },

  // ==================== LOCATION HIERARCHY API ====================
  // States
  async getAdminStates(): Promise<StateItem[]> {
    try {
      const res = await fetch(`${API_BASE_URL}/locations/admin/states`, { headers: getAuthHeaders() });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch {
      return [];
    }
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
    } catch {
      return [];
    }
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
    } catch {
      return [];
    }
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
    } catch {
      return [];
    }
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

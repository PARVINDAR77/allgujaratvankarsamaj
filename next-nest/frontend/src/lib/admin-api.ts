const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000/api/v1";

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

export const adminApi = {
  async getDashboardStats(): Promise<DashboardStats> {
    try {
      const token = typeof window !== "undefined" ? localStorage.getItem("adminToken") || localStorage.getItem("token") : null;
      const res = await fetch(`${API_BASE_URL}/admin/stats`, {
        headers: {
          "Content-Type": "application/json",
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
      });
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
          { id: "act-1", icon: "user-plus", title: "New Member Registered", user: "Vikram Vankar", time: "5 mins ago", status: "success" },
          { id: "act-2", icon: "shield-check", title: "Profile Verified", user: "Hiral Parmar", time: "22 mins ago", status: "info" },
          { id: "act-3", icon: "heart", title: "New Match Expressed", user: "Ramesh Solanki & Priya Vankar", time: "1 hour ago", status: "warning" },
          { id: "act-4", icon: "image", title: "New Photo Uploaded", user: "Karan Vankar", time: "2 hours ago", status: "info" },
          { id: "act-5", icon: "file-text", title: "Family Details Updated", user: "Maheshkumar Vankar", time: "4 hours ago", status: "success" },
        ],
        recentUsers: [
          { id: "u-1", name: "Ramesh Vankar", email: "ramesh@vankar.org", phone: "9876543210", pargana: "35 Pargana", status: "ACTIVE", role: "USER", createdAt: new Date().toISOString() },
          { id: "u-2", name: "Hiralben Parmar", email: "hiral@vankar.org", phone: "9876543211", pargana: "27 Pargana", status: "ACTIVE", role: "USER", createdAt: new Date().toISOString() },
          { id: "u-3", name: "Hemantkumar Vankar", email: "hemant@vankar.org", phone: "9876543212", pargana: "16 Pargana", status: "ACTIVE", role: "USER", createdAt: new Date().toISOString() },
          { id: "u-4", name: "Priyankaben Solanki", email: "priyanka@vankar.org", phone: "9876543213", pargana: "14 Pargana", status: "PENDING", role: "USER", createdAt: new Date().toISOString() },
          { id: "u-5", name: "Vijaykumar Vankar", email: "vijay@vankar.org", phone: "9876543214", pargana: "35 Pargana", status: "ACTIVE", role: "USER", createdAt: new Date().toISOString() },
        ],
        recentVerifications: [
          { id: "ver-1", name: "Hemantkumar Vankar", type: "ID Proof & Photo", status: "VERIFIED", date: "2026-09-09" },
          { id: "ver-2", name: "Hiralben Parmar", type: "Family Contact", status: "VERIFIED", date: "2026-09-09" },
          { id: "ver-3", name: "Mehul Vankar", type: "Education Certificate", status: "PENDING", date: "2026-09-10" },
          { id: "ver-4", name: "Aarti Vankar", type: "Profile Photo", status: "PENDING", date: "2026-09-10" },
        ],
      };
    }
  },

  async getUsers(): Promise<AdminUserItem[]> {
    try {
      const token = typeof window !== "undefined" ? localStorage.getItem("adminToken") || localStorage.getItem("token") : null;
      const res = await fetch(`${API_BASE_URL}/admin/users`, {
        headers: {
          "Content-Type": "application/json",
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
      });
      if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
      return await res.json();
    } catch {
      return [
        { id: "u-1", name: "Ramesh Vankar", email: "ramesh@vankar.org", phone: "9876543210", pargana: "35 Pargana", status: "ACTIVE", role: "USER", createdAt: "2026-09-01" },
        { id: "u-2", name: "Hiralben Parmar", email: "hiral@vankar.org", phone: "9876543211", pargana: "27 Pargana", status: "ACTIVE", role: "USER", createdAt: "2026-09-02" },
        { id: "u-3", name: "Hemantkumar Vankar", email: "hemant@vankar.org", phone: "9876543212", pargana: "16 Pargana", status: "ACTIVE", role: "USER", createdAt: "2026-09-03" },
        { id: "u-4", name: "Priyankaben Solanki", email: "priyanka@vankar.org", phone: "9876543213", pargana: "14 Pargana", status: "INACTIVE", role: "USER", createdAt: "2026-09-04" },
        { id: "u-5", name: "Admin Officer", email: "admin@vankarsamaj.org", phone: "9998887770", pargana: "35 Pargana", status: "ACTIVE", role: "ADMIN", createdAt: "2026-09-05" },
      ];
    }
  },
};

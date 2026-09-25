"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { adminApi, AdminUserItem } from "@/lib/admin-api";

export default function AdminUsersPage() {
  const [users, setUsers] = useState<AdminUserItem[]>([]);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const data = await adminApi.getUsers();
      setUsers(data || []);
      setError(null);
    } catch (err: any) {
      console.error(err);
      setError(err.message || "Failed to load users");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const formatName = (n: string, e?: string) => {
    if (!n || (n.includes("-") && n.length > 20)) {
      if (e && e.includes("@")) {
        return e.split("@")[0].replace(/[0-9]/g, " ").trim() || "Member Candidate";
      }
      return "Community Member";
    }
    return n;
  };

  const filteredUsers = users.filter((u) => {
    const matchesSearch =
      u.name.toLowerCase().includes(search.toLowerCase()) ||
      u.email.toLowerCase().includes(search.toLowerCase()) ||
      u.pargana.toLowerCase().includes(search.toLowerCase());
    const matchesStatus = statusFilter === "ALL" || u.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const toggleUserStatus = async (id: string, currentStatus: string) => {
    const newStatus = currentStatus === "ACTIVE" ? "INACTIVE" : "ACTIVE";
    try {
      await adminApi.updateUserStatus(id, newStatus);
      setUsers((prev) =>
        prev.map((u) => (u.id === id ? { ...u, status: newStatus as any } : u))
      );
    } catch (err: any) {
      alert("Failed to update status: " + err.message);
    }
  };

  const promoteToAdmin = async (id: string, currentRole: string) => {
    if (currentRole === "ADMIN" || currentRole === "SUPER_ADMIN") return;
    try {
      await adminApi.updateUserRole(id, "ADMIN");
      fetchUsers(); // Re-fetch to get updated role
    } catch (err: any) {
      alert("Failed to promote user: " + err.message);
    }
  };

  return (
    <AdminLayout title="User Management" subtitle="Manage registered community members & access statuses">
      <div  className="flex flex-col gap-6">
        {error && (
          <div   className="rounded-xl bg-red-500/10 text-red-300 border border-red-600 p-4" >
            {error}
          </div>
        )}

        {/* Search & Filter Header */}
        <div
            className="flex justify-between items-center flex-wrap border border-admin-gold/25 gap-4 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.4)] backdrop-blur-md bg-admin-bg-glass py-[18px] px-6" 
        >
          <div  className="flex items-center flex-wrap gap-[14px]">
            <div   className="relative min-w-[260px]" >
              <input
                type="text"
                placeholder="Search candidate name, email, pargana..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                style={{
                  width: "100%",
                  backgroundColor: "#041026",
                  border: "1px solid rgba(212, 175, 55, 0.35)",
                  borderRadius: "12px",
                  padding: "10px 14px 10px 38px",
                  fontSize: "12px",
                  color: "#FFFFFF",
                  outline: "none",
                }}
              />
              <span   className="absolute text-admin-muted text-[13px] left-3 top-[11px]" >
                🔍
              </span>
            </div>

            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              style={{
                backgroundColor: "#041026",
                border: "1px solid rgba(212, 175, 55, 0.35)",
                borderRadius: "12px",
                padding: "10px 16px",
                fontSize: "12px",
                color: "#D4AF37",
                fontWeight: 700,
                outline: "none",
                cursor: "pointer",
              }}
            >
              <option value="ALL">All Statuses</option>
              <option value="ACTIVE">ACTIVE Only</option>
              <option value="INACTIVE">INACTIVE Only</option>
              <option value="PENDING">PENDING Only</option>
            </select>
          </div>
        </div>

        {/* Users Data Table */}
        <div
            className="border border-admin-gold/25 p-6 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.4)] backdrop-blur-md bg-admin-bg-glass" 
        >
          {loading ? (
            <div   className="flex justify-center items-center text-center font-bold text-admin-gold text-sm gap-[10px] py-12 px-0" >
              <span className="animate-spin">⚙️</span>
              <span>Loading user records...</span>
            </div>
          ) : (
            <div  className="overflow-hidden border border-admin-gold/20 rounded-xl">
              <table  className="w-full text-left border-collapse text-white text-xs">
                <thead>
                  <tr  className="bg-admin-card border-b border-admin-gold/30">
                    <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Member Name</th>
                    <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Email Address</th>
                    <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Phone Number</th>
                    <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Pargana</th>
                    <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Role</th>
                    <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Status</th>
                    <th   className="text-right font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Actions</th>
                  </tr>
                </thead>
                <tbody  className="bg-admin-card">
                  {filteredUsers.map((u) => {
                    const displayName = formatName(u.name, u.email);
                    return (
                      <tr key={u.id}  className="hover:bg-admin-card/70 transition-colors border-b border-admin-gold/10">
                        <td  className="font-bold text-white py-[14px] px-[18px]">
                          <div  className="flex items-center gap-[10px]">
                            <div
                                style={{ background: "linear-gradient(135deg, rgba(212, 175, 55, 0.3) 0%, rgba(243, 229, 171, 0.1) 100%)" }} className="flex justify-center items-center font-extrabold shrink-0 rounded-full text-admin-gold text-xs border border-admin-gold/40 w-8 h-8" 
                            >
                              {displayName.charAt(0).toUpperCase()}
                            </div>
                            <span   className="overflow-hidden whitespace-nowrap text-ellipsis max-w-[160px]" >
                              {displayName}
                            </span>
                          </div>
                        </td>
                        <td   className="text-admin-muted text-[11px] py-[14px] px-[18px] font-mono" >
                          {u.email}
                        </td>
                        <td   className="text-admin-muted-lighter text-[11px] py-[14px] px-[18px] font-mono" >
                          {u.phone || "—"}
                        </td>
                        <td  className="font-semibold text-white py-[14px] px-[18px]">{u.pargana}</td>
                        <td  className="font-extrabold text-admin-gold text-[11px] py-[14px] px-[18px]">{u.role}</td>
                        <td  className="py-[14px] px-[18px]">
                          <StatusBadge status={u.status} />
                        </td>
                        <td  className="text-right py-[14px] px-[18px]">
                          <div  className="flex justify-end gap-2">
                            {u.role === "USER" && (
                              <button
                                onClick={() => promoteToAdmin(u.id, u.role)}
                                style={{
                                  padding: "6px 14px",
                                  borderRadius: "8px",
                                  fontSize: "11px",
                                  fontWeight: 800,
                                  cursor: "pointer",
                                  backgroundColor: "rgba(212, 175, 55, 0.1)",
                                  color: "#D4AF37",
                                  border: "1px solid rgba(212, 175, 55, 0.4)",
                                }}
                                className="transition-all"
                              >
                                Promote
                              </button>
                            )}
                            <button
                              onClick={() => toggleUserStatus(u.id, u.status)}
                              style={{
                                padding: "6px 14px",
                                borderRadius: "8px",
                                fontSize: "11px",
                                fontWeight: 800,
                                cursor: "pointer",
                                backgroundColor: u.status === "ACTIVE" ? "rgba(136, 19, 55, 0.6)" : "rgba(6, 78, 59, 0.6)",
                                color: u.status === "ACTIVE" ? "#FDA4AF" : "#6EE7B7",
                                border: u.status === "ACTIVE" ? "1px solid rgba(244, 63, 94, 0.4)" : "1px solid rgba(16, 185, 129, 0.4)",
                              }}
                              className="transition-all"
                            >
                              {u.status === "ACTIVE" ? "Suspend" : "Activate"}
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}

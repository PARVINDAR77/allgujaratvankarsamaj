"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { adminApi, AdminUserItem } from "@/lib/admin-api";

export default function AdminAdminsPage() {
  const [admins, setAdmins] = useState<AdminUserItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    adminApi.getUsers()
      .then((data) => {
        const users = Array.isArray(data) ? data : (data as any).items || [];
        // Filter out normal users, keep only admins
        const adminUsers = users.filter((u: AdminUserItem) => u.role === "ADMIN" || u.role === "SUPER_ADMIN" || u.role === "VERIFICATION_ADMIN" || u.role === "MODERATOR");
        setAdmins(adminUsers);
        setError(null);
      })
      .catch((err) => {
        console.error("Admins fetch error:", err);
        setError(err.message || "Failed to load admin accounts");
      })
      .finally(() => setLoading(false));
  }, []);

  return (
    <AdminLayout title="Admin User Management" subtitle="Manage administrator staff & role permissions">
      <div className="bg-admin-border border border-admin-gold-dark/30 rounded-2xl p-6 shadow-xl space-y-4">
        <div className="flex justify-between items-center">
          <h3 className="text-base font-bold text-white">Administrator Accounts</h3>
          <button className="px-4 py-2 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#E8C95A] text-black font-bold text-xs uppercase cursor-pointer hover:brightness-110">
            + Create New Admin
          </button>
        </div>

        {error && (
          <div className="rounded-xl bg-red-500/10 text-red-300 border border-red-600 p-4">
            {error}
          </div>
        )}

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-white">
            <thead className="bg-admin-card text-admin-gold uppercase text-[10px] tracking-wider border-b border-admin-gold-dark/30">
              <tr>
                <th className="py-3 px-4">Name</th>
                <th className="py-3 px-4">Email</th>
                <th className="py-3 px-4">Role</th>
                <th className="py-3 px-4 text-right">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#997D20]/10">
              {loading ? (
                <tr>
                  <td colSpan={4} className="py-8 text-center text-admin-muted font-bold">
                    <span className="animate-spin inline-block mr-2">⚙️</span>
                    Loading administrators...
                  </td>
                </tr>
              ) : admins.length === 0 ? (
                <tr>
                  <td colSpan={4} className="py-8 text-center text-admin-muted">
                    No administrators found.
                  </td>
                </tr>
              ) : (
                admins.map((a) => (
                  <tr key={a.id} className="hover:bg-admin-card/50 transition-colors">
                    <td className="py-3.5 px-4 font-bold text-white">{a.name}</td>
                    <td className="py-3.5 px-4 text-admin-muted-light">{a.email}</td>
                    <td className="py-3.5 px-4 font-extrabold text-admin-gold">{a.role}</td>
                    <td className="py-3.5 px-4 text-right"><StatusBadge status={a.status} /></td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  );
}

"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { adminApi, AdminUserItem } from "@/lib/admin-api";

export default function AdminUsersPage() {
  const [users, setUsers] = useState<AdminUserItem[]>([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    adminApi.getUsers().then((data) => {
      setUsers(data);
      setLoading(false);
    });
  }, []);

  const filteredUsers = users.filter(
    (u) =>
      u.name.toLowerCase().includes(search.toLowerCase()) ||
      u.email.toLowerCase().includes(search.toLowerCase()) ||
      u.pargana.toLowerCase().includes(search.toLowerCase())
  );

  const toggleUserStatus = (id: string) => {
    setUsers((prev) =>
      prev.map((u) =>
        u.id === id ? { ...u, status: u.status === "ACTIVE" ? "INACTIVE" : "ACTIVE" } : u
      )
    );
  };

  return (
    <AdminLayout title="User Management" subtitle="Manage registered community members & access statuses">
      <div className="space-y-6">
        {/* Search & Filter Header */}
        <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-4 flex flex-col sm:flex-row justify-between items-center gap-4">
          <div className="relative w-full sm:w-80">
            <input
              type="text"
              placeholder="Search by name, email, pargana..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl px-4 py-2.5 pl-10 text-xs text-white placeholder-[#AAB7C8]/60 focus:outline-none focus:border-[#D4AF37]"
            />
            <span className="absolute left-3 top-3 text-xs text-[#AAB7C8]">🔍</span>
          </div>

          <button className="w-full sm:w-auto px-4 py-2.5 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#E8C95A] text-black font-bold text-xs tracking-wider uppercase shadow-md hover:opacity-95">
            + Add New User
          </button>
        </div>

        {/* Users Data Table */}
        <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl">
          {loading ? (
            <div className="py-12 text-center text-[#D4AF37] font-bold text-sm">
              Loading user records...
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs text-white">
                <thead className="bg-[#041026] text-[#D4AF37] uppercase text-[10px] tracking-wider border-b border-[#997D20]/30">
                  <tr>
                    <th className="py-3 px-4">Name</th>
                    <th className="py-3 px-4">Email</th>
                    <th className="py-3 px-4">Phone</th>
                    <th className="py-3 px-4">Pargana</th>
                    <th className="py-3 px-4">Role</th>
                    <th className="py-3 px-4">Status</th>
                    <th className="py-3 px-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#997D20]/10">
                  {filteredUsers.map((u) => (
                    <tr key={u.id} className="hover:bg-[#041026]/50 transition-colors">
                      <td className="py-3.5 px-4 font-bold text-white">{u.name}</td>
                      <td className="py-3.5 px-4 text-[#AAB7C8]">{u.email}</td>
                      <td className="py-3.5 px-4 text-gray-300">{u.phone || "—"}</td>
                      <td className="py-3.5 px-4 text-white font-medium">{u.pargana}</td>
                      <td className="py-3.5 px-4 font-semibold text-[#D4AF37]">{u.role}</td>
                      <td className="py-3.5 px-4">
                        <StatusBadge status={u.status} />
                      </td>
                      <td className="py-3.5 px-4 text-right space-x-2">
                        <button
                          onClick={() => toggleUserStatus(u.id)}
                          className={`px-2.5 py-1 rounded text-[10px] font-bold border transition-colors ${
                            u.status === "ACTIVE"
                              ? "bg-rose-950/60 text-rose-400 border-rose-500/40 hover:bg-rose-900"
                              : "bg-emerald-950/60 text-emerald-400 border-emerald-500/40 hover:bg-emerald-900"
                          }`}
                        >
                          {u.status === "ACTIVE" ? "Suspend" : "Activate"}
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}

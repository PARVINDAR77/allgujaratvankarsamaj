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
  const [showAddModal, setShowAddModal] = useState(false);

  // New user form state
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [pargana, setPargana] = useState("35 Pargana");
  const [role, setRole] = useState("USER");

  useEffect(() => {
    adminApi.getUsers().then((data) => {
      setUsers(data);
      setLoading(false);
    });
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

  const toggleUserStatus = (id: string) => {
    setUsers((prev) =>
      prev.map((u) =>
        u.id === id ? { ...u, status: u.status === "ACTIVE" ? "INACTIVE" : "ACTIVE" } : u
      )
    );
  };

  const handleAddUser = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email) return;

    const newUser: AdminUserItem = {
      id: `u-${Date.now()}`,
      name: name || email.split("@")[0],
      email,
      phone: phone || "9876543210",
      pargana,
      status: "ACTIVE",
      role: role as any,
      createdAt: new Date().toISOString(),
    };

    setUsers([newUser, ...users]);
    setShowAddModal(false);
    setName("");
    setEmail("");
    setPhone("");
  };

  return (
    <AdminLayout title="User Management" subtitle="Manage registered community members & access statuses">
      <div className="space-y-6">
        {/* Search & Filter Header */}
        <div className="bg-[#0F2040] border border-[#997D20]/40 rounded-2xl p-4 flex flex-col sm:flex-row justify-between items-center gap-4 shadow-xl">
          <div className="flex flex-col sm:flex-row items-center gap-3 w-full sm:w-auto">
            <div className="relative w-full sm:w-72">
              <input
                type="text"
                placeholder="Search candidate name, email, pargana..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl px-4 py-2.5 pl-10 text-xs text-white placeholder-[#AAB7C8]/60 focus:outline-none focus:border-[#D4AF37]"
              />
              <span className="absolute left-3 top-3 text-xs text-[#AAB7C8]">🔍</span>
            </div>

            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="bg-[#041026] border border-[#997D20]/40 rounded-xl px-3 py-2.5 text-xs text-[#D4AF37] font-bold focus:outline-none"
            >
              <option value="ALL">All Statuses</option>
              <option value="ACTIVE">ACTIVE Only</option>
              <option value="INACTIVE">INACTIVE Only</option>
              <option value="PENDING">PENDING Only</option>
            </select>
          </div>

          <button
            onClick={() => setShowAddModal(true)}
            className="w-full sm:w-auto px-5 py-2.5 rounded-xl bg-gradient-to-r from-[#D4AF37] via-[#F3E5AB] to-[#E8C95A] text-black font-extrabold text-xs tracking-wider uppercase shadow-md hover:brightness-110 transition-all flex items-center justify-center gap-2"
          >
            <span>➕</span>
            <span>Add New Member</span>
          </button>
        </div>

        {/* Users Data Table */}
        <div className="bg-[#0F2040] border border-[#997D20]/40 rounded-2xl p-6 shadow-xl">
          {loading ? (
            <div className="py-12 text-center text-[#D4AF37] font-bold text-sm flex justify-center items-center gap-2">
              <span className="animate-spin">⚙️</span>
              <span>Loading user records...</span>
            </div>
          ) : (
            <div className="overflow-x-auto rounded-xl border border-[#997D20]/30">
              <table className="w-full text-left text-xs text-white border-collapse">
                <thead className="bg-[#041026] text-[#D4AF37] uppercase text-[10px] tracking-wider border-b border-[#997D20]/40">
                  <tr>
                    <th className="py-3.5 px-4 font-extrabold min-w-[160px]">Member Name</th>
                    <th className="py-3.5 px-4 font-extrabold min-w-[180px]">Email Address</th>
                    <th className="py-3.5 px-4 font-extrabold min-w-[120px]">Phone Number</th>
                    <th className="py-3.5 px-4 font-extrabold min-w-[110px]">Pargana</th>
                    <th className="py-3.5 px-4 font-extrabold min-w-[90px]">Role</th>
                    <th className="py-3.5 px-4 font-extrabold min-w-[100px]">Status</th>
                    <th className="py-3.5 px-4 font-extrabold text-right min-w-[120px]">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#997D20]/15 bg-[#0F2040]">
                  {filteredUsers.map((u) => {
                    const displayName = formatName(u.name, u.email);
                    return (
                      <tr key={u.id} className="hover:bg-[#041026]/70 transition-colors">
                        <td className="py-3.5 px-4 font-bold text-white">
                          <div className="flex items-center gap-2.5">
                            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-[#D4AF37]/30 to-[#E8C95A]/10 text-[#D4AF37] flex items-center justify-center font-black text-xs border border-[#D4AF37]/50 shadow-inner">
                              {displayName.charAt(0).toUpperCase()}
                            </div>
                            <span className="truncate max-w-[150px]">{displayName}</span>
                          </div>
                        </td>
                        <td className="py-3.5 px-4 text-[#AAB7C8] font-mono text-[11px] truncate max-w-[180px]">{u.email}</td>
                        <td className="py-3.5 px-4 text-gray-300 font-mono text-[11px]">{u.phone || "—"}</td>
                        <td className="py-3.5 px-4 text-white font-semibold">{u.pargana}</td>
                        <td className="py-3.5 px-4 font-extrabold text-[#D4AF37] text-[11px]">{u.role}</td>
                        <td className="py-3.5 px-4">
                          <StatusBadge status={u.status} />
                        </td>
                        <td className="py-3.5 px-4 text-right space-x-2">
                          <button
                            onClick={() => toggleUserStatus(u.id)}
                            className={`px-3 py-1.5 rounded-lg text-[10px] font-extrabold border transition-all ${
                              u.status === "ACTIVE"
                                ? "bg-rose-950/80 text-rose-300 border-rose-500/50 hover:bg-rose-800"
                                : "bg-emerald-950/80 text-emerald-300 border-emerald-500/50 hover:bg-emerald-800"
                            }`}
                          >
                            {u.status === "ACTIVE" ? "Suspend" : "Activate"}
                          </button>
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

      {/* Add New Member Modal */}
      {showAddModal && (
        <div className="fixed inset-0 bg-black/80 z-50 flex items-center justify-center p-4">
          <div className="bg-[#0F2040] border-2 border-[#D4AF37] rounded-2xl p-6 w-full max-w-md shadow-2xl space-y-4">
            <div className="flex justify-between items-center border-b border-[#997D20]/30 pb-3">
              <h3 className="text-base font-extrabold text-[#D4AF37] flex items-center gap-2">
                <span>➕</span> Add New Candidate Member
              </h3>
              <button
                onClick={() => setShowAddModal(false)}
                className="text-white hover:text-[#D4AF37] font-bold text-lg"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleAddUser} className="space-y-3.5 text-xs text-white">
              <div>
                <label className="block text-[#AAB7C8] mb-1 font-semibold">Candidate Full Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Ramesh Vankar"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl p-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-[#D4AF37]"
                />
              </div>

              <div>
                <label className="block text-[#AAB7C8] mb-1 font-semibold">Email Address</label>
                <input
                  type="email"
                  required
                  placeholder="e.g. candidate@vankarsamaj.org"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl p-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-[#D4AF37]"
                />
              </div>

              <div>
                <label className="block text-[#AAB7C8] mb-1 font-semibold">Phone Number</label>
                <input
                  type="text"
                  placeholder="e.g. 9876543210"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl p-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-[#D4AF37]"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-[#AAB7C8] mb-1 font-semibold">Pargana Region</label>
                  <select
                    value={pargana}
                    onChange={(e) => setPargana(e.target.value)}
                    className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl p-2.5 text-[#D4AF37] font-bold focus:outline-none"
                  >
                    <option value="35 Pargana">35 Pargana</option>
                    <option value="27 Pargana">27 Pargana</option>
                    <option value="16 Pargana">16 Pargana</option>
                    <option value="14 Pargana">14 Pargana</option>
                    <option value="Other Pargana">Other Pargana</option>
                  </select>
                </div>

                <div>
                  <label className="block text-[#AAB7C8] mb-1 font-semibold">Role</label>
                  <select
                    value={role}
                    onChange={(e) => setRole(e.target.value)}
                    className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl p-2.5 text-[#D4AF37] font-bold focus:outline-none"
                  >
                    <option value="USER">USER</option>
                    <option value="ADMIN">ADMIN</option>
                  </select>
                </div>
              </div>

              <div className="pt-3 flex gap-3">
                <button
                  type="button"
                  onClick={() => setShowAddModal(false)}
                  className="flex-1 py-2.5 rounded-xl bg-[#041026] text-gray-300 font-bold border border-[#997D20]/30 hover:bg-[#08152B]"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 py-2.5 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#E8C95A] text-black font-extrabold shadow-md hover:brightness-110"
                >
                  Save Candidate
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}


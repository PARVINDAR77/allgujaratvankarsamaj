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
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [newUserData, setNewUserData] = useState({
    name: "",
    email: "",
    phone: "",
    gender: "Male",
    password: "",
  });

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

  const handleDeleteUser = async (id: string, name: string) => {
    if (confirm(`Are you sure you want to permanently delete user "${name}"?`)) {
      try {
        await adminApi.deleteUser(id);
        setUsers(users.filter((u) => u.id !== id));
      } catch (err) {
        alert("Failed to delete user.");
      }
    }
  };

  const handleCreateUser = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL || "/api/v1"}/auth/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: newUserData.name.trim(),
          email: newUserData.email.trim(),
          phone: newUserData.phone.trim(),
          gender: newUserData.gender,
          password: newUserData.password,
        }),
      });
      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.message || "Failed to register candidate");
      }
      setIsModalOpen(false);
      setNewUserData({ name: "", email: "", phone: "", gender: "Male", password: "" });
      fetchUsers();
    } catch (err: any) {
      alert("Error registering candidate: " + err.message);
    } finally {
      setSubmitting(false);
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

          <button
            onClick={() => setIsModalOpen(true)}
            style={{
              padding: "10px 20px",
              borderRadius: "12px",
              background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
              color: "#041026",
              fontWeight: 800,
              fontSize: "12px",
              textTransform: "uppercase",
              letterSpacing: "0.8px",
              border: "none",
              cursor: "pointer",
              boxShadow: "0 4px 14px rgba(212, 175, 55, 0.4)",
            }}
            className="hover:brightness-110 transition-all flex items-center gap-1.5"
          >
            <span>+</span>
            <span>Add Candidate</span>
          </button>
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
                        <td style={{ padding: "14px 18px", textAlign: "right" }}>
                          <div style={{ display: "flex", justifyContent: "flex-end", gap: "8px" }}>
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
                            <button
                              onClick={() => handleDeleteUser(u.id, displayName)}
                              style={{
                                padding: "6px 14px",
                                borderRadius: "8px",
                                fontSize: "11px",
                                fontWeight: 800,
                                cursor: "pointer",
                                backgroundColor: "rgba(220, 38, 38, 0.15)",
                                color: "#EF4444",
                                border: "1px solid rgba(220, 38, 38, 0.3)",
                              }}
                              className="hover:bg-red-500/30 transition-all"
                            >
                              Delete
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

      {/* ─── ADD CANDIDATE MODAL ────────────────────────────────────── */}
      {isModalOpen && (
        <div style={{
          position: "fixed",
          top: 0, left: 0, right: 0, bottom: 0,
          backgroundColor: "rgba(4, 16, 38, 0.8)",
          backdropFilter: "blur(8px)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          zIndex: 9999,
          padding: "20px"
        }}>
          <div style={{
            backgroundColor: "#0D1B32",
            border: "1px solid rgba(212, 175, 55, 0.4)",
            borderRadius: "20px",
            width: "100%",
            maxWidth: "520px",
            boxShadow: "0 20px 50px rgba(0,0,0,0.6)",
            overflow: "hidden"
          }}>
            <div style={{
              padding: "20px 24px",
              borderBottom: "1px solid rgba(212, 175, 55, 0.2)",
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center"
            }}>
              <h3 style={{ margin: 0, color: "#FFFFFF", fontSize: "16px", fontWeight: 800, display: "flex", alignItems: "center", gap: "8px" }}>
                <span>👤</span> Add New Community Candidate
              </h3>
              <button 
                onClick={() => setIsModalOpen(false)}
                style={{ background: "none", border: "none", color: "#8E9BAE", fontSize: "20px", cursor: "pointer", padding: "4px" }}
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleCreateUser} style={{ padding: "24px", display: "flex", flexDirection: "column", gap: "16px" }}>
              <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
                <label style={{ fontSize: "11px", color: "#D4AF37", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1px" }}>Full Name</label>
                <input 
                  required
                  type="text" 
                  placeholder="e.g. Ramesh Vankar"
                  value={newUserData.name} 
                  onChange={e => setNewUserData({...newUserData, name: e.target.value})}
                  style={{ width: "100%", background: "rgba(4, 16, 38, 0.6)", border: "1px solid rgba(212, 175, 55, 0.3)", borderRadius: "8px", padding: "10px 14px", color: "#FFFFFF", fontSize: "13px", outline: "none" }} 
                />
              </div>

              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "16px" }}>
                <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
                  <label style={{ fontSize: "11px", color: "#D4AF37", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1px" }}>Email Address</label>
                  <input 
                    required
                    type="email" 
                    placeholder="user@example.com"
                    value={newUserData.email} 
                    onChange={e => setNewUserData({...newUserData, email: e.target.value})}
                    style={{ width: "100%", background: "rgba(4, 16, 38, 0.6)", border: "1px solid rgba(212, 175, 55, 0.3)", borderRadius: "8px", padding: "10px 14px", color: "#FFFFFF", fontSize: "13px", outline: "none" }} 
                  />
                </div>
                <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
                  <label style={{ fontSize: "11px", color: "#D4AF37", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1px" }}>Phone (10 Digits)</label>
                  <input 
                    required
                    type="tel" 
                    maxLength={10}
                    placeholder="9876543210"
                    value={newUserData.phone} 
                    onChange={e => setNewUserData({...newUserData, phone: e.target.value.replace(/\D/g, "")})}
                    style={{ width: "100%", background: "rgba(4, 16, 38, 0.6)", border: "1px solid rgba(212, 175, 55, 0.3)", borderRadius: "8px", padding: "10px 14px", color: "#FFFFFF", fontSize: "13px", outline: "none" }} 
                  />
                </div>
              </div>

              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "16px" }}>
                <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
                  <label style={{ fontSize: "11px", color: "#D4AF37", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1px" }}>Gender</label>
                  <select 
                    value={newUserData.gender} 
                    onChange={e => setNewUserData({...newUserData, gender: e.target.value})}
                    style={{ width: "100%", background: "#041026", border: "1px solid rgba(212, 175, 55, 0.3)", borderRadius: "8px", padding: "10px 14px", color: "#FFFFFF", fontSize: "13px", outline: "none", cursor: "pointer" }}
                  >
                    <option value="Male">Male</option>
                    <option value="Female">Female</option>
                    <option value="Other">Other</option>
                  </select>
                </div>
                <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
                  <label style={{ fontSize: "11px", color: "#D4AF37", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1px" }}>Password</label>
                  <input 
                    required
                    type="password" 
                    placeholder="Minimum 8 characters"
                    minLength={8}
                    value={newUserData.password} 
                    onChange={e => setNewUserData({...newUserData, password: e.target.value})}
                    style={{ width: "100%", background: "rgba(4, 16, 38, 0.6)", border: "1px solid rgba(212, 175, 55, 0.3)", borderRadius: "8px", padding: "10px 14px", color: "#FFFFFF", fontSize: "13px", outline: "none" }} 
                  />
                </div>
              </div>

              <div style={{ display: "flex", justifyContent: "flex-end", gap: "12px", marginTop: "12px" }}>
                <button 
                  type="button" 
                  onClick={() => setIsModalOpen(false)}
                  style={{ padding: "10px 20px", borderRadius: "10px", background: "transparent", color: "#8E9BAE", border: "1px solid rgba(255,255,255,0.1)", fontWeight: 700, cursor: "pointer", fontSize: "12px" }}
                >
                  Cancel
                </button>
                <button 
                  type="submit" 
                  disabled={submitting}
                  style={{ padding: "10px 24px", borderRadius: "10px", background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)", color: "#041026", border: "none", fontWeight: 900, textTransform: "uppercase", letterSpacing: "1px", cursor: "pointer", fontSize: "12px", opacity: submitting ? 0.7 : 1 }}
                >
                  {submitting ? "Registering..." : "Create Candidate"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}

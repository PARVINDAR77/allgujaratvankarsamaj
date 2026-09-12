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
      <div style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
        {/* Search & Filter Header */}
        <div
          style={{
            backgroundColor: "rgba(13, 27, 50, 0.85)",
            backdropFilter: "blur(16px)",
            border: "1px solid rgba(212, 175, 55, 0.25)",
            borderRadius: "16px",
            padding: "18px 24px",
            display: "flex",
            flexWrap: "wrap",
            justifyContent: "space-between",
            alignItems: "center",
            gap: "16px",
            boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4)",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: "14px", flexWrap: "wrap" }}>
            <div style={{ position: "relative", minWidth: "260px" }}>
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
              <span style={{ position: "absolute", left: "12px", top: "11px", fontSize: "13px", color: "#8E9BAE" }}>
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
            onClick={() => setShowAddModal(true)}
            style={{
              padding: "10px 22px",
              borderRadius: "12px",
              background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
              color: "#041026",
              fontWeight: 800,
              fontSize: "12px",
              textTransform: "uppercase",
              letterSpacing: "0.8px",
              border: "none",
              cursor: "pointer",
              display: "flex",
              alignItems: "center",
              gap: "8px",
              boxShadow: "0 4px 14px rgba(212, 175, 55, 0.3)",
            }}
            className="hover:brightness-110 transition-all"
          >
            <span>➕</span>
            <span>Add New Member</span>
          </button>
        </div>

        {/* Users Data Table */}
        <div
          style={{
            backgroundColor: "rgba(13, 27, 50, 0.85)",
            backdropFilter: "blur(16px)",
            border: "1px solid rgba(212, 175, 55, 0.25)",
            borderRadius: "16px",
            padding: "24px",
            boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4)",
          }}
        >
          {loading ? (
            <div style={{ padding: "48px 0", textAlign: "center", color: "#D4AF37", fontWeight: 700, fontSize: "14px", display: "flex", justifyContent: "center", alignItems: "center", gap: "10px" }}>
              <span className="animate-spin">⚙️</span>
              <span>Loading user records...</span>
            </div>
          ) : (
            <div style={{ borderRadius: "12px", overflow: "hidden", border: "1px solid rgba(212, 175, 55, 0.2)" }}>
              <table style={{ width: "100%", textAlign: "left", fontSize: "12px", color: "#FFFFFF", borderCollapse: "collapse" }}>
                <thead>
                  <tr style={{ backgroundColor: "#041026", borderBottom: "1px solid rgba(212, 175, 55, 0.3)" }}>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Member Name</th>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Email Address</th>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Phone Number</th>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Pargana</th>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Role</th>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Status</th>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", textAlign: "right" }}>Actions</th>
                  </tr>
                </thead>
                <tbody style={{ backgroundColor: "#0D1B32" }}>
                  {filteredUsers.map((u) => {
                    const displayName = formatName(u.name, u.email);
                    return (
                      <tr key={u.id} style={{ borderBottom: "1px solid rgba(212, 175, 55, 0.1)" }} className="hover:bg-[#041026]/70 transition-colors">
                        <td style={{ padding: "14px 18px", fontWeight: 700, color: "#FFFFFF" }}>
                          <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
                            <div
                              style={{
                                width: "32px",
                                height: "32px",
                                borderRadius: "50%",
                                background: "linear-gradient(135deg, rgba(212,175,55,0.3) 0%, rgba(243,229,171,0.1) 100%)",
                                color: "#D4AF37",
                                display: "flex",
                                alignItems: "center",
                                justifyContent: "center",
                                fontWeight: 800,
                                fontSize: "12px",
                                border: "1px solid rgba(212, 175, 55, 0.4)",
                                flexShrink: 0,
                              }}
                            >
                              {displayName.charAt(0).toUpperCase()}
                            </div>
                            <span style={{ overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", maxWidth: "160px" }}>
                              {displayName}
                            </span>
                          </div>
                        </td>
                        <td style={{ padding: "14px 18px", color: "#8E9BAE", fontFamily: "monospace", fontSize: "11px" }}>
                          {u.email}
                        </td>
                        <td style={{ padding: "14px 18px", color: "#CBD5E1", fontFamily: "monospace", fontSize: "11px" }}>
                          {u.phone || "—"}
                        </td>
                        <td style={{ padding: "14px 18px", color: "#FFFFFF", fontWeight: 600 }}>{u.pargana}</td>
                        <td style={{ padding: "14px 18px", fontWeight: 800, color: "#D4AF37", fontSize: "11px" }}>{u.role}</td>
                        <td style={{ padding: "14px 18px" }}>
                          <StatusBadge status={u.status} />
                        </td>
                        <td style={{ padding: "14px 18px", textAlign: "right" }}>
                          <button
                            onClick={() => toggleUserStatus(u.id)}
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
        <div
          style={{
            position: "fixed",
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: "rgba(0, 0, 0, 0.8)",
            backdropFilter: "blur(8px)",
            zIndex: 1000,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            padding: "20px",
          }}
        >
          <div
            style={{
              backgroundColor: "#0D1B32",
              border: "2px solid #D4AF37",
              borderRadius: "20px",
              padding: "28px",
              width: "100%",
              maxWidth: "480px",
              boxShadow: "0 20px 50px rgba(0, 0, 0, 0.8)",
            }}
          >
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
                borderBottom: "1px solid rgba(212, 175, 55, 0.25)",
                paddingBottom: "16px",
                marginBottom: "20px",
              }}
            >
              <h3
                style={{
                  fontSize: "18px",
                  fontWeight: 800,
                  color: "#D4AF37",
                  display: "flex",
                  alignItems: "center",
                  gap: "10px",
                  margin: 0,
                }}
              >
                <span>➕</span> Add New Candidate Member
              </h3>
              <button
                onClick={() => setShowAddModal(false)}
                style={{
                  background: "transparent",
                  border: "none",
                  color: "#FFFFFF",
                  fontSize: "20px",
                  fontWeight: 700,
                  cursor: "pointer",
                }}
                className="hover:text-[#D4AF37]"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleAddUser} style={{ display: "flex", flexDirection: "column", gap: "18px" }}>
              <div>
                <label style={{ display: "block", fontSize: "12px", fontWeight: 700, color: "#8E9BAE", marginBottom: "6px" }}>
                  Candidate Full Name
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Ramesh Vankar"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  style={{
                    width: "100%",
                    backgroundColor: "#041026",
                    border: "1px solid rgba(212, 175, 55, 0.35)",
                    borderRadius: "12px",
                    padding: "12px 16px",
                    fontSize: "13px",
                    color: "#FFFFFF",
                    outline: "none",
                  }}
                />
              </div>

              <div>
                <label style={{ display: "block", fontSize: "12px", fontWeight: 700, color: "#8E9BAE", marginBottom: "6px" }}>
                  Email Address
                </label>
                <input
                  type="email"
                  required
                  placeholder="e.g. candidate@vankarsamaj.org"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  style={{
                    width: "100%",
                    backgroundColor: "#041026",
                    border: "1px solid rgba(212, 175, 55, 0.35)",
                    borderRadius: "12px",
                    padding: "12px 16px",
                    fontSize: "13px",
                    color: "#FFFFFF",
                    outline: "none",
                  }}
                />
              </div>

              <div>
                <label style={{ display: "block", fontSize: "12px", fontWeight: 700, color: "#8E9BAE", marginBottom: "6px" }}>
                  Phone Number
                </label>
                <input
                  type="text"
                  placeholder="e.g. 9876543210"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  style={{
                    width: "100%",
                    backgroundColor: "#041026",
                    border: "1px solid rgba(212, 175, 55, 0.35)",
                    borderRadius: "12px",
                    padding: "12px 16px",
                    fontSize: "13px",
                    color: "#FFFFFF",
                    outline: "none",
                  }}
                />
              </div>

              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "14px" }}>
                <div>
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 700, color: "#8E9BAE", marginBottom: "6px" }}>
                    Pargana Region
                  </label>
                  <select
                    value={pargana}
                    onChange={(e) => setPargana(e.target.value)}
                    style={{
                      width: "100%",
                      backgroundColor: "#041026",
                      border: "1px solid rgba(212, 175, 55, 0.35)",
                      borderRadius: "12px",
                      padding: "12px 14px",
                      fontSize: "12px",
                      color: "#D4AF37",
                      fontWeight: 700,
                      outline: "none",
                    }}
                  >
                    <option value="35 Pargana">35 Pargana</option>
                    <option value="27 Pargana">27 Pargana</option>
                    <option value="16 Pargana">16 Pargana</option>
                    <option value="14 Pargana">14 Pargana</option>
                    <option value="Other Pargana">Other Pargana</option>
                  </select>
                </div>

                <div>
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 700, color: "#8E9BAE", marginBottom: "6px" }}>
                    Role
                  </label>
                  <select
                    value={role}
                    onChange={(e) => setRole(e.target.value)}
                    style={{
                      width: "100%",
                      backgroundColor: "#041026",
                      border: "1px solid rgba(212, 175, 55, 0.35)",
                      borderRadius: "12px",
                      padding: "12px 14px",
                      fontSize: "12px",
                      color: "#D4AF37",
                      fontWeight: 700,
                      outline: "none",
                    }}
                  >
                    <option value="USER">USER</option>
                    <option value="ADMIN">ADMIN</option>
                  </select>
                </div>
              </div>

              <div style={{ display: "flex", gap: "12px", marginTop: "10px" }}>
                <button
                  type="button"
                  onClick={() => setShowAddModal(false)}
                  style={{
                    flex: 1,
                    padding: "12px",
                    borderRadius: "12px",
                    backgroundColor: "#041026",
                    color: "#CBD5E1",
                    fontWeight: 700,
                    fontSize: "13px",
                    border: "1px solid rgba(212, 175, 55, 0.3)",
                    cursor: "pointer",
                  }}
                  className="hover:bg-[#08152B]"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  style={{
                    flex: 1,
                    padding: "12px",
                    borderRadius: "12px",
                    background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                    color: "#041026",
                    fontWeight: 800,
                    fontSize: "13px",
                    border: "none",
                    cursor: "pointer",
                    boxShadow: "0 4px 14px rgba(212, 175, 55, 0.3)",
                  }}
                  className="hover:brightness-110"
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



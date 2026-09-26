"use client";

import React, { useState, useEffect } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatCard } from "@/components/admin/StatCard";

interface GovtEmployeeAdminItem {
  id: string;
  verificationStatus: string;
  isFeatured: boolean;
  isActive: boolean;
  employmentType: string;
  officeLocation?: string;
  joiningYear?: number;
  rejectionReason?: string;
  createdAt: string;
  department?: { name: string; gujaratiName?: string };
  designation?: { name: string; gujaratiName?: string };
  verifications?: { id: string; documentType: string; documentUrl: string; status: string }[];
  profile?: {
    id: string;
    firstName: string;
    lastName: string;
    gender: string;
    user?: { email?: string; phone?: string };
    district?: { name: string };
  };
}

interface Stats {
  total: number;
  pending: number;
  verified: number;
  rejected: number;
  featured: number;
  active: number;
}

export default function GovernmentEmployeesAdminPage() {
  const [stats, setStats] = useState<Stats>({ total: 0, pending: 0, verified: 0, rejected: 0, featured: 0, active: 0 });
  const [profiles, setProfiles] = useState<GovtEmployeeAdminItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState("ALL");
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [selectedProof, setSelectedProof] = useState<GovtEmployeeAdminItem | null>(null);
  const [rejectionReason, setRejectionReason] = useState("");
  const [actionLoading, setActionLoading] = useState(false);

  const API_BASE = "http://localhost:3000/api/v1";

  const fetchStatsAndData = async () => {
    setLoading(true);
    try {
      const token = typeof window !== "undefined" ? localStorage.getItem("adminToken") : null;
      const headers = { Authorization: `Bearer ${token}` };

      // Fetch stats
      const statsRes = await fetch(`${API_BASE}/admin/government-employees/stats`, { headers });
      if (statsRes.ok) {
        const statsData = await statsRes.json();
        setStats(statsData);
      }

      // Fetch profiles list
      const listRes = await fetch(`${API_BASE}/admin/government-employees?page=${page}&limit=10&status=${statusFilter}`, { headers });
      if (listRes.ok) {
        const listData = await listRes.json();
        setProfiles(listData.items || []);
        setTotalPages(listData.meta?.totalPages || 1);
      }
    } catch (err) {
      console.error("Failed to load govt employees admin data", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchStatsAndData();
  }, [page, statusFilter]);

  const handleVerify = async (id: string, action: "APPROVE" | "REJECT") => {
    if (action === "REJECT" && !rejectionReason.trim()) {
      alert("Please provide a rejection reason for the member.");
      return;
    }
    setActionLoading(true);
    try {
      const token = typeof window !== "undefined" ? localStorage.getItem("adminToken") : null;
      const res = await fetch(`${API_BASE}/admin/government-employees/${id}/verify`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify({ action, rejectionReason }),
      });
      if (res.ok) {
        setSelectedProof(null);
        setRejectionReason("");
        fetchStatsAndData();
      } else {
        const err = await res.json();
        alert(err.message || "Failed to update verification status");
      }
    } catch (err) {
      alert("Network error updating verification status");
    } finally {
      setActionLoading(false);
    }
  };

  const handleToggleFeature = async (id: string, currentVal: boolean) => {
    try {
      const token = typeof window !== "undefined" ? localStorage.getItem("adminToken") : null;
      const res = await fetch(`${API_BASE}/admin/government-employees/${id}/feature`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify({ isFeatured: !currentVal }),
      });
      if (res.ok) {
        fetchStatsAndData();
      } else {
        const errData = await res.json();
        alert(errData.message || "Cannot toggle feature status");
      }
    } catch (err) {
      alert("Network error");
    }
  };

  const handleToggleStatus = async (id: string, currentVal: boolean) => {
    try {
      const token = typeof window !== "undefined" ? localStorage.getItem("adminToken") : null;
      const res = await fetch(`${API_BASE}/admin/government-employees/${id}/status`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
        body: JSON.stringify({ isActive: !currentVal }),
      });
      if (res.ok) {
        fetchStatsAndData();
      }
    } catch (err) {
      alert("Network error");
    }
  };

  return (
    <AdminLayout title="Government Employees">
      <div style={{ display: "flex", flexDirection: "column", gap: "28px", paddingBottom: "48px" }}>
        {/* Title Header */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div>
            <h1 style={{ fontSize: "28px", fontWeight: "900", color: "#FFFFFF", margin: "0 0 8px 0", display: "flex", alignItems: "center", gap: "12px", letterSpacing: "-0.5px" }}>
              <span style={{ filter: "drop-shadow(0 0 8px rgba(212,175,55,0.8))" }}>💼</span> 
              Government Employees Control Center
            </h1>
            <p style={{ color: "#8E9BAE", fontSize: "14px", margin: 0, fontWeight: 500 }}>
              Verify employment proofs, manage status, and feature verified profiles for All Gujarat Vankar Samaj Matrimony
            </p>
          </div>
        </div>

        {/* Dynamic KPI Cards */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))", gap: "20px" }}>
          <StatCard title="Total Govt Profiles" value={stats.total} icon="💼" change="Registered" isPositive />
          <StatCard title="Pending Approvals" value={stats.pending} icon="⏳" change="Action Needed" isPositive={false} />
          <StatCard title="Verified Profiles" value={stats.verified} icon="🛡️" change="Active Live" isPositive />
          <StatCard title="Rejected Proofs" value={stats.rejected} icon="❌" change="Resubmission" isPositive={false} />
          <StatCard title="Featured Live" value={stats.featured} icon="⭐" change="Hero Banner" isPositive />
        </div>

        {/* Filter Controls Bar */}
        <div 
          style={{ 
            background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
            backdropFilter: "blur(20px)",
            padding: "20px", 
            borderRadius: "16px", 
            border: "1px solid rgba(212, 175, 55, 0.3)", 
            display: "flex", 
            gap: "16px", 
            alignItems: "center",
            boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.05)"
          }}
        >
          <span style={{ color: "#D4AF37", fontWeight: "800", fontSize: "14px", textTransform: "uppercase", letterSpacing: "1px" }}>Filter Status:</span>
          <div style={{ display: "flex", gap: "10px", flexWrap: "wrap" }}>
            {["ALL", "PENDING", "VERIFIED", "REJECTED"].map((st) => (
              <button
                key={st}
                onClick={() => { setStatusFilter(st); setPage(1); }}
                style={{
                  background: statusFilter === st ? "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)" : "rgba(4, 16, 38, 0.6)",
                  color: statusFilter === st ? "#041026" : "#8E9BAE",
                  border: statusFilter === st ? "none" : "1px solid rgba(212, 175, 55, 0.3)",
                  padding: "8px 20px",
                  borderRadius: "10px",
                  fontWeight: "800",
                  fontSize: "12px",
                  cursor: "pointer",
                  transition: "all 0.3s ease",
                  boxShadow: statusFilter === st ? "0 4px 15px rgba(212, 175, 55, 0.3)" : "none",
                  textTransform: "uppercase",
                  letterSpacing: "0.5px"
                }}
                className={statusFilter !== st ? "hover:border-[#D4AF37] hover:text-[#D4AF37]" : ""}
              >
                {st}
              </button>
            ))}
          </div>
        </div>

        {/* Data Table */}
        <div 
          style={{ 
            background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
            backdropFilter: "blur(20px)",
            borderRadius: "20px", 
            border: "1px solid rgba(212, 175, 55, 0.3)", 
            overflow: "hidden",
            boxShadow: "0 15px 40px rgba(0, 0, 0, 0.5), inset 0 1px 0 rgba(255, 255, 255, 0.05)"
          }}
        >
          <div style={{ overflowX: "auto" }}>
            <table style={{ width: "100%", borderCollapse: "collapse", textAlign: "left", minWidth: "1000px" }}>
              <thead>
                <tr style={{ backgroundColor: "rgba(4, 16, 38, 0.8)", borderBottom: "1px solid rgba(212, 175, 55, 0.3)" }}>
                  {["MEMBER PROFILE", "DEPARTMENT & DESIGNATION", "LOCATION", "VERIFICATION", "FEATURED", "STATUS", "ACTIONS"].map((head, i) => (
                    <th key={head} style={{ padding: "18px 24px", color: "#D4AF37", fontSize: "11px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1.5px", textAlign: i === 6 ? "right" : "left" }}>
                      {head}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan={7} style={{ padding: "60px", textAlign: "center" }}>
                      <div style={{ width: "40px", height: "40px", border: "3px solid #D4AF37", borderTopColor: "transparent", borderRadius: "50%", margin: "0 auto 16px" }} className="animate-spin"></div>
                      <p style={{ color: "#D4AF37", fontSize: "14px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "2px", margin: 0 }}>Loading Profiles...</p>
                    </td>
                  </tr>
                ) : profiles.length === 0 ? (
                  <tr>
                    <td colSpan={7} style={{ padding: "60px", textAlign: "center" }}>
                      <div style={{ fontSize: "48px", marginBottom: "16px", opacity: 0.8 }}>📭</div>
                      <p style={{ color: "#FFFFFF", fontSize: "16px", fontWeight: 800, marginBottom: "8px" }}>No Profiles Found</p>
                      <p style={{ color: "#8E9BAE", fontSize: "14px", margin: 0 }}>There are no government employee profiles matching this criteria.</p>
                    </td>
                  </tr>
                ) : (
                  profiles.map((p) => {
                    const latestProof = p.verifications && p.verifications[0];
                    return (
                      <tr key={p.id} style={{ borderBottom: "1px solid rgba(212, 175, 55, 0.1)", transition: "all 0.2s ease" }} className="hover:bg-[rgba(212,175,55,0.05)]">
                        <td style={{ padding: "20px 24px" }}>
                          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                            <div
                              style={{
                                width: "40px",
                                height: "40px",
                                borderRadius: "50%",
                                background: "linear-gradient(135deg, rgba(212, 175, 55, 0.2) 0%, rgba(4, 16, 38, 0.9) 100%)",
                                border: "1px solid rgba(212, 175, 55, 0.4)",
                                color: "#D4AF37",
                                fontWeight: 800,
                                fontSize: "16px",
                                display: "flex",
                                alignItems: "center",
                                justifyContent: "center",
                              }}
                            >
                              {(p.profile?.firstName?.[0] || 'M')}
                            </div>
                            <div>
                              <div style={{ fontWeight: "800", color: "#FFFFFF", fontSize: "14px" }}>
                                {p.profile ? `${p.profile.firstName} ${p.profile.lastName}` : "Member Profile"}
                              </div>
                              <div style={{ fontSize: "12px", color: "#8E9BAE", marginTop: "2px", fontFamily: "monospace" }}>{p.profile?.user?.phone || p.profile?.user?.email || "No contact info"}</div>
                            </div>
                          </div>
                        </td>
                        <td style={{ padding: "20px 24px" }}>
                          <div style={{ color: "#FFFFFF", fontWeight: "700", fontSize: "13px" }}>{p.department?.name || "Dept Unspecified"}</div>
                          <div style={{ fontSize: "12px", color: "#D4AF37", marginTop: "2px", fontWeight: 600 }}>{p.designation?.name || p.employmentType}</div>
                        </td>
                        <td style={{ padding: "20px 24px", fontSize: "13px", color: "#E2E8F0", fontWeight: 600 }}>
                          {p.officeLocation || p.profile?.district?.name || "Gujarat"}
                        </td>
                        <td style={{ padding: "20px 24px" }}>
                          <span style={{
                            display: "inline-flex",
                            alignItems: "center",
                            gap: "6px",
                            padding: "6px 12px",
                            borderRadius: "8px",
                            fontSize: "11px",
                            fontWeight: "800",
                            textTransform: "uppercase",
                            letterSpacing: "0.5px",
                            backgroundColor: p.verificationStatus === "VERIFIED" ? "rgba(16, 185, 129, 0.15)" : p.verificationStatus === "REJECTED" ? "rgba(244, 63, 94, 0.15)" : "rgba(245, 158, 11, 0.15)",
                            color: p.verificationStatus === "VERIFIED" ? "#10B981" : p.verificationStatus === "REJECTED" ? "#F43F5E" : "#F59E0B",
                            border: `1px solid ${p.verificationStatus === "VERIFIED" ? "rgba(16, 185, 129, 0.3)" : p.verificationStatus === "REJECTED" ? "rgba(244, 63, 94, 0.3)" : "rgba(245, 158, 11, 0.3)"}`
                          }}>
                            {p.verificationStatus === "VERIFIED" ? "✓" : p.verificationStatus === "REJECTED" ? "✕" : "⏳"} {p.verificationStatus}
                          </span>
                        </td>
                        <td style={{ padding: "20px 24px" }}>
                          <button
                            onClick={() => handleToggleFeature(p.id, p.isFeatured)}
                            style={{
                              backgroundColor: p.isFeatured ? "rgba(212, 175, 55, 0.15)" : "rgba(4, 16, 38, 0.6)",
                              color: p.isFeatured ? "#F3E5AB" : "#8E9BAE",
                              border: p.isFeatured ? "1px solid rgba(212, 175, 55, 0.5)" : "1px solid rgba(212, 175, 55, 0.2)",
                              padding: "6px 12px",
                              borderRadius: "8px",
                              cursor: "pointer",
                              fontSize: "11px",
                              fontWeight: 800,
                              transition: "all 0.3s ease",
                              display: "inline-flex",
                              alignItems: "center",
                              gap: "4px"
                            }}
                            className={!p.isFeatured ? "hover:border-[#D4AF37] hover:text-[#D4AF37]" : ""}
                          >
                            {p.isFeatured ? "⭐ Featured" : "Feature"}
                          </button>
                        </td>
                        <td style={{ padding: "20px 24px" }}>
                          <button
                            onClick={() => handleToggleStatus(p.id, p.isActive)}
                            style={{
                              backgroundColor: p.isActive ? "rgba(16, 185, 129, 0.1)" : "rgba(142, 155, 174, 0.1)",
                              color: p.isActive ? "#10B981" : "#8E9BAE",
                              border: p.isActive ? "1px solid rgba(16, 185, 129, 0.3)" : "1px solid rgba(142, 155, 174, 0.3)",
                              padding: "6px 12px",
                              borderRadius: "8px",
                              cursor: "pointer",
                              fontSize: "11px",
                              fontWeight: 800,
                              transition: "all 0.3s ease",
                            }}
                            className={!p.isActive ? "hover:border-[#8E9BAE] hover:text-white" : ""}
                          >
                            {p.isActive ? "🟢 Active" : "⚫ Inactive"}
                          </button>
                        </td>
                        <td style={{ padding: "20px 24px", textAlign: "right" }}>
                          <button
                            onClick={() => setSelectedProof(p)}
                            style={{
                              backgroundColor: "rgba(4, 16, 38, 0.8)",
                              color: "#D4AF37",
                              border: "1px solid rgba(212, 175, 55, 0.4)",
                              padding: "8px 16px",
                              borderRadius: "8px",
                              fontWeight: "800",
                              fontSize: "11px",
                              cursor: "pointer",
                              transition: "all 0.3s ease",
                            }}
                            className="hover:bg-[#D4AF37] hover:text-black hover:shadow-[0_0_15px_rgba(212,175,55,0.4)]"
                          >
                            Review Proof
                          </button>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination Controls */}
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "20px 24px", backgroundColor: "rgba(4, 16, 38, 0.6)", borderTop: "1px solid rgba(212, 175, 55, 0.2)" }}>
            <span style={{ fontSize: "13px", color: "#8E9BAE", fontWeight: 600 }}>Page <strong style={{ color: "#FFFFFF" }}>{page}</strong> of <strong style={{ color: "#FFFFFF" }}>{totalPages}</strong></span>
            <div style={{ display: "flex", gap: "10px" }}>
              <button
                disabled={page <= 1}
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                style={{ padding: "8px 16px", borderRadius: "8px", backgroundColor: "rgba(4, 16, 38, 0.8)", color: page <= 1 ? "#475569" : "#D4AF37", border: "1px solid rgba(212, 175, 55, 0.3)", cursor: page <= 1 ? "not-allowed" : "pointer", fontSize: "12px", fontWeight: 700, transition: "all 0.2s" }}
                className={page > 1 ? "hover:bg-[#D4AF37] hover:text-black" : ""}
              >
                Previous
              </button>
              <button
                disabled={page >= totalPages}
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                style={{ padding: "8px 16px", borderRadius: "8px", backgroundColor: "rgba(4, 16, 38, 0.8)", color: page >= totalPages ? "#475569" : "#D4AF37", border: "1px solid rgba(212, 175, 55, 0.3)", cursor: page >= totalPages ? "not-allowed" : "pointer", fontSize: "12px", fontWeight: 700, transition: "all 0.2s" }}
                className={page < totalPages ? "hover:bg-[#D4AF37] hover:text-black" : ""}
              >
                Next
              </button>
            </div>
          </div>
        </div>

        {/* Verification Modal */}
        {selectedProof && (
          <div style={{ position: "fixed", inset: 0, backgroundColor: "rgba(0, 0, 0, 0.85)", backdropFilter: "blur(12px)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 100, padding: "24px" }}>
            <div 
              style={{ 
                background: "linear-gradient(145deg, rgba(13, 27, 50, 0.95) 0%, rgba(4, 12, 26, 0.98) 100%)", 
                border: "1px solid rgba(212, 175, 55, 0.5)", 
                borderRadius: "24px", 
                padding: "32px", 
                maxWidth: "550px", 
                width: "100%", 
                boxShadow: "0 25px 60px rgba(0, 0, 0, 0.8)",
                position: "relative"
              }}
            >
              <h3 style={{ fontSize: "24px", fontWeight: 900, color: "#FFFFFF", marginTop: 0, marginBottom: "8px", display: "flex", alignItems: "center", gap: "10px" }}>
                <span style={{ color: "#D4AF37" }}>📄</span> Review Employment Proof
              </h3>
              <p style={{ fontSize: "14px", color: "#8E9BAE", marginBottom: "24px" }}>
                Member: <strong style={{ color: "#FFFFFF" }}>{selectedProof.profile?.firstName} {selectedProof.profile?.lastName}</strong> ({selectedProof.department?.name})
              </p>

              {selectedProof.verifications && selectedProof.verifications.length > 0 ? (
                <div style={{ margin: "0 0 24px 0", padding: "16px", backgroundColor: "rgba(4, 16, 38, 0.6)", borderRadius: "12px", border: "1px solid rgba(212, 175, 55, 0.2)" }}>
                  <div style={{ fontSize: "13px", color: "#8E9BAE", marginBottom: "8px", fontWeight: 700 }}>Document Type: <span style={{ color: "#FFFFFF" }}>{selectedProof.verifications[0].documentType}</span></div>
                  <a href={selectedProof.verifications[0].documentUrl} target="_blank" rel="noreferrer" style={{ display: "inline-flex", alignItems: "center", gap: "8px", color: "#D4AF37", textDecoration: "none", fontSize: "14px", fontWeight: 800, padding: "10px 16px", backgroundColor: "rgba(212, 175, 55, 0.1)", borderRadius: "8px", border: "1px solid rgba(212, 175, 55, 0.3)", transition: "all 0.3s ease" }} className="hover:bg-[#D4AF37] hover:text-black">
                    <span>↗</span> Open Submitted Proof Document
                  </a>
                </div>
              ) : (
                <div style={{ padding: "16px", backgroundColor: "rgba(245, 158, 11, 0.1)", color: "#F59E0B", borderRadius: "12px", border: "1px solid rgba(245, 158, 11, 0.3)", margin: "0 0 24px 0", fontSize: "13px", fontWeight: 600, display: "flex", alignItems: "center", gap: "10px" }}>
                  <span>⚠️</span> No physical document URL uploaded yet. Member filled department details.
                </div>
              )}

              <div style={{ marginBottom: "28px" }}>
                <label style={{ display: "block", fontSize: "13px", color: "#8E9BAE", fontWeight: 700, marginBottom: "8px" }}>Rejection Reason (Required if rejecting):</label>
                <input
                  type="text"
                  value={rejectionReason}
                  onChange={(e) => setRejectionReason(e.target.value)}
                  placeholder="e.g., ID card illegible, appointment letter expired"
                  style={{ width: "100%", padding: "14px 16px", backgroundColor: "rgba(4, 16, 38, 0.8)", border: "1px solid rgba(212, 175, 55, 0.4)", borderRadius: "10px", color: "#FFFFFF", fontSize: "14px", outline: "none", transition: "all 0.3s ease" }}
                  className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]"
                />
              </div>

              <div style={{ display: "flex", justifyContent: "flex-end", gap: "12px", paddingTop: "20px", borderTop: "1px solid rgba(212, 175, 55, 0.2)" }}>
                <button
                  onClick={() => setSelectedProof(null)}
                  style={{ padding: "12px 20px", borderRadius: "10px", backgroundColor: "rgba(4, 16, 38, 0.8)", color: "#8E9BAE", border: "1px solid rgba(142, 155, 174, 0.3)", cursor: "pointer", fontWeight: 800, fontSize: "13px", transition: "all 0.3s ease" }}
                  className="hover:text-white hover:border-white"
                >
                  Cancel
                </button>
                <button
                  disabled={actionLoading}
                  onClick={() => handleVerify(selectedProof.id, "REJECT")}
                  style={{ padding: "12px 20px", borderRadius: "10px", backgroundColor: "rgba(225, 29, 72, 0.1)", color: "#F43F5E", border: "1px solid rgba(225, 29, 72, 0.4)", cursor: actionLoading ? "not-allowed" : "pointer", fontWeight: 800, fontSize: "13px", transition: "all 0.3s ease" }}
                  className={!actionLoading ? "hover:bg-[#E11D48] hover:text-white" : ""}
                >
                  Reject Proof
                </button>
                <button
                  disabled={actionLoading}
                  onClick={() => handleVerify(selectedProof.id, "APPROVE")}
                  style={{ padding: "12px 20px", borderRadius: "10px", background: "linear-gradient(135deg, #10B981 0%, #059669 100%)", color: "#FFFFFF", border: "none", cursor: actionLoading ? "not-allowed" : "pointer", fontWeight: 800, fontSize: "13px", transition: "all 0.3s ease", boxShadow: "0 4px 15px rgba(16, 185, 129, 0.4)" }}
                  className={!actionLoading ? "hover:scale-[1.05] hover:shadow-[0_8px_25px_rgba(16,185,129,0.5)]" : ""}
                >
                  Approve Verification
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}

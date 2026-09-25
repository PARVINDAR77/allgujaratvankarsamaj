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
      <div  style={{ color: "#F3F4F6", fontFamily: "'Inter', sans-serif" }} className="p-6">
        {/* Title Header */}
        <div  style={{ marginBottom: "24px" }} className="flex justify-between items-center">
          <div>
            <h1  style={{ fontWeight: "700", color: "#FFD700", margin: 0 }} className="text-[28px]">
              💼 Government Employees Control Center
            </h1>
            <p  style={{ color: "#9CA3AF", marginTop: "4px" }} className="text-sm">
              Verify employment proofs, manage status, and feature verified profiles for All Gujarat Vankar Samaj Matrimony
            </p>
          </div>
        </div>

        {/* Dynamic KPI Cards */}
        <div  style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))", marginBottom: "28px" }} className="gap-4">
          <StatCard title="Total Govt Profiles" value={stats.total} icon="💼" change="Registered" isPositive />
          <StatCard title="Pending Approvals" value={stats.pending} icon="⏳" change="Action Needed" isPositive={false} />
          <StatCard title="Verified Profiles" value={stats.verified} icon="🛡️" change="Active Live" isPositive />
          <StatCard title="Rejected Proofs" value={stats.rejected} icon="❌" change="Resubmission" isPositive={false} />
          <StatCard title="Featured Live" value={stats.featured} icon="⭐" change="Hero Banner" isPositive />
        </div>

        {/* Filter Controls Bar */}
        <div   style={{ backgroundColor: "#0B1E36", borderRadius: "10px", border: "1px solid rgba(153, 125, 32, 0.3)", marginBottom: "20px" }} className="flex items-center gap-4 p-4" >
          <span  style={{ color: "#D1D5DB", fontWeight: "600" }} className="text-sm">Filter Status:</span>
          {["ALL", "PENDING", "VERIFIED", "REJECTED"].map((st) => (
            <button
              key={st}
              onClick={() => { setStatusFilter(st); setPage(1); }}
              style={{
                backgroundColor: statusFilter === st ? "#B8860B" : "#11294D",
                color: statusFilter === st ? "#FFFFFF" : "#9CA3AF",
                border: "1px solid rgba(184, 134, 11, 0.4)",
                padding: "8px 16px",
                borderRadius: "6px",
                fontWeight: "600",
                fontSize: "13px",
                cursor: "pointer",
                transition: "all 0.2s ease",
              }}
            >
              {st}
            </button>
          ))}
        </div>

        {/* Data Table */}
        <div  style={{ backgroundColor: "#0B1E36", border: "1.5px solid rgba(153, 125, 32, 0.4)" }} className="overflow-hidden rounded-xl">
          <table  className="w-full text-left border-collapse">
            <thead>
              <tr  style={{ backgroundColor: "#061224", borderBottom: "1.5px solid rgba(153, 125, 32, 0.3)", color: "#FFD700" }} className="text-[13px]">
                <th style={{ padding: "14px 16px" }}>MEMBER PROFILE</th>
                <th style={{ padding: "14px 16px" }}>DEPARTMENT & DESIGNATION</th>
                <th style={{ padding: "14px 16px" }}>LOCATION</th>
                <th style={{ padding: "14px 16px" }}>VERIFICATION</th>
                <th style={{ padding: "14px 16px" }}>FEATURED</th>
                <th style={{ padding: "14px 16px" }}>STATUS</th>
                <th  style={{ padding: "14px 16px" }} className="text-right">ACTIONS</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan={7}  style={{ padding: "30px", color: "#9CA3AF" }} className="text-center">Loading Government Employees...</td>
                </tr>
              ) : profiles.length === 0 ? (
                <tr>
                  <td colSpan={7}  style={{ padding: "30px", color: "#9CA3AF" }} className="text-center">No government employee profiles matching criteria.</td>
                </tr>
              ) : (
                profiles.map((p) => {
                  const latestProof = p.verifications && p.verifications[0];
                  return (
                    <tr key={p.id} style={{ borderBottom: "1px solid rgba(255, 255, 255, 0.05)" }}>
                      <td style={{ padding: "14px 16px" }}>
                        <div  style={{ fontWeight: "700" }} className="text-white">
                          {p.profile ? `${p.profile.firstName} ${p.profile.lastName}` : "Member Profile"}
                        </div>
                        <div  style={{ color: "#9CA3AF" }} className="text-xs">{p.profile?.user?.phone || p.profile?.user?.email || "No phone"}</div>
                      </td>
                      <td style={{ padding: "14px 16px" }}>
                        <div style={{ color: "#E5E7EB", fontWeight: "600" }}>{p.department?.name || "Dept Unspecified"}</div>
                        <div  style={{ color: "#6B7280" }} className="text-xs">{p.designation?.name || p.employmentType}</div>
                      </td>
                      <td  style={{ padding: "14px 16px", color: "#D1D5DB" }} className="text-[13px]">
                        {p.officeLocation || p.profile?.district?.name || "Gujarat"}
                      </td>
                      <td style={{ padding: "14px 16px" }}>
                        <span  style={{ display: "inline-block", padding: "4px 10px", fontWeight: "700", backgroundColor: p.verificationStatus === "VERIFIED" ? "rgba(16, 185, 129, 0.2)" : p.verificationStatus === "REJECTED" ? "rgba(239, 68, 68, 0.2)" : "rgba(245, 158, 11, 0.2)", color: p.verificationStatus === "VERIFIED" ? "#10B981" : p.verificationStatus === "REJECTED" ? "#EF4444" : "#F59E0B" }} className="text-xs rounded-xl">
                          {p.verificationStatus}
                        </span>
                      </td>
                      <td style={{ padding: "14px 16px" }}>
                        <button
                          onClick={() => handleToggleFeature(p.id, p.isFeatured)}
                          style={{
                            backgroundColor: p.isFeatured ? "rgba(255, 215, 0, 0.2)" : "#1F2937",
                            color: p.isFeatured ? "#FFD700" : "#6B7280",
                            border: "1px solid #B8860B",
                            padding: "4px 8px",
                            borderRadius: "6px",
                            cursor: "pointer",
                            fontSize: "12px",
                          }}
                        >
                          {p.isFeatured ? "⭐ Featured" : "☆ Standard"}
                        </button>
                      </td>
                      <td style={{ padding: "14px 16px" }}>
                        <button
                          onClick={() => handleToggleStatus(p.id, p.isActive)}
                          style={{
                            backgroundColor: p.isActive ? "rgba(16, 185, 129, 0.2)" : "rgba(107, 114, 128, 0.2)",
                            color: p.isActive ? "#10B981" : "#9CA3AF",
                            border: "none",
                            padding: "4px 10px",
                            borderRadius: "6px",
                            cursor: "pointer",
                            fontSize: "12px",
                          }}
                        >
                          {p.isActive ? "Active" : "Inactive"}
                        </button>
                      </td>
                      <td  style={{ padding: "14px 16px" }} className="text-right">
                        <button
                          onClick={() => setSelectedProof(p)}
                          style={{
                            backgroundColor: "#1D4ED8",
                            color: "#FFFFFF",
                            border: "none",
                            padding: "6px 12px",
                            borderRadius: "6px",
                            fontWeight: "600",
                            fontSize: "12px",
                            cursor: "pointer",
                          }}
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

          {/* Pagination Controls */}
          <div  style={{ padding: "14px 16px", borderTop: "1px solid rgba(255, 255, 255, 0.05)" }} className="flex justify-between items-center">
            <span  style={{ color: "#9CA3AF" }} className="text-[13px]">Page {page} of {totalPages}</span>
            <div  className="flex gap-2">
              <button
                disabled={page <= 1}
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                style={{ padding: "6px 12px", borderRadius: "6px", backgroundColor: "#1F2937", color: "#E5E7EB", border: "none", cursor: page <= 1 ? "not-allowed" : "pointer" }}
              >
                Previous
              </button>
              <button
                disabled={page >= totalPages}
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                style={{ padding: "6px 12px", borderRadius: "6px", backgroundColor: "#1F2937", color: "#E5E7EB", border: "none", cursor: page >= totalPages ? "not-allowed" : "pointer" }}
              >
                Next
              </button>
            </div>
          </div>
        </div>

        {/* Verification Modal */}
        {selectedProof && (
          <div  style={{ inset: 0, backgroundColor: "rgba(0, 0, 0, 0.8)", zIndex: 100 }} className="flex justify-center items-center fixed">
            <div  style={{ backgroundColor: "#061224", border: "2px solid #FFD700", maxWidth: "550px", width: "90%", color: "#F3F4F6" }} className="p-6 rounded-xl">
              <h3 style={{ fontSize: "20px", color: "#FFD700", marginTop: 0 }}>Review Employment Proof</h3>
              <p  style={{ color: "#D1D5DB" }} className="text-sm">
                Member: <strong>{selectedProof.profile?.firstName} {selectedProof.profile?.lastName}</strong> ({selectedProof.department?.name})
              </p>

              {selectedProof.verifications && selectedProof.verifications.length > 0 ? (
                <div  style={{ margin: "16px 0", padding: "12px", backgroundColor: "#0B1E36" }} className="rounded-lg">
                  <div  style={{ color: "#9CA3AF", marginBottom: "6px" }} className="text-[13px]">Document Type: {selectedProof.verifications[0].documentType}</div>
                  <a href={selectedProof.verifications[0].documentUrl} target="_blank" rel="noreferrer"  style={{ color: "#60A5FA", textDecoration: "underline" }} className="text-sm">
                    📄 Open Submitted Proof Document / ID Card
                  </a>
                </div>
              ) : (
                <div  style={{ padding: "12px", backgroundColor: "#1F2937", color: "#F59E0B", margin: "16px 0" }} className="text-[13px] rounded-lg">
                  No physical document URL uploaded yet. Member filled department details.
                </div>
              )}

              <div style={{ marginBottom: "16px" }}>
                <label  style={{ display: "block", color: "#9CA3AF", marginBottom: "4px" }} className="text-[13px]">Rejection Reason (If rejecting):</label>
                <input
                  type="text"
                  value={rejectionReason}
                  onChange={(e) => setRejectionReason(e.target.value)}
                  placeholder="e.g., ID card illegible, appointment letter expired"
                  style={{ width: "100%", padding: "8px 12px", backgroundColor: "#11294D", border: "1px solid rgba(255, 215, 0, 0.4)", borderRadius: "6px", color: "#FFFFFF" }}
                />
              </div>

              <div  style={{ gap: "12px" }} className="flex justify-end">
                <button
                  onClick={() => setSelectedProof(null)}
                  style={{ padding: "8px 16px", borderRadius: "6px", backgroundColor: "#374151", color: "#FFFFFF", border: "none", cursor: "pointer" }}
                >
                  Cancel
                </button>
                <button
                  disabled={actionLoading}
                  onClick={() => handleVerify(selectedProof.id, "REJECT")}
                  style={{ padding: "8px 16px", borderRadius: "6px", backgroundColor: "#DC2626", color: "#FFFFFF", border: "none", cursor: "pointer", fontWeight: "700" }}
                >
                  Reject Proof
                </button>
                <button
                  disabled={actionLoading}
                  onClick={() => handleVerify(selectedProof.id, "APPROVE")}
                  style={{ padding: "8px 16px", borderRadius: "6px", backgroundColor: "#059669", color: "#FFFFFF", border: "none", cursor: "pointer", fontWeight: "700" }}
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

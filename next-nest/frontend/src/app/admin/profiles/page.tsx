"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { adminApi, AdminProfileItem } from "@/lib/admin-api";

export default function AdminProfilesPage() {
  const [profiles, setProfiles] = useState<AdminProfileItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [selectedProfile, setSelectedProfile] = useState<AdminProfileItem | null>(null);

  const loadProfiles = async () => {
    try {
      const data = await adminApi.getProfiles();
      setProfiles(data);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProfiles();
  }, []);

  const handleStatusChange = async (profileId: string, currentStatus: string) => {
    const newStatus = currentStatus === "APPROVED" ? "REJECTED" : "APPROVED";
    try {
      await adminApi.updateProfileStatus(profileId, newStatus);
      loadProfiles();
    } catch (err) {
      alert("Failed to update profile status.");
    }
  };

  const handleToggleFeatured = async (profileId: string, isFeatured: boolean) => {
    try {
      await adminApi.toggleProfileFeatured(profileId, !isFeatured);
      loadProfiles();
    } catch (err) {
      alert("Failed to update featured status.");
    }
  };

  const filtered = profiles.filter(
    (p) =>
      p.name.toLowerCase().includes(search.toLowerCase()) ||
      p.city.toLowerCase().includes(search.toLowerCase()) ||
      p.pargana.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <AdminLayout title="Profiles Management" subtitle="Review, approve & feature matrimonial candidate profiles">
      <div style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
        {/* Search Header */}
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
          <div style={{ position: "relative", minWidth: "300px" }}>
            <input
              type="text"
              placeholder="Search profiles by name, city, pargana..."
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
            <span style={{ position: "absolute", left: "12px", top: "11px", fontSize: "13px", color: "#8E9BAE" }}>🔍</span>
          </div>
          <div
            style={{
              fontSize: "12px",
              color: "#D4AF37",
              fontWeight: 800,
              backgroundColor: "#041026",
              padding: "8px 16px",
              borderRadius: "12px",
              border: "1px solid rgba(212, 175, 55, 0.3)",
            }}
          >
            Total Profiles: {profiles.length}
          </div>
        </div>

        {/* Profile Cards Grid */}
        {loading ? (
          <div style={{ padding: "48px 0", textAlign: "center", color: "#D4AF37", fontSize: "14px", fontWeight: 700 }}>
            Loading profiles from NestJS API...
          </div>
        ) : filtered.length === 0 ? (
          <div style={{ padding: "48px 0", textAlign: "center", color: "#8E9BAE", fontSize: "13px", fontWeight: 600 }}>
            No matrimonial profiles match your search filter.
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-5">
            {filtered.map((p) => (
              <div
                key={p.id}
                style={{
                  backgroundColor: "rgba(13, 27, 50, 0.85)",
                  backdropFilter: "blur(16px)",
                  border: "1px solid rgba(212, 175, 55, 0.25)",
                  borderRadius: "16px",
                  padding: "20px",
                  boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4)",
                  display: "flex",
                  flexDirection: "column",
                  justifyContent: "space-between",
                }}
                className="group hover:border-[#D4AF37] transition-all"
              >
                <div>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", gap: "10px", marginBottom: "14px" }}>
                    <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                      <div
                        style={{
                          width: "44px",
                          height: "44px",
                          borderRadius: "50%",
                          background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                          color: "#041026",
                          fontWeight: 800,
                          fontSize: "18px",
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                          boxShadow: "0 4px 12px rgba(212, 175, 55, 0.3)",
                          flexShrink: 0,
                        }}
                      >
                        {p.name.charAt(0)}
                      </div>
                      <div style={{ minWidth: 0 }}>
                        <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                          <h3 style={{ fontSize: "14px", fontWeight: 700, color: "#FFFFFF", margin: 0 }} className="group-hover:text-[#D4AF37] transition-colors truncate">
                            {p.name}
                          </h3>
                          {p.isFeatured && <span style={{ fontSize: "12px" }} title="Featured Candidate">⭐</span>}
                        </div>
                        <p style={{ fontSize: "11px", color: "#8E9BAE", margin: "3px 0 0 0" }} className="truncate">
                          {p.age} yrs • {p.gender} • {p.city}
                        </p>
                      </div>
                    </div>
                    <div style={{ flexShrink: 0 }}>
                      <StatusBadge status={p.status} />
                    </div>
                  </div>

                  <div
                    style={{
                      display: "flex",
                      flexDirection: "column",
                      gap: "6px",
                      fontSize: "12px",
                      padding: "12px 0",
                      borderTop: "1px solid rgba(212, 175, 55, 0.15)",
                      borderBottom: "1px solid rgba(212, 175, 55, 0.15)",
                      margin: "12px 0",
                    }}
                  >
                    <p style={{ display: "flex", justifyContent: "space-between", margin: 0 }}>
                      <span style={{ color: "#8E9BAE" }}>Pargana:</span>
                      <strong style={{ color: "#FFFFFF" }}>{p.pargana}</strong>
                    </p>
                    <p style={{ display: "flex", justifyContent: "space-between", margin: 0 }}>
                      <span style={{ color: "#8E9BAE" }}>Education:</span>
                      <span style={{ color: "#E2E8F0" }}>{p.education}</span>
                    </p>
                    <p style={{ display: "flex", justifyContent: "space-between", margin: 0 }}>
                      <span style={{ color: "#8E9BAE" }}>Occupation:</span>
                      <span style={{ color: "#E2E8F0" }}>{p.occupation}</span>
                    </p>
                  </div>
                </div>

                <div style={{ display: "flex", gap: "8px", paddingTop: "4px" }}>
                  <button
                    onClick={() => setSelectedProfile(p)}
                    style={{
                      flex: 1,
                      padding: "8px 12px",
                      borderRadius: "10px",
                      backgroundColor: "#041026",
                      border: "1px solid rgba(212, 175, 55, 0.35)",
                      color: "#D4AF37",
                      fontSize: "11px",
                      fontWeight: 700,
                      cursor: "pointer",
                    }}
                    className="hover:bg-[#D4AF37] hover:text-black transition-all"
                  >
                    View Details
                  </button>
                  <button
                    onClick={() => handleToggleFeatured(p.id, p.isFeatured)}
                    style={{
                      padding: "8px 12px",
                      borderRadius: "10px",
                      fontSize: "11px",
                      fontWeight: 700,
                      cursor: "pointer",
                      backgroundColor: p.isFeatured ? "rgba(120, 53, 15, 0.6)" : "#041026",
                      color: p.isFeatured ? "#FDE68A" : "#94A3B8",
                      border: p.isFeatured ? "1px solid rgba(245, 158, 11, 0.4)" : "1px solid rgba(212, 175, 55, 0.2)",
                    }}
                    className="transition-colors"
                  >
                    {p.isFeatured ? "⭐ Featured" : "Feature"}
                  </button>
                  <button
                    onClick={() => handleStatusChange(p.id, p.status)}
                    style={{
                      padding: "8px 12px",
                      borderRadius: "10px",
                      fontSize: "11px",
                      fontWeight: 700,
                      cursor: "pointer",
                      backgroundColor: p.status === "APPROVED" ? "rgba(136, 19, 55, 0.6)" : "rgba(6, 78, 59, 0.6)",
                      color: p.status === "APPROVED" ? "#FDA4AF" : "#6EE7B7",
                      border: p.status === "APPROVED" ? "1px solid rgba(244, 63, 94, 0.4)" : "1px solid rgba(16, 185, 129, 0.4)",
                    }}
                    className="transition-colors"
                  >
                    {p.status === "APPROVED" ? "Reject" : "Approve"}
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Profile Detail Modal */}
        {selectedProfile && (
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
            onClick={() => setSelectedProfile(null)}
          >
            <div
              style={{
                backgroundColor: "#0D1B32",
                border: "2px solid #D4AF37",
                borderRadius: "24px",
                padding: "28px",
                width: "100%",
                maxWidth: "460px",
                boxShadow: "0 20px 50px rgba(0, 0, 0, 0.8)",
                display: "flex",
                flexDirection: "column",
                gap: "18px",
                position: "relative",
              }}
              onClick={(e) => e.stopPropagation()}
            >
              <button
                onClick={() => setSelectedProfile(null)}
                style={{
                  position: "absolute",
                  top: "18px",
                  right: "20px",
                  background: "transparent",
                  border: "none",
                  color: "#8E9BAE",
                  fontSize: "20px",
                  fontWeight: 700,
                  cursor: "pointer",
                }}
                className="hover:text-white"
              >
                ✕
              </button>

              <div style={{ display: "flex", alignItems: "center", gap: "16px" }}>
                <div
                  style={{
                    width: "52px",
                    height: "52px",
                    borderRadius: "50%",
                    background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                    color: "#041026",
                    fontWeight: 800,
                    fontSize: "22px",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    boxShadow: "0 4px 14px rgba(212, 175, 55, 0.35)",
                    flexShrink: 0,
                  }}
                >
                  {selectedProfile.name.charAt(0)}
                </div>
                <div>
                  <h3 style={{ fontSize: "18px", fontWeight: 800, color: "#FFFFFF", margin: 0 }}>{selectedProfile.name}</h3>
                  <p style={{ fontSize: "12px", color: "#D4AF37", fontWeight: 700, margin: "3px 0 0 0" }}>
                    {selectedProfile.pargana} Candidate
                  </p>
                </div>
              </div>

              <div
                style={{
                  display: "flex",
                  flexDirection: "column",
                  gap: "10px",
                  fontSize: "12px",
                  color: "#E2E8F0",
                  borderTop: "1px solid rgba(212, 175, 55, 0.2)",
                  paddingTop: "16px",
                }}
              >
                <p style={{ margin: 0 }}>
                  <strong style={{ color: "#8E9BAE" }}>Age / Gender:</strong> {selectedProfile.age} years • {selectedProfile.gender}
                </p>
                <p style={{ margin: 0 }}>
                  <strong style={{ color: "#8E9BAE" }}>City of Residence:</strong> {selectedProfile.city}
                </p>
                <p style={{ margin: 0 }}>
                  <strong style={{ color: "#8E9BAE" }}>Education:</strong> {selectedProfile.education}
                </p>
                <p style={{ margin: 0 }}>
                  <strong style={{ color: "#8E9BAE" }}>Occupation:</strong> {selectedProfile.occupation}
                </p>
                <p style={{ display: "flex", alignItems: "center", gap: "8px", margin: 0 }}>
                  <strong style={{ color: "#8E9BAE" }}>Verification Status:</strong> <StatusBadge status={selectedProfile.status} />
                </p>
              </div>

              <div style={{ paddingTop: "8px" }}>
                <button
                  onClick={() => setSelectedProfile(null)}
                  style={{
                    width: "100%",
                    padding: "12px",
                    borderRadius: "12px",
                    background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                    color: "#041026",
                    fontWeight: 800,
                    fontSize: "12px",
                    textTransform: "uppercase",
                    letterSpacing: "0.8px",
                    border: "none",
                    cursor: "pointer",
                  }}
                >
                  Close Window
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}


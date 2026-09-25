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
      <div  className="flex flex-col gap-6">
        {/* Search Header */}
        <div
            className="flex justify-between items-center flex-wrap border border-admin-gold/25 gap-4 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.4)] backdrop-blur-md bg-admin-bg-glass py-[18px] px-6" 
        >
          <div  style={{ minWidth: "300px" }} className="relative">
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
            <span   className="absolute text-admin-muted text-[13px] left-3 top-[11px]" >🔍</span>
          </div>
          <div
             style={{ padding: "8px 16px" }} className="font-extrabold bg-admin-card text-admin-gold border border-admin-gold/30 text-xs rounded-xl"
          >
            Total Profiles: {profiles.length}
          </div>
        </div>

        {/* Profile Cards Grid */}
        {loading ? (
          <div   className="text-center font-bold text-admin-gold text-sm py-12 px-0" >
            Loading profiles from NestJS API...
          </div>
        ) : filtered.length === 0 ? (
          <div   className="text-center font-semibold text-admin-muted text-[13px] py-12 px-0" >
            No matrimonial profiles match your search filter.
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-5">
            {filtered.map((p) => (
              <div
                key={p.id}
                  style={{ padding: "20px" }} className="group hover:border-admin-gold transition-all flex flex-col justify-between border border-admin-gold/25 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.4)] backdrop-blur-md bg-admin-bg-glass"
                
              >
                <div>
                  <div  style={{ marginBottom: "14px" }} className="flex justify-between items-start gap-[10px]">
                    <div  style={{ gap: "12px" }} className="flex items-center">
                      <div
                          style={{ width: "44px", height: "44px", color: "#041026", fontSize: "18px", boxShadow: "0 4px 12px rgba(212, 175, 55, 0.3)" }} className="flex justify-center items-center font-extrabold shrink-0 rounded-full bg-gradient-to-br from-admin-gold via-admin-gold-light to-admin-gold-border" 
                      >
                        {p.name.charAt(0)}
                      </div>
                      <div style={{ minWidth: 0 }}>
                        <div  style={{ gap: "6px" }} className="flex items-center">
                          <h3  style={{ margin: 0 }} className="group-hover:text-admin-gold transition-colors truncate font-bold text-white text-sm">
                            {p.name}
                          </h3>
                          {p.isFeatured && <span  className="text-xs" title="Featured Candidate">⭐</span>}
                        </div>
                        <p  style={{ margin: "3px 0 0 0" }} className="truncate text-admin-muted text-[11px]">
                          {p.age} yrs • {p.gender} • {p.city}
                        </p>
                      </div>
                    </div>
                    <div  className="shrink-0">
                      <StatusBadge status={p.status} />
                    </div>
                  </div>

                  <div
                     style={{ gap: "6px", padding: "12px 0", borderTop: "1px solid rgba(212, 175, 55, 0.15)", borderBottom: "1px solid rgba(212, 175, 55, 0.15)", margin: "12px 0" }} className="flex flex-col text-xs"
                  >
                    <p  style={{ margin: 0 }} className="flex justify-between">
                      <span  className="text-admin-muted">Pargana:</span>
                      <strong  className="text-white">{p.pargana}</strong>
                    </p>
                    <p  style={{ margin: 0 }} className="flex justify-between">
                      <span  className="text-admin-muted">Education:</span>
                      <span style={{ color: "#E2E8F0" }}>{p.education}</span>
                    </p>
                    <p  style={{ margin: 0 }} className="flex justify-between">
                      <span  className="text-admin-muted">Occupation:</span>
                      <span style={{ color: "#E2E8F0" }}>{p.occupation}</span>
                    </p>
                  </div>
                </div>

                <div  style={{ paddingTop: "4px" }} className="flex gap-2">
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
                    className="hover:bg-admin-gold hover:text-black transition-all"
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
             style={{ backgroundColor: "rgba(0, 0, 0, 0.8)", backdropFilter: "blur(8px)", padding: "20px" }} className="flex justify-center items-center fixed top-0 left-0 right-0 bottom-0 z-[1000]"
            onClick={() => setSelectedProfile(null)}
          >
            <div
               style={{ border: "2px solid #D4AF37", borderRadius: "24px", padding: "28px", maxWidth: "460px", boxShadow: "0 20px 50px rgba(0, 0, 0, 0.8)", gap: "18px" }} className="flex flex-col w-full relative bg-admin-card"
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

              <div  className="flex items-center gap-4">
                <div
                    style={{ width: "52px", height: "52px", color: "#041026", fontSize: "22px", boxShadow: "0 4px 14px rgba(212, 175, 55, 0.35)" }} className="flex justify-center items-center font-extrabold shrink-0 rounded-full bg-gradient-to-br from-admin-gold via-admin-gold-light to-admin-gold-border" 
                >
                  {selectedProfile.name.charAt(0)}
                </div>
                <div>
                  <h3  style={{ fontSize: "18px", margin: 0 }} className="font-extrabold text-white">{selectedProfile.name}</h3>
                  <p  style={{ margin: "3px 0 0 0" }} className="font-bold text-admin-gold text-xs">
                    {selectedProfile.pargana} Candidate
                  </p>
                </div>
              </div>

              <div
                 style={{ color: "#E2E8F0", borderTop: "1px solid rgba(212, 175, 55, 0.2)", paddingTop: "16px" }} className="flex flex-col text-xs gap-[10px]"
              >
                <p style={{ margin: 0 }}>
                  <strong  className="text-admin-muted">Age / Gender:</strong> {selectedProfile.age} years • {selectedProfile.gender}
                </p>
                <p style={{ margin: 0 }}>
                  <strong  className="text-admin-muted">City of Residence:</strong> {selectedProfile.city}
                </p>
                <p style={{ margin: 0 }}>
                  <strong  className="text-admin-muted">Education:</strong> {selectedProfile.education}
                </p>
                <p style={{ margin: 0 }}>
                  <strong  className="text-admin-muted">Occupation:</strong> {selectedProfile.occupation}
                </p>
                <p  style={{ margin: 0 }} className="flex items-center gap-2">
                  <strong  className="text-admin-muted">Verification Status:</strong> <StatusBadge status={selectedProfile.status} />
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


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

  const [selectedCategory, setSelectedCategory] = useState<string>("");

  const loadProfiles = async () => {
    try {
      const data = await adminApi.getProfiles(selectedCategory);
      setProfiles(data);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadProfiles();
  }, [selectedCategory]);

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
      <div style={{ display: "flex", flexDirection: "column", gap: "28px", paddingBottom: "48px" }}>
        
        {/* Search Header */}
        <div
          style={{
            background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
            backdropFilter: "blur(20px)",
            border: "1px solid rgba(212, 175, 55, 0.3)",
            borderRadius: "20px",
            padding: "24px",
            display: "flex",
            flexWrap: "wrap",
            justifyContent: "space-between",
            alignItems: "center",
            gap: "20px",
            boxShadow: "0 15px 35px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.05)",
          }}
        >
          <div style={{ display: "flex", flex: "1 1 auto", gap: "16px", flexWrap: "wrap" }}>
            <div style={{ position: "relative", flex: "1 1 300px" }}>
              <span style={{ position: "absolute", left: "16px", top: "50%", transform: "translateY(-50%)", fontSize: "16px", opacity: 0.7 }}>🔍</span>
              <input
                type="text"
                placeholder="Search profiles by name, city, pargana..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                style={{
                  width: "100%",
                  backgroundColor: "rgba(4, 16, 38, 0.6)",
                  border: "1px solid rgba(212, 175, 55, 0.3)",
                  borderRadius: "12px",
                  padding: "14px 16px 14px 48px",
                  fontSize: "14px",
                  color: "#FFFFFF",
                  fontWeight: 600,
                  outline: "none",
                  transition: "all 0.3s ease",
                  boxShadow: "inset 0 2px 10px rgba(0,0,0,0.2)"
                }}
                className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]"
              />
            </div>
            
            <div style={{ position: "relative", minWidth: "220px" }}>
              <select
                value={selectedCategory}
                onChange={(e) => setSelectedCategory(e.target.value)}
                style={{
                  width: "100%",
                  backgroundColor: "rgba(4, 16, 38, 0.6)",
                  border: "1px solid rgba(212, 175, 55, 0.3)",
                  borderRadius: "12px",
                  padding: "14px 16px",
                  fontSize: "14px",
                  color: "#FFFFFF",
                  fontWeight: 600,
                  outline: "none",
                  appearance: "none",
                  cursor: "pointer",
                  transition: "all 0.3s ease",
                  boxShadow: "inset 0 2px 10px rgba(0,0,0,0.2)"
                }}
                className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]"
              >
                <option value="" style={{ background: "#0a1526" }}>All Categories</option>
                <option value="government" style={{ background: "#0a1526" }}>Government Profile</option>
                <option value="private" style={{ background: "#0a1526" }}>Private Job Profile</option>
                <option value="business" style={{ background: "#0a1526" }}>Business Person Profile</option>
              </select>
              <span style={{ position: "absolute", right: "16px", top: "50%", transform: "translateY(-50%)", pointerEvents: "none", opacity: 0.7 }}>
                ▼
              </span>
            </div>
          </div>
          <div
            style={{
              fontSize: "14px",
              color: "#041026",
              fontWeight: 900,
              background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
              padding: "12px 24px",
              borderRadius: "12px",
              boxShadow: "0 8px 20px rgba(212, 175, 55, 0.3)",
              display: "flex",
              alignItems: "center",
              gap: "8px",
              textTransform: "uppercase",
              letterSpacing: "1px"
            }}
          >
            <span>Total Profiles:</span>
            <span style={{ fontSize: "18px" }}>{profiles.length}</span>
          </div>
        </div>

        {/* Profile Cards Grid */}
        {loading ? (
          <div style={{ padding: "64px", textAlign: "center", backgroundColor: "rgba(13, 27, 50, 0.6)", borderRadius: "20px", border: "1px solid rgba(212, 175, 55, 0.15)" }}>
            <div style={{ width: "40px", height: "40px", border: "3px solid #D4AF37", borderTopColor: "transparent", borderRadius: "50%", margin: "0 auto 16px" }} className="animate-spin"></div>
            <p style={{ color: "#D4AF37", fontSize: "14px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "2px" }}>Loading profiles...</p>
          </div>
        ) : filtered.length === 0 ? (
          <div style={{ padding: "64px", textAlign: "center", backgroundColor: "rgba(13, 27, 50, 0.6)", borderRadius: "20px", border: "1px solid rgba(212, 175, 55, 0.15)" }}>
            <div style={{ fontSize: "48px", marginBottom: "16px" }}>🔍</div>
            <p style={{ color: "#FFFFFF", fontSize: "16px", fontWeight: 800, marginBottom: "8px" }}>No Profiles Found</p>
            <p style={{ color: "#8E9BAE", fontSize: "14px" }}>Try adjusting your search criteria.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-8">
            {filtered.map((p) => (
              <div
                key={p.id}
                style={{
                  background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
                  backdropFilter: "blur(20px)",
                  border: p.isFeatured ? "1px solid rgba(212, 175, 55, 0.6)" : "1px solid rgba(212, 175, 55, 0.2)",
                  borderRadius: "20px",
                  padding: "24px",
                  boxShadow: p.isFeatured ? "0 15px 40px rgba(212, 175, 55, 0.15)" : "0 15px 35px rgba(0, 0, 0, 0.4)",
                  display: "flex",
                  flexDirection: "column",
                  justifyContent: "space-between",
                  position: "relative",
                  overflow: "hidden",
                  transition: "all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)"
                }}
                className="group hover:-translate-y-2 hover:shadow-[0_20px_40px_rgba(212,175,55,0.25)] hover:border-[#D4AF37]"
              >
                {/* Decorative Accent */}
                <div style={{ position: "absolute", top: 0, right: 0, width: "100px", height: "100px", background: p.isFeatured ? "radial-gradient(circle, rgba(212,175,55,0.3) 0%, rgba(0,0,0,0) 70%)" : "radial-gradient(circle, rgba(212,175,55,0.1) 0%, rgba(0,0,0,0) 70%)", transform: "translate(30%, -30%)" }}></div>

                <div>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", gap: "12px", marginBottom: "20px" }}>
                    <div style={{ display: "flex", alignItems: "center", gap: "16px" }}>
                      <div
                        style={{
                          width: "56px",
                          height: "56px",
                          borderRadius: "16px",
                          background: p.isFeatured ? "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)" : "linear-gradient(135deg, rgba(212, 175, 55, 0.3) 0%, rgba(4, 16, 38, 0.9) 100%)",
                          color: p.isFeatured ? "#041026" : "#D4AF37",
                          border: p.isFeatured ? "none" : "1px solid rgba(212, 175, 55, 0.5)",
                          fontWeight: 900,
                          fontSize: "24px",
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                          boxShadow: p.isFeatured ? "0 8px 20px rgba(212, 175, 55, 0.4)" : "inset 0 2px 10px rgba(255,255,255,0.1)",
                          flexShrink: 0,
                          transition: "all 0.3s ease"
                        }}
                        className="group-hover:scale-110 group-hover:rotate-3"
                      >
                        {p.name.charAt(0)}
                      </div>
                      <div style={{ minWidth: 0 }}>
                        <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                          <h3 style={{ fontSize: "18px", fontWeight: 900, color: "#FFFFFF", margin: 0, lineHeight: 1.2 }} className="group-hover:text-[#F3E5AB] transition-colors truncate">
                            {p.name}
                          </h3>
                          {p.isFeatured && <span style={{ fontSize: "16px", filter: "drop-shadow(0 0 5px rgba(212,175,55,0.8))" }} title="Featured Candidate">⭐</span>}
                        </div>
                        <p style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 600, margin: "4px 0 0 0", textTransform: "uppercase", letterSpacing: "0.5px" }} className="truncate">
                          {p.age} yrs • <span style={{ color: p.gender.toLowerCase() === 'male' ? '#60A5FA' : '#F472B6' }}>{p.gender}</span> • {p.city}
                        </p>
                      </div>
                    </div>
                    <div  className="shrink-0">
                      <StatusBadge status={p.status} />
                    </div>
                  </div>

                  <div
                    style={{
                      display: "flex",
                      flexDirection: "column",
                      gap: "10px",
                      padding: "16px 0",
                      borderTop: "1px solid rgba(212, 175, 55, 0.15)",
                      borderBottom: "1px solid rgba(212, 175, 55, 0.15)",
                      marginBottom: "20px",
                    }}
                  >
                    {[
                      { label: "Pargana", value: p.pargana },
                      { label: "Education", value: p.education },
                      { label: "Occupation", value: p.occupation }
                    ].map((item, idx) => (
                      <div key={idx} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "8px 12px", borderRadius: "10px", backgroundColor: "rgba(4, 16, 38, 0.4)", border: "1px solid rgba(212, 175, 55, 0.05)" }}>
                        <span style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 700 }}>{item.label}:</span>
                        <span style={{ fontSize: "13px", color: "#FFFFFF", fontWeight: 800, textAlign: "right", maxWidth: "65%", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{item.value}</span>
                      </div>
                    ))}
                  </div>
                </div>

                <div style={{ display: "flex", gap: "10px" }}>
                  <button
                    onClick={() => setSelectedProfile(p)}
                    style={{
                      flex: 1,
                      padding: "12px",
                      borderRadius: "12px",
                      backgroundColor: "rgba(4, 16, 38, 0.8)",
                      border: "1px solid rgba(212, 175, 55, 0.4)",
                      color: "#D4AF37",
                      fontSize: "12px",
                      fontWeight: 800,
                      cursor: "pointer",
                      transition: "all 0.3s ease",
                      display: "flex",
                      justifyContent: "center",
                      alignItems: "center",
                    }}
                    className="hover:bg-[#D4AF37] hover:text-black hover:shadow-[0_0_15px_rgba(212,175,55,0.4)]"
                  >
                    View Details
                  </button>
                  <button
                    onClick={() => handleToggleFeatured(p.id, p.isFeatured)}
                    style={{
                      padding: "12px 16px",
                      borderRadius: "12px",
                      fontSize: "12px",
                      fontWeight: 800,
                      cursor: "pointer",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      gap: "6px",
                      backgroundColor: p.isFeatured ? "rgba(212, 175, 55, 0.15)" : "rgba(4, 16, 38, 0.6)",
                      color: p.isFeatured ? "#F3E5AB" : "#8E9BAE",
                      border: p.isFeatured ? "1px solid rgba(212, 175, 55, 0.5)" : "1px solid rgba(212, 175, 55, 0.2)",
                      transition: "all 0.3s ease",
                    }}
                    className="hover:bg-[rgba(212,175,55,0.2)] hover:border-[#D4AF37] hover:text-[#D4AF37]"
                  >
                    {p.isFeatured ? "⭐ Featured" : "Feature"}
                  </button>
                  <button
                    onClick={() => handleStatusChange(p.id, p.status)}
                    style={{
                      padding: "12px 16px",
                      borderRadius: "12px",
                      fontSize: "12px",
                      fontWeight: 800,
                      cursor: "pointer",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      backgroundColor: p.status === "APPROVED" ? "rgba(225, 29, 72, 0.1)" : "rgba(16, 185, 129, 0.1)",
                      color: p.status === "APPROVED" ? "#E11D48" : "#10B981",
                      border: p.status === "APPROVED" ? "1px solid rgba(225, 29, 72, 0.3)" : "1px solid rgba(16, 185, 129, 0.3)",
                      transition: "all 0.3s ease",
                    }}
                    className={p.status === "APPROVED" ? "hover:bg-[#E11D48] hover:text-white" : "hover:bg-[#10B981] hover:text-white"}
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
              backgroundColor: "rgba(0, 0, 0, 0.85)",
              backdropFilter: "blur(12px)",
              zIndex: 1000,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              padding: "24px",
            }}
            onClick={() => setSelectedProfile(null)}
          >
            <div
              style={{
                background: "linear-gradient(145deg, rgba(13, 27, 50, 0.95) 0%, rgba(4, 12, 26, 0.98) 100%)",
                border: "1px solid rgba(212, 175, 55, 0.4)",
                borderRadius: "24px",
                padding: "32px",
                width: "100%",
                maxWidth: "500px",
                boxShadow: "0 25px 60px rgba(0, 0, 0, 0.8)",
                display: "flex",
                flexDirection: "column",
                gap: "24px",
                position: "relative",
              }}
              onClick={(e) => e.stopPropagation()}
            >
              <button
                onClick={() => setSelectedProfile(null)}
                style={{
                  position: "absolute",
                  top: "24px",
                  right: "24px",
                  background: "transparent",
                  border: "none",
                  color: "#8E9BAE",
                  fontSize: "24px",
                  cursor: "pointer",
                  transition: "color 0.3s ease",
                }}
                className="hover:text-white"
              >
                ✕
              </button>

              <div style={{ display: "flex", alignItems: "center", gap: "20px" }}>
                <div
                  style={{
                    width: "70px",
                    height: "70px",
                    borderRadius: "20px",
                    background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                    color: "#041026",
                    fontWeight: 900,
                    fontSize: "32px",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    boxShadow: "0 10px 25px rgba(212, 175, 55, 0.4)",
                    flexShrink: 0,
                  }}
                >
                  {selectedProfile.name.charAt(0)}
                </div>
                <div>
                  <h3 style={{ fontSize: "24px", fontWeight: 900, color: "#FFFFFF", margin: "0 0 6px 0", letterSpacing: "-0.5px" }}>{selectedProfile.name}</h3>
                  <p style={{ fontSize: "14px", color: "#D4AF37", fontWeight: 800, margin: 0, textTransform: "uppercase", letterSpacing: "1px" }}>
                    {selectedProfile.pargana} Candidate
                  </p>
                </div>
              </div>

              <div
                style={{
                  display: "flex",
                  flexDirection: "column",
                  gap: "12px",
                  borderTop: "1px solid rgba(212, 175, 55, 0.2)",
                  paddingTop: "24px",
                }}
              >
                {[
                  { label: "Age / Gender", value: `${selectedProfile.age} years • ${selectedProfile.gender}` },
                  { label: "City of Residence", value: selectedProfile.city },
                  { label: "Education", value: selectedProfile.education },
                  { label: "Occupation", value: selectedProfile.occupation }
                ].map((item, idx) => (
                  <div key={idx} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "12px 16px", borderRadius: "12px", backgroundColor: "rgba(4, 16, 38, 0.6)", border: "1px solid rgba(212, 175, 55, 0.1)" }}>
                    <span style={{ fontSize: "13px", color: "#8E9BAE", fontWeight: 700 }}>{item.label}:</span>
                    <span style={{ fontSize: "14px", color: "#FFFFFF", fontWeight: 800, textAlign: "right", maxWidth: "60%" }}>{item.value}</span>
                  </div>
                ))}
                
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "12px 16px", borderRadius: "12px", backgroundColor: "rgba(4, 16, 38, 0.6)", border: "1px solid rgba(212, 175, 55, 0.1)" }}>
                  <span style={{ fontSize: "13px", color: "#8E9BAE", fontWeight: 700 }}>Verification Status:</span>
                  <StatusBadge status={selectedProfile.status} />
                </div>
              </div>

              <div style={{ paddingTop: "16px", borderTop: "1px solid rgba(212, 175, 55, 0.2)", marginTop: "8px" }}>
                <button
                  onClick={() => setSelectedProfile(null)}
                  style={{
                    width: "100%",
                    padding: "16px",
                    borderRadius: "14px",
                    background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                    color: "#041026",
                    fontWeight: 900,
                    fontSize: "14px",
                    textTransform: "uppercase",
                    letterSpacing: "1px",
                    border: "none",
                    cursor: "pointer",
                    boxShadow: "0 10px 25px rgba(212, 175, 55, 0.4)",
                    transition: "all 0.3s ease",
                  }}
                  className="hover:scale-[1.03] hover:shadow-[0_15px_35px_rgba(212,175,55,0.6)] active:scale-[0.98]"
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


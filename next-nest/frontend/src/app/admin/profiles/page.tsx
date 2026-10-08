"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { adminApi, AdminProfileItem } from "@/lib/admin-api";

export default function AdminProfilesPage() {
  const [profiles, setProfiles] = useState<AdminProfileItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [selectedProfile, setSelectedProfile] = useState<AdminProfileItem | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string>("");
  const [previewImage, setPreviewImage] = useState<{ url: string; title: string } | null>(null);

  const loadProfiles = async () => {
    setLoading(true);
    try {
      const data = await adminApi.getProfiles(selectedCategory);
      setProfiles(Array.isArray(data) ? data : []);
      setError(null);
    } catch (e: any) {
      console.error(e);
      setError(e.message || "Failed to load profiles");
      setProfiles([]);
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
      await loadProfiles();
      if (selectedProfile && selectedProfile.id === profileId) {
        setSelectedProfile({ ...selectedProfile, status: newStatus });
      }
    } catch (err) {
      alert("Failed to update profile status.");
    }
  };

  const handleToggleFeatured = async (profileId: string, isFeatured: boolean) => {
    try {
      await adminApi.toggleProfileFeatured(profileId, !isFeatured);
      await loadProfiles();
      if (selectedProfile && selectedProfile.id === profileId) {
        setSelectedProfile({ ...selectedProfile, isFeatured: !isFeatured });
      }
    } catch (err) {
      alert("Failed to update featured status.");
    }
  };

  const getFullUrl = (url?: string) => {
    if (!url) return "";
    if (url.startsWith("http://") || url.startsWith("https://") || url.startsWith("data:")) return url;
    return `https://allgujaratvankarsamaj.com${url.startsWith("/") ? "" : "/"}${url}`;
  };

  const getCandidatePhotos = (p: AdminProfileItem): string[] => {
    if (Array.isArray(p.photos) && p.photos.length > 0) return p.photos;
    if (p.photoUrl) return [p.photoUrl];
    return [];
  };

  const safeProfiles = Array.isArray(profiles) ? profiles : [];
  const filtered = safeProfiles.filter(
    (p) =>
      p &&
      (
        (p.name && p.name.toLowerCase().includes(search.toLowerCase())) ||
        (p.city && p.city.toLowerCase().includes(search.toLowerCase())) ||
        (p.pargana && p.pargana.toLowerCase().includes(search.toLowerCase())) ||
        (p.user?.phone && p.user.phone.includes(search))
      )
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
                placeholder="Search profiles by name, city, phone, pargana..."
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

        {error && (
          <div style={{
            backgroundColor: "rgba(220, 38, 38, 0.15)",
            border: "1px solid rgba(239, 68, 68, 0.4)",
            borderRadius: "14px",
            padding: "16px 20px",
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            color: "#FCA5A5",
            fontSize: "13px",
            fontWeight: 600,
          }}>
            <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
              <span>⚠️</span>
              <span>{error}</span>
            </div>
            <button
              onClick={() => loadProfiles()}
              style={{
                backgroundColor: "rgba(239, 68, 68, 0.2)",
                border: "1px solid #EF4444",
                borderRadius: "8px",
                padding: "6px 14px",
                color: "#FFFFFF",
                fontSize: "12px",
                fontWeight: 700,
                cursor: "pointer",
              }}
            >
              Retry
            </button>
          </div>
        )}

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
            {filtered.map((p) => {
              const candidatePhotos = getCandidatePhotos(p);
              const avatarPhoto = candidatePhotos[0] ? getFullUrl(candidatePhotos[0]) : null;

              return (
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
                            overflow: "hidden",
                            position: "relative",
                            transition: "all 0.3s ease"
                          }}
                          className="group-hover:scale-110 group-hover:rotate-3"
                        >
                          {avatarPhoto ? (
                            <img
                              src={avatarPhoto}
                              alt={p.name}
                              className="w-full h-full object-cover"
                            />
                          ) : (
                            p.name.charAt(0)
                          )}
                        </div>
                        <div style={{ minWidth: 0 }}>
                          <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                            <h3 style={{ fontSize: "18px", fontWeight: 900, color: "#FFFFFF", margin: 0, lineHeight: 1.2 }} className="group-hover:text-[#F3E5AB] transition-colors truncate">
                              {p.name}
                            </h3>
                            {p.isFeatured && <span style={{ fontSize: "16px", filter: "drop-shadow(0 0 5px rgba(212,175,55,0.8))" }} title="Featured Candidate">⭐</span>}
                          </div>
                          <p style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 600, margin: "4px 0 0 0", textTransform: "uppercase", letterSpacing: "0.5px" }} className="truncate">
                            {p.age} yrs • <span style={{ color: p.gender?.toLowerCase() === 'male' ? '#60A5FA' : '#F472B6' }}>{p.gender}</span> • {p.city}
                          </p>
                          <div className="flex items-center gap-2 mt-1">
                            {candidatePhotos.length > 0 && (
                              <span className="text-[10px] bg-admin-card text-admin-gold border border-admin-gold/30 px-1.5 py-0.5 rounded font-bold">
                                📸 {candidatePhotos.length} photo{candidatePhotos.length > 1 ? "s" : ""}
                              </span>
                            )}
                            {p.verification && (
                              <span className="text-[10px] bg-emerald-950/40 text-emerald-400 border border-emerald-500/30 px-1.5 py-0.5 rounded font-bold">
                                🛡️ {p.verification.documentType || "ID Proof"}
                              </span>
                            )}
                          </div>
                        </div>
                      </div>
                      <div className="shrink-0">
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
                        { label: "Occupation", value: p.occupation },
                        ...(p.user?.phone ? [{ label: "Contact Phone", value: p.user.phone }] : [])
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
              );
            })}
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
              backgroundColor: "rgba(0, 0, 0, 0.88)",
              backdropFilter: "blur(14px)",
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
                background: "linear-gradient(145deg, rgba(13, 27, 50, 0.98) 0%, rgba(4, 12, 26, 0.99) 100%)",
                border: "1px solid rgba(212, 175, 55, 0.4)",
                borderRadius: "24px",
                padding: "28px",
                width: "100%",
                maxWidth: "720px",
                maxHeight: "92vh",
                overflowY: "auto",
                boxShadow: "0 25px 60px rgba(0, 0, 0, 0.85)",
                display: "flex",
                flexDirection: "column",
                gap: "22px",
                position: "relative",
              }}
              onClick={(e) => e.stopPropagation()}
            >
              <button
                onClick={() => setSelectedProfile(null)}
                style={{
                  position: "absolute",
                  top: "20px",
                  right: "20px",
                  background: "rgba(255, 255, 255, 0.08)",
                  border: "1px solid rgba(255, 255, 255, 0.2)",
                  borderRadius: "50%",
                  width: "36px",
                  height: "36px",
                  color: "#8E9BAE",
                  fontSize: "18px",
                  cursor: "pointer",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  transition: "all 0.3s ease",
                }}
                className="hover:text-white hover:bg-rose-500/20 hover:border-rose-400"
              >
                ✕
              </button>

              {/* Profile Header */}
              <div style={{ display: "flex", alignItems: "center", gap: "20px" }}>
                <div
                  style={{
                    width: "72px",
                    height: "72px",
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
                    overflow: "hidden",
                  }}
                >
                  {getCandidatePhotos(selectedProfile)[0] ? (
                    <img
                      src={getFullUrl(getCandidatePhotos(selectedProfile)[0])}
                      alt={selectedProfile.name}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    selectedProfile.name.charAt(0)
                  )}
                </div>
                <div>
                  <h3 style={{ fontSize: "24px", fontWeight: 900, color: "#FFFFFF", margin: "0 0 4px 0", letterSpacing: "-0.5px" }}>{selectedProfile.name}</h3>
                  <p style={{ fontSize: "13px", color: "#D4AF37", fontWeight: 800, margin: 0, textTransform: "uppercase", letterSpacing: "1px" }}>
                    {selectedProfile.pargana} Candidate
                  </p>
                  {selectedProfile.user?.phone && (
                    <p style={{ fontSize: "12px", color: "#8E9BAE", margin: "4px 0 0 0", fontFamily: "monospace" }}>
                      📞 {selectedProfile.user.phone} {selectedProfile.user.email ? `• ✉️ ${selectedProfile.user.email}` : ""}
                    </p>
                  )}
                </div>
              </div>

              {/* BOX 1: Candidate Photos Gallery (2 to 5 photos) */}
              <div
                style={{
                  background: "rgba(4, 16, 38, 0.7)",
                  border: "1px solid rgba(212, 175, 55, 0.25)",
                  borderRadius: "16px",
                  padding: "16px",
                }}
              >
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <span className="text-base">📸</span>
                    <span className="font-extrabold text-white text-xs uppercase tracking-wider">Candidate Photos Box</span>
                  </div>
                  <span className="text-[11px] font-bold text-admin-gold bg-admin-gold/15 px-2.5 py-0.5 rounded-full border border-admin-gold/30">
                    {getCandidatePhotos(selectedProfile).length} of 2-5 Photos
                  </span>
                </div>

                {getCandidatePhotos(selectedProfile).length > 0 ? (
                  <div className="grid grid-cols-3 sm:grid-cols-5 gap-3">
                    {getCandidatePhotos(selectedProfile).map((pUrl, idx) => {
                      const full = getFullUrl(pUrl);
                      return (
                        <div
                          key={idx}
                          onClick={() => setPreviewImage({ url: full, title: `${selectedProfile.name} - Photo ${idx + 1}` })}
                          className="relative aspect-square rounded-xl overflow-hidden border border-admin-gold/40 hover:border-admin-gold cursor-pointer group shadow-md transition-all hover:scale-105"
                          title="Click to view full photo"
                        >
                          <img
                            src={full}
                            alt={`Candidate photo ${idx + 1}`}
                            className="w-full h-full object-cover"
                          />
                          <div className="absolute inset-0 bg-black/25 group-hover:bg-transparent transition-colors" />
                          <span className="absolute bottom-1 right-1 bg-black/80 text-[10px] font-extrabold text-admin-gold px-1.5 py-0.5 rounded">
                            #{idx + 1}
                          </span>
                          <span className="absolute top-1 left-1 opacity-0 group-hover:opacity-100 transition-opacity bg-admin-gold text-black text-[9px] font-bold px-1 rounded">
                            Zoom 🔍
                          </span>
                        </div>
                      );
                    })}
                  </div>
                ) : (
                  <div className="py-4 text-center text-admin-muted text-xs italic">
                    No candidate photos uploaded yet.
                  </div>
                )}
              </div>

              {/* BOX 2: ID Proof Verification Box (Front & Back Mandatory) */}
              <div
                style={{
                  background: "rgba(4, 16, 38, 0.7)",
                  border: "1px solid rgba(212, 175, 55, 0.25)",
                  borderRadius: "16px",
                  padding: "16px",
                }}
              >
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <span className="text-base">🛡️</span>
                    <span className="font-extrabold text-white text-xs uppercase tracking-wider">Government ID Proof Verification</span>
                  </div>
                  {selectedProfile.verification ? (
                    <span className="text-[11px] font-extrabold text-emerald-400 bg-emerald-950/60 px-2.5 py-0.5 rounded-full border border-emerald-500/40">
                      {selectedProfile.verification.documentType || "Govt ID"} • {selectedProfile.verification.status}
                    </span>
                  ) : (
                    <span className="text-[11px] text-amber-400 bg-amber-950/50 px-2.5 py-0.5 rounded-full border border-amber-500/30">
                      Pending Submission
                    </span>
                  )}
                </div>

                {selectedProfile.verification ? (
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    {/* Front Side Card */}
                    <div className="bg-admin-card/80 border border-emerald-500/30 rounded-xl p-3 flex flex-col items-center">
                      <div className="w-full flex items-center justify-between mb-2">
                        <span className="text-[11px] font-extrabold text-emerald-400 uppercase tracking-wider flex items-center gap-1">
                          <span>📄</span> Front Side (Mandatory)
                        </span>
                        <span className="text-[9px] bg-emerald-500/20 text-emerald-300 font-bold px-1.5 py-0.5 rounded">
                          Uploaded
                        </span>
                      </div>
                      {selectedProfile.verification.documentUrl ? (
                        <div
                          onClick={() => setPreviewImage({
                            url: getFullUrl(selectedProfile.verification?.documentUrl),
                            title: `${selectedProfile.name} - ${selectedProfile.verification?.documentType || 'ID Proof'} (Front Side)`
                          })}
                          className="relative w-full h-36 rounded-lg overflow-hidden border border-emerald-500/40 hover:border-emerald-400 cursor-pointer group shadow-inner"
                        >
                          <img
                            src={getFullUrl(selectedProfile.verification.documentUrl)}
                            alt="ID Front"
                            className="w-full h-full object-cover"
                          />
                          <div className="absolute inset-0 bg-emerald-950/30 group-hover:bg-transparent flex items-center justify-center">
                            <span className="bg-black/80 text-white text-[11px] font-bold px-2 py-1 rounded-md opacity-90 group-hover:opacity-100 transition-opacity">
                              🔍 Click to Zoom Front
                            </span>
                          </div>
                        </div>
                      ) : (
                        <div className="w-full h-36 rounded-lg border border-dashed border-rose-500/40 flex items-center justify-center text-xs text-rose-400">
                          Front image missing
                        </div>
                      )}
                    </div>

                    {/* Back Side Card */}
                    <div className="bg-admin-card/80 border border-cyan-500/30 rounded-xl p-3 flex flex-col items-center">
                      <div className="w-full flex items-center justify-between mb-2">
                        <span className="text-[11px] font-extrabold text-cyan-400 uppercase tracking-wider flex items-center gap-1">
                          <span>📄</span> Back Side (Mandatory)
                        </span>
                        <span className="text-[9px] bg-cyan-500/20 text-cyan-300 font-bold px-1.5 py-0.5 rounded">
                          {selectedProfile.verification.documentBackUrl ? "Uploaded" : "Pending"}
                        </span>
                      </div>
                      {selectedProfile.verification.documentBackUrl ? (
                        <div
                          onClick={() => setPreviewImage({
                            url: getFullUrl(selectedProfile.verification?.documentBackUrl),
                            title: `${selectedProfile.name} - ${selectedProfile.verification?.documentType || 'ID Proof'} (Back Side)`
                          })}
                          className="relative w-full h-36 rounded-lg overflow-hidden border border-cyan-500/40 hover:border-cyan-400 cursor-pointer group shadow-inner"
                        >
                          <img
                            src={getFullUrl(selectedProfile.verification.documentBackUrl)}
                            alt="ID Back"
                            className="w-full h-full object-cover"
                          />
                          <div className="absolute inset-0 bg-cyan-950/30 group-hover:bg-transparent flex items-center justify-center">
                            <span className="bg-black/80 text-white text-[11px] font-bold px-2 py-1 rounded-md opacity-90 group-hover:opacity-100 transition-opacity">
                              🔍 Click to Zoom Back
                            </span>
                          </div>
                        </div>
                      ) : (
                        <div className="w-full h-36 rounded-lg border border-dashed border-amber-500/40 flex items-center justify-center text-xs text-amber-400">
                          Back side not submitted
                        </div>
                      )}
                    </div>
                  </div>
                ) : (
                  <div className="py-6 text-center text-admin-muted text-xs italic bg-admin-card/40 rounded-xl border border-admin-gold/10">
                    Candidate has not submitted government ID proof documents yet.
                  </div>
                )}
              </div>

              {/* Profile Details List */}
              <div
                style={{
                  display: "flex",
                  flexDirection: "column",
                  gap: "10px",
                }}
              >
                {[
                  { label: "Age / Gender", value: `${selectedProfile.age} years • ${selectedProfile.gender}` },
                  { label: "City of Residence", value: selectedProfile.city },
                  { label: "Education", value: selectedProfile.education },
                  { label: "Occupation", value: selectedProfile.occupation },
                  { label: "Profile Status", value: selectedProfile.status },
                  { label: "Featured Status", value: selectedProfile.isFeatured ? "Featured ⭐" : "Standard" },
                ].map((item, idx) => (
                  <div key={idx} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "10px 14px", borderRadius: "10px", backgroundColor: "rgba(4, 16, 38, 0.6)", border: "1px solid rgba(212, 175, 55, 0.1)" }}>
                    <span style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 700 }}>{item.label}:</span>
                    <span style={{ fontSize: "13px", color: "#FFFFFF", fontWeight: 800, textAlign: "right", maxWidth: "60%" }}>{item.value}</span>
                  </div>
                ))}
              </div>

              {/* Modal Actions */}
              <div style={{ display: "flex", gap: "12px", paddingTop: "12px", borderTop: "1px solid rgba(212, 175, 55, 0.2)" }}>
                <button
                  onClick={() => handleStatusChange(selectedProfile.id, selectedProfile.status)}
                  style={{
                    flex: 1,
                    padding: "14px",
                    borderRadius: "12px",
                    backgroundColor: selectedProfile.status === "APPROVED" ? "rgba(225, 29, 72, 0.2)" : "rgba(16, 185, 129, 0.2)",
                    color: selectedProfile.status === "APPROVED" ? "#FDA4AF" : "#6EE7B7",
                    border: selectedProfile.status === "APPROVED" ? "1px solid #E11D48" : "1px solid #10B981",
                    fontWeight: 900,
                    fontSize: "13px",
                    cursor: "pointer",
                    transition: "all 0.3s ease",
                  }}
                  className="hover:scale-[1.02] active:scale-[0.98]"
                >
                  {selectedProfile.status === "APPROVED" ? "Reject Profile" : "Approve Profile"}
                </button>
                <button
                  onClick={() => setSelectedProfile(null)}
                  style={{
                    flex: 1,
                    padding: "14px",
                    borderRadius: "12px",
                    background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                    color: "#041026",
                    fontWeight: 900,
                    fontSize: "13px",
                    textTransform: "uppercase",
                    letterSpacing: "1px",
                    border: "none",
                    cursor: "pointer",
                    boxShadow: "0 8px 20px rgba(212, 175, 55, 0.3)",
                    transition: "all 0.3s ease",
                  }}
                  className="hover:scale-[1.02] active:scale-[0.98]"
                >
                  Close Window
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Lightbox Zoom Modal */}
        {previewImage && (
          <div
            style={{
              position: "fixed",
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: "rgba(0, 0, 0, 0.92)",
              backdropFilter: "blur(14px)",
              zIndex: 3000,
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              justifyContent: "center",
              padding: "24px",
            }}
            onClick={() => setPreviewImage(null)}
          >
            <div
              style={{
                position: "relative",
                maxWidth: "92vw",
                maxHeight: "88vh",
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                gap: "12px",
              }}
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex justify-between items-center w-full bg-admin-card/90 px-4 py-2.5 rounded-xl border border-admin-gold/30">
                <span className="font-extrabold text-admin-gold text-xs tracking-wider">
                  {previewImage.title}
                </span>
                <div className="flex items-center gap-3">
                  <a
                    href={previewImage.url}
                    target="_blank"
                    rel="noreferrer"
                    className="text-[11px] text-white hover:text-admin-gold font-bold underline"
                  >
                    Open Original ↗
                  </a>
                  <button
                    onClick={() => setPreviewImage(null)}
                    className="text-gray-400 hover:text-white text-lg font-bold px-2 py-0.5"
                  >
                    ✕
                  </button>
                </div>
              </div>

              <img
                src={previewImage.url}
                alt={previewImage.title}
                style={{
                  maxWidth: "90vw",
                  maxHeight: "78vh",
                  objectFit: "contain",
                  borderRadius: "16px",
                  border: "2px solid rgba(212, 175, 55, 0.5)",
                  boxShadow: "0 25px 60px rgba(0,0,0,0.85)",
                }}
              />
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}



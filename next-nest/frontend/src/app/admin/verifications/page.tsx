"use client";

import React, { useState, useEffect } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { adminApi } from "@/lib/admin-api";

export default function AdminVerificationsPage() {
  const [items, setItems] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState("ALL");
  const [search, setSearch] = useState("");
  const [previewImage, setPreviewImage] = useState<{ url: string; title: string } | null>(null);

  const fetchVerifications = async () => {
    try {
      setLoading(true);
      const data = await adminApi.getVerifications();
      setItems(Array.isArray(data) ? data : ((data as any).data || []));
      setError(null);
    } catch (err: any) {
      console.error(err);
      setError(err.message || "Failed to fetch verifications");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchVerifications();
  }, []);

  const updateStatus = async (id: string, action: string) => {
    let reason;
    if (action === "REJECTED") {
      reason = window.prompt("Please enter a rejection reason:");
      if (reason === null) return; // User cancelled
    }
    
    try {
      await adminApi.updateVerificationStatus(id, action, reason);
      await fetchVerifications();
    } catch (err: any) {
      alert("Failed to update status: " + (err.message || "Unknown error"));
    }
  };

  const getFullUrl = (url?: string) => {
    if (!url) return "";
    if (url.startsWith("http://") || url.startsWith("https://") || url.startsWith("data:")) return url;
    return `https://allgujaratvankarsamaj.com${url.startsWith("/") ? "" : "/"}${url}`;
  };

  const getCandidatePhotos = (profile: any): string[] => {
    if (!profile) return [];
    if (Array.isArray(profile.photos)) return profile.photos;
    if (typeof profile.photos === "string") {
      try {
        const parsed = JSON.parse(profile.photos);
        if (Array.isArray(parsed)) return parsed;
      } catch {}
    }
    if (profile.photoUrl) return [profile.photoUrl];
    return [];
  };

  const filteredItems = items.filter((item) => {
    const memberName = item.profile ? `${item.profile.firstName || ''} ${item.profile.lastName || ''}`.trim() || item.profile.name || '' : (item.name || '');
    const matchesSearch = memberName.toLowerCase().includes(search.toLowerCase()) || 
                          (item.documentType || '').toLowerCase().includes(search.toLowerCase()) ||
                          (item.profile?.user?.phone || '').includes(search);
    const matchesFilter = filter === "ALL" || item.status === filter;
    return matchesSearch && matchesFilter;
  });

  return (
    <AdminLayout title="Verification Management" subtitle="Approve or reject submitted community profile proofs">
      <div className="flex flex-col gap-6">
        {/* Search & Status Filter Bar */}
        <div className="flex justify-between items-center flex-wrap border border-admin-gold/25 gap-4 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.4)] backdrop-blur-md bg-admin-bg-glass py-[18px] px-6">
          <div style={{ minWidth: "300px" }} className="relative">
            <input
              type="text"
              placeholder="Search member, phone or document type..."
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
            <span className="absolute text-admin-muted text-[13px] left-3 top-[11px]">🔍</span>
          </div>

          <div className="flex gap-2">
            {["ALL", "PENDING", "VERIFIED", "REJECTED"].map((tab) => (
              <button
                key={tab}
                onClick={() => setFilter(tab)}
                style={{
                  padding: "8px 16px",
                  borderRadius: "12px",
                  fontSize: "12px",
                  fontWeight: 800,
                  border: "none",
                  cursor: "pointer",
                  backgroundColor: filter === tab ? "#D4AF37" : "#041026",
                  color: filter === tab ? "#041026" : "#8E9BAE",
                  boxShadow: filter === tab ? "0 4px 12px rgba(212, 175, 55, 0.3)" : "none",
                }}
                className="transition-all"
              >
                {tab}
              </button>
            ))}
          </div>
        </div>

        {/* Verification Submissions Table */}
        <div className="border border-admin-gold/25 p-6 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.4)] backdrop-blur-md bg-admin-bg-glass">
          <div style={{ marginBottom: "20px" }} className="flex justify-between items-center">
            <h3 style={{ margin: 0 }} className="flex items-center font-extrabold text-white text-base gap-2">
              <span>🛡️</span> Verification Review Requests
            </h3>
            <span style={{ borderRadius: "20px" }} className="font-extrabold bg-admin-card text-admin-gold border border-admin-gold/30 text-[11px] py-1.5 px-3.5">
              Pending Queue: {items.filter(i => i.status === "PENDING").length}
            </span>
          </div>

          {loading ? (
            <div className="py-16 text-center">
              <div className="w-8 h-8 border-2 border-admin-gold border-t-transparent rounded-full animate-spin mx-auto mb-3"></div>
              <p className="text-admin-gold text-xs font-bold uppercase tracking-wider">Loading verification records...</p>
            </div>
          ) : filteredItems.length === 0 ? (
            <div className="py-12 text-center text-admin-muted text-sm">
              No verification requests found matching your filter.
            </div>
          ) : (
            <div className="overflow-x-auto border border-admin-gold/20 rounded-xl">
              <table className="w-full text-left border-collapse text-white text-xs">
                <thead>
                  <tr className="bg-admin-card border-b border-admin-gold/30">
                    <th className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[16px] tracking-[1px]">Member Details</th>
                    <th className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[16px] tracking-[1px]">Candidate Photos (2-5)</th>
                    <th className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[16px] tracking-[1px]">ID Proof (Front & Back)</th>
                    <th className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[16px] tracking-[1px]">Date</th>
                    <th className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[16px] tracking-[1px]">Status</th>
                    <th className="text-right font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[16px] tracking-[1px]">Actions</th>
                  </tr>
                </thead>
                <tbody className="bg-admin-card divide-y divide-admin-gold/10">
                  {filteredItems.map((item) => {
                    const memberName = item.profile ? `${item.profile.firstName || ''} ${item.profile.lastName || ''}`.trim() || item.profile.name || "Unknown" : (item.name || "Unknown");
                    const photos = getCandidatePhotos(item.profile);
                    const frontUrl = getFullUrl(item.documentUrl);
                    const backUrl = getFullUrl(item.documentBackUrl);

                    return (
                      <tr key={item.id} className="hover:bg-admin-card/70 transition-colors">
                        {/* Member Details */}
                        <td className="py-[14px] px-[16px] align-top">
                          <div className="font-bold text-white text-sm">{memberName}</div>
                          {item.profile?.user?.phone && (
                            <div className="text-[11px] text-admin-muted mt-0.5 font-mono">
                              📞 {item.profile.user.phone}
                            </div>
                          )}
                          {item.profile?.user?.email && (
                            <div className="text-[11px] text-admin-muted font-mono truncate max-w-[160px]">
                              ✉️ {item.profile.user.email}
                            </div>
                          )}
                          <div className="text-[10px] text-admin-gold/80 mt-1 font-semibold">
                            📍 {item.profile?.city || item.profile?.nativePlace || "Gujarat"}
                          </div>
                        </td>

                        {/* Candidate Photos (2 to 5) */}
                        <td className="py-[14px] px-[16px] align-top">
                          {photos.length > 0 ? (
                            <div>
                              <div className="text-[10px] font-bold text-admin-gold mb-1.5 flex items-center gap-1">
                                <span>📸</span> {photos.length} Photo{photos.length > 1 ? "s" : ""}
                              </div>
                              <div className="flex flex-wrap gap-1.5 max-w-[200px]">
                                {photos.map((pUrl, idx) => {
                                  const full = getFullUrl(pUrl);
                                  return (
                                    <div
                                      key={idx}
                                      onClick={() => setPreviewImage({ url: full, title: `${memberName} - Photo ${idx + 1}` })}
                                      className="relative w-11 h-11 rounded-lg overflow-hidden border border-admin-gold/40 cursor-pointer hover:scale-110 hover:border-admin-gold transition-transform group"
                                      title={`Click to zoom photo ${idx + 1}`}
                                    >
                                      <img
                                        src={full}
                                        alt={`Photo ${idx + 1}`}
                                        className="w-full h-full object-cover"
                                      />
                                      <div className="absolute inset-0 bg-black/30 group-hover:bg-transparent transition-colors" />
                                      <span className="absolute bottom-0 right-0 bg-black/70 text-[8px] font-bold text-admin-gold px-1 rounded-tl">
                                        #{idx + 1}
                                      </span>
                                    </div>
                                  );
                                })}
                              </div>
                            </div>
                          ) : (
                            <span className="text-[11px] text-admin-muted italic">No photos</span>
                          )}
                        </td>

                        {/* ID Proof (Front & Back) */}
                        <td className="py-[14px] px-[16px] align-top">
                          <div className="font-semibold text-white mb-1.5 flex items-center gap-1">
                            <span className="px-2 py-0.5 rounded bg-admin-gold/15 text-admin-gold border border-admin-gold/30 text-[10px] font-extrabold uppercase">
                              {item.documentType || "ID Proof"}
                            </span>
                          </div>

                          <div className="flex items-center gap-2 mt-1">
                            {/* Front Side */}
                            <div className="flex flex-col items-center">
                              <span className="text-[9px] font-extrabold text-admin-gold uppercase tracking-wider mb-0.5">Front Side</span>
                              {frontUrl ? (
                                <div
                                  onClick={() => setPreviewImage({ url: frontUrl, title: `${memberName} - ${item.documentType || 'ID Proof'} (Front Side)` })}
                                  className="relative w-16 h-12 rounded-lg overflow-hidden border-2 border-emerald-500/50 hover:border-emerald-400 cursor-pointer hover:scale-105 transition-transform group shadow-md"
                                  title="Click to view Front Side ID"
                                >
                                  <img
                                    src={frontUrl}
                                    alt="Front ID"
                                    className="w-full h-full object-cover"
                                  />
                                  <span className="absolute inset-0 bg-emerald-950/20 group-hover:bg-transparent flex items-center justify-center text-[10px] font-bold text-white">
                                    🔍
                                  </span>
                                </div>
                              ) : (
                                <div className="w-16 h-12 rounded-lg border border-dashed border-rose-500/40 flex items-center justify-center text-[9px] text-rose-400">
                                  Missing
                                </div>
                              )}
                            </div>

                            {/* Back Side */}
                            <div className="flex flex-col items-center">
                              <span className="text-[9px] font-extrabold text-admin-gold uppercase tracking-wider mb-0.5">Back Side</span>
                              {backUrl ? (
                                <div
                                  onClick={() => setPreviewImage({ url: backUrl, title: `${memberName} - ${item.documentType || 'ID Proof'} (Back Side)` })}
                                  className="relative w-16 h-12 rounded-lg overflow-hidden border-2 border-cyan-500/50 hover:border-cyan-400 cursor-pointer hover:scale-105 transition-transform group shadow-md"
                                  title="Click to view Back Side ID"
                                >
                                  <img
                                    src={backUrl}
                                    alt="Back ID"
                                    className="w-full h-full object-cover"
                                  />
                                  <span className="absolute inset-0 bg-cyan-950/20 group-hover:bg-transparent flex items-center justify-center text-[10px] font-bold text-white">
                                    🔍
                                  </span>
                                </div>
                              ) : (
                                <div className="w-16 h-12 rounded-lg border border-dashed border-amber-500/40 flex items-center justify-center text-[9px] text-amber-400">
                                  N/A
                                </div>
                              )}
                            </div>
                          </div>
                        </td>

                        {/* Date */}
                        <td className="text-admin-muted-lighter text-[11px] py-[14px] px-[16px] font-mono align-top whitespace-nowrap">
                          {new Date(item.createdAt).toLocaleDateString()}
                        </td>

                        {/* Status */}
                        <td className="py-[14px] px-[16px] align-top">
                          <StatusBadge status={item.status} />
                          {item.status === "REJECTED" && item.rejectionReason && (
                            <div className="text-[10px] text-rose-400 mt-1 font-medium max-w-[150px]">
                              Reason: {item.rejectionReason}
                            </div>
                          )}
                        </td>

                        {/* Actions */}
                        <td className="text-right py-[14px] px-[16px] align-top whitespace-nowrap">
                          <div className="flex justify-end gap-2">
                            {item.status === "PENDING" ? (
                              <>
                                <button
                                  onClick={() => updateStatus(item.id, "VERIFIED")}
                                  style={{
                                    padding: "6px 14px",
                                    borderRadius: "8px",
                                    backgroundColor: "rgba(6, 78, 59, 0.6)",
                                    color: "#6EE7B7",
                                    border: "1px solid rgba(16, 185, 129, 0.4)",
                                    fontSize: "11px",
                                    fontWeight: 800,
                                    cursor: "pointer",
                                  }}
                                  className="hover:bg-emerald-800 transition-colors"
                                >
                                  Approve
                                </button>
                                <button
                                  onClick={() => updateStatus(item.id, "REJECTED")}
                                  style={{
                                    padding: "6px 14px",
                                    borderRadius: "8px",
                                    backgroundColor: "rgba(136, 19, 55, 0.6)",
                                    color: "#FDA4AF",
                                    border: "1px solid rgba(244, 63, 94, 0.4)",
                                    fontSize: "11px",
                                    fontWeight: 800,
                                    cursor: "pointer",
                                  }}
                                  className="hover:bg-rose-800 transition-colors"
                                >
                                  Reject
                                </button>
                              </>
                            ) : (
                              <button
                                onClick={() => updateStatus(item.id, item.status === "VERIFIED" ? "REJECTED" : "VERIFIED")}
                                style={{
                                  padding: "4px 10px",
                                  borderRadius: "6px",
                                  backgroundColor: "rgba(255, 255, 255, 0.05)",
                                  color: "#8E9BAE",
                                  border: "1px solid rgba(255, 255, 255, 0.15)",
                                  fontSize: "10px",
                                  fontWeight: 700,
                                  cursor: "pointer",
                                }}
                                className="hover:text-white transition-colors"
                              >
                                Change Status
                              </button>
                            )}
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

        {/* Lightbox Image Preview Modal */}
        {previewImage && (
          <div
            style={{
              position: "fixed",
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: "rgba(0, 0, 0, 0.9)",
              backdropFilter: "blur(12px)",
              zIndex: 2000,
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
                maxWidth: "90vw",
                maxHeight: "85vh",
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                gap: "12px",
              }}
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex justify-between items-center w-full bg-admin-card/90 px-4 py-2 rounded-xl border border-admin-gold/30">
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
                  maxHeight: "75vh",
                  objectFit: "contain",
                  borderRadius: "16px",
                  border: "2px solid rgba(212, 175, 55, 0.5)",
                  boxShadow: "0 25px 60px rgba(0,0,0,0.8)",
                }}
              />
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}




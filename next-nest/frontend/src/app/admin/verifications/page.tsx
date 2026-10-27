"use client";

import React, { useState, useEffect } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { adminApi } from "@/lib/admin-api";

function isPdf(url?: string): boolean {
  if (!url) return false;
  const clean = url.split("?")[0].toLowerCase();
  return clean.endsWith(".pdf");
}

function DocumentThumbnail({
  url,
  label,
  side,
  memberName,
  onZoom,
}: {
  url?: string;
  label: string;
  side: "front" | "back";
  memberName: string;
  onZoom: (url: string, title: string) => void;
}) {
  const [loadError, setLoadError] = useState(false);
  const isFront = side === "front";
  const borderColor = isFront ? "border-emerald-500/50 hover:border-emerald-400" : "border-cyan-500/50 hover:border-cyan-400";
  const bgOverlay = isFront ? "bg-emerald-950/30" : "bg-cyan-950/30";
  const badgeColor = isFront ? "text-emerald-300 bg-emerald-950/80 border-emerald-500/40" : "text-cyan-300 bg-cyan-950/80 border-cyan-500/40";

  if (!url || url === "null" || url.trim() === "") {
    return (
      <div className="flex flex-col items-center">
        <span className="text-[9px] font-extrabold text-admin-gold uppercase tracking-wider mb-1">{isFront ? "Front Side" : "Back Side"}</span>
        <div className={`w-16 h-12 rounded-lg border border-dashed ${isFront ? "border-rose-500/40 text-rose-400" : "border-amber-500/40 text-amber-400"} flex items-center justify-center text-[9px] font-bold bg-[#041026]/40`}>
          {isFront ? "Missing" : "N/A"}
        </div>
      </div>
    );
  }

  const pdf = isPdf(url);

  return (
    <div className="flex flex-col items-center">
      <span className="text-[9px] font-extrabold text-admin-gold uppercase tracking-wider mb-1">{isFront ? "Front Side" : "Back Side"}</span>
      {pdf ? (
        <a
          href={url}
          target="_blank"
          rel="noopener noreferrer"
          className="relative w-16 h-12 rounded-lg overflow-hidden border-2 border-red-500/60 bg-red-950/40 hover:bg-red-900/50 flex flex-col items-center justify-center text-center p-1 cursor-pointer hover:scale-105 transition-all shadow-md group"
          title={`Click to open ${isFront ? "Front" : "Back"} PDF Document`}
        >
          <span className="text-sm">📄</span>
          <span className="text-[8px] font-bold text-red-200 uppercase tracking-tighter">Open PDF ↗</span>
        </a>
      ) : loadError ? (
        <a
          href={url}
          target="_blank"
          rel="noopener noreferrer"
          className={`relative w-16 h-12 rounded-lg overflow-hidden border ${badgeColor} flex flex-col items-center justify-center text-center p-1 cursor-pointer hover:scale-105 transition-all shadow-md`}
          title={`Click to open document in new tab (${url})`}
        >
          <span className="text-xs">🪪</span>
          <span className="text-[8px] font-extrabold uppercase tracking-tight">View Doc ↗</span>
        </a>
      ) : (
        <div
          onClick={() => onZoom(url, `${memberName} - ${label} (${isFront ? "Front Side" : "Back Side"})`)}
          className={`relative w-16 h-12 rounded-lg overflow-hidden border-2 ${borderColor} cursor-pointer hover:scale-105 transition-transform group shadow-md bg-[#041026]`}
          title={`Click to inspect ${isFront ? "Front" : "Back"} ID`}
        >
          <img
            src={url}
            alt={isFront ? "Front ID" : "Back ID"}
            className="w-full h-full object-cover"
            onError={() => setLoadError(true)}
          />
          <div className={`absolute inset-0 ${bgOverlay} group-hover:bg-transparent flex items-center justify-center text-[10px] font-bold text-white transition-colors`}>
            🔍
          </div>
        </div>
      )}
    </div>
  );
}

function CandidatePhotoThumb({
  url,
  idx,
  memberName,
  onZoom,
}: {
  url: string;
  idx: number;
  memberName: string;
  onZoom: (url: string, title: string) => void;
}) {
  const [loadError, setLoadError] = useState(false);

  return (
    <div
      onClick={() => onZoom(url, `${memberName} - Photo ${idx + 1}`)}
      className="relative w-11 h-11 rounded-lg overflow-hidden border border-admin-gold/40 cursor-pointer hover:scale-110 hover:border-admin-gold transition-all group bg-[#041026] shadow-sm flex items-center justify-center"
      title={`Click to zoom photo ${idx + 1}`}
    >
      {loadError ? (
        <div className="w-full h-full flex flex-col items-center justify-center bg-admin-card text-admin-gold text-[10px]">
          <span>📷</span>
          <span className="text-[8px] font-bold">#{idx + 1}</span>
        </div>
      ) : (
        <>
          <img
            src={url}
            alt={`Photo ${idx + 1}`}
            className="w-full h-full object-cover"
            onError={() => setLoadError(true)}
          />
          <div className="absolute inset-0 bg-black/30 group-hover:bg-transparent transition-colors" />
          <span className="absolute bottom-0 right-0 bg-black/75 text-[8px] font-extrabold text-admin-gold px-1 rounded-tl">
            #{idx + 1}
          </span>
        </>
      )}
    </div>
  );
}

export default function AdminVerificationsPage() {
  const [items, setItems] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState("ALL");
  const [search, setSearch] = useState("");
  const [previewImage, setPreviewImage] = useState<{ url: string; title: string } | null>(null);
  const [rejectingItem, setRejectingItem] = useState<{ id: string; name: string } | null>(null);
  const [rejectionReason, setRejectionReason] = useState("");
  const [updating, setUpdating] = useState(false);

  const fetchVerifications = async () => {
    try {
      setLoading(true);
      const data = await adminApi.getVerifications();
      const raw = Array.isArray(data) ? data : ((data as any).data || []);
      const seen = new Set();
      const unique = [];
      for (const item of raw) {
        const key = item.profileId || item.profile?.id || item.id;
        if (key && !seen.has(key)) {
          seen.add(key);
          unique.push(item);
        }
      }
      setItems(unique);
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

  useEffect(() => {
    if (typeof window !== "undefined") {
      const urlParams = new URLSearchParams(window.location.search);
      const urlSearch = urlParams.get("search");
      if (urlSearch) {
        setSearch(urlSearch);
      }
    }
  }, []);

  const updateStatus = async (id: string, action: string, reason?: string) => {
    if (action === "REJECTED" && !reason) {
      const item = items.find((i) => i.id === id);
      const name = item?.profile ? `${item.profile.firstName || ""} ${item.profile.lastName || ""}`.trim() : (item?.name || "Candidate");
      setRejectingItem({ id, name });
      setRejectionReason("");
      return;
    }

    try {
      setUpdating(true);
      await adminApi.updateVerificationStatus(id, action, reason);
      setRejectingItem(null);
      setRejectionReason("");
      await fetchVerifications();
    } catch (err: any) {
      alert("Failed to update status: " + (err.message || "Unknown error"));
    } finally {
      setUpdating(false);
    }
  };

  const handleConfirmRejection = () => {
    if (!rejectingItem) return;
    if (!rejectionReason.trim()) {
      alert("કૃપા કરીને અસ્વીકારનું કારણ દાખલ કરો (Please specify a rejection reason)");
      return;
    }
    updateStatus(rejectingItem.id, "REJECTED", rejectionReason.trim());
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
                padding: "10px 36px 10px 38px",
                fontSize: "12px",
                color: "#FFFFFF",
                outline: "none",
              }}
            />
            <span className="absolute text-admin-muted text-[13px] left-3 top-[11px]">🔍</span>
            {search && (
              <button
                type="button"
                onClick={() => {
                  setSearch("");
                  if (typeof window !== "undefined" && window.history.replaceState) {
                    const url = new URL(window.location.href);
                    url.searchParams.delete("search");
                    window.history.replaceState({}, "", url.toString());
                  }
                }}
                style={{
                  position: "absolute",
                  right: "10px",
                  top: "50%",
                  transform: "translateY(-50%)",
                  backgroundColor: "rgba(212, 175, 55, 0.2)",
                  border: "1px solid rgba(212, 175, 55, 0.4)",
                  borderRadius: "50%",
                  width: "20px",
                  height: "20px",
                  color: "#D4AF37",
                  cursor: "pointer",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  fontSize: "10px",
                  fontWeight: "bold",
                }}
                title="Clear Search"
              >
                ✕
              </button>
            )}
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
            <div className="overflow-x-auto border border-admin-gold/20 rounded-xl max-h-[750px] overflow-y-auto">
              <table className="w-full text-left border-collapse text-white text-xs">
                <thead className="sticky top-0 z-20 bg-[#0B1D3D] shadow-md border-b-2 border-admin-gold/40">
                  <tr>
                    <th className="bg-[#0B1D3D] font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[16px] tracking-[1px]">Member Details</th>
                    <th className="bg-[#0B1D3D] font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[16px] tracking-[1px]">Candidate Photos (2-5)</th>
                    <th className="bg-[#0B1D3D] font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[16px] tracking-[1px]">ID Proof (Front & Back)</th>
                    <th className="bg-[#0B1D3D] font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[16px] tracking-[1px]">Date</th>
                    <th className="bg-[#0B1D3D] font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[16px] tracking-[1px]">Status</th>
                    <th className="bg-[#0B1D3D] text-right font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[16px] tracking-[1px]">Actions</th>
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
                                {photos.map((pUrl, idx) => (
                                  <CandidatePhotoThumb
                                    key={idx}
                                    url={getFullUrl(pUrl)}
                                    idx={idx}
                                    memberName={memberName}
                                    onZoom={(url, title) => setPreviewImage({ url, title })}
                                  />
                                ))}
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
                            <DocumentThumbnail
                              url={frontUrl}
                              label={item.documentType || "ID Proof"}
                              side="front"
                              memberName={memberName}
                              onZoom={(url, title) => setPreviewImage({ url, title })}
                            />
                            <DocumentThumbnail
                              url={backUrl}
                              label={item.documentType || "ID Proof"}
                              side="back"
                              memberName={memberName}
                              onZoom={(url, title) => setPreviewImage({ url, title })}
                            />
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
                maxWidth: "92vw",
                maxHeight: "88vh",
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                gap: "12px",
                width: isPdf(previewImage.url) ? "750px" : "auto",
              }}
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex justify-between items-center w-full bg-admin-card/95 px-4 py-2.5 rounded-xl border border-admin-gold/30 shadow-lg">
                <span className="font-extrabold text-admin-gold text-xs tracking-wider">
                  {previewImage.title}
                </span>
                <div className="flex items-center gap-3">
                  <a
                    href={previewImage.url}
                    target="_blank"
                    rel="noreferrer"
                    className="text-[11px] text-white hover:text-admin-gold font-bold underline flex items-center gap-1"
                  >
                    <span>Open Original</span> ↗
                  </a>
                  <button
                    onClick={() => setPreviewImage(null)}
                    className="text-gray-400 hover:text-white text-lg font-bold px-2 py-0.5 leading-none rounded hover:bg-white/10"
                  >
                    ✕
                  </button>
                </div>
              </div>

              {isPdf(previewImage.url) ? (
                <div className="w-full h-[65vh] bg-[#071224] rounded-2xl border-2 border-admin-gold/50 flex flex-col items-center justify-center p-8 text-center shadow-2xl">
                  <span className="text-5xl mb-4">📄</span>
                  <h4 className="text-white font-bold text-base mb-2">PDF Verification Document</h4>
                  <p className="text-slate-400 text-xs mb-6 max-w-md">
                    This document was uploaded as a PDF file. You can view it directly in your browser tab or download it.
                  </p>
                  <a
                    href={previewImage.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="px-6 py-2.5 rounded-xl bg-admin-gold text-admin-bg font-extrabold text-xs shadow-lg hover:brightness-110 transition-all"
                  >
                    Open PDF Document ↗
                  </a>
                </div>
              ) : (
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
                  onError={(e) => {
                    (e.target as HTMLElement).style.display = "none";
                    const parent = (e.target as HTMLElement).parentElement;
                    if (parent && !parent.querySelector(".modal-img-error")) {
                      const errDiv = document.createElement("div");
                      errDiv.className = "modal-img-error p-8 text-center bg-[#071224] rounded-xl border border-admin-gold/40 text-white";
                      errDiv.innerHTML = `<div style="font-size: 32px; margin-bottom: 8px;">⚠️</div><div style="font-weight: 700; margin-bottom: 6px;">Image could not be loaded</div><div style="font-size: 11px; color: #94a3b8; margin-bottom: 12px;">The original image file may be missing or protected.</div><a href="${previewImage.url}" target="_blank" rel="noopener noreferrer" style="display: inline-block; padding: 6px 14px; background: rgba(212,175,55,0.2); border: 1px solid #D4AF37; border-radius: 8px; color: #D4AF37; font-size: 11px; font-weight: 700;">Open Direct URL ↗</a>`;
                      parent.appendChild(errDiv);
                    }
                  }}
                />
              )}
            </div>
          </div>
        )}

        {/* Dedicated Rejection Reason Modal */}
        {rejectingItem && (
          <div
            style={{
              position: "fixed",
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: "rgba(4, 16, 38, 0.85)",
              backdropFilter: "blur(10px)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              zIndex: 3000,
              padding: "20px",
            }}
            onClick={() => setRejectingItem(null)}
          >
            <div
              style={{
                backgroundColor: "#0D1B32",
                border: "1px solid rgba(244, 63, 94, 0.4)",
                borderRadius: "20px",
                padding: "28px",
                width: "100%",
                maxWidth: "520px",
                boxShadow: "0 25px 60px rgba(0,0,0,0.8)",
              }}
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-2">
                  <span className="text-xl">⚠️</span>
                  <h3 className="text-base font-extrabold text-white">
                    Reject Verification Proof
                  </h3>
                </div>
                <button
                  onClick={() => setRejectingItem(null)}
                  className="text-gray-400 hover:text-white font-bold"
                >
                  ✕
                </button>
              </div>

              <p className="text-xs text-slate-300 mb-4 leading-relaxed">
                Candidate: <strong className="text-admin-gold">{rejectingItem.name}</strong>
                <br />
                Please select or write a reason so the member can correct and re-upload valid proof:
              </p>

              {/* Quick Reason Pills */}
              <div className="flex flex-wrap gap-2 mb-4">
                {[
                  "સ્પષ્ટ ઓળખપત્ર દેખાતું નથી (Blurry / Unreadable ID)",
                  "નામમાં તફાવત છે (Name mismatch with profile)",
                  "આગળ અને પાછળ બંને બાજુ જરૂરી છે (Both Front & Back required)",
                  "અમાન્ય દસ્તાવેજ પ્રકાર (Invalid Document Type)",
                  "સરકારી ઓળખપત્ર અસ્પષ્ટ છે (Govt ID not legible)",
                ].map((reasonText, idx) => (
                  <button
                    key={idx}
                    type="button"
                    onClick={() => setRejectionReason(reasonText)}
                    style={{
                      padding: "6px 12px",
                      borderRadius: "8px",
                      backgroundColor: rejectionReason === reasonText ? "rgba(244, 63, 94, 0.3)" : "rgba(255, 255, 255, 0.05)",
                      border: rejectionReason === reasonText ? "1px solid #F43F5E" : "1px solid rgba(255, 255, 255, 0.15)",
                      color: rejectionReason === reasonText ? "#FDA4AF" : "#CBD5E1",
                      fontSize: "11px",
                      fontWeight: 600,
                      cursor: "pointer",
                    }}
                    className="hover:border-rose-400 transition-colors"
                  >
                    {reasonText}
                  </button>
                ))}
              </div>

              {/* Custom Input */}
              <div className="mb-6">
                <label className="text-[11px] font-bold text-admin-gold block mb-1">
                  Rejection Reason / અસ્વીકારનું કારણ:
                </label>
                <textarea
                  rows={3}
                  value={rejectionReason}
                  onChange={(e) => setRejectionReason(e.target.value)}
                  placeholder="Enter rejection reason for candidate..."
                  style={{
                    width: "100%",
                    backgroundColor: "#041026",
                    border: "1px solid rgba(212, 175, 55, 0.4)",
                    borderRadius: "10px",
                    padding: "10px 14px",
                    fontSize: "12px",
                    color: "#FFFFFF",
                    outline: "none",
                  }}
                />
              </div>

              {/* Modal Buttons */}
              <div className="flex justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setRejectingItem(null)}
                  style={{
                    padding: "10px 18px",
                    borderRadius: "10px",
                    backgroundColor: "transparent",
                    color: "#94A3B8",
                    border: "1px solid rgba(255, 255, 255, 0.2)",
                    fontSize: "12px",
                    fontWeight: 700,
                    cursor: "pointer",
                  }}
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={handleConfirmRejection}
                  disabled={updating || !rejectionReason.trim()}
                  style={{
                    padding: "10px 22px",
                    borderRadius: "10px",
                    backgroundColor: "#E11D48",
                    color: "#FFFFFF",
                    border: "none",
                    fontSize: "12px",
                    fontWeight: 800,
                    cursor: updating || !rejectionReason.trim() ? "not-allowed" : "pointer",
                    opacity: updating || !rejectionReason.trim() ? 0.6 : 1,
                  }}
                  className="hover:bg-rose-700 transition-colors shadow-lg"
                >
                  {updating ? "Saving..." : "Confirm Rejection"}
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}




"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { adminApi } from "@/lib/admin-api";

export default function AdvertisementsPage() {
  const [ads, setAds] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<any>(null);

  const [formTitle, setFormTitle] = useState("");
  const [formImageUrl, setFormImageUrl] = useState("");
  const [formTargetUrl, setFormTargetUrl] = useState("");
  const [formPlacement, setFormPlacement] = useState("HOME_BANNER");
  const [formIsActive, setFormIsActive] = useState(true);
  const [uploading, setUploading] = useState(false);

  const loadAds = async () => {
    try {
      setLoading(true);
      const data = await adminApi.getAdvertisements();
      setAds(data);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadAds();
  }, []);

  const openCreate = () => {
    setEditingItem(null);
    setFormTitle("");
    setFormImageUrl("");
    setFormTargetUrl("");
    setFormPlacement("HOME_BANNER");
    setFormIsActive(true);
    setIsModalOpen(true);
  };

  const openEdit = (ad: any) => {
    setEditingItem(ad);
    setFormTitle(ad.title || "");
    setFormImageUrl(ad.imageUrl || "");
    setFormTargetUrl(ad.targetUrl || "");
    setFormPlacement(ad.placement || "HOME_BANNER");
    setFormIsActive(ad.isActive !== false);
    setIsModalOpen(true);
  };

  const handleDelete = async (id: string, title: string) => {
    if (confirm(`Are you sure you want to delete "${title}"?`)) {
      try {
        await adminApi.deleteAdvertisement(id);
        loadAds();
      } catch (err) {
        alert("Failed to delete Advertisement");
      }
    }
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploading(true);
    const formData = new FormData();
    formData.append("file", file);

    try {
      const token = localStorage.getItem("adminToken") || localStorage.getItem("token");
      const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000/api/v1"}/storage/upload`, {
        method: "POST",
        headers: {
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        body: formData,
      });

      if (!res.ok) throw new Error("Upload failed");
      const data = await res.json();
      setFormImageUrl(data.url);
    } catch (err) {
      alert("Failed to upload file");
    } finally {
      setUploading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const payload: any = {
        title: formTitle,
        imageUrl: formImageUrl,
        placement: formPlacement,
        isActive: formIsActive,
      };
      
      if (formTargetUrl.trim() !== "") {
        payload.targetUrl = formTargetUrl.trim();
      }

      if (editingItem) {
        await adminApi.updateAdvertisement(editingItem.id, payload);
      } else {
        await adminApi.createAdvertisement(payload);
      }
      setIsModalOpen(false);
      loadAds();
    } catch (err) {
      alert("Error saving Advertisement");
    }
  };

  return (
    <AdminLayout title="Advertisement Management">
      <div style={{ display: "flex", flexDirection: "column", gap: "24px", paddingBottom: "48px" }}>
        
        {/* Header */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: "16px" }}>
          <div>
            <h1 style={{ fontSize: "28px", fontWeight: "900", color: "#FFFFFF", margin: "0 0 8px 0", display: "flex", alignItems: "center", gap: "12px", letterSpacing: "-0.5px" }}>
              <span style={{ filter: "drop-shadow(0 0 8px rgba(212,175,55,0.8))" }}>📢</span> 
              Advertisement Management
            </h1>
            <p style={{ color: "#8E9BAE", fontSize: "14px", margin: 0, fontWeight: 500 }}>
              Manage promotional content and advertisements displayed on the Flutter App.
            </p>
          </div>
          <button 
            onClick={openCreate}
            style={{
              padding: "12px 24px",
              borderRadius: "12px",
              background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
              color: "#041026",
              fontWeight: 900,
              fontSize: "13px",
              textTransform: "uppercase",
              letterSpacing: "0.8px",
              border: "none",
              cursor: "pointer",
              boxShadow: "0 4px 14px rgba(212, 175, 55, 0.4)",
              transition: "all 0.3s"
            }}
          >
            + New Advertisement
          </button>
        </div>
        
        {/* Main Content Area */}
        <div style={{
          backgroundColor: "rgba(13, 27, 50, 0.85)",
          backdropFilter: "blur(16px)",
          border: "1px solid rgba(212, 175, 55, 0.25)",
          borderRadius: "16px",
          padding: "24px",
          boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4)",
        }}>
          {loading ? (
            <div style={{ padding: "40px", textAlign: "center", color: "#8E9BAE" }}>Loading...</div>
          ) : (
            <div style={{ borderRadius: "12px", overflow: "hidden", border: "1px solid rgba(212, 175, 55, 0.2)" }}>
              <table style={{ width: "100%", textAlign: "left", fontSize: "13px", color: "#FFFFFF", borderCollapse: "collapse" }}>
                <thead>
                  <tr style={{ backgroundColor: "#041026", borderBottom: "1px solid rgba(212, 175, 55, 0.3)" }}>
                    <th style={{ padding: "14px 18px", fontWeight: 800, color: "#D4AF37" }}>Banner</th>
                    <th style={{ padding: "14px 18px", fontWeight: 800, color: "#D4AF37" }}>Title</th>
                    <th style={{ padding: "14px 18px", fontWeight: 800, color: "#D4AF37" }}>Placement</th>
                    <th style={{ padding: "14px 18px", fontWeight: 800, color: "#D4AF37" }}>Status</th>
                    <th style={{ padding: "14px 18px", fontWeight: 800, color: "#D4AF37", textAlign: "right" }}>Actions</th>
                  </tr>
                </thead>
                <tbody style={{ backgroundColor: "#0D1B32" }}>
                  {ads.length === 0 ? (
                    <tr>
                      <td colSpan={5} style={{ padding: "60px", textAlign: "center", color: "#8E9BAE" }}>
                        <div style={{ fontSize: "40px", marginBottom: "16px", opacity: 0.5 }}>🪧</div>
                        <h3 style={{ margin: "0 0 8px 0", color: "#FFFFFF", fontSize: "16px" }}>No Advertisements Yet</h3>
                        <p style={{ margin: 0, fontSize: "13px" }}>Click "+ New Advertisement" to create your first promotion.</p>
                      </td>
                    </tr>
                  ) : (
                    ads.map((ad: any) => (
                      <tr key={ad.id} style={{ borderBottom: "1px solid rgba(255,255,255,0.05)" }}>
                        <td style={{ padding: "12px 18px" }}>
                          {ad.imageUrl ? (
                            <img src={ad.imageUrl} alt={ad.title} style={{ height: "40px", width: "80px", objectFit: "cover", borderRadius: "6px" }} />
                          ) : (
                            <span style={{ color: "#8E9BAE", fontStyle: "italic" }}>No Image</span>
                          )}
                        </td>
                        <td style={{ padding: "12px 18px", fontWeight: 600 }}>{ad.title}</td>
                        <td style={{ padding: "12px 18px" }}>{ad.placement}</td>
                        <td style={{ padding: "12px 18px" }}>
                          <span style={{
                            padding: "4px 10px",
                            borderRadius: "20px",
                            fontSize: "11px",
                            fontWeight: 700,
                            backgroundColor: ad.isActive ? "rgba(46, 213, 115, 0.15)" : "rgba(255, 71, 87, 0.15)",
                            color: ad.isActive ? "#2ed573" : "#ff4757",
                            border: `1px solid ${ad.isActive ? "rgba(46, 213, 115, 0.3)" : "rgba(255, 71, 87, 0.3)"}`
                          }}>
                            {ad.isActive ? "Active" : "Inactive"}
                          </span>
                        </td>
                        <td style={{ padding: "12px 18px", textAlign: "right" }}>
                          <button 
                            onClick={() => openEdit(ad)}
                            style={{ background: "rgba(212, 175, 55, 0.1)", color: "#D4AF37", border: "1px solid rgba(212, 175, 55, 0.3)", padding: "6px 12px", borderRadius: "6px", marginRight: "8px", cursor: "pointer", fontWeight: 600 }}
                          >
                            Edit
                          </button>
                          <button 
                            onClick={() => handleDelete(ad.id, ad.title)}
                            style={{ background: "rgba(255, 71, 87, 0.1)", color: "#ff4757", border: "1px solid rgba(255, 71, 87, 0.3)", padding: "6px 12px", borderRadius: "6px", cursor: "pointer", fontWeight: 600 }}
                          >
                            Delete
                          </button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Modal */}
        {isModalOpen && (
          <div style={{ position: "fixed", top: 0, left: 0, right: 0, bottom: 0, backgroundColor: "rgba(0, 0, 0, 0.8)", backdropFilter: "blur(8px)", zIndex: 1000, display: "flex", alignItems: "center", justifyContent: "center", padding: "20px" }}>
            <div style={{ backgroundColor: "#0D1B32", border: "2px solid #D4AF37", borderRadius: "20px", width: "100%", maxWidth: "500px", boxShadow: "0 20px 50px rgba(0,0,0,0.8)", maxHeight: "90vh", display: "flex", flexDirection: "column", overflow: "hidden" }}>
              {/* Fixed Header */}
              <div style={{ padding: "24px 32px", borderBottom: "1px solid rgba(212,175,55,0.3)", display: "flex", justifyContent: "space-between", alignItems: "center", backgroundColor: "rgba(13, 27, 50, 0.95)" }}>
                <h2 style={{ color: "#FFFFFF", fontSize: "22px", margin: 0 }}>
                  {editingItem ? "Edit Advertisement" : "New Advertisement"}
                </h2>
                <button onClick={() => setIsModalOpen(false)} style={{ background: "none", border: "none", color: "#8E9BAE", fontSize: "28px", cursor: "pointer", padding: 0, lineHeight: 1 }}>&times;</button>
              </div>
              
              {/* Scrollable Form Body */}
              <div style={{ overflowY: "auto", padding: "32px", flex: 1 }}>
              <form onSubmit={handleSubmit} style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
                <div>
                  <label style={{ display: "block", color: "#8E9BAE", marginBottom: "6px", fontSize: "13px" }}>Title *</label>
                  <input required value={formTitle} onChange={e => setFormTitle(e.target.value)} type="text" style={{ width: "100%", padding: "10px", borderRadius: "8px", border: "1px solid rgba(212,175,55,0.3)", backgroundColor: "rgba(0,0,0,0.2)", color: "#FFF" }} />
                </div>
                
                <div>
                  <label style={{ display: "block", color: "#8E9BAE", marginBottom: "6px", fontSize: "13px" }}>Image URL (or Upload File) *</label>
                  <div style={{ display: "flex", gap: "8px" }}>
                    <input required value={formImageUrl} onChange={e => setFormImageUrl(e.target.value)} type="url" placeholder="https://" style={{ flex: 1, padding: "10px", borderRadius: "8px", border: "1px solid rgba(212,175,55,0.3)", backgroundColor: "rgba(0,0,0,0.2)", color: "#FFF" }} />
                    <label style={{ 
                      padding: "10px 16px", 
                      borderRadius: "8px", 
                      background: "rgba(212, 175, 55, 0.1)", 
                      color: "#D4AF37", 
                      border: "1px solid rgba(212, 175, 55, 0.3)", 
                      cursor: "pointer", 
                      fontWeight: 600,
                      display: "flex",
                      alignItems: "center"
                    }}>
                      {uploading ? "Uploading..." : "Upload"}
                      <input type="file" accept="image/*,application/pdf" onChange={handleFileUpload} style={{ display: "none" }} disabled={uploading} />
                    </label>
                  </div>
                  {formImageUrl && (
                    <div style={{ marginTop: "12px", border: "1px dashed rgba(212,175,55,0.4)", borderRadius: "8px", padding: "8px", textAlign: "center" }}>
                       <img src={formImageUrl} alt="Preview" style={{ maxHeight: "100px", maxWidth: "100%", borderRadius: "4px" }} onError={(e) => (e.currentTarget.style.display = 'none')} />
                    </div>
                  )}
                </div>

                <div>
                  <label style={{ display: "block", color: "#8E9BAE", marginBottom: "6px", fontSize: "13px" }}>Target URL (Optional link when clicked)</label>
                  <input value={formTargetUrl} onChange={e => setFormTargetUrl(e.target.value)} type="url" style={{ width: "100%", padding: "10px", borderRadius: "8px", border: "1px solid rgba(212,175,55,0.3)", backgroundColor: "rgba(0,0,0,0.2)", color: "#FFF" }} />
                </div>

                <div>
                  <label style={{ display: "block", color: "#8E9BAE", marginBottom: "6px", fontSize: "13px" }}>Placement</label>
                  <select value={formPlacement} onChange={e => setFormPlacement(e.target.value)} style={{ width: "100%", padding: "10px", borderRadius: "8px", border: "1px solid rgba(212,175,55,0.3)", backgroundColor: "rgba(0,0,0,0.2)", color: "#FFF" }}>
                    <option value="HOME_BANNER">Home Banner</option>
                    <option value="DIRECTORY_TOP">Directory Top</option>
                    <option value="POPUP">Popup</option>
                    <option value="PAVAN_PRERNADATA">1. Pavan Prernadata (Home Button)</option>
                    <option value="SAMAJ_SUPER_STARS">2. Samaj Super Stars (Home Button)</option>
                  </select>
                </div>

                <div style={{ display: "flex", alignItems: "center", gap: "10px", marginTop: "8px" }}>
                  <input 
                    type="checkbox" 
                    id="isActive" 
                    checked={formIsActive} 
                    onChange={e => setFormIsActive(e.target.checked)}
                    style={{ width: "18px", height: "18px", accentColor: "#D4AF37" }}
                  />
                  <label htmlFor="isActive" style={{ color: "#FFF", fontSize: "14px", cursor: "pointer" }}>Is Active</label>
                </div>

                <div style={{ display: "flex", gap: "12px", marginTop: "24px" }}>
                  <button type="button" onClick={() => setIsModalOpen(false)} style={{ flex: 1, padding: "12px", borderRadius: "8px", background: "transparent", color: "#8E9BAE", border: "1px solid #8E9BAE", fontWeight: 600, cursor: "pointer" }}>Cancel</button>
                  <button type="submit" style={{ flex: 1, padding: "12px", borderRadius: "8px", background: "#D4AF37", color: "#041026", border: "none", fontWeight: 800, cursor: "pointer" }}>Save</button>
                </div>
              </form>
              </div>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}

"use client";

import { useState, useEffect } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { fetchFromBackend, getImageUrl } from "@/lib/api";

export default function SamajPavanPrernadataManagementPage() {
  const [PavanPrernadatas, setPavanPrernadatas] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [uploading, setUploading] = useState(false);
  const [brokenImages, setBrokenImages] = useState<Record<string, boolean>>({});

  const [formData, setFormData] = useState({
    name: "",
    gujaratiName: "",
    photoUrl: "",
    description: "",
    designation: "",
    year: "",
    displayOrder: 0,
    isActive: true,
  });

  useEffect(() => {
    fetchPavanPrernadatas();
  }, []);

  const fetchPavanPrernadatas = async () => {
    setIsLoading(true);
    try {
      const token = localStorage.getItem("adminToken") || localStorage.getItem("token") || "";
      const res = await fetchFromBackend("/admin/pavan-prernadata", {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (res.statusCode === 200) {
        setPavanPrernadatas(res.data || []);
      }
    } catch (e) {
      console.error(e);
    }
    setIsLoading(false);
  };

  const openModal = (PavanPrernadata?: any) => {
    if (PavanPrernadata) {
      setEditingId(PavanPrernadata.id);
      setFormData({
        name: PavanPrernadata.name || "",
        gujaratiName: PavanPrernadata.gujaratiName || "",
        photoUrl: PavanPrernadata.photoUrl || "",
        description: PavanPrernadata.description || "",
        designation: PavanPrernadata.designation || "",
        year: PavanPrernadata.year || "",
        displayOrder: PavanPrernadata.displayOrder || 0,
        isActive: PavanPrernadata.isActive,
      });
    } else {
      setEditingId(null);
      setFormData({
        name: "", gujaratiName: "", photoUrl: "", description: "", designation: "", year: "", displayOrder: 0, isActive: true,
      });
    }
    setIsModalOpen(true);
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploading(true);
    const data = new FormData();
    data.append("file", file);

    try {
      const token = localStorage.getItem("adminToken") || localStorage.getItem("token") || "";
      const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL || "/api/v1"}/storage/upload`, {
        method: "POST",
        headers: {
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        body: data,
      });

      if (!res.ok) throw new Error("Upload failed");
      const json = await res.json();
      setFormData(prev => ({ ...prev, photoUrl: getImageUrl(json.url) }));
    } catch (err) {
      alert("Failed to upload file");
    } finally {
      setUploading(false);
    }
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    const token = localStorage.getItem("adminToken") || localStorage.getItem("token") || "";
    try {
      let res;
      if (editingId) {
        res = await fetchFromBackend(`/admin/pavan-prernadata/${editingId}`, {
          method: "PATCH",
          body: JSON.stringify({ ...formData, displayOrder: parseInt(formData.displayOrder.toString()) }),
          headers: { Authorization: `Bearer ${token}` }
        });
      } else {
        res = await fetchFromBackend(`/admin/pavan-prernadata`, {
          method: "POST",
          body: JSON.stringify({ ...formData, displayOrder: parseInt(formData.displayOrder.toString()) }),
          headers: { Authorization: `Bearer ${token}` }
        });
      }
      if (res.statusCode === 200 || res.statusCode === 201) {
        setIsModalOpen(false);
        fetchPavanPrernadatas();
      } else {
        alert("Failed to save.");
      }
    } catch (e) {
      console.error(e);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Are you sure you want to delete this record?")) return;
    const token = localStorage.getItem("adminToken") || localStorage.getItem("token") || "";
    try {
      const res = await fetchFromBackend(`/admin/pavan-prernadata/${id}`, {
        method: "DELETE",
        headers: { Authorization: `Bearer ${token}` }
      });
      if (res.statusCode === 200) {
        fetchPavanPrernadatas();
      }
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <AdminLayout title="PavanPrernadata Management">
      <div style={{ display: "flex", flexDirection: "column", gap: "24px", paddingBottom: "48px" }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: "16px" }}>
          <div>
            <h1 style={{ fontSize: "28px", fontWeight: "900", color: "#FFFFFF", margin: "0 0 8px 0", display: "flex", alignItems: "center", gap: "12px", letterSpacing: "-0.5px" }}>
              <span style={{ filter: "drop-shadow(0 0 8px rgba(212,175,55,0.8))" }}>🏆</span> 
              PavanPrernadata Management
            </h1>
            <p style={{ color: "#8E9BAE", fontSize: "14px", margin: 0, fontWeight: 500 }}>
              Manage the high-achieving members of the community.
            </p>
          </div>
          <button 
            onClick={() => openModal()}
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
            + Add PavanPrernadata
          </button>
        </div>
        
        {isLoading ? (
          <div style={{ padding: "60px", textAlign: "center", display: "flex", flexDirection: "column", alignItems: "center", gap: "16px" }}>
            <div style={{ width: "40px", height: "40px", border: "3px solid #D4AF37", borderTopColor: "transparent", borderRadius: "50%" }} className="animate-spin"></div>
            <p style={{ color: "#D4AF37", fontSize: "14px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "2px", margin: 0 }}>Loading records...</p>
          </div>
        ) : (
          <div style={{
            backgroundColor: "rgba(13, 27, 50, 0.85)",
            backdropFilter: "blur(16px)",
            border: "1px solid rgba(212, 175, 55, 0.25)",
            borderRadius: "16px",
            padding: "24px",
            boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4)",
          }}>
            <div style={{ borderRadius: "12px", overflow: "hidden", border: "1px solid rgba(212, 175, 55, 0.2)" }}>
              <table style={{ width: "100%", textAlign: "left", fontSize: "12px", color: "#FFFFFF", borderCollapse: "collapse" }}>
                <thead>
                  <tr style={{ backgroundColor: "#041026", borderBottom: "1px solid rgba(212, 175, 55, 0.3)" }}>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Photo</th>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Name</th>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Designation & Year</th>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Status</th>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", textAlign: "right" }}>Actions</th>
                  </tr>
                </thead>
                <tbody style={{ backgroundColor: "#0D1B32" }}>
                  {PavanPrernadatas.map((PavanPrernadata) => (
                    <tr key={PavanPrernadata.id} style={{ borderBottom: "1px solid rgba(212, 175, 55, 0.1)" }}>
                      <td style={{ padding: "14px 18px" }}>
                        {PavanPrernadata.photoUrl && !brokenImages[PavanPrernadata.id] ? (
                          <img 
                            src={getImageUrl(PavanPrernadata.photoUrl)} 
                            alt={PavanPrernadata.name} 
                            onError={() => setBrokenImages(prev => ({ ...prev, [PavanPrernadata.id]: true }))}
                            style={{ width: "40px", height: "40px", borderRadius: "50%", objectFit: "cover", border: "2px solid rgba(212,175,55,0.4)" }} 
                          />
                        ) : (
                          <div style={{ width: "40px", height: "40px", borderRadius: "50%", background: "linear-gradient(135deg, rgba(212,175,55,0.3) 0%, rgba(243,229,171,0.1) 100%)", color: "#D4AF37", display: "flex", alignItems: "center", justifyContent: "center", fontWeight: 800, fontSize: "12px", border: "1px solid rgba(212, 175, 55, 0.4)" }}>
                            {(PavanPrernadata.name || "N").charAt(0).toUpperCase()}
                          </div>
                        )}
                      </td>
                      <td style={{ padding: "14px 18px", fontWeight: 700, color: "#FFFFFF" }}>
                        <div style={{ fontSize: "13px" }}>{PavanPrernadata.name}</div>
                        {PavanPrernadata.gujaratiName && <div style={{ fontSize: "11px", color: "#8E9BAE" }}>{PavanPrernadata.gujaratiName}</div>}
                      </td>
                      <td style={{ padding: "14px 18px", color: "#CBD5E1" }}>
                        <div style={{ fontWeight: 600 }}>{PavanPrernadata.designation}</div>
                        <div style={{ fontSize: "11px", color: "#8E9BAE" }}>{PavanPrernadata.year}</div>
                      </td>
                      <td style={{ padding: "14px 18px" }}>
                        <span style={{
                          padding: "6px 12px",
                          borderRadius: "20px",
                          fontSize: "10px",
                          fontWeight: 800,
                          textTransform: "uppercase",
                          letterSpacing: "0.5px",
                          backgroundColor: PavanPrernadata.isActive ? "rgba(16, 185, 129, 0.15)" : "rgba(136, 19, 55, 0.6)",
                          color: PavanPrernadata.isActive ? "#10B981" : "#FDA4AF",
                          border: PavanPrernadata.isActive ? "1px solid rgba(16, 185, 129, 0.3)" : "1px solid rgba(244, 63, 94, 0.4)",
                        }}>
                          {PavanPrernadata.isActive ? 'Active' : 'Hidden'}
                        </span>
                      </td>
                      <td style={{ padding: "14px 18px", textAlign: "right" }}>
                        <div style={{ display: "flex", justifyContent: "flex-end", gap: "8px" }}>
                          <button onClick={() => openModal(PavanPrernadata)} style={{ padding: "6px 14px", borderRadius: "8px", fontSize: "11px", fontWeight: 800, cursor: "pointer", backgroundColor: "rgba(59, 130, 246, 0.15)", color: "#60A5FA", border: "1px solid rgba(59, 130, 246, 0.3)" }}>
                            Edit
                          </button>
                          <button onClick={() => handleDelete(PavanPrernadata.id)} style={{ padding: "6px 14px", borderRadius: "8px", fontSize: "11px", fontWeight: 800, cursor: "pointer", backgroundColor: "rgba(220, 38, 38, 0.15)", color: "#EF4444", border: "1px solid rgba(220, 38, 38, 0.3)" }}>
                            Delete
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                  {PavanPrernadatas.length === 0 && (
                    <tr>
                      <td colSpan={5} style={{ padding: "40px", textAlign: "center", color: "#8E9BAE", fontWeight: 600 }}>No PavanPrernadata records found.</td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {isModalOpen && (
          <div style={{ position: "fixed", top: 0, left: 0, right: 0, bottom: 0, backgroundColor: "rgba(0, 0, 0, 0.8)", backdropFilter: "blur(8px)", zIndex: 1000, display: "flex", alignItems: "center", justifyContent: "center", padding: "20px" }}>
            <div style={{ backgroundColor: "#0D1B32", border: "2px solid #D4AF37", borderRadius: "20px", width: "100%", maxWidth: "600px", maxHeight: "90vh", display: "flex", flexDirection: "column", overflow: "hidden", boxShadow: "0 20px 50px rgba(0,0,0,0.8)" }}>
              {/* Fixed Header */}
              <div style={{ padding: "24px 28px", borderBottom: "1px solid rgba(212,175,55,0.2)", display: "flex", justifyContent: "space-between", alignItems: "center", backgroundColor: "rgba(13, 27, 50, 0.95)", zIndex: 10 }}>
                <h2 style={{ margin: 0, fontSize: "20px", fontWeight: 800, color: "#FFFFFF", letterSpacing: "0.5px" }}>
                  {editingId ? 'Edit' : 'Add'} PavanPrernadata
                </h2>
                <button onClick={() => setIsModalOpen(false)} style={{ background: "none", border: "none", color: "#8E9BAE", fontSize: "28px", cursor: "pointer", padding: 0, lineHeight: 1 }}>&times;</button>
              </div>
              
              {/* Scrollable Form Body */}
              <div style={{ overflowY: "auto", flex: 1 }}>
                <form onSubmit={handleSave} style={{ padding: "28px", display: "flex", flexDirection: "column", gap: "20px" }}>
                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "20px" }}>
                  <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
                    <label style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 700, textTransform: "uppercase", letterSpacing: "1px" }}>Name (English)</label>
                    <input required type="text" value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})} style={{ width: "100%", background: "rgba(4, 16, 38, 0.6)", border: "1px solid rgba(212, 175, 55, 0.3)", borderRadius: "8px", padding: "12px 16px", color: "#FFFFFF", fontSize: "14px", fontWeight: 600, outline: "none" }} />
                  </div>
                  <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
                    <label style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 700, textTransform: "uppercase", letterSpacing: "1px" }}>Name (Gujarati)</label>
                    <input type="text" value={formData.gujaratiName} onChange={e => setFormData({...formData, gujaratiName: e.target.value})} style={{ width: "100%", background: "rgba(4, 16, 38, 0.6)", border: "1px solid rgba(212, 175, 55, 0.3)", borderRadius: "8px", padding: "12px 16px", color: "#FFFFFF", fontSize: "14px", fontWeight: 600, outline: "none" }} />
                  </div>
                </div>
                <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
                  <label style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 700, textTransform: "uppercase", letterSpacing: "1px" }}>Photo URL</label>
                  <div style={{ display: "flex", gap: "12px" }}>
                    <input type="text" placeholder="https://example.com/photo.jpg" value={formData.photoUrl} onChange={e => setFormData({...formData, photoUrl: e.target.value})} style={{ flex: 1, background: "rgba(4, 16, 38, 0.6)", border: "1px solid rgba(212, 175, 55, 0.3)", borderRadius: "8px", padding: "12px 16px", color: "#FFFFFF", fontSize: "14px", fontWeight: 600, outline: "none" }} />
                    <label style={{ padding: "12px 20px", background: "rgba(212, 175, 55, 0.15)", border: "1px solid rgba(212, 175, 55, 0.4)", borderRadius: "8px", color: "#D4AF37", cursor: "pointer", fontWeight: 700, display: "flex", alignItems: "center", gap: "8px" }}>
                      {uploading ? "Uploading..." : "Upload Image"}
                      <input type="file" accept="image/*" onChange={handleFileUpload} style={{ display: "none" }} disabled={uploading} />
                    </label>
                  </div>
                </div>
                <div style={{ display: "grid", gridTemplateColumns: "2fr 1fr", gap: "20px" }}>
                  <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
                    <label style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 700, textTransform: "uppercase", letterSpacing: "1px" }}>Designation / Achievement</label>
                    <input type="text" value={formData.designation} onChange={e => setFormData({...formData, designation: e.target.value})} style={{ width: "100%", background: "rgba(4, 16, 38, 0.6)", border: "1px solid rgba(212, 175, 55, 0.3)", borderRadius: "8px", padding: "12px 16px", color: "#FFFFFF", fontSize: "14px", fontWeight: 600, outline: "none" }} />
                  </div>
                  <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
                    <label style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 700, textTransform: "uppercase", letterSpacing: "1px" }}>Year</label>
                    <input type="text" placeholder="e.g. 2023" value={formData.year} onChange={e => setFormData({...formData, year: e.target.value})} style={{ width: "100%", background: "rgba(4, 16, 38, 0.6)", border: "1px solid rgba(212, 175, 55, 0.3)", borderRadius: "8px", padding: "12px 16px", color: "#FFFFFF", fontSize: "14px", fontWeight: 600, outline: "none", textAlign: "center" }} />
                  </div>
                </div>
                <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
                  <label style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 700, textTransform: "uppercase", letterSpacing: "1px" }}>Description</label>
                  <textarea rows={3} value={formData.description} onChange={e => setFormData({...formData, description: e.target.value})} style={{ width: "100%", background: "rgba(4, 16, 38, 0.6)", border: "1px solid rgba(212, 175, 55, 0.3)", borderRadius: "8px", padding: "12px 16px", color: "#FFFFFF", fontSize: "14px", fontWeight: 600, outline: "none", resize: "vertical" }} />
                </div>
                <div style={{ display: "flex", gap: "24px", alignItems: "center", padding: "12px", backgroundColor: "rgba(4,16,38,0.4)", borderRadius: "8px", border: "1px solid rgba(255,255,255,0.05)" }}>
                  <label style={{ display: "flex", alignItems: "center", gap: "10px", color: "#CBD5E1", fontSize: "13px", fontWeight: 600, cursor: "pointer" }}>
                    <input type="checkbox" checked={formData.isActive} onChange={e => setFormData({...formData, isActive: e.target.checked})} style={{ width: "18px", height: "18px", accentColor: "#D4AF37", cursor: "pointer" }} />
                    Is Active (Visible to public)
                  </label>
                  <label style={{ display: "flex", alignItems: "center", gap: "10px", color: "#CBD5E1", fontSize: "13px", fontWeight: 600 }}>
                    Display Order: 
                    <input type="number" value={formData.displayOrder} onChange={e => setFormData({...formData, displayOrder: parseInt(e.target.value) || 0})} style={{ width: "60px", background: "rgba(0,0,0,0.3)", border: "1px solid rgba(212, 175, 55, 0.3)", borderRadius: "6px", padding: "6px", color: "#FFFFFF", textAlign: "center", outline: "none", fontWeight: 700 }} />
                  </label>
                </div>
                
                <div style={{ display: "flex", justifyContent: "flex-end", gap: "12px", marginTop: "16px" }}>
                  <button type="button" onClick={() => setIsModalOpen(false)} style={{ padding: "12px 24px", borderRadius: "10px", background: "transparent", color: "#8E9BAE", border: "1px solid rgba(255,255,255,0.1)", fontWeight: 700, cursor: "pointer" }}>Cancel</button>
                  <button type="submit" style={{ padding: "12px 32px", borderRadius: "10px", background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)", color: "#041026", border: "none", fontWeight: 900, textTransform: "uppercase", letterSpacing: "1px", cursor: "pointer", boxShadow: "0 4px 15px rgba(212, 175, 55, 0.4)" }}>Save Record</button>
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

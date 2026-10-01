"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { adminApi, ParganaItem } from "@/lib/admin-api";

export default function AdminParganasPage() {
  const [parganas, setParganas] = useState<ParganaItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const [showModal, setShowModal] = useState(false);
  const [editingItem, setEditingItem] = useState<ParganaItem | null>(null);

  const [formName, setFormName] = useState("");
  const [formGujaratiName, setFormGujaratiName] = useState("");
  const [formDescription, setFormDescription] = useState("");
  const [formVillageCount, setFormVillageCount] = useState("");
  const [formDistrictRegion, setFormDistrictRegion] = useState("");
  const [formLeader, setFormLeader] = useState("");
  const [formPhone, setFormPhone] = useState("");
  const [formIsActive, setFormIsActive] = useState(true);

  const loadParganas = async () => {
    try {
      const data = await adminApi.getParganas();
      setParganas(data);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadParganas();
  }, []);

  const openCreate = () => {
    setEditingItem(null);
    setFormName("");
    setFormGujaratiName("");
    setFormDescription("");
    setFormVillageCount("");
    setFormDistrictRegion("");
    setFormLeader("");
    setFormPhone("");
    setFormIsActive(true);
    setShowModal(true);
  };

  const openEdit = (p: ParganaItem) => {
    setEditingItem(p);
    setFormName(p.name);
    setFormGujaratiName(p.gujaratiName || "");
    setFormDescription(p.description || "");
    setFormVillageCount(p.villageCount || "");
    setFormDistrictRegion(p.districtRegion || "");
    setFormLeader(p.leaderName || "");
    setFormPhone(p.contactPhone || "");
    setFormIsActive(p.isActive !== false);
    setShowModal(true);
  };

  const handleDelete = async (id: string, name: string) => {
    if (confirm(`Are you sure you want to delete "${name}"?`)) {
      try {
        await adminApi.deletePargana(id);
        loadParganas();
      } catch (err) {
        alert("Failed to delete Pargana");
      }
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const payload = {
        name: formName,
        gujaratiName: formGujaratiName,
        description: formDescription,
        villageCount: formVillageCount,
        districtRegion: formDistrictRegion,
        leaderName: formLeader,
        contactPhone: formPhone,
        isActive: formIsActive,
      };

      if (editingItem) {
        await adminApi.updatePargana(editingItem.id, payload);
      } else {
        await adminApi.createPargana(payload);
      }
      setShowModal(false);
      loadParganas();
    } catch (err) {
      alert("Error saving Pargana division");
    }
  };

  const filteredParganas = parganas.filter((p) =>
    (p.name + (p.gujaratiName || "") + (p.districtRegion || "") + (p.description || "")).toLowerCase().includes(searchTerm.toLowerCase())
  );

  const inputStyle = {
    width: "100%",
    backgroundColor: "rgba(4, 16, 38, 0.6)",
    border: "1px solid rgba(212, 175, 55, 0.3)",
    borderRadius: "12px",
    padding: "14px 16px",
    color: "#FFFFFF",
    fontSize: "14px",
    fontWeight: 600,
    outline: "none",
    transition: "all 0.3s ease",
    boxShadow: "inset 0 2px 10px rgba(0,0,0,0.2)"
  };

  return (
    <AdminLayout title="Pargana Management" subtitle="Manage Vankar Samaj regional divisions, village counts, Gujarati titles & contacts">
      <div style={{ display: "flex", flexDirection: "column", gap: "28px", paddingBottom: "48px" }}>
        
        {/* Top Control Bar */}
        <div style={{
          backgroundColor: "rgba(13, 27, 50, 0.85)",
          backdropFilter: "blur(16px)",
          border: "1px solid rgba(212, 175, 55, 0.25)",
          borderRadius: "20px",
          padding: "24px",
          boxShadow: "0 15px 40px rgba(0, 0, 0, 0.4)",
          display: "flex",
          gap: "20px",
          justifyContent: "space-between",
          alignItems: "center"
        }} className="flex-col md:flex-row">
          
          <div style={{ position: "relative", flex: 1, width: "100%" }}>
            <span style={{ position: "absolute", left: "16px", top: "50%", transform: "translateY(-50%)", fontSize: "16px", opacity: 0.7 }}>🔍</span>
            <input
              type="text"
              placeholder="Search pargana division by name, Gujarati title, district..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{ ...inputStyle, paddingLeft: "48px" }}
              className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]"
            />
          </div>

          <button
            onClick={openCreate}
            style={{
              padding: "14px 28px",
              borderRadius: "12px",
              background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
              color: "#041026",
              fontWeight: 900,
              fontSize: "14px",
              textTransform: "uppercase",
              letterSpacing: "1px",
              border: "none",
              cursor: "pointer",
              boxShadow: "0 10px 25px rgba(212, 175, 55, 0.3)",
              display: "flex",
              alignItems: "center",
              gap: "8px",
              transition: "all 0.3s ease",
              whiteSpace: "nowrap",
            }}
            className="hover:scale-[1.05] hover:shadow-[0_15px_35px_rgba(212,175,55,0.5)] active:scale-95 w-full md:w-auto justify-center"
          >
            <span style={{ fontSize: "18px" }}>+</span> Add New Pargana
          </button>
        </div>

        {/* Content Section */}
        {loading ? (
          <div style={{ padding: "64px", textAlign: "center", backgroundColor: "rgba(13, 27, 50, 0.6)", borderRadius: "20px", border: "1px solid rgba(212, 175, 55, 0.15)" }}>
            <div style={{ width: "40px", height: "40px", border: "3px solid #D4AF37", borderTopColor: "transparent", borderRadius: "50%", margin: "0 auto 16px" }} className="animate-spin"></div>
            <p style={{ color: "#D4AF37", fontSize: "14px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "2px" }}>Loading pargana divisions...</p>
          </div>
        ) : filteredParganas.length === 0 ? (
          <div style={{ padding: "64px", textAlign: "center", backgroundColor: "rgba(13, 27, 50, 0.6)", borderRadius: "20px", border: "1px solid rgba(212, 175, 55, 0.15)" }}>
            <div style={{ fontSize: "48px", marginBottom: "16px" }}>🏛️</div>
            <p style={{ color: "#FFFFFF", fontSize: "16px", fontWeight: 800, marginBottom: "8px" }}>No Pargana Divisions Found</p>
            <p style={{ color: "#8E9BAE", fontSize: "14px" }}>Try adjusting your search filter or click "+ Add New Pargana" to create one.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {filteredParganas.map((p) => (
              <div
                key={p.id}
                className="group"
                style={{
                  backgroundColor: "rgba(13, 27, 50, 0.85)",
                  backdropFilter: "blur(16px)",
                  border: "1px solid rgba(212, 175, 55, 0.25)",
                  borderRadius: "20px",
                  padding: "24px",
                  boxShadow: "0 15px 40px rgba(0, 0, 0, 0.4)",
                  display: "flex",
                  flexDirection: "column",
                  transition: "all 0.3s ease",
                  position: "relative",
                  overflow: "hidden"
                }}
              >
                {/* Decorative Accent */}
                <div style={{ position: "absolute", top: 0, right: 0, width: "80px", height: "80px", background: "radial-gradient(circle, rgba(212,175,55,0.2) 0%, rgba(0,0,0,0) 70%)", transform: "translate(30%, -30%)" }}></div>
                {/* Card Header */}
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: "20px", borderBottom: "1px solid rgba(212, 175, 55, 0.15)", paddingBottom: "16px" }}>
                  <div style={{ display: "flex", gap: "12px", alignItems: "flex-start" }}>
                    <div style={{
                      width: "44px", height: "44px", borderRadius: "12px", backgroundColor: "rgba(4, 16, 38, 0.8)", border: "1px solid rgba(212, 175, 55, 0.3)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "20px", boxShadow: "inset 0 0 10px rgba(0,0,0,0.5)"
                    }} className="group-hover:scale-110 transition-transform">
                      🏛️
                    </div>
                    <div>
                      <h4 style={{ fontSize: "16px", fontWeight: 900, color: "#D4AF37", lineHeight: 1.2, marginBottom: "4px" }}>{p.name}</h4>
                      {p.gujaratiName && (
                        <p style={{ fontSize: "14px", fontWeight: 700, color: "#FFFFFF", marginBottom: "4px" }}>{p.gujaratiName}</p>
                      )}
                    </div>
                  </div>
                  <span style={{
                    fontSize: "10px", fontWeight: 900, padding: "4px 8px", borderRadius: "8px", textTransform: "uppercase", letterSpacing: "1px",
                    backgroundColor: p.isActive !== false ? "rgba(16, 185, 129, 0.1)" : "rgba(225, 29, 72, 0.1)",
                    color: p.isActive !== false ? "#10B981" : "#E11D48",
                    border: p.isActive !== false ? "1px solid rgba(16, 185, 129, 0.3)" : "1px solid rgba(225, 29, 72, 0.3)",
                  }}>
                    {p.isActive !== false ? "ACTIVE" : "INACTIVE"}
                  </span>
                </div>

                {/* Card Specs */}
                <div style={{ display: "flex", flexDirection: "column", gap: "10px", flex: 1, marginBottom: "24px" }}>
                  {[{ label: "Village Count", value: p.computedVillageCount || p.villageCount },
                    { label: "Districts/Region", value: p.districtRegion },
                    { label: "Leader Name", value: p.leaderName || "N/A" },
                    { label: "Contact Phone", value: p.contactPhone || "N/A" },
                  ].map((spec, idx) => (
                    spec.value && (
                      <div key={idx} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "8px 12px", borderRadius: "10px", backgroundColor: "rgba(4, 16, 38, 0.4)", border: "1px solid rgba(212, 175, 55, 0.05)" }}>
                        <span style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 600 }}>{spec.label}:</span>
                        <span style={{ fontSize: "13px", color: "#FFFFFF", fontWeight: 700, textAlign: "right", maxWidth: "60%", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{spec.value}</span>
                      </div>
                    )
                  ))}
                  
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "8px 12px", borderRadius: "10px", backgroundColor: "rgba(212, 175, 55, 0.05)", border: "1px solid rgba(212, 175, 55, 0.2)" }}>
                    <span style={{ fontSize: "12px", color: "#D4AF37", fontWeight: 700 }}>Registered Profiles:</span>
                    <span style={{ fontSize: "16px", color: "#F3E5AB", fontWeight: 900 }}>{p.totalCount || 0}</span>
                  </div>
                </div>

                {/* Card Actions */}
                <div style={{ display: "flex", gap: "12px" }}>
                  <button
                    onClick={() => openEdit(p)}
                    style={{ flex: 1, padding: "10px", borderRadius: "10px", backgroundColor: "rgba(4, 16, 38, 0.8)", border: "1px solid rgba(212, 175, 55, 0.4)", color: "#D4AF37", fontSize: "12px", fontWeight: 800, cursor: "pointer", transition: "all 0.3s ease", display: "flex", justifyContent: "center", alignItems: "center", gap: "6px" }}
                    className="hover:bg-[#D4AF37] hover:text-black hover:shadow-[0_0_15px_rgba(212,175,55,0.4)]"
                  >
                    <span>✏️</span> Edit Details
                  </button>
                  <button
                    onClick={() => handleDelete(p.id, p.name)}
                    style={{ padding: "10px 16px", borderRadius: "10px", backgroundColor: "rgba(225, 29, 72, 0.1)", border: "1px solid rgba(225, 29, 72, 0.3)", color: "#E11D48", fontSize: "12px", fontWeight: 800, cursor: "pointer", transition: "all 0.3s ease", display: "flex", justifyContent: "center", alignItems: "center" }}
                    className="hover:bg-[#E11D48] hover:text-white"
                    title="Delete Pargana"
                  >
                    🗑️
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Modal Dialog */}
      {showModal && (
        <div style={{ position: "fixed", top: 0, left: 0, width: "100%", height: "100%", backgroundColor: "rgba(0, 0, 0, 0.8)", backdropFilter: "blur(8px)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 1000, padding: "24px" }}>
          <div style={{
            backgroundColor: "rgba(13, 27, 50, 0.95)",
            border: "1px solid rgba(212, 175, 55, 0.4)",
            borderRadius: "24px",
            width: "100%",
            maxWidth: "700px",
            maxHeight: "90vh",
            overflowY: "auto",
            boxShadow: "0 25px 60px rgba(0, 0, 0, 0.8)",
            display: "flex",
            flexDirection: "column",
          }}>
            <div style={{ padding: "24px 32px", borderBottom: "1px solid rgba(212, 175, 55, 0.2)", display: "flex", justifyContent: "space-between", alignItems: "center", position: "sticky", top: 0, backgroundColor: "rgba(13, 27, 50, 0.95)", zIndex: 10 }}>
              <h3 style={{ fontSize: "20px", fontWeight: 900, color: "#D4AF37", margin: 0, display: "flex", alignItems: "center", gap: "10px" }}>
                <span>🏛️</span> {editingItem ? "Edit Pargana Region" : "Add New Pargana Region"}
              </h3>
              <button onClick={() => setShowModal(false)} style={{ background: "none", border: "none", color: "#8E9BAE", fontSize: "24px", cursor: "pointer" }} className="hover:text-white">✕</button>
            </div>

            <form onSubmit={handleSubmit} style={{ padding: "32px", display: "flex", flexDirection: "column", gap: "24px" }}>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "20px" }} className="grid-cols-1 md:grid-cols-2">
                <div>
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>Pargana Name (English)</label>
                  <input type="text" required placeholder="e.g. 35 Gam Pargana (Idar)" value={formName} onChange={(e) => setFormName(e.target.value)} style={inputStyle} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
                </div>
                <div>
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>Gujarati Name (ગુજરાતી)</label>
                  <input type="text" placeholder="e.g. ૩૫ ગામ પરગણું (ઈડર)" value={formGujaratiName} onChange={(e) => setFormGujaratiName(e.target.value)} style={inputStyle} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
                </div>
              </div>

              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "20px" }} className="grid-cols-1 md:grid-cols-2">
                <div>
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>Village Count (ગામ સંખ્યા)</label>
                  <input type="text" placeholder="e.g. 35 Gam / ૩૫ ગામ" value={formVillageCount} onChange={(e) => setFormVillageCount(e.target.value)} style={inputStyle} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
                </div>
                <div>
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>District / Region Coverage</label>
                  <input type="text" placeholder="e.g. Idar, Sabarkantha, Aravalli" value={formDistrictRegion} onChange={(e) => setFormDistrictRegion(e.target.value)} style={inputStyle} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
                </div>
              </div>

              <div>
                <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>Description</label>
                <textarea rows={2} placeholder="Provide brief details about this division..." value={formDescription} onChange={(e) => setFormDescription(e.target.value)} style={{ ...inputStyle, resize: "vertical" }} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
              </div>

              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "20px" }} className="grid-cols-1 md:grid-cols-2">
                <div>
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>Regional Leader Name</label>
                  <input type="text" placeholder="Leader / Representative name" value={formLeader} onChange={(e) => setFormLeader(e.target.value)} style={inputStyle} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
                </div>
                <div>
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>Contact Phone</label>
                  <input type="text" placeholder="Phone number" value={formPhone} onChange={(e) => setFormPhone(e.target.value)} style={inputStyle} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
                </div>
              </div>

              <div style={{ display: "flex", alignItems: "center", gap: "12px", padding: "16px", backgroundColor: "rgba(4, 16, 38, 0.6)", borderRadius: "12px", border: "1px solid rgba(212, 175, 55, 0.2)" }}>
                <input type="checkbox" id="isActiveToggle" checked={formIsActive} onChange={(e) => setFormIsActive(e.target.checked)} style={{ width: "18px", height: "18px", accentColor: "#D4AF37", cursor: "pointer" }} />
                <label htmlFor="isActiveToggle" style={{ color: "#FFFFFF", fontWeight: 700, fontSize: "14px", cursor: "pointer", userSelect: "none" }}>Active (Show in Flutter app & Pargana overview)</label>
              </div>

              <div style={{ display: "flex", justifyContent: "flex-end", gap: "16px", marginTop: "16px", paddingTop: "24px", borderTop: "1px solid rgba(212, 175, 55, 0.2)" }}>
                <button type="button" onClick={() => setShowModal(false)} style={{ padding: "14px 24px", borderRadius: "12px", backgroundColor: "transparent", border: "1px solid #8E9BAE", color: "#8E9BAE", fontWeight: 800, fontSize: "14px", cursor: "pointer", transition: "all 0.3s ease" }} className="hover:bg-[#8E9BAE] hover:text-[#041026]">Cancel</button>
                <button type="submit" style={{ padding: "14px 32px", borderRadius: "12px", background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)", color: "#041026", fontWeight: 900, fontSize: "14px", border: "none", cursor: "pointer", boxShadow: "0 10px 25px rgba(212, 175, 55, 0.4)", transition: "all 0.3s ease" }} className="hover:scale-[1.05] hover:shadow-[0_15px_35px_rgba(212,175,55,0.6)] active:scale-95">Save Pargana</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}

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
<<<<<<< HEAD
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
=======
        <div className="bg-admin-navy border border-admin-gold/30 rounded-2xl p-4 sm:p-5 shadow-2xl flex flex-col sm:flex-row gap-4 justify-between items-center backdrop-blur-md">
          <div className="relative flex-1 w-full">
            <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-admin-gold/70 text-sm">
              🔍
            </div>
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
            <input
              type="text"
              placeholder="Search pargana division by name, Gujarati title, district..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
<<<<<<< HEAD
              style={{ ...inputStyle, paddingLeft: "48px" }}
              className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]"
=======
              className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl pl-10 pr-4 py-2.5 text-xs sm:text-sm text-white placeholder-gray-400 focus:outline-none focus:border-admin-gold focus:ring-1 focus:ring-[#D4AF37] transition-all"
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
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
<<<<<<< HEAD
          <div style={{ padding: "64px", textAlign: "center", backgroundColor: "rgba(13, 27, 50, 0.6)", borderRadius: "20px", border: "1px solid rgba(212, 175, 55, 0.15)" }}>
            <div style={{ width: "40px", height: "40px", border: "3px solid #D4AF37", borderTopColor: "transparent", borderRadius: "50%", margin: "0 auto 16px" }} className="animate-spin"></div>
            <p style={{ color: "#D4AF37", fontSize: "14px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "2px" }}>Loading pargana divisions...</p>
          </div>
        ) : filteredParganas.length === 0 ? (
          <div style={{ padding: "64px", textAlign: "center", backgroundColor: "rgba(13, 27, 50, 0.6)", borderRadius: "20px", border: "1px solid rgba(212, 175, 55, 0.15)" }}>
            <div style={{ fontSize: "48px", marginBottom: "16px" }}>🏛️</div>
            <p style={{ color: "#FFFFFF", fontSize: "16px", fontWeight: 800, marginBottom: "8px" }}>No Pargana Divisions Found</p>
            <p style={{ color: "#8E9BAE", fontSize: "14px" }}>Try adjusting your search filter or click "+ Add New Pargana" to create one.</p>
=======
          <div className="p-12 text-center bg-admin-navy/60 rounded-2xl border border-admin-gold/20">
            <div className="w-10 h-10 border-3 border-admin-gold border-t-transparent rounded-full animate-spin mx-auto mb-3"></div>
            <p className="text-admin-gold text-xs font-bold uppercase tracking-widest">Loading pargana divisions from API...</p>
          </div>
        ) : filteredParganas.length === 0 ? (
          <div className="p-12 text-center bg-admin-navy/60 rounded-2xl border border-admin-gold/20 space-y-3">
            <div className="text-3xl">🏛️</div>
            <p className="text-white font-bold text-sm">No Pargana Divisions Found</p>
            <p className="text-gray-400 text-xs">Try adjusting your search filter or click "+ Add New Pargana" to create one.</p>
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {filteredParganas.map((p) => (
              <div
                key={p.id}
<<<<<<< HEAD
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
=======
                className="bg-gradient-to-b from-[#0A162D] to-[#040C1A] border border-admin-gold/30 hover:border-admin-gold rounded-2xl p-5 shadow-xl hover:shadow-[#D4AF37]/10 transition-all duration-300 flex flex-col justify-between group"
              >
                <div>
                  {/* Card Header */}
                  <div className="flex justify-between items-start gap-3 mb-3 pb-3 border-b border-admin-gold/20">
                    <div className="flex items-start gap-3">
                      <div className="w-10 h-10 rounded-xl bg-admin-card-hover border border-admin-gold/40 flex items-center justify-center text-lg shadow-inner shrink-0 group-hover:scale-105 transition-all">
                        🏛️
                      </div>
                      <div>
                        <h4 className="text-base font-extrabold text-admin-gold leading-tight">{p.name}</h4>
                        {p.gujaratiName && (
                          <p className="text-sm font-bold text-white mt-0.5">{p.gujaratiName}</p>
                        )}
                        {p.description && (
                          <p className="text-xs text-gray-300 mt-1 line-clamp-2">{p.description}</p>
                        )}
                      </div>
                    </div>
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388

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

<<<<<<< HEAD
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
=======
                  {/* Card Specs */}
                  <div className="space-y-2 text-xs py-2">
                    {(p.computedVillageCount || p.villageCount) && (
                      <div className="flex justify-between items-center py-1 px-2.5 rounded-lg bg-admin-card-hover/60 border border-admin-gold/10">
                        <span className="text-gray-400">Village Count (ગામ):</span>
                        <span className="text-admin-gold font-bold">{p.computedVillageCount || p.villageCount}</span>
                      </div>
                    )}

                    {p.districtRegion && (
                      <div className="flex justify-between items-center py-1 px-2.5 rounded-lg bg-admin-card-hover/60 border border-admin-gold/10">
                        <span className="text-gray-400">Districts/Region:</span>
                        <span className="text-white font-medium text-right max-w-[60%] truncate">{p.districtRegion}</span>
                      </div>
                    )}

                    <div className="flex justify-between items-center py-1 px-2.5 rounded-lg bg-admin-card-hover/60 border border-admin-gold/10">
                      <span className="text-gray-400">Leader Name:</span>
                      <span className="text-white font-medium">{p.leaderName || "N/A"}</span>
                    </div>

                    <div className="flex justify-between items-center py-1 px-2.5 rounded-lg bg-admin-card-hover/60 border border-admin-gold/10">
                      <span className="text-gray-400">Contact Phone:</span>
                      <span className="text-white font-medium">{p.contactPhone || "N/A"}</span>
                    </div>

                    <div className="flex justify-between items-center py-1 px-2.5 rounded-lg bg-admin-card-hover/60 border border-admin-gold/10">
                      <span className="text-gray-400">Registered Profiles:</span>
                      <span className="text-[#E8C95A] font-extrabold">{p.totalCount || 0}</span>
                    </div>
                  </div>
                </div>

                {/* Card Action Buttons */}
                <div className="flex gap-2 pt-4 mt-2 border-t border-admin-gold/20">
                  <button
                    onClick={() => openEdit(p)}
                    className="flex-1 py-2 px-3 rounded-xl bg-admin-card-hover border border-admin-gold/40 text-admin-gold text-xs font-bold hover:bg-admin-gold hover:text-black transition-all cursor-pointer flex items-center justify-center gap-1.5 shadow-sm"
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
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
<<<<<<< HEAD
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
=======
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-admin-navy border border-admin-gold/50 rounded-2xl p-6 w-full max-w-lg space-y-5 max-h-[90vh] overflow-y-auto shadow-2xl">
            <div className="flex justify-between items-center pb-3 border-b border-admin-gold/20">
              <h3 className="text-lg font-extrabold text-admin-gold flex items-center gap-2">
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
                <span>🏛️</span> {editingItem ? "Edit Pargana Region" : "Add New Pargana Region"}
              </h3>
              <button onClick={() => setShowModal(false)} style={{ background: "none", border: "none", color: "#8E9BAE", fontSize: "24px", cursor: "pointer" }} className="hover:text-white">✕</button>
            </div>

            <form onSubmit={handleSubmit} style={{ padding: "32px", display: "flex", flexDirection: "column", gap: "24px" }}>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "20px" }} className="grid-cols-1 md:grid-cols-2">
                <div>
<<<<<<< HEAD
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>Pargana Name (English)</label>
                  <input type="text" required placeholder="e.g. 35 Gam Pargana (Idar)" value={formName} onChange={(e) => setFormName(e.target.value)} style={inputStyle} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
=======
                  <label className="block text-gray-300 font-semibold mb-1.5">Pargana Name (English)</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. 35 Gam Pargana (Idar)"
                    value={formName}
                    onChange={(e) => setFormName(e.target.value)}
                    className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-admin-gold"
                  />
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
                </div>
                <div>
<<<<<<< HEAD
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>Gujarati Name (ગુજરાતી)</label>
                  <input type="text" placeholder="e.g. ૩૫ ગામ પરગણું (ઈડર)" value={formGujaratiName} onChange={(e) => setFormGujaratiName(e.target.value)} style={inputStyle} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
=======
                  <label className="block text-gray-300 font-semibold mb-1.5">Gujarati Name (ગુજરાતી)</label>
                  <input
                    type="text"
                    placeholder="e.g. ૩૫ ગામ પરગણું (ઈડર)"
                    value={formGujaratiName}
                    onChange={(e) => setFormGujaratiName(e.target.value)}
                    className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-admin-gold"
                  />
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
                </div>
              </div>

              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "20px" }} className="grid-cols-1 md:grid-cols-2">
                <div>
<<<<<<< HEAD
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>Village Count (ગામ સંખ્યા)</label>
                  <input type="text" placeholder="e.g. 35 Gam / ૩૫ ગામ" value={formVillageCount} onChange={(e) => setFormVillageCount(e.target.value)} style={inputStyle} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
=======
                  <label className="block text-gray-300 font-semibold mb-1.5">Village Count (ગામ સંખ્યા)</label>
                  <input
                    type="text"
                    placeholder="e.g. 35 Gam / ૩૫ ગામ"
                    value={formVillageCount}
                    onChange={(e) => setFormVillageCount(e.target.value)}
                    className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-admin-gold"
                  />
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
                </div>
                <div>
<<<<<<< HEAD
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>District / Region Coverage</label>
                  <input type="text" placeholder="e.g. Idar, Sabarkantha, Aravalli" value={formDistrictRegion} onChange={(e) => setFormDistrictRegion(e.target.value)} style={inputStyle} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
=======
                  <label className="block text-gray-300 font-semibold mb-1.5">District / Region Coverage</label>
                  <input
                    type="text"
                    placeholder="e.g. Idar, Sabarkantha, Aravalli"
                    value={formDistrictRegion}
                    onChange={(e) => setFormDistrictRegion(e.target.value)}
                    className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-admin-gold"
                  />
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
                </div>
              </div>

              <div>
<<<<<<< HEAD
                <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>Description</label>
                <textarea rows={2} placeholder="Provide brief details about this division..." value={formDescription} onChange={(e) => setFormDescription(e.target.value)} style={{ ...inputStyle, resize: "vertical" }} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
=======
                <label className="block text-gray-300 font-semibold mb-1.5">Description</label>
                <textarea
                  rows={2}
                  placeholder="Provide brief details about this division..."
                  value={formDescription}
                  onChange={(e) => setFormDescription(e.target.value)}
                  className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-admin-gold"
                />
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
              </div>

              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "20px" }} className="grid-cols-1 md:grid-cols-2">
                <div>
<<<<<<< HEAD
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>Regional Leader Name</label>
                  <input type="text" placeholder="Leader / Representative name" value={formLeader} onChange={(e) => setFormLeader(e.target.value)} style={inputStyle} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
=======
                  <label className="block text-gray-300 font-semibold mb-1.5">Regional Leader Name</label>
                  <input
                    type="text"
                    placeholder="Leader / Representative name"
                    value={formLeader}
                    onChange={(e) => setFormLeader(e.target.value)}
                    className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-admin-gold"
                  />
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
                </div>
                <div>
<<<<<<< HEAD
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
=======
                  <label className="block text-gray-300 font-semibold mb-1.5">Contact Phone</label>
                  <input
                    type="text"
                    placeholder="Phone number"
                    value={formPhone}
                    onChange={(e) => setFormPhone(e.target.value)}
                    className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-admin-gold"
                  />
                </div>
              </div>

              <div className="flex items-center gap-3 pt-2 p-3 bg-admin-card-hover/80 rounded-xl border border-admin-gold/20">
                <input
                  type="checkbox"
                  id="isActiveToggle"
                  checked={formIsActive}
                  onChange={(e) => setFormIsActive(e.target.checked)}
                  className="w-4 h-4 accent-[#D4AF37] cursor-pointer"
                />
                <label htmlFor="isActiveToggle" className="text-white font-semibold cursor-pointer select-none">
                  Active (Show in Flutter app & Pargana overview)
                </label>
              </div>

              <div className="pt-3 flex justify-end gap-3 border-t border-admin-gold/20">
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="px-4 py-2.5 rounded-xl bg-gray-800 text-gray-300 font-bold hover:bg-gray-700 cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2.5 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#E8C95A] text-black font-extrabold hover:brightness-110 cursor-pointer shadow-md"
                >
                  Save Pargana
                </button>
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
              </div>
            </form>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}

"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatCard } from "@/components/admin/StatCard";
import {
  adminApi,
  StateItem,
  DistrictItem,
  TalukaItem,
  ParganaItem,
  VillageItem,
} from "@/lib/admin-api";

type ActiveTab = "states" | "districts" | "talukas" | "parganas" | "villages";

export default function AdminLocationsPage() {
  const [activeTab, setActiveTab] = useState<ActiveTab>("states");
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");

  // Data lists
  const [states, setStates] = useState<StateItem[]>([]);
  const [districts, setDistricts] = useState<DistrictItem[]>([]);
  const [talukas, setTalukas] = useState<TalukaItem[]>([]);
  const [parganas, setParganas] = useState<ParganaItem[]>([]);
  const [villages, setVillages] = useState<VillageItem[]>([]);

  // Modal State
  const [showModal, setShowModal] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);

  // Form Fields
  const [formStateId, setFormStateId] = useState("");
  const [formDistrictId, setFormDistrictId] = useState("");
  const [formTalukaId, setFormTalukaId] = useState("");
  const [formParganaId, setFormParganaId] = useState("");
  const [formName, setFormName] = useState("");
  const [formGujaratiName, setFormGujaratiName] = useState("");
  const [formCode, setFormCode] = useState("");
  const [formPincode, setFormPincode] = useState("");
  const [formIsActive, setFormIsActive] = useState(true);

  // Load active tab data
  const loadData = async () => {
    setLoading(true);
    try {
      if (activeTab === "states") {
        const data = await adminApi.getAdminStates();
        setStates(data);
      } else if (activeTab === "districts") {
        const [stData, distData] = await Promise.all([
          adminApi.getAdminStates(),
          adminApi.getAdminDistricts(),
        ]);
        setStates(stData);
        setDistricts(distData);
      } else if (activeTab === "talukas") {
        const [distData, talData] = await Promise.all([
          adminApi.getAdminDistricts(),
          adminApi.getAdminTalukas(),
        ]);
        setDistricts(distData);
        setTalukas(talData);
      } else if (activeTab === "parganas") {
        const data = await adminApi.getParganas();
        setParganas(data);
      } else if (activeTab === "villages") {
        const [parData, talData, vilData] = await Promise.all([
          adminApi.getParganas(),
          adminApi.getAdminTalukas(),
          adminApi.getAdminVillages({ search: searchTerm }),
        ]);
        setParganas(parData);
        setTalukas(talData);
        setVillages(vilData);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [activeTab]);

  useEffect(() => {
    if (activeTab === "villages") {
      const timer = setTimeout(() => {
        adminApi.getAdminVillages({ search: searchTerm }).then(setVillages);
      }, 300);
      return () => clearTimeout(timer);
    }
  }, [searchTerm]);

  const openCreateModal = () => {
    setEditingId(null);
    setFormStateId(states[0]?.id || "");
    setFormDistrictId(districts[0]?.id || "");
    setFormTalukaId(talukas[0]?.id || "");
    setFormParganaId(parganas[0]?.id || "");
    setFormName("");
    setFormGujaratiName("");
    setFormCode("");
    setFormPincode("");
    setFormIsActive(true);
    setShowModal(true);
  };

  const openEditModal = (item: any) => {
    setEditingId(item.id);
    setFormName(item.name || "");
    setFormGujaratiName(item.gujaratiName || "");
    setFormCode(item.code || "");
    setFormPincode(item.pincode || "");
    setFormIsActive(item.isActive !== false);
    if (activeTab === "districts") setFormStateId(item.stateId || "");
    if (activeTab === "talukas") setFormDistrictId(item.districtId || "");
    if (activeTab === "villages") {
      setFormParganaId(item.parganaId || "");
      setFormTalukaId(item.talukaId || "");
    }
    setShowModal(true);
  };

  const handleDelete = async (id: string, name: string) => {
    if (confirm(`Are you sure you want to deactivate "${name}"?`)) {
      try {
        if (activeTab === "states") await adminApi.deleteState(id);
        if (activeTab === "districts") await adminApi.deleteDistrict(id);
        if (activeTab === "talukas") await adminApi.deleteTaluka(id);
        if (activeTab === "villages") await adminApi.deleteVillage(id);
        loadData();
      } catch {
        alert("Failed to deactivate location");
      }
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (activeTab === "states") {
        const payload = { name: formName, gujaratiName: formGujaratiName, code: formCode || formName.toUpperCase().slice(0, 3), isActive: formIsActive };
        if (editingId) await adminApi.updateState(editingId, payload);
        else await adminApi.createState(payload);
      } else if (activeTab === "districts") {
        const payload = { stateId: formStateId, name: formName, gujaratiName: formGujaratiName, code: formCode, isActive: formIsActive };
        if (editingId) await adminApi.updateDistrict(editingId, payload);
        else await adminApi.createDistrict(payload);
      } else if (activeTab === "talukas") {
        const payload = { districtId: formDistrictId, name: formName, gujaratiName: formGujaratiName, code: formCode, isActive: formIsActive };
        if (editingId) await adminApi.updateTaluka(editingId, payload);
        else await adminApi.createTaluka(payload);
      } else if (activeTab === "villages") {
        const payload = { parganaId: formParganaId || undefined, talukaId: formTalukaId || undefined, name: formName, gujaratiName: formGujaratiName, pincode: formPincode, isActive: formIsActive };
        if (editingId) await adminApi.updateVillage(editingId, payload);
        else await adminApi.createVillage(payload);
      }
      setShowModal(false);
      loadData();
    } catch {
      alert("Error saving location entity");
    }
  };

  return (
    <AdminLayout title="Location Hierarchy Management">
      <div style={{ display: "flex", flexDirection: "column", gap: "28px", paddingBottom: "48px" }}>
        
        {/* Title Header */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div>
            <h1 style={{ fontSize: "28px", fontWeight: "900", color: "#FFFFFF", margin: "0 0 8px 0", display: "flex", alignItems: "center", gap: "12px", letterSpacing: "-0.5px" }}>
              <span style={{ filter: "drop-shadow(0 0 8px rgba(212,175,55,0.8))" }}>🌍</span> 
              Location Control Center
            </h1>
            <p style={{ color: "#8E9BAE", fontSize: "14px", margin: 0, fontWeight: 500 }}>
              Manage States, Districts, Talukas, Parganas, and Villages with hierarchical mapping
            </p>
          </div>
        </div>

        {/* Dynamic KPI Cards */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: "20px" }}>
          <StatCard title="Total States" value={states.length} icon="📌" change="Active" isPositive />
          <StatCard title="Total Districts" value={activeTab === 'districts' ? districts.length : 33} icon="📍" change="Gujarat" isPositive />
          <StatCard title="Total Talukas" value={activeTab === 'talukas' ? talukas.length : 252} icon="🏢" change="Mapped" isPositive />
          <StatCard title="Samaj Parganas" value={activeTab === 'parganas' ? parganas.length : 14} icon="🏛️" change="Verified" isPositive />
        </div>

        {/* Navigation Tabs */}
        <div 
          style={{ 
            background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
            backdropFilter: "blur(20px)",
            padding: "8px", 
            borderRadius: "16px", 
            border: "1px solid rgba(212, 175, 55, 0.3)", 
            display: "flex", 
            gap: "8px", 
            flexWrap: "wrap",
            boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.05)"
          }}
        >
          {[
            { id: "states", label: "📌 States", count: states.length },
            { id: "districts", label: "📍 Districts", count: districts.length },
            { id: "talukas", label: "🏢 Talukas", count: talukas.length },
            { id: "parganas", label: "🏛️ Parganas", count: parganas.length },
            { id: "villages", label: "🏡 Villages", count: villages.length },
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => {
                setActiveTab(tab.id as ActiveTab);
                setSearchTerm("");
              }}
              style={{
                flex: 1,
                minWidth: "120px",
                background: activeTab === tab.id ? "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)" : "transparent",
                color: activeTab === tab.id ? "#041026" : "#8E9BAE",
                border: "none",
                padding: "12px 16px",
                borderRadius: "10px",
                fontWeight: "900",
                fontSize: "13px",
                cursor: "pointer",
                transition: "all 0.3s ease",
                boxShadow: activeTab === tab.id ? "0 4px 15px rgba(212, 175, 55, 0.4)" : "none",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                gap: "8px",
                textTransform: "uppercase",
                letterSpacing: "0.5px"
              }}
              className={activeTab !== tab.id ? "hover:bg-[rgba(212,175,55,0.1)] hover:text-[#D4AF37]" : ""}
            >
              <span>{tab.label}</span>
              {tab.count > 0 && activeTab === tab.id && (
                <span style={{ backgroundColor: "rgba(0,0,0,0.2)", padding: "2px 8px", borderRadius: "10px", fontSize: "11px", fontWeight: 900 }}>
                  {tab.count}
                </span>
              )}
            </button>
          ))}
        </div>

        {/* Action Header Bar */}
        <div 
          style={{ 
            background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
            backdropFilter: "blur(20px)",
            padding: "20px", 
            borderRadius: "16px", 
            border: "1px solid rgba(212, 175, 55, 0.3)", 
            display: "flex", 
            gap: "16px", 
            flexWrap: "wrap",
            alignItems: "center",
            boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.05)"
          }}
        >
          <div style={{ flex: 1, position: "relative", minWidth: "250px" }}>
            <span style={{ position: "absolute", left: "16px", top: "50%", transform: "translateY(-50%)", color: "#D4AF37", fontSize: "16px" }}>🔍</span>
            <input
              type="text"
              placeholder={`Search ${activeTab} by name or Gujarati title...`}
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{
                width: "100%",
                background: "rgba(4, 16, 38, 0.6)",
                border: "1px solid rgba(212, 175, 55, 0.4)",
                borderRadius: "12px",
                padding: "12px 16px 12px 44px",
                color: "#FFFFFF",
                fontSize: "14px",
                outline: "none",
                transition: "all 0.3s ease",
                boxSizing: "border-box"
              }}
              className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)] placeholder:text-[#475569]"
            />
          </div>

          <button
            onClick={openCreateModal}
            style={{
              background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
              color: "#041026",
              border: "none",
              padding: "12px 24px",
              borderRadius: "12px",
              fontWeight: "900",
              fontSize: "13px",
              cursor: "pointer",
              transition: "all 0.3s ease",
              boxShadow: "0 4px 15px rgba(212, 175, 55, 0.4)",
              display: "flex",
              alignItems: "center",
              gap: "8px",
              textTransform: "uppercase",
              letterSpacing: "0.5px"
            }}
            className="hover:scale-[1.02] hover:shadow-[0_8px_25px_rgba(212,175,55,0.5)] active:scale-95"
          >
            <span style={{ fontSize: "18px" }}>+</span> ADD NEW {activeTab.slice(0, -1).toUpperCase()}
          </button>
        </div>

        {/* Grid List */}
        {loading ? (
          <div style={{ padding: "60px", textAlign: "center", background: "rgba(4, 16, 38, 0.6)", borderRadius: "20px", border: "1px solid rgba(212, 175, 55, 0.2)" }}>
            <div style={{ width: "40px", height: "40px", border: "3px solid #D4AF37", borderTopColor: "transparent", borderRadius: "50%", margin: "0 auto 16px" }} className="animate-spin"></div>
            <p style={{ color: "#D4AF37", fontSize: "14px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "2px", margin: 0 }}>Loading {activeTab}...</p>
          </div>
        ) : (
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(320px, 1fr))", gap: "20px" }}>
            {/* STATES TAB */}
            {activeTab === "states" &&
              states
                .filter((s) => (s.name + (s.gujaratiName || "")).toLowerCase().includes(searchTerm.toLowerCase()))
                .map((s) => (
                  <div key={s.id} style={{ background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)", borderRadius: "20px", border: "1px solid rgba(212, 175, 55, 0.3)", padding: "24px", display: "flex", flexDirection: "column", justifyContent: "space-between", boxShadow: "0 10px 30px rgba(0, 0, 0, 0.3)", transition: "all 0.3s ease" }} className="hover:border-[#D4AF37] hover:transform hover:-translate-y-1">
                    <div>
                      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: "16px" }}>
                        <div>
                          <h4 style={{ fontSize: "18px", fontWeight: "900", color: "#D4AF37", margin: "0 0 4px 0" }}>{s.name}</h4>
                          {s.gujaratiName && <p style={{ fontSize: "14px", fontWeight: "700", color: "#FFFFFF", margin: 0 }}>{s.gujaratiName}</p>}
                        </div>
                        <span style={{ padding: "4px 10px", fontSize: "10px", fontWeight: "900", borderRadius: "10px", textTransform: "uppercase", letterSpacing: "0.5px", backgroundColor: s.isActive ? "rgba(16, 185, 129, 0.15)" : "rgba(244, 63, 94, 0.15)", color: s.isActive ? "#10B981" : "#F43F5E", border: `1px solid ${s.isActive ? "rgba(16, 185, 129, 0.3)" : "rgba(244, 63, 94, 0.3)"}` }}>
                          {s.isActive ? "ACTIVE" : "INACTIVE"}
                        </span>
                      </div>
                      <div style={{ fontSize: "13px", padding: "16px 0", borderTop: "1px solid rgba(212, 175, 55, 0.15)", borderBottom: "1px solid rgba(212, 175, 55, 0.15)", margin: "16px 0", display: "flex", flexDirection: "column", gap: "10px" }}>
                        <div style={{ display: "flex", justifyContent: "space-between" }}><span style={{ color: "#8E9BAE" }}>State Code:</span> <strong style={{ color: "#FFFFFF" }}>{s.code}</strong></div>
                        <div style={{ display: "flex", justifyContent: "space-between" }}><span style={{ color: "#8E9BAE" }}>Districts Count:</span> <strong style={{ color: "#D4AF37" }}>{s._count?.districts || 0}</strong></div>
                      </div>
                    </div>
                    <div style={{ display: "flex", gap: "12px" }}>
                      <button onClick={() => openEditModal(s)} style={{ flex: 1, padding: "10px", borderRadius: "10px", background: "rgba(4, 16, 38, 0.8)", border: "1px solid rgba(212, 175, 55, 0.5)", color: "#D4AF37", fontSize: "12px", fontWeight: "800", cursor: "pointer", transition: "all 0.3s ease" }} className="hover:bg-[#D4AF37] hover:text-black">EDIT</button>
                      <button onClick={() => handleDelete(s.id, s.name)} style={{ padding: "10px 16px", borderRadius: "10px", background: "rgba(225, 29, 72, 0.1)", border: "1px solid rgba(225, 29, 72, 0.4)", color: "#F43F5E", fontSize: "12px", fontWeight: "800", cursor: "pointer", transition: "all 0.3s ease" }} className="hover:bg-[#E11D48] hover:text-white">DEACTIVATE</button>
                    </div>
                  </div>
                ))}

            {/* DISTRICTS TAB */}
            {activeTab === "districts" &&
              districts
                .filter((d) => (d.name + (d.gujaratiName || "")).toLowerCase().includes(searchTerm.toLowerCase()))
                .map((d) => (
                  <div key={d.id} style={{ background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)", borderRadius: "20px", border: "1px solid rgba(212, 175, 55, 0.3)", padding: "24px", display: "flex", flexDirection: "column", justifyContent: "space-between", boxShadow: "0 10px 30px rgba(0, 0, 0, 0.3)", transition: "all 0.3s ease" }} className="hover:border-[#D4AF37] hover:transform hover:-translate-y-1">
                    <div>
                      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: "16px" }}>
                        <div>
                          <h4 style={{ fontSize: "18px", fontWeight: "900", color: "#D4AF37", margin: "0 0 4px 0" }}>{d.name}</h4>
                          {d.gujaratiName && <p style={{ fontSize: "14px", fontWeight: "700", color: "#FFFFFF", margin: 0 }}>{d.gujaratiName}</p>}
                        </div>
                        <span style={{ padding: "4px 10px", fontSize: "10px", fontWeight: "900", borderRadius: "10px", textTransform: "uppercase", letterSpacing: "0.5px", backgroundColor: d.isActive ? "rgba(16, 185, 129, 0.15)" : "rgba(244, 63, 94, 0.15)", color: d.isActive ? "#10B981" : "#F43F5E", border: `1px solid ${d.isActive ? "rgba(16, 185, 129, 0.3)" : "rgba(244, 63, 94, 0.3)"}` }}>
                          {d.isActive ? "ACTIVE" : "INACTIVE"}
                        </span>
                      </div>
                      <div style={{ fontSize: "13px", padding: "16px 0", borderTop: "1px solid rgba(212, 175, 55, 0.15)", borderBottom: "1px solid rgba(212, 175, 55, 0.15)", margin: "16px 0", display: "flex", flexDirection: "column", gap: "10px" }}>
                        <div style={{ display: "flex", justifyContent: "space-between" }}><span style={{ color: "#8E9BAE" }}>State:</span> <strong style={{ color: "#FFFFFF" }}>{d.state?.name || "Gujarat"}</strong></div>
                        <div style={{ display: "flex", justifyContent: "space-between" }}><span style={{ color: "#8E9BAE" }}>Talukas Count:</span> <strong style={{ color: "#D4AF37" }}>{d._count?.talukas || 0}</strong></div>
                      </div>
                    </div>
                    <div style={{ display: "flex", gap: "12px" }}>
                      <button onClick={() => openEditModal(d)} style={{ flex: 1, padding: "10px", borderRadius: "10px", background: "rgba(4, 16, 38, 0.8)", border: "1px solid rgba(212, 175, 55, 0.5)", color: "#D4AF37", fontSize: "12px", fontWeight: "800", cursor: "pointer", transition: "all 0.3s ease" }} className="hover:bg-[#D4AF37] hover:text-black">EDIT</button>
                      <button onClick={() => handleDelete(d.id, d.name)} style={{ padding: "10px 16px", borderRadius: "10px", background: "rgba(225, 29, 72, 0.1)", border: "1px solid rgba(225, 29, 72, 0.4)", color: "#F43F5E", fontSize: "12px", fontWeight: "800", cursor: "pointer", transition: "all 0.3s ease" }} className="hover:bg-[#E11D48] hover:text-white">DEACTIVATE</button>
                    </div>
                  </div>
                ))}

            {/* TALUKAS TAB */}
            {activeTab === "talukas" &&
              talukas
                .filter((t) => (t.name + (t.gujaratiName || "")).toLowerCase().includes(searchTerm.toLowerCase()))
                .map((t) => (
                  <div key={t.id} style={{ background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)", borderRadius: "20px", border: "1px solid rgba(212, 175, 55, 0.3)", padding: "24px", display: "flex", flexDirection: "column", justifyContent: "space-between", boxShadow: "0 10px 30px rgba(0, 0, 0, 0.3)", transition: "all 0.3s ease" }} className="hover:border-[#D4AF37] hover:transform hover:-translate-y-1">
                    <div>
                      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: "16px" }}>
                        <div>
                          <h4 style={{ fontSize: "18px", fontWeight: "900", color: "#D4AF37", margin: "0 0 4px 0" }}>{t.name}</h4>
                          {t.gujaratiName && <p style={{ fontSize: "14px", fontWeight: "700", color: "#FFFFFF", margin: 0 }}>{t.gujaratiName}</p>}
                        </div>
                        <span style={{ padding: "4px 10px", fontSize: "10px", fontWeight: "900", borderRadius: "10px", textTransform: "uppercase", letterSpacing: "0.5px", backgroundColor: t.isActive ? "rgba(16, 185, 129, 0.15)" : "rgba(244, 63, 94, 0.15)", color: t.isActive ? "#10B981" : "#F43F5E", border: `1px solid ${t.isActive ? "rgba(16, 185, 129, 0.3)" : "rgba(244, 63, 94, 0.3)"}` }}>
                          {t.isActive ? "ACTIVE" : "INACTIVE"}
                        </span>
                      </div>
                      <div style={{ fontSize: "13px", padding: "16px 0", borderTop: "1px solid rgba(212, 175, 55, 0.15)", borderBottom: "1px solid rgba(212, 175, 55, 0.15)", margin: "16px 0", display: "flex", flexDirection: "column", gap: "10px" }}>
                        <div style={{ display: "flex", justifyContent: "space-between" }}><span style={{ color: "#8E9BAE" }}>District:</span> <strong style={{ color: "#FFFFFF" }}>{t.district?.name || "N/A"}</strong></div>
                        <div style={{ display: "flex", justifyContent: "space-between" }}><span style={{ color: "#8E9BAE" }}>Villages Count:</span> <strong style={{ color: "#D4AF37" }}>{t._count?.villages || 0}</strong></div>
                      </div>
                    </div>
                    <div style={{ display: "flex", gap: "12px" }}>
                      <button onClick={() => openEditModal(t)} style={{ flex: 1, padding: "10px", borderRadius: "10px", background: "rgba(4, 16, 38, 0.8)", border: "1px solid rgba(212, 175, 55, 0.5)", color: "#D4AF37", fontSize: "12px", fontWeight: "800", cursor: "pointer", transition: "all 0.3s ease" }} className="hover:bg-[#D4AF37] hover:text-black">EDIT</button>
                      <button onClick={() => handleDelete(t.id, t.name)} style={{ padding: "10px 16px", borderRadius: "10px", background: "rgba(225, 29, 72, 0.1)", border: "1px solid rgba(225, 29, 72, 0.4)", color: "#F43F5E", fontSize: "12px", fontWeight: "800", cursor: "pointer", transition: "all 0.3s ease" }} className="hover:bg-[#E11D48] hover:text-white">DEACTIVATE</button>
                    </div>
                  </div>
                ))}

            {/* PARGANAS TAB */}
            {activeTab === "parganas" &&
              parganas.map((p) => (
                <div key={p.id} style={{ background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)", borderRadius: "20px", border: "1px solid rgba(212, 175, 55, 0.3)", padding: "24px", display: "flex", flexDirection: "column", justifyContent: "space-between", boxShadow: "0 10px 30px rgba(0, 0, 0, 0.3)", transition: "all 0.3s ease" }} className="hover:border-[#D4AF37] hover:transform hover:-translate-y-1">
                  <div>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: "16px" }}>
                      <div>
                        <h4 style={{ fontSize: "18px", fontWeight: "900", color: "#D4AF37", margin: "0 0 4px 0" }}>{p.name}</h4>
                        {p.gujaratiName && <p style={{ fontSize: "14px", fontWeight: "700", color: "#FFFFFF", margin: 0 }}>{p.gujaratiName}</p>}
                      </div>
                      <span style={{ padding: "4px 10px", fontSize: "10px", fontWeight: "900", borderRadius: "10px", textTransform: "uppercase", letterSpacing: "0.5px", backgroundColor: p.isActive !== false ? "rgba(16, 185, 129, 0.15)" : "rgba(244, 63, 94, 0.15)", color: p.isActive !== false ? "#10B981" : "#F43F5E", border: `1px solid ${p.isActive !== false ? "rgba(16, 185, 129, 0.3)" : "rgba(244, 63, 94, 0.3)"}` }}>
                        {p.isActive !== false ? "ACTIVE" : "INACTIVE"}
                      </span>
                    </div>
                    <div style={{ fontSize: "13px", padding: "16px 0", borderTop: "1px solid rgba(212, 175, 55, 0.15)", margin: "16px 0 0 0", display: "flex", flexDirection: "column", gap: "10px" }}>
                      <div style={{ display: "flex", justifyContent: "space-between" }}><span style={{ color: "#8E9BAE" }}>Calculated Villages:</span> <strong style={{ color: "#D4AF37" }}>{p.computedVillageCount || p.villageCount || "N/A"}</strong></div>
                      <div style={{ display: "flex", justifyContent: "space-between" }}><span style={{ color: "#8E9BAE" }}>Leader Name:</span> <strong style={{ color: "#FFFFFF" }}>{p.leaderName || "N/A"}</strong></div>
                    </div>
                  </div>
                </div>
              ))}

            {/* VILLAGES TAB */}
            {activeTab === "villages" &&
              villages.map((v) => (
                <div key={v.id} style={{ background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)", borderRadius: "20px", border: "1px solid rgba(212, 175, 55, 0.3)", padding: "24px", display: "flex", flexDirection: "column", justifyContent: "space-between", boxShadow: "0 10px 30px rgba(0, 0, 0, 0.3)", transition: "all 0.3s ease" }} className="hover:border-[#D4AF37] hover:transform hover:-translate-y-1">
                  <div>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: "16px" }}>
                      <div>
                        <h4 style={{ fontSize: "18px", fontWeight: "900", color: "#D4AF37", margin: "0 0 4px 0" }}>{v.name}</h4>
                        {v.gujaratiName && <p style={{ fontSize: "14px", fontWeight: "700", color: "#FFFFFF", margin: 0 }}>{v.gujaratiName}</p>}
                      </div>
                      <span style={{ padding: "4px 10px", fontSize: "10px", fontWeight: "900", borderRadius: "10px", textTransform: "uppercase", letterSpacing: "0.5px", backgroundColor: v.isActive ? "rgba(16, 185, 129, 0.15)" : "rgba(244, 63, 94, 0.15)", color: v.isActive ? "#10B981" : "#F43F5E", border: `1px solid ${v.isActive ? "rgba(16, 185, 129, 0.3)" : "rgba(244, 63, 94, 0.3)"}` }}>
                        {v.isActive ? "ACTIVE" : "INACTIVE"}
                      </span>
                    </div>
                    <div style={{ fontSize: "13px", padding: "16px 0", borderTop: "1px solid rgba(212, 175, 55, 0.15)", borderBottom: "1px solid rgba(212, 175, 55, 0.15)", margin: "16px 0", display: "flex", flexDirection: "column", gap: "10px" }}>
                      <div style={{ display: "flex", justifyContent: "space-between" }}><span style={{ color: "#8E9BAE" }}>Pargana:</span> <strong style={{ color: "#FFFFFF" }}>{v.pargana?.name || "N/A"}</strong></div>
                      <div style={{ display: "flex", justifyContent: "space-between" }}><span style={{ color: "#8E9BAE" }}>Taluka:</span> <strong style={{ color: "#FFFFFF" }}>{v.taluka?.name || "N/A"}</strong></div>
                      {v.pincode && <div style={{ display: "flex", justifyContent: "space-between" }}><span style={{ color: "#8E9BAE" }}>Pincode:</span> <strong style={{ color: "#D4AF37" }}>{v.pincode}</strong></div>}
                    </div>
                  </div>
                  <div style={{ display: "flex", gap: "12px" }}>
                    <button onClick={() => openEditModal(v)} style={{ flex: 1, padding: "10px", borderRadius: "10px", background: "rgba(4, 16, 38, 0.8)", border: "1px solid rgba(212, 175, 55, 0.5)", color: "#D4AF37", fontSize: "12px", fontWeight: "800", cursor: "pointer", transition: "all 0.3s ease" }} className="hover:bg-[#D4AF37] hover:text-black">EDIT</button>
                    <button onClick={() => handleDelete(v.id, v.name)} style={{ padding: "10px 16px", borderRadius: "10px", background: "rgba(225, 29, 72, 0.1)", border: "1px solid rgba(225, 29, 72, 0.4)", color: "#F43F5E", fontSize: "12px", fontWeight: "800", cursor: "pointer", transition: "all 0.3s ease" }} className="hover:bg-[#E11D48] hover:text-white">DEACTIVATE</button>
                  </div>
                </div>
              ))}
          </div>
        )}
      </div>

      {/* Modal Dialog */}
      {showModal && (
        <div style={{ position: "fixed", inset: 0, backgroundColor: "rgba(0, 0, 0, 0.85)", backdropFilter: "blur(12px)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 100, padding: "24px" }}>
          <div 
            style={{ 
              background: "linear-gradient(145deg, rgba(13, 27, 50, 0.95) 0%, rgba(4, 12, 26, 0.98) 100%)", 
              border: "1px solid rgba(212, 175, 55, 0.5)", 
              borderRadius: "24px", 
              padding: "32px", 
              maxWidth: "600px", 
              width: "100%", 
              boxShadow: "0 25px 60px rgba(0, 0, 0, 0.8)",
              maxHeight: "90vh",
              overflowY: "auto"
            }}
          >
            <h3 style={{ fontSize: "24px", fontWeight: 900, color: "#FFFFFF", marginTop: 0, marginBottom: "24px", display: "flex", alignItems: "center", gap: "10px" }}>
              <span style={{ color: "#D4AF37" }}>✏️</span> {editingId ? `Edit ${activeTab.slice(0, -1)}` : `Add New ${activeTab.slice(0, -1)}`}
            </h3>

            <form onSubmit={handleSubmit} style={{ display: "flex", flexDirection: "column", gap: "20px" }}>
              {activeTab === "districts" && (
                <div>
                  <label style={{ display: "block", fontSize: "13px", color: "#8E9BAE", fontWeight: 800, marginBottom: "8px", textTransform: "uppercase" }}>State</label>
                  <select value={formStateId} onChange={(e) => setFormStateId(e.target.value)} style={{ width: "100%", padding: "14px 16px", backgroundColor: "rgba(4, 16, 38, 0.8)", border: "1px solid rgba(212, 175, 55, 0.4)", borderRadius: "12px", color: "#FFFFFF", fontSize: "14px", outline: "none" }}>
                    {states.map((s) => (<option key={s.id} value={s.id}>{s.name} ({s.gujaratiName})</option>))}
                  </select>
                </div>
              )}

              {activeTab === "talukas" && (
                <div>
                  <label style={{ display: "block", fontSize: "13px", color: "#8E9BAE", fontWeight: 800, marginBottom: "8px", textTransform: "uppercase" }}>District</label>
                  <select value={formDistrictId} onChange={(e) => setFormDistrictId(e.target.value)} style={{ width: "100%", padding: "14px 16px", backgroundColor: "rgba(4, 16, 38, 0.8)", border: "1px solid rgba(212, 175, 55, 0.4)", borderRadius: "12px", color: "#FFFFFF", fontSize: "14px", outline: "none" }}>
                    {districts.map((d) => (<option key={d.id} value={d.id}>{d.name} ({d.gujaratiName})</option>))}
                  </select>
                </div>
              )}

              {activeTab === "villages" && (
                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "16px" }}>
                  <div>
                    <label style={{ display: "block", fontSize: "13px", color: "#8E9BAE", fontWeight: 800, marginBottom: "8px", textTransform: "uppercase" }}>Pargana (Samaj)</label>
                    <select value={formParganaId} onChange={(e) => setFormParganaId(e.target.value)} style={{ width: "100%", padding: "14px 16px", backgroundColor: "rgba(4, 16, 38, 0.8)", border: "1px solid rgba(212, 175, 55, 0.4)", borderRadius: "12px", color: "#FFFFFF", fontSize: "14px", outline: "none" }}>
                      <option value="">Select Pargana (Optional)</option>
                      {parganas.map((p) => (<option key={p.id} value={p.id}>{p.name}</option>))}
                    </select>
                  </div>
                  <div>
                    <label style={{ display: "block", fontSize: "13px", color: "#8E9BAE", fontWeight: 800, marginBottom: "8px", textTransform: "uppercase" }}>Taluka (Govt)</label>
                    <select value={formTalukaId} onChange={(e) => setFormTalukaId(e.target.value)} style={{ width: "100%", padding: "14px 16px", backgroundColor: "rgba(4, 16, 38, 0.8)", border: "1px solid rgba(212, 175, 55, 0.4)", borderRadius: "12px", color: "#FFFFFF", fontSize: "14px", outline: "none" }}>
                      <option value="">Select Taluka (Optional)</option>
                      {talukas.map((t) => (<option key={t.id} value={t.id}>{t.name}</option>))}
                    </select>
                  </div>
                </div>
              )}

              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "16px" }}>
                <div>
                  <label style={{ display: "block", fontSize: "13px", color: "#8E9BAE", fontWeight: 800, marginBottom: "8px", textTransform: "uppercase" }}>Name (English)</label>
                  <input type="text" required placeholder="Name in English" value={formName} onChange={(e) => setFormName(e.target.value)} style={{ width: "100%", padding: "14px 16px", backgroundColor: "rgba(4, 16, 38, 0.8)", border: "1px solid rgba(212, 175, 55, 0.4)", borderRadius: "12px", color: "#FFFFFF", fontSize: "14px", outline: "none", boxSizing: "border-box" }} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
                </div>
                <div>
                  <label style={{ display: "block", fontSize: "13px", color: "#8E9BAE", fontWeight: 800, marginBottom: "8px", textTransform: "uppercase" }}>Gujarati Name</label>
                  <input type="text" placeholder="નામ ગુજરાતીમાં" value={formGujaratiName} onChange={(e) => setFormGujaratiName(e.target.value)} style={{ width: "100%", padding: "14px 16px", backgroundColor: "rgba(4, 16, 38, 0.8)", border: "1px solid rgba(212, 175, 55, 0.4)", borderRadius: "12px", color: "#FFFFFF", fontSize: "14px", outline: "none", boxSizing: "border-box" }} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
                </div>
              </div>

              {activeTab === "villages" && (
                <div>
                  <label style={{ display: "block", fontSize: "13px", color: "#8E9BAE", fontWeight: 800, marginBottom: "8px", textTransform: "uppercase" }}>Pincode</label>
                  <input type="text" placeholder="e.g. 383430" value={formPincode} onChange={(e) => setFormPincode(e.target.value)} style={{ width: "100%", padding: "14px 16px", backgroundColor: "rgba(4, 16, 38, 0.8)", border: "1px solid rgba(212, 175, 55, 0.4)", borderRadius: "12px", color: "#FFFFFF", fontSize: "14px", outline: "none", boxSizing: "border-box" }} className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]" />
                </div>
              )}

              <div style={{ display: "flex", alignItems: "center", gap: "10px", marginTop: "8px", padding: "12px", backgroundColor: "rgba(16, 185, 129, 0.05)", borderRadius: "12px", border: "1px solid rgba(16, 185, 129, 0.2)" }}>
                <input type="checkbox" id="locActive" checked={formIsActive} onChange={(e) => setFormIsActive(e.target.checked)} style={{ width: "18px", height: "18px", accentColor: "#D4AF37", cursor: "pointer" }} />
                <label htmlFor="locActive" style={{ color: "#FFFFFF", fontWeight: 700, fontSize: "14px", cursor: "pointer" }}>Active (Show in Flutter app)</label>
              </div>

              <div style={{ display: "flex", justifyContent: "flex-end", gap: "12px", paddingTop: "24px", borderTop: "1px solid rgba(212, 175, 55, 0.2)", marginTop: "8px" }}>
                <button type="button" onClick={() => setShowModal(false)} style={{ padding: "14px 24px", borderRadius: "12px", backgroundColor: "rgba(4, 16, 38, 0.8)", color: "#8E9BAE", border: "1px solid rgba(142, 155, 174, 0.3)", cursor: "pointer", fontWeight: 800, fontSize: "13px", transition: "all 0.3s ease", textTransform: "uppercase", letterSpacing: "1px" }} className="hover:text-white hover:border-white">
                  Cancel
                </button>
                <button type="submit" style={{ padding: "14px 24px", borderRadius: "12px", background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)", color: "#041026", border: "none", cursor: "pointer", fontWeight: 900, fontSize: "13px", transition: "all 0.3s ease", boxShadow: "0 4px 15px rgba(212, 175, 55, 0.4)", textTransform: "uppercase", letterSpacing: "1px" }} className="hover:scale-[1.02] hover:shadow-[0_8px_25px_rgba(212,175,55,0.5)]">
                  Save Location
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}

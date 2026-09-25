"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
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
    <AdminLayout title="Location Hierarchy Management" subtitle="Manage States, Districts, Talukas, Parganas, and Villages (State ➔ District ➔ Taluka ➔ Pargana ➔ Village)">
      <div className="space-y-6 pb-12">
        {/* Navigation Tabs */}
        <div className="bg-admin-navy border border-admin-gold/30 rounded-2xl p-2 flex flex-wrap gap-2 shadow-xl">
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
              className={`flex-1 min-w-[130px] py-3 px-4 rounded-xl text-xs sm:text-sm font-extrabold transition-all cursor-pointer flex items-center justify-center gap-2 ${
                activeTab === tab.id
                  ? "bg-gradient-to-r from-[#D4AF37] to-[#E8C95A] text-black shadow-lg scale-105"
                  : "text-gray-300 hover:bg-admin-card-hover hover:text-admin-gold"
              }`}
            >
              <span>{tab.label}</span>
              {tab.count > 0 && (
                <span className={`px-2 py-0.5 rounded-full text-[10px] ${activeTab === tab.id ? "bg-black/20 text-black" : "bg-admin-gold/20 text-admin-gold"}`}>
                  {tab.count}
                </span>
              )}
            </button>
          ))}
        </div>

        {/* Action Header Bar */}
        <div className="bg-admin-navy border border-admin-gold/30 rounded-2xl p-4 flex flex-col sm:flex-row gap-4 justify-between items-center shadow-2xl">
          <div className="relative flex-1 w-full">
            <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-admin-gold/70 text-sm">🔍</div>
            <input
              type="text"
              placeholder={`Search ${activeTab} by name or Gujarati title...`}
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl pl-10 pr-4 py-2.5 text-xs sm:text-sm text-white placeholder-gray-400 focus:outline-none focus:border-admin-gold"
            />
          </div>

          <button
            onClick={openCreateModal}
            className="w-full sm:w-auto px-5 py-2.5 rounded-xl bg-gradient-to-r from-[#D4AF37] via-[#E8C95A] to-[#D4AF37] text-black font-extrabold text-xs uppercase tracking-wider shadow-lg hover:brightness-110 active:scale-95 transition-all cursor-pointer flex items-center justify-center gap-2"
          >
            <span className="text-base font-black">+</span> Add New {activeTab.slice(0, -1)}
          </button>
        </div>

        {/* Grid List */}
        {loading ? (
          <div className="p-12 text-center bg-admin-navy/60 rounded-2xl border border-admin-gold/20">
            <div className="w-10 h-10 border-3 border-admin-gold border-t-transparent rounded-full animate-spin mx-auto mb-3"></div>
            <p className="text-admin-gold text-xs font-bold uppercase tracking-widest">Loading {activeTab} from database...</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            {/* STATES TAB */}
            {activeTab === "states" &&
              states
                .filter((s) => (s.name + (s.gujaratiName || "")).toLowerCase().includes(searchTerm.toLowerCase()))
                .map((s) => (
                  <div key={s.id} className="bg-gradient-to-b from-[#0A162D] to-[#040C1A] border border-admin-gold/30 hover:border-admin-gold rounded-2xl p-5 shadow-xl flex flex-col justify-between">
                    <div>
                      <div className="flex justify-between items-start mb-2">
                        <div>
                          <h4 className="text-base font-extrabold text-admin-gold">{s.name}</h4>
                          {s.gujaratiName && <p className="text-sm font-bold text-white">{s.gujaratiName}</p>}
                        </div>
                        <span className={`px-2.5 py-1 text-[10px] font-extrabold rounded-full border ${s.isActive ? "bg-emerald-500/15 text-emerald-400 border-emerald-500/30" : "bg-rose-500/15 text-rose-400 border-rose-500/30"}`}>
                          {s.isActive ? "ACTIVE" : "INACTIVE"}
                        </span>
                      </div>
                      <div className="text-xs space-y-1.5 border-t border-admin-gold/20 pt-3 my-3">
                        <div className="flex justify-between text-gray-400"><span>State Code:</span> <strong className="text-white">{s.code}</strong></div>
                        <div className="flex justify-between text-gray-400"><span>Districts Count:</span> <strong className="text-admin-gold">{s._count?.districts || 0}</strong></div>
                      </div>
                    </div>
                    <div className="flex gap-2 pt-2 border-t border-admin-gold/20">
                      <button onClick={() => openEditModal(s)} className="flex-1 py-2 rounded-xl bg-admin-card-hover border border-admin-gold/40 text-admin-gold text-xs font-bold hover:bg-admin-gold hover:text-black transition-all">Edit</button>
                      <button onClick={() => handleDelete(s.id, s.name)} className="py-2 px-3 rounded-xl bg-rose-950/40 border border-rose-800/40 text-rose-300 text-xs font-bold hover:bg-rose-800 hover:text-white transition-all">Deactivate</button>
                    </div>
                  </div>
                ))}

            {/* DISTRICTS TAB */}
            {activeTab === "districts" &&
              districts
                .filter((d) => (d.name + (d.gujaratiName || "")).toLowerCase().includes(searchTerm.toLowerCase()))
                .map((d) => (
                  <div key={d.id} className="bg-gradient-to-b from-[#0A162D] to-[#040C1A] border border-admin-gold/30 hover:border-admin-gold rounded-2xl p-5 shadow-xl flex flex-col justify-between">
                    <div>
                      <div className="flex justify-between items-start mb-2">
                        <div>
                          <h4 className="text-base font-extrabold text-admin-gold">{d.name}</h4>
                          {d.gujaratiName && <p className="text-sm font-bold text-white">{d.gujaratiName}</p>}
                        </div>
                        <span className={`px-2.5 py-1 text-[10px] font-extrabold rounded-full border ${d.isActive ? "bg-emerald-500/15 text-emerald-400 border-emerald-500/30" : "bg-rose-500/15 text-rose-400 border-rose-500/30"}`}>
                          {d.isActive ? "ACTIVE" : "INACTIVE"}
                        </span>
                      </div>
                      <div className="text-xs space-y-1.5 border-t border-admin-gold/20 pt-3 my-3">
                        <div className="flex justify-between text-gray-400"><span>State:</span> <strong className="text-white">{d.state?.name || "Gujarat"}</strong></div>
                        <div className="flex justify-between text-gray-400"><span>Talukas Count:</span> <strong className="text-admin-gold">{d._count?.talukas || 0}</strong></div>
                      </div>
                    </div>
                    <div className="flex gap-2 pt-2 border-t border-admin-gold/20">
                      <button onClick={() => openEditModal(d)} className="flex-1 py-2 rounded-xl bg-admin-card-hover border border-admin-gold/40 text-admin-gold text-xs font-bold hover:bg-admin-gold hover:text-black transition-all">Edit</button>
                      <button onClick={() => handleDelete(d.id, d.name)} className="py-2 px-3 rounded-xl bg-rose-950/40 border border-rose-800/40 text-rose-300 text-xs font-bold hover:bg-rose-800 hover:text-white transition-all">Deactivate</button>
                    </div>
                  </div>
                ))}

            {/* TALUKAS TAB */}
            {activeTab === "talukas" &&
              talukas
                .filter((t) => (t.name + (t.gujaratiName || "")).toLowerCase().includes(searchTerm.toLowerCase()))
                .map((t) => (
                  <div key={t.id} className="bg-gradient-to-b from-[#0A162D] to-[#040C1A] border border-admin-gold/30 hover:border-admin-gold rounded-2xl p-5 shadow-xl flex flex-col justify-between">
                    <div>
                      <div className="flex justify-between items-start mb-2">
                        <div>
                          <h4 className="text-base font-extrabold text-admin-gold">{t.name}</h4>
                          {t.gujaratiName && <p className="text-sm font-bold text-white">{t.gujaratiName}</p>}
                        </div>
                        <span className={`px-2.5 py-1 text-[10px] font-extrabold rounded-full border ${t.isActive ? "bg-emerald-500/15 text-emerald-400 border-emerald-500/30" : "bg-rose-500/15 text-rose-400 border-rose-500/30"}`}>
                          {t.isActive ? "ACTIVE" : "INACTIVE"}
                        </span>
                      </div>
                      <div className="text-xs space-y-1.5 border-t border-admin-gold/20 pt-3 my-3">
                        <div className="flex justify-between text-gray-400"><span>District:</span> <strong className="text-white">{t.district?.name || "N/A"}</strong></div>
                        <div className="flex justify-between text-gray-400"><span>Villages Count:</span> <strong className="text-admin-gold">{t._count?.villages || 0}</strong></div>
                      </div>
                    </div>
                    <div className="flex gap-2 pt-2 border-t border-admin-gold/20">
                      <button onClick={() => openEditModal(t)} className="flex-1 py-2 rounded-xl bg-admin-card-hover border border-admin-gold/40 text-admin-gold text-xs font-bold hover:bg-admin-gold hover:text-black transition-all">Edit</button>
                      <button onClick={() => handleDelete(t.id, t.name)} className="py-2 px-3 rounded-xl bg-rose-950/40 border border-rose-800/40 text-rose-300 text-xs font-bold hover:bg-rose-800 hover:text-white transition-all">Deactivate</button>
                    </div>
                  </div>
                ))}

            {/* PARGANAS TAB */}
            {activeTab === "parganas" &&
              parganas.map((p) => (
                <div key={p.id} className="bg-gradient-to-b from-[#0A162D] to-[#040C1A] border border-admin-gold/30 hover:border-admin-gold rounded-2xl p-5 shadow-xl flex flex-col justify-between">
                  <div>
                    <div className="flex justify-between items-start mb-2">
                      <div>
                        <h4 className="text-base font-extrabold text-admin-gold">{p.name}</h4>
                        {p.gujaratiName && <p className="text-sm font-bold text-white">{p.gujaratiName}</p>}
                      </div>
                      <span className={`px-2.5 py-1 text-[10px] font-extrabold rounded-full border ${p.isActive !== false ? "bg-emerald-500/15 text-emerald-400 border-emerald-500/30" : "bg-rose-500/15 text-rose-400 border-rose-500/30"}`}>
                        {p.isActive !== false ? "ACTIVE" : "INACTIVE"}
                      </span>
                    </div>
                    <div className="text-xs space-y-1.5 border-t border-admin-gold/20 pt-3 my-3">
                      <div className="flex justify-between text-gray-400"><span>Calculated Villages:</span> <strong className="text-admin-gold">{p.computedVillageCount || p.villageCount || "N/A"}</strong></div>
                      <div className="flex justify-between text-gray-400"><span>Leader Name:</span> <strong className="text-white">{p.leaderName || "N/A"}</strong></div>
                    </div>
                  </div>
                </div>
              ))}

            {/* VILLAGES TAB */}
            {activeTab === "villages" &&
              villages.map((v) => (
                <div key={v.id} className="bg-gradient-to-b from-[#0A162D] to-[#040C1A] border border-admin-gold/30 hover:border-admin-gold rounded-2xl p-5 shadow-xl flex flex-col justify-between">
                  <div>
                    <div className="flex justify-between items-start mb-2">
                      <div>
                        <h4 className="text-base font-extrabold text-admin-gold">{v.name}</h4>
                        {v.gujaratiName && <p className="text-sm font-bold text-white">{v.gujaratiName}</p>}
                      </div>
                      <span className={`px-2.5 py-1 text-[10px] font-extrabold rounded-full border ${v.isActive ? "bg-emerald-500/15 text-emerald-400 border-emerald-500/30" : "bg-rose-500/15 text-rose-400 border-rose-500/30"}`}>
                        {v.isActive ? "ACTIVE" : "INACTIVE"}
                      </span>
                    </div>
                    <div className="text-xs space-y-1.5 border-t border-admin-gold/20 pt-3 my-3">
                      <div className="flex justify-between text-gray-400"><span>Pargana:</span> <strong className="text-white">{v.pargana?.name || "N/A"}</strong></div>
                      <div className="flex justify-between text-gray-400"><span>Taluka:</span> <strong className="text-white">{v.taluka?.name || "N/A"}</strong></div>
                      {v.pincode && <div className="flex justify-between text-gray-400"><span>Pincode:</span> <strong className="text-admin-gold">{v.pincode}</strong></div>}
                    </div>
                  </div>
                  <div className="flex gap-2 pt-2 border-t border-admin-gold/20">
                    <button onClick={() => openEditModal(v)} className="flex-1 py-2 rounded-xl bg-admin-card-hover border border-admin-gold/40 text-admin-gold text-xs font-bold hover:bg-admin-gold hover:text-black transition-all">Edit</button>
                    <button onClick={() => handleDelete(v.id, v.name)} className="py-2 px-3 rounded-xl bg-rose-950/40 border border-rose-800/40 text-rose-300 text-xs font-bold hover:bg-rose-800 hover:text-white transition-all">Deactivate</button>
                  </div>
                </div>
              ))}
          </div>
        )}
      </div>

      {/* Modal Dialog */}
      {showModal && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-admin-navy border border-admin-gold/50 rounded-2xl p-6 w-full max-w-lg space-y-4 max-h-[90vh] overflow-y-auto shadow-2xl">
            <h3 className="text-lg font-extrabold text-admin-gold">
              {editingId ? `Edit ${activeTab.slice(0, -1)}` : `Add New ${activeTab.slice(0, -1)}`}
            </h3>

            <form onSubmit={handleSubmit} className="space-y-4 text-xs">
              {activeTab === "districts" && (
                <div>
                  <label className="block text-gray-300 font-semibold mb-1">State</label>
                  <select value={formStateId} onChange={(e) => setFormStateId(e.target.value)} className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white">
                    {states.map((s) => (<option key={s.id} value={s.id}>{s.name} ({s.gujaratiName})</option>))}
                  </select>
                </div>
              )}

              {activeTab === "talukas" && (
                <div>
                  <label className="block text-gray-300 font-semibold mb-1">District</label>
                  <select value={formDistrictId} onChange={(e) => setFormDistrictId(e.target.value)} className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white">
                    {districts.map((d) => (<option key={d.id} value={d.id}>{d.name} ({d.gujaratiName})</option>))}
                  </select>
                </div>
              )}

              {activeTab === "villages" && (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div>
                    <label className="block text-gray-300 font-semibold mb-1">Pargana (Samaj)</label>
                    <select value={formParganaId} onChange={(e) => setFormParganaId(e.target.value)} className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white">
                      <option value="">Select Pargana (Optional)</option>
                      {parganas.map((p) => (<option key={p.id} value={p.id}>{p.name}</option>))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-gray-300 font-semibold mb-1">Taluka (Govt)</label>
                    <select value={formTalukaId} onChange={(e) => setFormTalukaId(e.target.value)} className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white">
                      <option value="">Select Taluka (Optional)</option>
                      {talukas.map((t) => (<option key={t.id} value={t.id}>{t.name}</option>))}
                    </select>
                  </div>
                </div>
              )}

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-gray-300 font-semibold mb-1">Name (English)</label>
                  <input type="text" required placeholder="Name in English" value={formName} onChange={(e) => setFormName(e.target.value)} className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white" />
                </div>
                <div>
                  <label className="block text-gray-300 font-semibold mb-1">Gujarati Name (ગુજરાતી)</label>
                  <input type="text" placeholder="નામ ગુજરાતીમાં" value={formGujaratiName} onChange={(e) => setFormGujaratiName(e.target.value)} className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white" />
                </div>
              </div>

              {activeTab === "villages" && (
                <div>
                  <label className="block text-gray-300 font-semibold mb-1">Pincode</label>
                  <input type="text" placeholder="e.g. 383430" value={formPincode} onChange={(e) => setFormPincode(e.target.value)} className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white" />
                </div>
              )}

              <div className="flex items-center gap-2 pt-2">
                <input type="checkbox" id="locActive" checked={formIsActive} onChange={(e) => setFormIsActive(e.target.checked)} className="accent-[#D4AF37]" />
                <label htmlFor="locActive" className="text-white font-semibold cursor-pointer">Active (Show in Flutter app)</label>
              </div>

              <div className="pt-3 flex justify-end gap-3 border-t border-admin-gold/20">
                <button type="button" onClick={() => setShowModal(false)} className="px-4 py-2 rounded-xl bg-gray-800 text-gray-300 font-bold hover:bg-gray-700">Cancel</button>
                <button type="submit" className="px-5 py-2 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#E8C95A] text-black font-extrabold hover:brightness-110">Save Location</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}

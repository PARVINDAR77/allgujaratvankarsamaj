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

  return (
    <AdminLayout title="Pargana Management" subtitle="Manage Vankar Samaj regional divisions, village counts, Gujarati titles & contacts">
      <div className="space-y-6 pb-12">
        {/* Top Control Bar */}
        <div className="bg-admin-navy border border-admin-gold/30 rounded-2xl p-4 sm:p-5 shadow-2xl flex flex-col sm:flex-row gap-4 justify-between items-center backdrop-blur-md">
          <div className="relative flex-1 w-full">
            <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-admin-gold/70 text-sm">
              🔍
            </div>
            <input
              type="text"
              placeholder="Search pargana division by name, Gujarati title, district..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl pl-10 pr-4 py-2.5 text-xs sm:text-sm text-white placeholder-gray-400 focus:outline-none focus:border-admin-gold focus:ring-1 focus:ring-[#D4AF37] transition-all"
            />
          </div>

          <button
            onClick={openCreate}
            className="w-full sm:w-auto px-5 py-2.5 rounded-xl bg-gradient-to-r from-[#D4AF37] via-[#E8C95A] to-[#D4AF37] text-black font-extrabold text-xs uppercase tracking-wider shadow-lg hover:brightness-110 active:scale-95 transition-all cursor-pointer flex items-center justify-center gap-2"
          >
            <span className="text-base font-black">+</span> Add New Pargana
          </button>
        </div>

        {/* Content Section */}
        {loading ? (
          <div className="p-12 text-center bg-admin-navy/60 rounded-2xl border border-admin-gold/20">
            <div className="w-10 h-10 border-3 border-admin-gold border-t-transparent rounded-full animate-spin mx-auto mb-3"></div>
            <p className="text-admin-gold text-xs font-bold uppercase tracking-widest">Loading pargana divisions from API...</p>
          </div>
        ) : filteredParganas.length === 0 ? (
          <div className="p-12 text-center bg-admin-navy/60 rounded-2xl border border-admin-gold/20 space-y-3">
            <div className="text-3xl">🏛️</div>
            <p className="text-white font-bold text-sm">No Pargana Divisions Found</p>
            <p className="text-gray-400 text-xs">Try adjusting your search filter or click "+ Add New Pargana" to create one.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredParganas.map((p) => (
              <div
                key={p.id}
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

                    <span
                      className={`px-2.5 py-1 text-[10px] font-extrabold rounded-full border shrink-0 uppercase tracking-wider ${
                        p.isActive !== false
                          ? "bg-emerald-500/15 text-emerald-400 border-emerald-500/30"
                          : "bg-rose-500/15 text-rose-400 border-rose-500/30"
                      }`}
                    >
                      {p.isActive !== false ? "ACTIVE" : "INACTIVE"}
                    </span>
                  </div>

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
                  >
                    <span>✏️</span> Edit Details
                  </button>
                  <button
                    onClick={() => handleDelete(p.id, p.name)}
                    className="py-2 px-3 rounded-xl bg-rose-950/40 border border-rose-800/40 text-rose-300 text-xs font-bold hover:bg-rose-800 hover:text-white transition-all cursor-pointer flex items-center justify-center gap-1.5 shadow-sm"
                  >
                    <span>🗑️</span> Delete
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Modal Dialog */}
      {showModal && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-admin-navy border border-admin-gold/50 rounded-2xl p-6 w-full max-w-lg space-y-5 max-h-[90vh] overflow-y-auto shadow-2xl">
            <div className="flex justify-between items-center pb-3 border-b border-admin-gold/20">
              <h3 className="text-lg font-extrabold text-admin-gold flex items-center gap-2">
                <span>🏛️</span> {editingItem ? "Edit Pargana Region" : "Add New Pargana Region"}
              </h3>
              <button
                onClick={() => setShowModal(false)}
                className="text-gray-400 hover:text-white text-lg font-bold cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4 text-xs">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-gray-300 font-semibold mb-1.5">Pargana Name (English)</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. 35 Gam Pargana (Idar)"
                    value={formName}
                    onChange={(e) => setFormName(e.target.value)}
                    className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-admin-gold"
                  />
                </div>

                <div>
                  <label className="block text-gray-300 font-semibold mb-1.5">Gujarati Name (ગુજરાતી)</label>
                  <input
                    type="text"
                    placeholder="e.g. ૩૫ ગામ પરગણું (ઈડર)"
                    value={formGujaratiName}
                    onChange={(e) => setFormGujaratiName(e.target.value)}
                    className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-admin-gold"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-gray-300 font-semibold mb-1.5">Village Count (ગામ સંખ્યા)</label>
                  <input
                    type="text"
                    placeholder="e.g. 35 Gam / ૩૫ ગામ"
                    value={formVillageCount}
                    onChange={(e) => setFormVillageCount(e.target.value)}
                    className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-admin-gold"
                  />
                </div>

                <div>
                  <label className="block text-gray-300 font-semibold mb-1.5">District / Region Coverage</label>
                  <input
                    type="text"
                    placeholder="e.g. Idar, Sabarkantha, Aravalli"
                    value={formDistrictRegion}
                    onChange={(e) => setFormDistrictRegion(e.target.value)}
                    className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-admin-gold"
                  />
                </div>
              </div>

              <div>
                <label className="block text-gray-300 font-semibold mb-1.5">Description</label>
                <textarea
                  rows={2}
                  placeholder="Provide brief details about this division..."
                  value={formDescription}
                  onChange={(e) => setFormDescription(e.target.value)}
                  className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-admin-gold"
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-gray-300 font-semibold mb-1.5">Regional Leader Name</label>
                  <input
                    type="text"
                    placeholder="Leader / Representative name"
                    value={formLeader}
                    onChange={(e) => setFormLeader(e.target.value)}
                    className="w-full bg-admin-card-hover border border-admin-gold/40 rounded-xl px-3.5 py-2.5 text-white placeholder-gray-500 focus:outline-none focus:border-admin-gold"
                  />
                </div>

                <div>
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
              </div>
            </form>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}

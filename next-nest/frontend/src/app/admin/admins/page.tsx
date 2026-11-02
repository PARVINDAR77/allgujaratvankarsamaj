"use client";

import React, { useEffect, useState, useMemo } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { adminApi, AdminSubAdminItem, CreateSubAdminDto, UpdateSubAdminDto } from "@/lib/admin-api";

interface SectionDef {
  key: string;
  name: string;
  gujarati: string;
  icon: string;
  category: "Overview & Users" | "Community & Directory" | "Content & Management";
  description: string;
  route: string;
}

const ADMIN_SECTIONS_CATALOG: SectionDef[] = [
  // Overview & Users
  {
    key: "dashboard",
    name: "Dashboard Overview",
    gujarati: "ડેશબોર્ડ આંકડાકીય વિગત",
    icon: "📊",
    category: "Overview & Users",
    description: "Access high-level stats, growth analytics, and dashboard metrics",
    route: "/admin/dashboard",
  },
  {
    key: "users",
    name: "User Accounts",
    gujarati: "સભ્યો એકાઉન્ટ મેનેજમેન્ટ",
    icon: "👥",
    category: "Overview & Users",
    description: "Manage registered members, account statuses, and account blocking",
    route: "/admin/users",
  },
  {
    key: "profiles",
    name: "Matrimonial Profiles",
    gujarati: "વર-કન્યા પ્રોફાઇલ્સ",
    icon: "👤",
    category: "Overview & Users",
    description: "Review marriage candidate profiles, approve/reject biodatas, and feature profiles",
    route: "/admin/profiles",
  },
  {
    key: "government_employees",
    name: "Govt. & Private Employees",
    gujarati: "કર્મચારી ડિરેક્ટરી",
    icon: "💼",
    category: "Overview & Users",
    description: "Manage government and corporate employee listings and designations",
    route: "/admin/government-employees",
  },
  {
    key: "verifications",
    name: "ID Proof Verifications (KYC)",
    gujarati: "ઓળખપત્ર ચકાસણી (KYC)",
    icon: "🛡️",
    category: "Overview & Users",
    description: "Review voter IDs, driving licenses, job cards with AI document verification",
    route: "/admin/verifications",
  },
  {
    key: "matches",
    name: "Matches & Compatibility",
    gujarati: "મેચમેકિંગ અને પસંદગી",
    icon: "💖",
    category: "Overview & Users",
    description: "Inspect candidate matches, proposals, and mutual compatibility data",
    route: "/admin/matches",
  },

  // Community & Directory
  {
    key: "education",
    name: "Education (5 Guidance Boxes)",
    gujarati: "શિક્ષણ માર્ગદર્શન (૫ બોક્સ)",
    icon: "🎓",
    category: "Community & Directory",
    description: "Manage educational guidance links, career videos, and learning materials",
    route: "/admin/education",
  },
  {
    key: "locations",
    name: "Locations & Parganas",
    gujarati: "ગામ, તાલુકા અને પરગણા",
    icon: "📍",
    category: "Community & Directory",
    description: "Manage states, districts, talukas, villages, and community parganas",
    route: "/admin/locations",
  },
  {
    key: "services",
    name: "Samaj Services & Vendors",
    gujarati: "સમાજ સેવાઓ / વેન્ડર્સ",
    icon: "🤝",
    category: "Community & Directory",
    description: "Manage community businesses, caterers, decorators, and service providers",
    route: "/admin/services",
  },
  {
    key: "pavan_prernadata",
    name: "Pavan Prernadata",
    gujarati: "પાવન પ્રેરણાદાતા",
    icon: "📖",
    category: "Community & Directory",
    description: "Manage inspirational social figures, community history, and biographies",
    route: "/admin/pavan-prernadata",
  },
  {
    key: "samaj_super_stars",
    name: "Samaj Super Stars",
    gujarati: "સમાજ સુપર સ્ટાર્સ",
    icon: "🌟",
    category: "Community & Directory",
    description: "Honor and showcase remarkable community achievers and role models",
    route: "/admin/samaj-super-stars",
  },
  {
    key: "samaj_ratna",
    name: "Samaj Ratna Awards",
    gujarati: "સમાજ રત્ન એવોર્ડ્સ",
    icon: "🏆",
    category: "Community & Directory",
    description: "Manage community jewel awards and recognized community luminaries",
    route: "/admin/samaj-ratna",
  },

  // Content & Management
  {
    key: "home_screen",
    name: "Home Screen Management",
    gujarati: "હોમ સ્ક્રીન કાર્ડ્સ અને બેનર્સ",
    icon: "📱",
    category: "Content & Management",
    description: "Customize top carousel banners and action button cards across web and app",
    route: "/admin/home-screen",
  },
  {
    key: "advertisements",
    name: "Advertisements (Box 1 & 2)",
    gujarati: "જાહેરાતો (બોક્સ ૧ અને ૨)",
    icon: "📢",
    category: "Content & Management",
    description: "Manage sponsored advertisements, external links, and promotional banners",
    route: "/admin/advertisements",
  },
  {
    key: "notifications",
    name: "Broadcast Notifications",
    gujarati: "સંદેશાઓ અને નોટિફિકેશન",
    icon: "🔔",
    category: "Content & Management",
    description: "Compose and dispatch broadcast push notifications to registered users",
    route: "/admin/notifications",
  },
  {
    key: "reports",
    name: "Reports & Grievances",
    gujarati: "ફરિયાદ નિવારણ અને રિપોર્ટ્સ",
    icon: "📈",
    category: "Content & Management",
    description: "Inspect member complaints, flagged profiles, and take moderation action",
    route: "/admin/reports",
  },
  {
    key: "otp_analytics",
    name: "OTP & SMS Analytics",
    gujarati: "OTP અને SMS એનાલિટિક્સ",
    icon: "💬",
    category: "Content & Management",
    description: "Inspect live verification codes, dispatch delivery logs, and SMS quotas",
    route: "/admin/otp-analytics",
  },
  {
    key: "settings",
    name: "System Settings",
    gujarati: "સિસ્ટમ કન્ફિગ્યુરેશન",
    icon: "⚙️",
    category: "Content & Management",
    description: "Configure platform settings, contact information, terms, and policies",
    route: "/admin/settings",
  },
];

export default function AdminAdminsPage() {
  const [admins, setAdmins] = useState<AdminSubAdminItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingAdmin, setEditingAdmin] = useState<AdminSubAdminItem | null>(null);
  const [submitting, setSubmitting] = useState(false);

  // Form Fields
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    password: "",
    status: "ACTIVE" as "ACTIVE" | "INACTIVE",
    permissions: [] as string[],
  });

  const loadAdmins = async () => {
    setLoading(true);
    try {
      const data = await adminApi.getSubAdmins();
      setAdmins(Array.isArray(data) ? data : []);
      setError(null);
    } catch (err: any) {
      console.error("Admins fetch error:", err);
      setError(err.message || "Failed to load admin staff accounts");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadAdmins();
  }, []);

  const openCreateModal = () => {
    setEditingAdmin(null);
    setFormData({
      name: "",
      email: "",
      phone: "",
      password: "",
      status: "ACTIVE",
      permissions: [
        "dashboard",
        "verifications",
        "profiles",
      ],
    });
    setError(null);
    setIsModalOpen(true);
  };

  const openEditModal = (admin: AdminSubAdminItem) => {
    setEditingAdmin(admin);
    setFormData({
      name: admin.name || "",
      email: admin.email || "",
      phone: admin.phone || "",
      password: "",
      status: admin.status || "ACTIVE",
      permissions: Array.isArray(admin.permissions) ? admin.permissions : [],
    });
    setError(null);
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setEditingAdmin(null);
  };

  const togglePermission = (key: string) => {
    setFormData((prev) => {
      const current = prev.permissions;
      if (current.includes(key)) {
        return { ...prev, permissions: current.filter((k) => k !== key) };
      } else {
        return { ...prev, permissions: [...current, key] };
      }
    });
  };

  const selectAllPermissions = () => {
    setFormData((prev) => ({
      ...prev,
      permissions: ADMIN_SECTIONS_CATALOG.map((s) => s.key),
    }));
  };

  const clearAllPermissions = () => {
    setFormData((prev) => ({
      ...prev,
      permissions: [],
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name.trim()) {
      alert("કૃપા કરીને સબ-એડમિનનું નામ દાખલ કરો (Please enter name)");
      return;
    }
    if (!formData.email.trim()) {
      alert("કૃપા કરીને ઇમેઇલ સરનામું દાખલ કરો (Please enter email)");
      return;
    }
    if (!editingAdmin && (!formData.password || formData.password.length < 6)) {
      alert("પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ (Password must be at least 6 characters)");
      return;
    }

    setSubmitting(true);
    setError(null);

    try {
      if (editingAdmin) {
        // Update existing sub-admin
        const updatePayload: UpdateSubAdminDto = {
          name: formData.name.trim(),
          phone: formData.phone.trim() || undefined,
          status: formData.status,
          permissions: formData.permissions,
        };
        if (formData.password && formData.password.trim().length >= 6) {
          updatePayload.password = formData.password.trim();
        }
        await adminApi.updateSubAdmin(editingAdmin.id, updatePayload);
        setSuccessMsg(`સબ-એડમિન "${formData.name}" સફળતાપૂર્વક અપડેટ થયો (Updated successfully)`);
      } else {
        // Create new sub-admin
        const createPayload: CreateSubAdminDto = {
          name: formData.name.trim(),
          email: formData.email.trim().toLowerCase(),
          phone: formData.phone.trim() || undefined,
          password: formData.password.trim(),
          permissions: formData.permissions,
        };
        await adminApi.createSubAdmin(createPayload);
        setSuccessMsg(`નવો સબ-એડમિન "${formData.name}" સફળતાપૂર્વક બન્યો (Created successfully)`);
      }

      closeModal();
      await loadAdmins();
      setTimeout(() => setSuccessMsg(null), 5000);
    } catch (err: any) {
      console.error("Save admin error:", err);
      alert(err.message || "Failed to save sub-admin");
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (admin: AdminSubAdminItem) => {
    if (admin.role === "SUPER_ADMIN") {
      alert("સુપર એડમિન એકાઉન્ટ ડિલીટ કરી શકાતું નથી (Cannot delete Super Admin account)");
      return;
    }
    const confirmed = window.confirm(
      `શું તમે ખરેખર સબ-એડમિન "${admin.name}" (${admin.email}) ને ડિલીટ કરવા માંગો છો?\n\nઆ ક્રિયા રદ કરી શકાતી નથી!`
    );
    if (!confirmed) return;

    try {
      await adminApi.deleteSubAdmin(admin.id);
      setSuccessMsg(`સબ-એડમિન "${admin.name}" સફળતાપૂર્વક ડિલીટ થયો`);
      await loadAdmins();
      setTimeout(() => setSuccessMsg(null), 5000);
    } catch (err: any) {
      alert(err.message || "Failed to delete sub-admin");
    }
  };

  const handleToggleStatus = async (admin: AdminSubAdminItem) => {
    if (admin.role === "SUPER_ADMIN") return;
    const nextStatus = admin.status === "ACTIVE" ? "INACTIVE" : "ACTIVE";
    try {
      await adminApi.updateSubAdmin(admin.id, { status: nextStatus });
      await loadAdmins();
    } catch (err: any) {
      alert(err.message || "Failed to update status");
    }
  };

  return (
    <AdminLayout
      title="Sub-Admin Staff & Permission Access Control"
      subtitle="સબ-એડમિન સ્ટાફ મેનેજમેન્ટ અને સેક્શન પરવાનગી નિયંત્રણ"
    >
      <div className="space-y-6">
        {/* Top Summary & Action Bar */}
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 bg-gradient-to-r from-[#0B1528] via-[#0F1E38] to-[#0B1528] border border-[#D4AF37]/30 rounded-2xl p-6 shadow-xl">
          <div>
            <div className="flex items-center gap-3">
              <span className="text-3xl">👑</span>
              <div>
                <h2 className="text-xl font-black text-[#D4AF37] tracking-wide">
                  Sub-Admin Staff Management
                </h2>
                <p className="text-xs text-slate-300 font-medium mt-0.5">
                  સુપર એડમિન દ્વારા સબ-એડમિન બનાવવું અને ચોક્કસ સેક્શનની પરવાનગી આપવી
                </p>
              </div>
            </div>
            <div className="flex items-center gap-3 mt-3 text-xs text-slate-400">
              <span className="inline-flex items-center gap-1 bg-[#D4AF37]/10 px-2.5 py-1 rounded-lg border border-[#D4AF37]/20 text-[#D4AF37] font-bold">
                👥 Total Administrators: {admins.length}
              </span>
              <span className="inline-flex items-center gap-1 bg-emerald-500/10 px-2.5 py-1 rounded-lg border border-emerald-500/20 text-emerald-400 font-bold">
                ✓ Active Staff: {admins.filter((a) => a.status === "ACTIVE").length}
              </span>
            </div>
          </div>

          <button
            onClick={openCreateModal}
            className="flex items-center gap-2 px-5 py-3 rounded-xl bg-gradient-to-r from-[#D4AF37] via-[#F3E5AB] to-[#C59B27] text-[#041026] font-extrabold text-xs uppercase tracking-wider shadow-lg hover:shadow-[#D4AF37]/25 hover:brightness-110 active:scale-95 transition-all cursor-pointer"
          >
            <span className="text-base font-black">+</span>
            <span>Create New Sub-Admin (નવો સબ-એડમિન)</span>
          </button>
        </div>

        {/* Success Alert Banner */}
        {successMsg && (
          <div className="flex items-center gap-3 bg-emerald-950/80 border border-emerald-500 text-emerald-200 px-5 py-4 rounded-xl shadow-lg animate-in fade-in">
            <span className="text-xl">✅</span>
            <p className="text-sm font-bold">{successMsg}</p>
          </div>
        )}

        {/* Error Alert Banner */}
        {error && (
          <div className="flex items-center gap-3 bg-rose-950/80 border border-rose-500 text-rose-200 px-5 py-4 rounded-xl shadow-lg">
            <span className="text-xl">⚠️</span>
            <p className="text-sm font-bold">{error}</p>
          </div>
        )}

        {/* Administrators List Table */}
        <div className="bg-[#0B1528] border border-[#D4AF37]/25 rounded-2xl p-6 shadow-2xl">
          <div className="flex items-center justify-between pb-4 border-b border-slate-700/60 mb-4">
            <h3 className="text-sm font-extrabold uppercase tracking-wider text-slate-200">
              Active Administrator & Sub-Admin Accounts
            </h3>
            <span className="text-xs text-slate-400">
              Auto-synced with MySQL Database
            </span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs text-white">
              <thead className="bg-[#07101E] text-[#D4AF37] uppercase text-[10px] tracking-wider border-b border-[#D4AF37]/20">
                <tr>
                  <th className="py-3 px-4 font-black">Staff Member</th>
                  <th className="py-3 px-4 font-black">Role</th>
                  <th className="py-3 px-4 font-black">Permitted Sections (સેક્શન પરવાનગી)</th>
                  <th className="py-3 px-4 font-black text-center">Status</th>
                  <th className="py-3 px-4 font-black text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800/80">
                {loading ? (
                  <tr>
                    <td colSpan={5} className="py-12 text-center text-slate-400 font-bold">
                      <div className="inline-block w-8 h-8 border-3 border-[#D4AF37] border-t-transparent rounded-full animate-spin mb-2"></div>
                      <p>Loading administrators & permissions...</p>
                    </td>
                  </tr>
                ) : admins.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="py-12 text-center text-slate-400 font-semibold">
                      No administrator accounts found.
                    </td>
                  </tr>
                ) : (
                  admins.map((admin) => {
                    const isRoot = admin.role === "SUPER_ADMIN";
                    const perms: string[] = Array.isArray(admin.permissions) ? admin.permissions : [];

                    return (
                      <tr
                        key={admin.id}
                        className="hover:bg-slate-800/40 transition-colors group"
                      >
                        {/* Name & Contact Info */}
                        <td className="py-4 px-4">
                          <div className="flex items-center gap-3">
                            <div className={`w-9 h-9 rounded-xl flex items-center justify-center font-bold text-sm shadow ${
                              isRoot
                                ? "bg-gradient-to-br from-[#D4AF37] to-[#B38728] text-black"
                                : "bg-slate-800 text-[#D4AF37] border border-[#D4AF37]/30"
                            }`}>
                              {admin.name ? admin.name.charAt(0).toUpperCase() : "A"}
                            </div>
                            <div>
                              <div className="font-bold text-white text-sm flex items-center gap-2">
                                <span>{admin.name || "Administrator"}</span>
                                {isRoot && (
                                  <span className="text-[10px] px-1.5 py-0.5 rounded bg-[#D4AF37]/20 text-[#D4AF37] font-extrabold border border-[#D4AF37]/40">
                                    ROOT
                                  </span>
                                )}
                              </div>
                              <div className="text-slate-400 text-xs mt-0.5">
                                <span>{admin.email}</span>
                                {admin.phone && <span className="ml-2 text-slate-500">• {admin.phone}</span>}
                              </div>
                            </div>
                          </div>
                        </td>

                        {/* Role Badge */}
                        <td className="py-4 px-4">
                          <span
                            className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-[11px] font-extrabold tracking-wide uppercase border ${
                              isRoot
                                ? "bg-[#D4AF37]/15 text-[#D4AF37] border-[#D4AF37]/40 shadow-sm"
                                : "bg-sky-500/15 text-sky-300 border-sky-500/30"
                            }`}
                          >
                            <span>{isRoot ? "👑" : "🛡️"}</span>
                            <span>{admin.role.replace("_", " ")}</span>
                          </span>
                        </td>

                        {/* Permitted Sections Badges */}
                        <td className="py-4 px-4 max-w-md">
                          {isRoot ? (
                            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-gradient-to-r from-[#D4AF37]/20 to-transparent border border-[#D4AF37]/30 text-[#D4AF37] font-bold text-xs">
                              <span>⭐</span>
                              <span>Full Platform Access (તમામ સેક્શનનો સંપૂર્ણ અધિકાર)</span>
                            </div>
                          ) : perms.length === 0 ? (
                            <span className="text-slate-500 italic text-xs">
                              No sections assigned (કોઈ પરવાનગી નથી)
                            </span>
                          ) : (
                            <div className="flex flex-wrap gap-1.5">
                              {perms.map((pKey) => {
                                const section = ADMIN_SECTIONS_CATALOG.find((s) => s.key === pKey);
                                return (
                                  <span
                                    key={pKey}
                                    title={section?.description || pKey}
                                    className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-slate-800/90 text-slate-300 border border-slate-700 text-[11px] font-medium hover:border-[#D4AF37]/40 transition-colors"
                                  >
                                    <span>{section?.icon || "📁"}</span>
                                    <span>{section?.name || pKey}</span>
                                  </span>
                                );
                              })}
                            </div>
                          )}
                        </td>

                        {/* Status Toggle */}
                        <td className="py-4 px-4 text-center">
                          <button
                            onClick={() => handleToggleStatus(admin)}
                            disabled={isRoot}
                            title={isRoot ? "Super Admin cannot be deactivated" : "Click to toggle Active / Inactive"}
                            className={`cursor-pointer transition-transform active:scale-95 ${
                              isRoot ? "opacity-90 cursor-default" : ""
                            }`}
                          >
                            <StatusBadge status={admin.status} />
                          </button>
                        </td>

                        {/* Action Buttons */}
                        <td className="py-4 px-4 text-right">
                          <div className="inline-flex items-center gap-1.5">
                            <button
                              onClick={() => openEditModal(admin)}
                              className="px-2.5 py-1.5 rounded-lg bg-slate-800 hover:bg-[#D4AF37]/20 text-slate-300 hover:text-[#D4AF37] border border-slate-700 hover:border-[#D4AF37]/40 font-semibold text-xs transition-colors cursor-pointer"
                              title="Edit Permissions & Info"
                            >
                              ✏️ Edit
                            </button>

                            {!isRoot && (
                              <button
                                onClick={() => handleDelete(admin)}
                                className="px-2.5 py-1.5 rounded-lg bg-rose-950/40 hover:bg-rose-900 text-rose-300 hover:text-white border border-rose-800/40 font-semibold text-xs transition-colors cursor-pointer"
                                title="Delete Sub-Admin"
                              >
                                🗑️ Delete
                              </button>
                            )}
                          </div>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* ========================================================================= */}
      {/* CREATE / EDIT SUB-ADMIN MODAL WITH CHECKLIST */}
      {/* ========================================================================= */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in overflow-y-auto">
          <div className="relative w-full max-w-4xl bg-[#091322] border-2 border-[#D4AF37] rounded-3xl shadow-2xl overflow-hidden my-8 max-h-[90vh] flex flex-col">
            {/* Modal Header */}
            <div className="flex items-center justify-between px-6 py-5 bg-gradient-to-r from-[#0E1E38] via-[#142646] to-[#0E1E38] border-b border-[#D4AF37]/30">
              <div className="flex items-center gap-3">
                <span className="text-2xl">{editingAdmin ? "✏️" : "👑"}</span>
                <div>
                  <h3 className="text-base font-extrabold text-[#D4AF37] tracking-wide">
                    {editingAdmin
                      ? `Edit Sub-Admin Permissions: ${editingAdmin.name}`
                      : "Create New Sub-Admin Staff Account (નવો સબ-એડમિન)"}
                  </h3>
                  <p className="text-xs text-slate-300">
                    આ સબ-એડમિન કયા સેક્શનનો ઉપયોગ કરી શકશે તે નીચે આપેલા બોક્સ ટીક કરીને નક્કી કરો
                  </p>
                </div>
              </div>
              <button
                onClick={closeModal}
                className="w-8 h-8 rounded-full bg-slate-800 hover:bg-slate-700 text-slate-400 hover:text-white flex items-center justify-center text-sm font-bold cursor-pointer"
              >
                ✕
              </button>
            </div>

            {/* Modal Scrollable Body */}
            <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-6 space-y-6 custom-scrollbar">
              {/* Personal Details Row */}
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 bg-[#060D19] p-4 rounded-2xl border border-slate-800">
                {/* Full Name */}
                <div>
                  <label className="block text-xs font-bold text-slate-300 mb-1.5">
                    Staff Full Name (નામ) *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    placeholder="e.g. Kiritbhai Vankar"
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-xs focus:border-[#D4AF37] focus:ring-1 focus:ring-[#D4AF37] outline-none"
                  />
                </div>

                {/* Email Address */}
                <div>
                  <label className="block text-xs font-bold text-slate-300 mb-1.5">
                    Email (Login Username) *
                  </label>
                  <input
                    type="email"
                    required
                    disabled={!!editingAdmin}
                    value={formData.email}
                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                    placeholder="subadmin@vankarsamaj.org"
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-xs focus:border-[#D4AF37] focus:ring-1 focus:ring-[#D4AF37] outline-none disabled:opacity-60 disabled:cursor-not-allowed"
                  />
                </div>

                {/* Mobile Phone */}
                <div>
                  <label className="block text-xs font-bold text-slate-300 mb-1.5">
                    Phone Number (મોબાઇલ નંબર)
                  </label>
                  <input
                    type="tel"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    placeholder="e.g. 9876543210"
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-xs focus:border-[#D4AF37] focus:ring-1 focus:ring-[#D4AF37] outline-none"
                  />
                </div>

                {/* Password */}
                <div>
                  <label className="block text-xs font-bold text-slate-300 mb-1.5">
                    {editingAdmin ? "New Password (ખાલી રાખો જો ન બદલવો હોય)" : "Password (પાસવર્ડ) *"}
                  </label>
                  <input
                    type="password"
                    required={!editingAdmin}
                    value={formData.password}
                    onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                    placeholder={editingAdmin ? "Leave blank to keep current" : "Min 6 characters"}
                    className="w-full px-3.5 py-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-xs focus:border-[#D4AF37] focus:ring-1 focus:ring-[#D4AF37] outline-none"
                  />
                </div>
              </div>

              {/* SECTION PERMISSIONS CHECKLIST HEADER */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-2 border-t border-slate-800">
                <div>
                  <h4 className="text-sm font-black text-[#D4AF37] uppercase tracking-wider flex items-center gap-2">
                    <span>🛡️</span>
                    <span>Admin Section Access Checklist (સેક્શન પરવાનગીઓ પસંદ કરો)</span>
                  </h4>
                  <p className="text-xs text-slate-400 mt-0.5">
                    જે સેક્શન ટીક કરેલા હશે તે જ સબ-એડમિનની સ્ક્રીન પર દેખાશે અને વાપરી શકાશે
                  </p>
                </div>

                {/* Bulk Select Toggles */}
                <div className="flex items-center gap-2">
                  <span className="text-xs font-bold px-2.5 py-1 rounded-md bg-[#D4AF37]/15 text-[#D4AF37] border border-[#D4AF37]/30">
                    {formData.permissions.length} of {ADMIN_SECTIONS_CATALOG.length} Selected
                  </span>
                  <button
                    type="button"
                    onClick={selectAllPermissions}
                    className="px-3 py-1.5 rounded-lg bg-slate-800 hover:bg-[#D4AF37] text-slate-300 hover:text-black font-bold text-xs border border-slate-700 transition-colors cursor-pointer"
                  >
                    ✓ Select All (બધા પસંદ કરો)
                  </button>
                  <button
                    type="button"
                    onClick={clearAllPermissions}
                    className="px-3 py-1.5 rounded-lg bg-slate-800 hover:bg-rose-900 text-slate-300 hover:text-white font-bold text-xs border border-slate-700 transition-colors cursor-pointer"
                  >
                    ✗ Clear All
                  </button>
                </div>
              </div>

              {/* INTERACTIVE CHECKLIST CARDS GRID */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3.5">
                {ADMIN_SECTIONS_CATALOG.map((sec) => {
                  const isChecked = formData.permissions.includes(sec.key);

                  return (
                    <div
                      key={sec.key}
                      onClick={() => togglePermission(sec.key)}
                      className={`p-4 rounded-2xl border-2 transition-all cursor-pointer flex items-start gap-3 select-none ${
                        isChecked
                          ? "bg-gradient-to-br from-[#12233F] to-[#0A162B] border-[#D4AF37] shadow-lg shadow-[#D4AF37]/10"
                          : "bg-[#060D19]/80 border-slate-800 hover:border-slate-700 opacity-75 hover:opacity-100"
                      }`}
                    >
                      {/* Custom Checkbox */}
                      <div className="pt-0.5 shrink-0">
                        <div
                          className={`w-5 h-5 rounded-md flex items-center justify-center border-2 transition-all ${
                            isChecked
                              ? "bg-[#D4AF37] border-[#D4AF37] text-black font-black"
                              : "border-slate-600 bg-slate-900"
                          }`}
                        >
                          {isChecked && <span className="text-xs">✓</span>}
                        </div>
                      </div>

                      {/* Content */}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2">
                          <span className="text-lg">{sec.icon}</span>
                          <span className={`text-xs font-black truncate ${
                            isChecked ? "text-[#F3E5AB]" : "text-slate-300"
                          }`}>
                            {sec.name}
                          </span>
                        </div>
                        <div className="text-[11px] font-bold text-emerald-400 mt-0.5">
                          {sec.gujarati}
                        </div>
                        <p className="text-[10.5px] text-slate-400 mt-1 line-clamp-2 leading-relaxed">
                          {sec.description}
                        </p>
                      </div>
                    </div>
                  );
                })}
              </div>

              {/* Modal Footer Controls */}
              <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-800">
                <button
                  type="button"
                  onClick={closeModal}
                  disabled={submitting}
                  className="px-5 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 font-bold text-xs transition-colors cursor-pointer"
                >
                  Cancel (રદ કરો)
                </button>

                <button
                  type="submit"
                  disabled={submitting}
                  className="flex items-center gap-2 px-6 py-2.5 rounded-xl bg-gradient-to-r from-[#D4AF37] via-[#F3E5AB] to-[#C59B27] text-[#041026] font-black text-xs uppercase tracking-wider shadow-lg hover:brightness-110 active:scale-95 transition-all cursor-pointer disabled:opacity-60"
                >
                  {submitting && <span className="animate-spin inline-block mr-1">⚙️</span>}
                  <span>
                    {editingAdmin ? "Save Permissions (પરવાનગી સાચવો)" : "Create Sub-Admin (સબ-એડમિન બનાવો)"}
                  </span>
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}

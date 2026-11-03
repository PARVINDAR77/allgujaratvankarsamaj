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
  const [showPassword, setShowPassword] = useState(false);

  // Form Fields
  const [currentAdminUser, setCurrentAdminUser] = useState<any>(null);
  const [modalError, setModalError] = useState<string | null>(null);
  const [activeCategoryTab, setActiveCategoryTab] = useState<string>("ALL");
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    password: "",
    status: "ACTIVE" as "ACTIVE" | "INACTIVE",
    role: "SUB_ADMIN" as "SUPER_ADMIN" | "SUB_ADMIN" | "ADMIN",
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
    if (typeof window !== "undefined") {
      try {
        const stored = localStorage.getItem("adminUser");
        if (stored) {
          setCurrentAdminUser(JSON.parse(stored));
        }
      } catch (_) {}
    }
    loadAdmins();
  }, []);

  const openCreateModal = () => {
    setEditingAdmin(null);
    setModalError(null);
    setActiveCategoryTab("ALL");
    setFormData({
      name: "",
      email: "",
      phone: "",
      password: "",
      status: "ACTIVE",
      role: "SUB_ADMIN",
      permissions: [
        "dashboard",
        "verifications",
        "profiles",
      ],
    });
    setIsModalOpen(true);
  };

  const openEditModal = (admin: AdminSubAdminItem) => {
    setEditingAdmin(admin);
    setModalError(null);
    setActiveCategoryTab("ALL");
    setFormData({
      name: admin.name || "",
      email: admin.email || "",
      phone: admin.phone || "",
      password: "",
      status: admin.status || "ACTIVE",
      role: (admin.role as any) || "SUB_ADMIN",
      permissions: Array.isArray(admin.permissions) ? admin.permissions : [],
    });
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setEditingAdmin(null);
    setModalError(null);
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

  const selectCategoryPermissions = (category: string) => {
    const catKeys = ADMIN_SECTIONS_CATALOG.filter((s) => s.category === category).map((s) => s.key);
    setFormData((prev) => {
      const merged = new Set([...prev.permissions, ...catKeys]);
      return { ...prev, permissions: Array.from(merged) };
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setModalError(null);

    if (!formData.name.trim()) {
      setModalError("કૃપા કરીને સબ-એડમિનનું નામ દાખલ કરો (Please enter name)");
      return;
    }
    if (!formData.email.trim()) {
      setModalError("કૃપા કરીને ઇમેઇલ સરનામું દાખલ કરો (Please enter email)");
      return;
    }
    if (!editingAdmin && (!formData.password || formData.password.trim().length < 6)) {
      setModalError("પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ (Password must be at least 6 characters)");
      return;
    }

    setSubmitting(true);

    try {
      if (editingAdmin) {
        // Update existing admin / sub-admin
        const updatePayload: UpdateSubAdminDto = {
          name: formData.name.trim(),
          phone: formData.phone.trim() || undefined,
          status: formData.status,
          role: formData.role,
          permissions: formData.permissions,
        };
        if (formData.password && formData.password.trim().length >= 6) {
          updatePayload.password = formData.password.trim();
        }
        await adminApi.updateSubAdmin(editingAdmin.id, updatePayload);
        setSuccessMsg(`એકાઉન્ટ "${formData.name}" સફળતાપૂર્વક અપડેટ થયું (Updated successfully)`);
      } else {
        // Create new sub-admin
        const createPayload: CreateSubAdminDto = {
          name: formData.name.trim(),
          email: formData.email.trim().toLowerCase(),
          phone: formData.phone.trim() || undefined,
          password: formData.password.trim(),
          role: formData.role,
          permissions: formData.permissions,
        };
        await adminApi.createSubAdmin(createPayload);
        setSuccessMsg(`નવો સ્ટાફ એકાઉન્ટ "${formData.name}" સફળતાપૂર્વક બન્યો (Created successfully)`);
      }

      closeModal();
      await loadAdmins();
      setTimeout(() => setSuccessMsg(null), 5000);
    } catch (err: any) {
      console.error("Save admin error:", err);
      setModalError(err.message || "Failed to save admin account");
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (admin: AdminSubAdminItem) => {
    if (currentAdminUser && (currentAdminUser.id === admin.id || currentAdminUser.email?.toLowerCase() === admin.email?.toLowerCase())) {
      alert("તમે તમારું પોતાનું સક્રિય એકાઉન્ટ ડિલીટ કરી શકતા નથી (You cannot delete your own active account)");
      return;
    }

    const confirmed = window.confirm(
      `શું તમે ખરેખર એકાઉન્ટ "${admin.name || "Administrator"}" (${admin.email}) ને ડિલીટ કરવા માંગો છો?\n\nઆ એકાઉન્ટ કાયમ માટે ડિલીટ થઈ જશે અને તેની બધી એક્સેસ રદ થશે!`
    );
    if (!confirmed) return;

    try {
      await adminApi.deleteSubAdmin(admin.id);
      setSuccessMsg(`એકાઉન્ટ "${admin.name || admin.email}" સફળતાપૂર્વક ડિલીટ થયું (Deleted successfully)`);
      await loadAdmins();
      setTimeout(() => setSuccessMsg(null), 5000);
    } catch (err: any) {
      alert(err.message || "Failed to delete admin account");
    }
  };

  const handleToggleStatus = async (admin: AdminSubAdminItem) => {
    if (currentAdminUser && (currentAdminUser.id === admin.id || currentAdminUser.email?.toLowerCase() === admin.email?.toLowerCase())) return;
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
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-5 bg-gradient-to-r from-[#071326] via-[#0D1E3A] to-[#071326] border border-[#D4AF37]/35 rounded-2xl p-6 sm:p-7 shadow-2xl relative overflow-hidden">
          <div className="absolute top-0 right-0 w-80 h-full bg-gradient-to-l from-[#D4AF37]/10 to-transparent pointer-events-none" />
          <div className="relative z-10">
            <div className="flex items-center gap-3.5">
              <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-[#D4AF37]/25 to-transparent border border-[#D4AF37]/40 flex items-center justify-center shadow-lg text-2xl">
                👑
              </div>
              <div>
                <h2 className="text-xl sm:text-2xl font-black text-[#F5E6A3] tracking-wide flex items-center gap-2">
                  <span>Sub-Admin Staff Management</span>
                </h2>
                <p className="text-xs sm:text-sm text-slate-300 font-medium mt-1">
                  સુપર એડમિન દ્વારા સબ-એડમિન બનાવવું અને ચોક્કસ સેક્શનની પરવાનગી આપવી
                </p>
              </div>
            </div>

            <div className="flex flex-wrap items-center gap-3 mt-4 text-xs font-bold">
              <span className="inline-flex items-center gap-1.5 bg-[#D4AF37]/15 px-3.5 py-1.5 rounded-xl border border-[#D4AF37]/30 text-[#F5E6A3] shadow-sm">
                👥 Total Administrators: {admins.length}
              </span>
              <span className="inline-flex items-center gap-1.5 bg-emerald-500/15 px-3.5 py-1.5 rounded-xl border border-emerald-500/30 text-emerald-300 shadow-sm">
                ✓ Active Staff: {admins.filter((a) => a.status === "ACTIVE").length}
              </span>
            </div>
          </div>

          <button
            onClick={openCreateModal}
            className="relative z-10 flex items-center gap-2.5 px-6 py-3.5 rounded-xl bg-gradient-to-r from-[#D4AF37] via-[#F7E7A9] to-[#C59B27] text-[#041026] font-black text-xs sm:text-sm uppercase tracking-wider shadow-xl shadow-[#D4AF37]/25 hover:shadow-[#D4AF37]/40 hover:brightness-110 active:scale-95 transition-all cursor-pointer whitespace-nowrap"
          >
            <span className="text-lg font-black leading-none">+</span>
            <span>CREATE NEW SUB-ADMIN (નવો સબ-એડમિન)</span>
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
        <div className="bg-[#071326] border border-[#D4AF37]/30 rounded-2xl p-6 sm:p-7 shadow-2xl overflow-hidden">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between pb-4 border-b border-slate-700/60 mb-5 gap-2">
            <div>
              <h3 className="text-sm sm:text-base font-black uppercase tracking-wider text-[#F5E6A3] flex items-center gap-2">
                <span>🛡️</span>
                <span>Active Administrator & Sub-Admin Accounts</span>
              </h3>
              <p className="text-xs text-slate-400 mt-0.5">
                એડમિન અને સબ-એડમિન સ્ટાફ લિસ્ટ અને તેમની સોંપાયેલ પરવાનગીઓ
              </p>
            </div>
            <span className="text-xs font-semibold px-3 py-1 rounded-lg bg-slate-800/80 border border-slate-700 text-slate-300 w-fit">
              ⚡ Auto-synced with MySQL Database
            </span>
          </div>

          <div className="overflow-x-auto rounded-xl border border-slate-800/80">
            <table className="w-full text-left text-xs text-white">
              <thead className="bg-[#050E1B] text-[#D4AF37] uppercase text-[11px] tracking-wider border-b border-[#D4AF37]/25">
                <tr>
                  <th className="py-3.5 px-5 font-black">Staff Member (નામ અને વિગત)</th>
                  <th className="py-3.5 px-4 font-black">Role (હોદ્દો)</th>
                  <th className="py-3.5 px-5 font-black">Permitted Sections (સોંપાયેલ સેક્શન)</th>
                  <th className="py-3.5 px-4 font-black text-center">Status</th>
                  <th className="py-3.5 px-5 font-black text-right min-w-[220px]">Actions (ક્રિયાઓ)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-800/80 bg-[#061020]/60">
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
                    const isSelf = !!(currentAdminUser && (
                      currentAdminUser.id === admin.id ||
                      (currentAdminUser.email && admin.email && currentAdminUser.email.toLowerCase() === admin.email.toLowerCase())
                    ));
                    const canDelete = !isSelf;
                    const canToggleStatus = !isSelf;
                    const perms: string[] = Array.isArray(admin.permissions) ? admin.permissions : [];

                    return (
                      <tr
                        key={admin.id}
                        className="hover:bg-slate-800/50 transition-colors group"
                      >
                        {/* Name & Contact Info */}
                        <td className="py-4 px-5">
                          <div className="flex items-center gap-3.5">
                            <div className={`w-11 h-11 rounded-2xl flex items-center justify-center font-black text-base shadow-md ${
                              isRoot
                                ? "bg-gradient-to-br from-[#D4AF37] via-[#F3E5AB] to-[#B38728] text-slate-950"
                                : "bg-gradient-to-br from-slate-800 to-slate-900 text-[#D4AF37] border border-[#D4AF37]/35 shadow-inner"
                            }`}>
                              {admin.name ? admin.name.charAt(0).toUpperCase() : "A"}
                            </div>
                            <div>
                              <div className="font-bold text-white text-sm flex items-center gap-2">
                                <span>{admin.name || "Administrator"}</span>
                                {isRoot && (
                                  <span className="text-[10px] px-2 py-0.5 rounded-md bg-[#D4AF37]/20 text-[#F5E6A3] font-black border border-[#D4AF37]/40 tracking-wider">
                                    SUPER ADMIN
                                  </span>
                                )}
                                {isSelf && (
                                  <span className="text-[10px] px-2 py-0.5 rounded-md bg-emerald-500/20 text-emerald-300 font-black border border-emerald-500/30">
                                    YOU
                                  </span>
                                )}
                              </div>
                              <div className="text-slate-400 text-xs mt-1 flex items-center gap-2">
                                <span className="font-medium text-slate-300">{admin.email}</span>
                                {admin.phone && (
                                  <span className="text-slate-400 font-mono bg-slate-800/80 px-2 py-0.5 rounded-md border border-slate-700/60">
                                    📞 {admin.phone}
                                  </span>
                                )}
                              </div>
                            </div>
                          </div>
                        </td>

                        {/* Role Badge */}
                        <td className="py-4 px-4 whitespace-nowrap">
                          {isRoot ? (
                            <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-gradient-to-r from-[#D4AF37]/25 to-amber-950/30 text-[#F5E6A3] border border-[#D4AF37]/50 font-black text-xs shadow-sm">
                              <span>👑</span>
                              <span>SUPER ADMIN</span>
                            </span>
                          ) : (
                            <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-sky-950/60 text-sky-300 border border-sky-600/50 font-black text-xs shadow-sm">
                              <span>🛡️</span>
                              <span>SUB-ADMIN</span>
                            </span>
                          )}
                        </td>

                        {/* Permitted Sections Badges */}
                        <td className="py-4 px-5 max-w-md">
                          {isRoot ? (
                            <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-xl bg-gradient-to-r from-[#D4AF37]/20 to-transparent border border-[#D4AF37]/40 text-[#F5E6A3] font-bold text-xs shadow-sm">
                              <span className="text-base">⭐</span>
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
                                    className="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg bg-slate-900/90 text-slate-200 border border-slate-700/80 text-[11px] font-semibold hover:border-[#D4AF37]/50 transition-colors shadow-xs"
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
                            disabled={!canToggleStatus}
                            title={
                              isSelf
                                ? "You cannot deactivate your own active account"
                                : "Click to toggle Active / Inactive"
                            }
                            className={`cursor-pointer transition-transform active:scale-95 inline-block ${
                              !canToggleStatus ? "opacity-90 cursor-default" : ""
                            }`}
                          >
                            <StatusBadge status={admin.status} />
                          </button>
                        </td>

                        {/* Action Buttons */}
                        <td className="py-4 px-5 text-right whitespace-nowrap">
                          <div className="inline-flex items-center gap-2.5 justify-end">
                            <button
                              onClick={() => openEditModal(admin)}
                              className="px-3.5 py-2 rounded-xl bg-gradient-to-r from-amber-500/15 to-amber-600/10 hover:from-amber-500/30 hover:to-amber-600/20 text-[#F5E6A3] hover:text-white border border-[#D4AF37]/40 hover:border-[#D4AF37] font-bold text-xs transition-all cursor-pointer flex items-center gap-1.5 shadow-sm active:scale-95"
                              title="Edit Permissions & Info"
                            >
                              <span className="text-sm">✏️</span>
                              <span>Edit</span>
                            </button>

                            {canDelete ? (
                              <button
                                onClick={() => handleDelete(admin)}
                                className="px-3.5 py-2 rounded-xl bg-gradient-to-r from-rose-950/80 to-rose-900/60 hover:from-rose-900 hover:to-rose-800 text-rose-200 hover:text-white border border-rose-700/60 hover:border-rose-500 font-bold text-xs transition-all cursor-pointer flex items-center gap-1.5 shadow-sm active:scale-95"
                                title={`Delete ${admin.name || admin.email}`}
                              >
                                <span className="text-sm">🗑️</span>
                                <span>Delete</span>
                              </button>
                            ) : (
                              <button
                                disabled
                                className="px-3.5 py-2 rounded-xl bg-slate-900/60 text-slate-500 border border-slate-800 font-bold text-xs cursor-not-allowed flex items-center gap-1.5 opacity-40"
                                title="You cannot delete your own currently logged in account"
                              >
                                <span className="text-sm">🔒</span>
                                <span>Current User</span>
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
      {/* CREATE / EDIT SUB-ADMIN MODAL WITH CHECKLIST (CYBERPUNK RBAC HUD) */}
      {/* ========================================================================= */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 md:p-6 bg-black/85 backdrop-blur-md animate-in fade-in overflow-y-auto">
          <div className="relative w-full max-w-5xl bg-[#070D18] border border-cyan-500/30 rounded-2xl sm:rounded-3xl shadow-[0_0_50px_rgba(6,182,212,0.15)] overflow-hidden my-6 max-h-[92vh] flex flex-col">
            
            {/* Modal Header */}
            <div className="shrink-0 flex items-center justify-between px-6 py-4 bg-[#081224] border-b border-cyan-500/20">
              <div className="flex items-center gap-3.5">
                <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-amber-400 to-amber-600 flex items-center justify-center shadow-lg text-black font-black text-xl">
                  👑
                </div>
                <div>
                  <div className="flex items-center gap-2.5">
                    <h3 className="text-base sm:text-lg font-black text-white tracking-wide">
                      {editingAdmin
                        ? `Edit Sub-Admin Permissions: ${editingAdmin.name}`
                        : "Create Sub-Admin Staff Account (નવો સબ-એડમિન એકાઉન્ટ)"}
                    </h3>
                    <span className="bg-cyan-950/80 text-cyan-400 border border-cyan-500/30 text-[10px] font-mono px-2 py-0.5 rounded tracking-wider font-bold">
                      RBAC HUD V3.4
                    </span>
                  </div>
                  <p className="text-xs text-slate-400 font-medium mt-0.5 flex items-center gap-1.5">
                    <span className="text-cyan-400">ⓘ</span>
                    <span>આ સબ-એડમિન કયા સેક્શનનો ઉપયોગ કરી શકશે તે નીચે આપેલા બોક્સ ટીક કરીને નક્કી કરો</span>
                  </p>
                </div>
              </div>
              <button
                type="button"
                onClick={closeModal}
                className="w-9 h-9 rounded-xl bg-slate-900/80 hover:bg-rose-950/80 hover:text-rose-300 border border-slate-700/80 text-slate-400 flex items-center justify-center text-sm font-bold transition-all cursor-pointer"
                title="Close"
              >
                ✕
              </button>
            </div>

            {/* Modal Scrollable Body */}
            <form onSubmit={handleSubmit} autoComplete="off" className="flex-1 overflow-y-auto p-5 sm:p-6 space-y-5 custom-scrollbar bg-[#050A14]">
              
              {/* Error Alert Box inside Modal */}
              {modalError && (
                <div className="flex items-start gap-3 p-3.5 rounded-xl bg-rose-950/80 border border-rose-600/60 text-rose-200 text-xs font-semibold animate-shake">
                  <span className="text-base shrink-0">⚠️</span>
                  <div className="flex-1">{modalError}</div>
                </div>
              )}

              {/* Personal Details Card */}
              <div className="bg-[#081224] p-4 sm:p-5 rounded-2xl border border-slate-800/90 shadow-inner space-y-4">
                
                {/* Row 1: Full Name, Email Username, Assigned Role */}
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                  {/* Full Name */}
                  <div>
                    <label className="block text-xs font-bold text-slate-300 mb-1.5 uppercase tracking-wider">
                      Staff Full Name (નામ) <span className="text-cyan-400">*</span>
                    </label>
                    <input
                      type="text"
                      required
                      value={formData.name}
                      onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                      placeholder="e.g. Parmit Vankar"
                      className="w-full px-3.5 py-2.5 rounded-xl bg-[#040812] border border-slate-800 text-white text-xs placeholder:text-slate-600 focus:border-cyan-400 focus:ring-1 focus:ring-cyan-400 outline-none transition-all"
                    />
                  </div>

                  {/* Email Address */}
                  <div>
                    <label className="block text-xs font-bold text-slate-300 mb-1.5 uppercase tracking-wider">
                      Email Username (ઇમેઇલ લોગિન) <span className="text-cyan-400">*</span>
                    </label>
                    <input
                      type="email"
                      required
                      autoComplete="new-password"
                      disabled={!!editingAdmin}
                      value={formData.email}
                      onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                      placeholder="staff@vankarsamaj.org"
                      className="w-full px-3.5 py-2.5 rounded-xl bg-[#040812] border border-slate-800 text-white text-xs placeholder:text-slate-600 focus:border-cyan-400 focus:ring-1 focus:ring-cyan-400 outline-none transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                    />
                  </div>

                  {/* Account Role */}
                  <div>
                    <label className="block text-xs font-bold text-slate-300 mb-1.5 uppercase tracking-wider">
                      Account Role (હોદ્દો) <span className="text-cyan-400">*</span>
                    </label>
                    <select
                      value={formData.role}
                      disabled={editingAdmin?.email === "panjabiparvindar77@gmail.com"}
                      onChange={(e) => {
                        const newRole = e.target.value as any;
                        setFormData((prev) => ({
                          ...prev,
                          role: newRole,
                          permissions: newRole === "SUPER_ADMIN" ? ADMIN_SECTIONS_CATALOG.map((s) => s.key) : prev.permissions,
                        }));
                      }}
                      className="w-full px-3.5 py-2.5 rounded-xl bg-[#040812] border border-slate-800 text-white text-xs font-medium focus:border-cyan-400 focus:ring-1 focus:ring-cyan-400 outline-none transition-all disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
                    >
                      <option value="SUB_ADMIN">🛡️ Sub-Admin (નિયંત્રિત સેક્શન)</option>
                      <option value="SUPER_ADMIN">👑 Super Admin (સંપૂર્ણ અધિકાર)</option>
                    </select>
                  </div>
                </div>

                {/* Row 2: Phone Number (OTP ENABLED) & Password (ENCRYPTED 256-BIT) */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2 border-t border-slate-800/80">
                  {/* Phone Number */}
                  <div>
                    <div className="flex items-center justify-between mb-1.5">
                      <label className="text-xs font-bold text-slate-300 uppercase tracking-wider flex items-center gap-1.5">
                        <span>📱</span>
                        <span>Phone Number (મોબાઇલ નંબર)</span>
                      </label>
                      <span className="text-[10px] font-mono font-bold text-cyan-400 tracking-wider">
                        OTP ENABLED
                      </span>
                    </div>
                    <div className="flex items-center rounded-xl bg-[#040812] border border-slate-800 focus-within:border-cyan-400 focus-within:ring-1 focus-within:ring-cyan-400 overflow-hidden transition-all">
                      <span className="px-3.5 py-2.5 text-xs font-mono font-bold text-slate-400 bg-slate-900/60 border-r border-slate-800 select-none">
                        +91
                      </span>
                      <input
                        type="tel"
                        value={formData.phone}
                        onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                        placeholder="9879859911"
                        className="w-full px-3 py-2.5 bg-transparent text-white text-xs placeholder:text-slate-600 outline-none font-mono"
                      />
                    </div>
                  </div>

                  {/* Password */}
                  <div>
                    <div className="flex items-center justify-between mb-1.5">
                      <label className="text-xs font-bold text-slate-300 uppercase tracking-wider flex items-center gap-1.5">
                        <span>🔑</span>
                        <span>{editingAdmin ? "Change Password (નવો પાસવર્ડ)" : "Password * (પાસવર્ડ *)"}</span>
                      </label>
                      <span className="text-[10px] font-mono font-bold text-emerald-400 tracking-wider">
                        ENCRYPTED 256-BIT
                      </span>
                    </div>
                    <div className="relative flex items-center rounded-xl bg-[#040812] border border-slate-800 focus-within:border-cyan-400 focus-within:ring-1 focus-within:ring-cyan-400 overflow-hidden transition-all">
                      <input
                        type={showPassword ? "text" : "password"}
                        autoComplete="new-password"
                        required={!editingAdmin}
                        value={formData.password}
                        onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                        placeholder={editingAdmin ? "ખાલી રાખો જો બદલવો ન હોય" : "••••••••••••"}
                        className="w-full px-3.5 py-2.5 bg-transparent text-white text-xs placeholder:text-slate-600 outline-none pr-12 font-mono"
                      />
                      <button
                        type="button"
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute right-3 text-slate-400 hover:text-cyan-400 text-xs font-bold cursor-pointer transition-colors select-none"
                      >
                        {showPassword ? "🙈 Hide" : "👁️ Show"}
                      </button>
                    </div>
                  </div>
                </div>

                {/* Account Status for Editing */}
                {editingAdmin && (
                  <div className="pt-2 border-t border-slate-800/80">
                    <label className="block text-xs font-bold text-slate-300 mb-1.5 uppercase tracking-wider">
                      Account Status (સ્થિતિ)
                    </label>
                    <select
                      value={formData.status}
                      onChange={(e) => setFormData({ ...formData, status: e.target.value as any })}
                      className="w-full sm:w-1/3 px-3.5 py-2.5 rounded-xl bg-[#040812] border border-slate-800 text-white text-xs font-medium focus:border-cyan-400 focus:ring-1 focus:ring-cyan-400 outline-none transition-all cursor-pointer"
                    >
                      <option value="ACTIVE">🟢 ACTIVE (સક્રિય)</option>
                      <option value="INACTIVE">🔴 INACTIVE (નિષ્ક્રિય)</option>
                    </select>
                  </div>
                )}
              </div>

              {/* SECTION PERMISSIONS CHECKLIST HEADER */}
              <div className="space-y-4 pt-1">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <div className="flex items-center gap-2">
                    <span className="text-cyan-400 text-base">🛡️</span>
                    <h4 className="text-xs sm:text-sm font-black text-white uppercase tracking-wider">
                      Admin Section Access Checklist <span className="text-slate-400 font-medium text-xs">(સેક્શન પરવાનગીઓ પસંદ કરો)</span>
                    </h4>
                  </div>

                  {/* Bulk Select Toggles */}
                  <div className="flex items-center gap-2.5">
                    <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-cyan-950/70 border border-cyan-500/40 text-cyan-300 font-mono font-bold text-xs shadow-sm">
                      <span className="w-2 h-2 rounded-full bg-cyan-400 animate-pulse"></span>
                      <span>{formData.permissions.length} / {ADMIN_SECTIONS_CATALOG.length} Selected</span>
                    </span>
                    <button
                      type="button"
                      onClick={selectAllPermissions}
                      className="px-3 py-1.5 rounded-lg bg-[#0A162B] hover:bg-cyan-950 border border-slate-700/80 hover:border-cyan-500/60 text-slate-200 hover:text-cyan-300 font-bold text-xs transition-all cursor-pointer flex items-center gap-1"
                    >
                      <span>✓✓</span>
                      <span>Select All (બધા પસંદ કરો)</span>
                    </button>
                    <button
                      type="button"
                      onClick={clearAllPermissions}
                      className="px-3 py-1.5 rounded-lg bg-[#0A162B] hover:bg-rose-950/60 border border-slate-700/80 hover:border-rose-500/60 text-slate-300 hover:text-rose-300 font-bold text-xs transition-all cursor-pointer flex items-center gap-1"
                    >
                      <span>↺</span>
                      <span>Clear All</span>
                    </button>
                  </div>
                </div>

                {/* Category Filter Tabs */}
                <div className="flex flex-wrap items-center gap-2">
                  {[
                    { id: "ALL", label: "All Sections (બધા સેક્શન)", icon: "✨" },
                    { id: "Overview & Users", label: "Overview & Users", icon: "👥" },
                    { id: "Community & Directory", label: "Community & Directory", icon: "🤝" },
                    { id: "Content & Management", label: "Content & Settings", icon: "📢" },
                  ].map((tab) => {
                    const isActive = activeCategoryTab === tab.id;
                    const catCount = tab.id === "ALL" 
                      ? ADMIN_SECTIONS_CATALOG.length 
                      : ADMIN_SECTIONS_CATALOG.filter((s) => s.category === tab.id).length;
                    const catSelected = tab.id === "ALL"
                      ? formData.permissions.length
                      : ADMIN_SECTIONS_CATALOG.filter((s) => s.category === tab.id && formData.permissions.includes(s.key)).length;

                    return (
                      <button
                        key={tab.id}
                        type="button"
                        onClick={() => setActiveCategoryTab(tab.id)}
                        className={`px-3.5 py-1.5 rounded-xl text-xs font-bold transition-all cursor-pointer flex items-center gap-2 border ${
                          isActive
                            ? "bg-cyan-950/80 text-cyan-300 border-cyan-400 shadow-[0_0_15px_rgba(6,182,212,0.25)]"
                            : "bg-[#091120] text-slate-400 border-slate-800 hover:border-slate-700 hover:text-slate-200"
                        }`}
                      >
                        <span>{tab.icon}</span>
                        <span>{tab.label}</span>
                        <span className={`text-[10px] px-1.5 py-0.2 rounded font-mono font-bold ${
                          isActive ? "bg-cyan-500/20 text-cyan-200" : "bg-slate-800/80 text-slate-500"
                        }`}>
                          {catSelected}/{catCount}
                        </span>
                      </button>
                    );
                  })}
                </div>

                {/* INTERACTIVE CHECKLIST CARDS GRID (CYBERPUNK NEON CARDS) */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3 pt-1">
                  {ADMIN_SECTIONS_CATALOG
                    .filter((sec) => activeCategoryTab === "ALL" || sec.category === activeCategoryTab)
                    .map((sec) => {
                      const isChecked = formData.permissions.includes(sec.key);

                      return (
                        <div
                          key={sec.key}
                          onClick={() => togglePermission(sec.key)}
                          className={`p-3.5 rounded-xl border transition-all cursor-pointer flex items-start gap-3 select-none relative group ${
                            isChecked
                              ? "bg-gradient-to-br from-[#0B1E38] to-[#071326] border-cyan-400 shadow-[0_0_20px_rgba(6,182,212,0.25)] ring-1 ring-cyan-400/40"
                              : "bg-[#081120]/90 border-slate-800/90 hover:border-slate-700 hover:bg-[#0B172B] opacity-80 hover:opacity-100"
                          }`}
                        >
                          {/* Custom Checkbox */}
                          <div className="pt-0.5 shrink-0">
                            <div
                              className={`w-5 h-5 rounded-md flex items-center justify-center border transition-all ${
                                isChecked
                                  ? "bg-cyan-400 border-cyan-400 text-slate-950 font-black shadow-[0_0_10px_rgba(6,182,212,0.5)]"
                                  : "border-slate-700 bg-slate-900 text-transparent group-hover:border-slate-600"
                              }`}
                            >
                              <span className="text-xs leading-none">✓</span>
                            </div>
                          </div>

                          {/* Content */}
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-1.5">
                              <span className="text-base shrink-0">{sec.icon}</span>
                              <span className={`text-xs font-black truncate ${
                                isChecked ? "text-white" : "text-slate-200"
                              }`}>
                                {sec.name}
                              </span>
                            </div>
                            <div className={`text-[11px] font-bold mt-0.5 ${
                              isChecked ? "text-cyan-300" : "text-slate-400"
                            }`}>
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
              </div>

              {/* Modal Footer Controls */}
              <div className="flex flex-col sm:flex-row items-center justify-between gap-4 pt-4 border-t border-slate-800/80">
                <div className="text-xs font-medium flex items-center gap-2">
                  <span className="w-2.5 h-2.5 rounded-full bg-emerald-400 animate-pulse shadow-[0_0_8px_rgba(52,211,153,0.8)]"></span>
                  <span className="text-slate-300">
                    <strong className="text-emerald-400">{formData.permissions.length}</strong> સેક્શન સબ-એડમિનને સોંપાશે (Ready to Provision)
                  </span>
                </div>

                <div className="flex items-center gap-3 w-full sm:w-auto justify-end">
                  <button
                    type="button"
                    onClick={closeModal}
                    disabled={submitting}
                    className="flex-1 sm:flex-none px-6 py-3 rounded-xl bg-[#091120] hover:bg-slate-800 text-slate-300 font-bold text-xs uppercase tracking-wider transition-colors cursor-pointer border border-slate-700/80 shadow-sm"
                  >
                    CANCEL (રદ કરો)
                  </button>

                  <button
                    type="submit"
                    disabled={submitting}
                    className="flex-1 sm:flex-none flex items-center justify-center gap-2 px-8 py-3 rounded-xl bg-gradient-to-r from-cyan-400 via-teal-300 to-emerald-400 hover:from-cyan-300 hover:to-emerald-300 text-slate-950 font-black text-xs sm:text-sm uppercase tracking-wider shadow-[0_0_25px_rgba(6,182,212,0.4)] hover:shadow-[0_0_35px_rgba(6,182,212,0.6)] active:scale-95 transition-all cursor-pointer disabled:opacity-60 whitespace-nowrap"
                  >
                    {submitting ? (
                      <span className="animate-spin inline-block text-base">⚙️</span>
                    ) : (
                      <span className="text-base font-black">⊕</span>
                    )}
                    <span>
                      {editingAdmin ? "SAVE PERMISSIONS (પરવાનગી સાચવો)" : "CREATE SUB-ADMIN (સબ-એડમિન બનાવો)"}
                    </span>
                  </button>
                </div>
              </div>
            </form>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}

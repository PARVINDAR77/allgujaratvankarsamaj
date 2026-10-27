"use client";

import React, { useState, useEffect, useCallback, useRef } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { adminApi, AdminProfileItem, AdminUserItem } from "@/lib/admin-api";

interface AdminHeaderProps {
  onToggleSidebar: () => void;
  title: string;
  subtitle?: string;
}

interface LiveNotificationItem {
  id: string;
  title: string;
  message: string;
  time: string;
  route: string;
  type: "VERIFICATION" | "USER" | "SYSTEM";
  icon: string;
  isRead: boolean;
}

interface AdminNavPage {
  name: string;
  gujarati: string;
  href: string;
  icon: string;
  category: string;
  keywords: string;
}

const ADMIN_NAV_PAGES: AdminNavPage[] = [
  { name: "Profiles Management", gujarati: "વર-કન્યા પ્રોફાઇલ્સ", href: "/admin/profiles", icon: "👤", category: "Candidates", keywords: "profile candidate groom bride biodata rishta લગ્ન ઉમેદવાર bio" },
  { name: "User Management", gujarati: "સભ્યો એકાઉન્ટ", href: "/admin/users", icon: "👥", category: "Users", keywords: "users accounts members login સભ્યો એકાઉન્ટ" },
  { name: "Verifications (KYC)", gujarati: "ઓળખ ચકાસણી", href: "/admin/verifications", icon: "🛡️", category: "KYC", keywords: "verification aadhar document kyc પુરાવા ચકાસણી આધારકાર્ડ" },
  { name: "Education (5 Boxes)", gujarati: "શિક્ષણ માર્ગદર્શન (૫ બોક્સ)", href: "/admin/education", icon: "🎓", category: "Community", keywords: "education study video guidance pdf પુસ્તક શિક્ષણ બોર્ડ" },
  { name: "Government Employees", gujarati: "સરકારી અને ખાનગી કર્મચારીઓ", href: "/admin/government-employees", icon: "💼", category: "Community", keywords: "govt government employee job nokri કર્મચારી નોકરી" },
  { name: "Matches & Compatibility", gujarati: "મેચમેકિંગ અને પસંદગી", href: "/admin/matches", icon: "💖", category: "Matchmaking", keywords: "matches match compatibility interest પસંદગી મેચ" },
  { name: "Samaj Super Stars", gujarati: "સમાજ સુપર સ્ટાર્સ", href: "/admin/samaj-super-stars", icon: "🌟", category: "Honors", keywords: "super stars superstars achievements સિદ્ધિ ગૌરવ સ્ટાર" },
  { name: "Samaj Ratna", gujarati: "સમાજ રત્ન એવોર્ડ", href: "/admin/samaj-ratna", icon: "🏆", category: "Honors", keywords: "samaj ratna award honors રત્ન એવોર્ડ સન્માન" },
  { name: "Samaj Services", gujarati: "સમાજ સેવાઓ / વેન્ડર્સ", href: "/admin/services", icon: "🤝", category: "Services", keywords: "services business caterer mandap photographer સેવાઓ કેટરર્સ" },
  { name: "Pavan Prernadata", gujarati: "પાવન પ્રેરણાદાતા", href: "/admin/pavan-prernadata", icon: "📖", category: "Heritage", keywords: "pavan prernadata inspiration history ઇતિહાસ પ્રેરણા મહાપુરુષ" },
  { name: "Locations & Villages", gujarati: "ગામ અને તાલુકા", href: "/admin/locations", icon: "📍", category: "Locations", keywords: "locations villages taluka district ગામ તાલુકો જિલ્લો" },
  { name: "Parganas Directory", gujarati: "પરગણા યાદી", href: "/admin/parganas", icon: "🏛️", category: "Locations", keywords: "pargana parganas region વિસ્તાર પરગણું ૧૨ પરગણા" },
  { name: "Photo Moderation", gujarati: "ફોટો ચકાસણી", href: "/admin/photos", icon: "🖼️", category: "Moderation", keywords: "photos images pictures avatar ફોટા મંજૂરી" },
  { name: "Advertisements & Banners", gujarati: "જાહેરાત અને બેનર્સ", href: "/admin/advertisements", icon: "📢", category: "Marketing", keywords: "ads advertisements banners જાહેરાત પ્રમોશન સ્પોન્સર" },
  { name: "Home Screen Banners", gujarati: "હોમ સ્ક્રીન બેનર્સ", href: "/admin/home-screen", icon: "📱", category: "App Setup", keywords: "home screen mobile app banners હોમ સ્ક્રીન" },
  { name: "Notifications Broadcast", gujarati: "સંદેશાઓ / નોટિફિકેશન", href: "/admin/notifications", icon: "🔔", category: "System", keywords: "notifications broadcast push alert સૂચના મેસેજ" },
  { name: "Reports & Grievances", gujarati: "ફરિયાદ નિવારણ", href: "/admin/reports", icon: "📈", category: "Moderation", keywords: "reports complaints issues flag ફરિયાદ બ્લોક રિપોર્ટ" },
  { name: "System Settings", gujarati: "સિસ્ટમ સેટિંગ્સ", href: "/admin/settings", icon: "⚙️", category: "System", keywords: "settings config maintenance સેટિંગ્સ સિસ્ટમ" },
  { name: "Dashboard Overview", gujarati: "ડેશબોર્ડ આંકડાકીય વિગત", href: "/admin/dashboard", icon: "📊", category: "Analytics", keywords: "dashboard stats analytics summary ડેશબોર્ડ આંકડા" },
];

export const AdminHeader: React.FC<AdminHeaderProps> = ({
  onToggleSidebar,
  title,
  subtitle = "Welcome to All Gujarat Vankar Samaj Admin Panel",
}) => {
  const router = useRouter();
  const [showNotifications, setShowNotifications] = useState(false);
  const [showProfileMenu, setShowProfileMenu] = useState(false);
  const [showSearch, setShowSearch] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [searchCategory, setSearchCategory] = useState<"ALL" | "PROFILES" | "USERS" | "PAGES">("ALL");

  const [cachedProfiles, setCachedProfiles] = useState<AdminProfileItem[]>([]);
  const [cachedUsers, setCachedUsers] = useState<AdminUserItem[]>([]);
  const [isLoadingSearchData, setIsLoadingSearchData] = useState(false);
  const searchInputRef = useRef<HTMLInputElement>(null);

  const [notifications, setNotifications] = useState<LiveNotificationItem[]>([]);
  const [isLoadingNotifs, setIsLoadingNotifs] = useState(false);
  const notifRef = useRef<HTMLDivElement>(null);
  const profileRef = useRef<HTMLDivElement>(null);

  // Close dropdowns on outside click
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (notifRef.current && !notifRef.current.contains(event.target as Node)) {
        setShowNotifications(false);
      }
      if (profileRef.current && !profileRef.current.contains(event.target as Node)) {
        setShowProfileMenu(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Fetch real-time live admin notifications from backend
  const fetchLiveNotifications = useCallback(async () => {
    try {
      setIsLoadingNotifs(true);
      const readIds = new Set<string>();
      try {
        const stored = localStorage.getItem("admin_read_notification_ids");
        if (stored) {
          const arr = JSON.parse(stored);
          if (Array.isArray(arr)) arr.forEach((id: string) => readIds.add(id));
        }
      } catch (_) {}

      const items: LiveNotificationItem[] = [];

      // 1. Fetch real pending verifications (High Priority)
      try {
        const verifData = await adminApi.getVerifications();
        const verifList = Array.isArray(verifData) ? verifData : ((verifData as any)?.data || []);
        
        const pendingVerifs = verifList.filter((v: any) => v.status === "PENDING");
        for (const v of pendingVerifs.slice(0, 10)) {
          const candidateName = v.profile?.name || v.profile?.firstName || "Candidate";
          const docType = v.documentType || "Aadhar / Document";
          const id = `verif-${v.id}`;
          items.push({
            id,
            title: "ઓળખ ચકાસણી બાકી (Pending Verification)",
            message: `${candidateName} એ ${docType} ચકાસણી માટે મોકલેલ છે.`,
            time: v.createdAt || new Date().toISOString(),
            route: "/admin/verifications",
            type: "VERIFICATION",
            icon: "🛡️",
            isRead: readIds.has(id),
          });
        }
      } catch (_) {}

      // 2. Fetch dashboard stats for recent registrations
      try {
        const stats = await adminApi.getDashboardStats();
        if (stats?.recentUsers && Array.isArray(stats.recentUsers)) {
          for (const u of stats.recentUsers.slice(0, 5)) {
            const id = `user-${u.id}`;
            const name = u.name || "નવું સભ્ય";
            const pargana = u.pargana && u.pargana !== "Not Set" ? u.pargana : "સમાજ";
            items.push({
              id,
              title: "નવું સભ્ય નોંધણી (New Candidate)",
              message: `${name} (${pargana}) એ પોર્ટલ પર નોંધણી કરી.`,
              time: u.createdAt || new Date().toISOString(),
              route: "/admin/users",
              type: "USER",
              icon: "👤",
              isRead: readIds.has(id),
            });
          }
        }
      } catch (_) {}

      // Sort by time descending
      items.sort((a, b) => new Date(b.time).getTime() - new Date(a.time).getTime());

      // Fallback greeting if brand new system with 0 activity
      if (items.length === 0) {
        items.push({
          id: "sys-welcome",
          title: "સિસ્ટમ સક્રિય છે (System Active)",
          message: "તમામ રેકોર્ડ્સ અને ચકાસણી અપ-ટૂ-ડેટ છે. કોઈ પેન્ડિંગ વિનંતી નથી.",
          time: new Date().toISOString(),
          route: "/admin/dashboard",
          type: "SYSTEM",
          icon: "✅",
          isRead: true,
        });
      }

      setNotifications(items);
    } catch (err) {
      console.error("Live notifications fetch error:", err);
    } finally {
      setIsLoadingNotifs(false);
    }
  }, []);

  // Initial fetch and 30-second live polling
  useEffect(() => {
    fetchLiveNotifications();
    const interval = setInterval(fetchLiveNotifications, 30000);
    return () => clearInterval(interval);
  }, [fetchLiveNotifications]);

  const unreadCount = notifications.filter((n) => !n.isRead).length;

  const markAllAsRead = () => {
    try {
      const allIds = notifications.map((n) => n.id);
      localStorage.setItem("admin_read_notification_ids", JSON.stringify(allIds));
    } catch (_) {}
    setNotifications((prev) => prev.map((n) => ({ ...n, isRead: true })));
  };

  const handleNotificationClick = (item: LiveNotificationItem) => {
    try {
      const stored = localStorage.getItem("admin_read_notification_ids");
      const readList = stored ? JSON.parse(stored) : [];
      if (!readList.includes(item.id)) {
        readList.push(item.id);
        localStorage.setItem("admin_read_notification_ids", JSON.stringify(readList));
      }
    } catch (_) {}

    setNotifications((prev) =>
      prev.map((n) => (n.id === item.id ? { ...n, isRead: true } : n))
    );
    setShowNotifications(false);
    router.push(item.route);
  };

  // Focus search input when search opens
  useEffect(() => {
    if (showSearch) {
      const timer = setTimeout(() => {
        searchInputRef.current?.focus();
      }, 60);
      return () => clearTimeout(timer);
    }
  }, [showSearch]);

  // Global keyboard shortcut: Ctrl+K / Cmd+K to open; ESC to close
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "k") {
        e.preventDefault();
        setShowSearch((prev) => !prev);
      } else if (e.key === "Escape" && showSearch) {
        e.preventDefault();
        setShowSearch(false);
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [showSearch]);

  // Fetch profiles and users cache when search is opened
  useEffect(() => {
    if (showSearch && cachedProfiles.length === 0 && !isLoadingSearchData) {
      setIsLoadingSearchData(true);
      Promise.allSettled([adminApi.getProfiles(), adminApi.getUsers()])
        .then(([profRes, userRes]) => {
          if (profRes.status === "fulfilled" && Array.isArray(profRes.value)) {
            setCachedProfiles(profRes.value);
          }
          if (userRes.status === "fulfilled" && Array.isArray(userRes.value)) {
            setCachedUsers(userRes.value);
          }
        })
        .finally(() => setIsLoadingSearchData(false));
    }
  }, [showSearch, cachedProfiles.length, isLoadingSearchData]);

  // Filter calculation
  const cleanQuery = searchQuery.trim().toLowerCase();

  const matchedPages = cleanQuery
    ? ADMIN_NAV_PAGES.filter(
        (p) =>
          p.name.toLowerCase().includes(cleanQuery) ||
          p.gujarati.toLowerCase().includes(cleanQuery) ||
          p.keywords.toLowerCase().includes(cleanQuery)
      )
    : ADMIN_NAV_PAGES.slice(0, 6);

  const matchedProfiles = cleanQuery
    ? cachedProfiles.filter((p) => {
        if (!p) return false;
        return (
          (p.name && p.name.toLowerCase().includes(cleanQuery)) ||
          (p.id && p.id.toLowerCase().includes(cleanQuery)) ||
          (p.city && p.city.toLowerCase().includes(cleanQuery)) ||
          (p.pargana && p.pargana.toLowerCase().includes(cleanQuery)) ||
          (p.education && p.education.toLowerCase().includes(cleanQuery)) ||
          (p.occupation && p.occupation.toLowerCase().includes(cleanQuery)) ||
          (p.gender && p.gender.toLowerCase().includes(cleanQuery)) ||
          (p.user?.phone && p.user.phone.includes(searchQuery.trim())) ||
          (p.user?.email && p.user.email.toLowerCase().includes(cleanQuery))
        );
      }).slice(0, 10)
    : [];

  const matchedUsers = cleanQuery
    ? cachedUsers.filter((u) => {
        if (!u) return false;
        return (
          (u.name && u.name.toLowerCase().includes(cleanQuery)) ||
          (u.email && u.email.toLowerCase().includes(cleanQuery)) ||
          (u.phone && u.phone.includes(searchQuery.trim())) ||
          (u.id && u.id.toLowerCase().includes(cleanQuery)) ||
          (u.pargana && u.pargana.toLowerCase().includes(cleanQuery)) ||
          (u.role && u.role.toLowerCase().includes(cleanQuery))
        );
      }).slice(0, 8)
    : [];

  const handleSelectPage = (href: string) => {
    setShowSearch(false);
    setSearchQuery("");
    router.push(href);
  };

  const handleSelectProfile = (p: any) => {
    setShowSearch(false);
    const searchParam = p.name || p.id || searchQuery.trim();
    router.push(`/admin/profiles?search=${encodeURIComponent(searchParam)}`);
  };

  const handleSelectUser = (u: any) => {
    setShowSearch(false);
    const searchParam = u.name || u.email || searchQuery.trim();
    router.push(`/admin/users?search=${encodeURIComponent(searchParam)}`);
  };

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const query = searchQuery.trim();
    if (!query) return;
    setShowSearch(false);
    router.push(`/admin/profiles?search=${encodeURIComponent(query)}`);
  };

  const handleSearchUsersSubmit = () => {
    const query = searchQuery.trim();
    if (!query) return;
    setShowSearch(false);
    router.push(`/admin/users?search=${encodeURIComponent(query)}`);
  };

  const formatRelativeTime = (isoString: string) => {
    try {
      const date = new Date(isoString);
      const diffMs = Date.now() - date.getTime();
      const diffMins = Math.floor(diffMs / 60000);
      const diffHours = Math.floor(diffMins / 60);
      const diffDays = Math.floor(diffHours / 24);

      if (diffMins < 1) return "હમણાં જ (Just now)";
      if (diffMins < 60) return `${diffMins} મિનિટ પહેલાં`;
      if (diffHours < 24) return `${diffHours} કલાક પહેલાં`;
      if (diffDays === 1) return "ગઈકાલે (Yesterday)";
      return date.toLocaleDateString("gu-IN", { month: "short", day: "numeric" });
    } catch (_) {
      return "તાજેતરમાં";
    }
  };

  return (
    <header
      style={{
        backgroundColor: "#071224",
        backdropFilter: "blur(16px)",
        borderBottom: "1px solid rgba(212, 175, 55, 0.25)",
        boxShadow: "0 6px 25px rgba(0, 0, 0, 0.65)",
        position: "sticky",
        top: 0,
        zIndex: 40,
        padding: "14px 24px",
      }}
      className="flex justify-between items-center gap-4 transition-all"
    >
      {/* Left: Mobile Toggle & Page Info */}
      <div style={{ minWidth: 0 }} className="flex items-center flex-1 gap-3.5">
        <button
          onClick={onToggleSidebar}
          style={{
            padding: "8px 12px",
            borderRadius: "10px",
            backgroundColor: "#0F2040",
            border: "1px solid rgba(212, 175, 55, 0.35)",
            color: "#D4AF37",
          }}
          className="md:hidden hover:bg-[#D4AF37] hover:text-[#041026] transition-all cursor-pointer shrink-0 text-sm font-bold shadow-md"
          aria-label="Toggle Navigation"
        >
          ☰
        </button>

        <div style={{ minWidth: 0, gap: "12px" }} className="flex items-center">
          <div>
            <h1
              style={{
                fontSize: "19px",
                fontWeight: 900,
                letterSpacing: "-0.3px",
                margin: 0,
                lineHeight: 1.2,
                color: "#FFFFFF",
              }}
              className="truncate"
            >
              {title}
            </h1>
            <p
              style={{ margin: "2px 0 0 0", lineHeight: 1.2, color: "#8E9BAE" }}
              className="hidden sm:block truncate font-medium text-xs"
            >
              {subtitle}
            </p>
          </div>
        </div>
      </div>

      {/* Right: Search, Notifications, Admin Profile */}
      <div style={{ gap: "10px" }} className="flex items-center shrink-0">
        {/* Search Portal Trigger Button */}
        <button
          onClick={() => setShowSearch(true)}
          style={{
            padding: "8px 16px",
            borderRadius: "20px",
            backgroundColor: "#0B1A33",
            border: "1px solid rgba(212, 175, 55, 0.35)",
            color: "#D4AF37",
            cursor: "pointer",
            fontSize: "12.5px",
            fontWeight: 600,
            display: "flex",
            alignItems: "center",
            gap: "8px",
            boxShadow: "0 2px 10px rgba(0, 0, 0, 0.25)",
            transition: "all 0.2s ease",
          }}
          className="hover:border-[#D4AF37] hover:bg-[#0F2344] hover:shadow-[0_0_15px_rgba(212,175,55,0.2)]"
          title="Search candidates, phone, ID, or admin pages (Ctrl+K)"
        >
          <span style={{ fontSize: "14px" }}>🔍</span>
          <span className="hidden sm:inline font-medium text-[#8E9BAE] text-xs">
            Search candidates, phone, pages...
          </span>
          <kbd
            style={{
              padding: "1px 6px",
              borderRadius: "5px",
              backgroundColor: "rgba(212, 175, 55, 0.15)",
              border: "1px solid rgba(212, 175, 55, 0.3)",
              fontSize: "10px",
              fontWeight: 700,
              color: "#D4AF37",
              letterSpacing: "0.5px",
            }}
            className="hidden md:inline-block ml-1"
          >
            Ctrl K
          </kbd>
        </button>

        {/* --- LIVE INTERACTIVE NOTIFICATION BELL (🔔) --- */}
        <div ref={notifRef} className="relative">
          <button
            onClick={() => {
              setShowNotifications(!showNotifications);
              setShowProfileMenu(false);
              fetchLiveNotifications();
            }}
            style={{
              width: "40px",
              height: "40px",
              borderRadius: "50%",
              backgroundColor: "#0B1A33",
              border: unreadCount > 0 ? "1.5px solid #F59E0B" : "1px solid rgba(212, 175, 55, 0.3)",
              color: "#FFFFFF",
              cursor: "pointer",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: "16px",
              position: "relative",
              boxShadow: unreadCount > 0 ? "0 0 12px rgba(245, 158, 11, 0.35)" : "none",
            }}
            className="hover:border-[#D4AF37] transition-all hover:scale-105 active:scale-95"
            aria-label="Live Notifications"
            title={unreadCount > 0 ? `${unreadCount} નવી સૂચનાઓ` : "સૂચનાઓ (Notifications)"}
          >
            🔔
            {unreadCount > 0 && (
              <span
                style={{
                  top: "-2px",
                  right: "-2px",
                  minWidth: "18px",
                  height: "18px",
                  padding: "0 4px",
                  backgroundColor: "#EF4444",
                  color: "#FFFFFF",
                  boxShadow: "0 2px 8px rgba(239, 68, 68, 0.6)",
                  border: "1.5px solid #071120",
                }}
                className="flex justify-center items-center font-black absolute rounded-full text-[10px] animate-pulse"
              >
                {unreadCount > 99 ? "99+" : unreadCount}
              </span>
            )}
          </button>

          {/* Real-time Notification Dropdown Drawer */}
          {showNotifications && (
            <div
              style={{
                marginTop: "10px",
                width: "360px",
                maxWidth: "calc(100vw - 32px)",
                backgroundColor: "#071324",
                boxShadow: "0 15px 45px rgba(0, 0, 0, 0.75)",
                zIndex: 50,
                border: "1px solid rgba(212, 175, 55, 0.35)",
              }}
              className="absolute right-0 rounded-2xl p-4 animate-in fade-in slide-in-from-top-2 duration-200"
            >
              {/* Dropdown Header */}
              <div
                style={{
                  paddingBottom: "10px",
                  borderBottom: "1px solid rgba(212, 175, 55, 0.2)",
                  marginBottom: "12px",
                }}
                className="flex justify-between items-center"
              >
                <div className="flex items-center gap-2">
                  <span className="text-base">🔔</span>
                  <span className="font-extrabold text-white text-sm">
                    સૂચનાઓ (Notifications)
                  </span>
                  {unreadCount > 0 && (
                    <span className="bg-red-500/20 text-red-400 border border-red-500/30 text-[10px] font-bold px-2 py-0.5 rounded-full">
                      {unreadCount} નવી
                    </span>
                  )}
                </div>
                {unreadCount > 0 && (
                  <button
                    onClick={markAllAsRead}
                    className="font-bold text-[#D4AF37] hover:text-[#F3E5AB] text-xs transition-colors cursor-pointer bg-transparent border-none p-0"
                  >
                    બધી વંચાઈ ગઈ (Mark read)
                  </button>
                )}
              </div>

              {/* Notification Items List */}
              <div
                style={{ maxHeight: "360px", overflowY: "auto" }}
                className="flex flex-col gap-2.5 custom-scrollbar pr-1"
              >
                {isLoadingNotifs && notifications.length === 0 ? (
                  <div className="flex justify-center items-center py-8 text-slate-400 text-xs gap-2">
                    <span className="animate-spin text-base">⏳</span>
                    <span>સૂચનાઓ લાવી રહ્યું છે...</span>
                  </div>
                ) : notifications.length === 0 ? (
                  <div className="text-center py-8 text-slate-400">
                    <p className="text-2xl mb-1">🎉</p>
                    <p className="text-xs font-semibold text-white">બધી બાબતો પૂર્ણ છે!</p>
                    <p className="text-[11px] text-slate-400">કોઈ નવી અથવા બાકી સૂચના નથી.</p>
                  </div>
                ) : (
                  notifications.map((item) => (
                    <div
                      key={item.id}
                      onClick={() => handleNotificationClick(item)}
                      style={{
                        padding: "10px 12px",
                        borderRadius: "12px",
                        backgroundColor: item.isRead ? "rgba(11, 26, 51, 0.6)" : "rgba(212, 175, 55, 0.1)",
                        border: item.isRead
                          ? "1px solid rgba(255, 255, 255, 0.08)"
                          : "1px solid rgba(212, 175, 55, 0.4)",
                        cursor: "pointer",
                        transition: "all 0.2s ease",
                      }}
                      className="hover:bg-[#0F254B] hover:border-[#D4AF37] group flex items-start gap-3"
                    >
                      <span className="text-lg mt-0.5 shrink-0 p-1.5 rounded-lg bg-black/30 border border-white/10">
                        {item.icon}
                      </span>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center justify-between gap-1">
                          <p className="font-bold text-white text-xs truncate group-hover:text-[#F3E5AB]">
                            {item.title}
                          </p>
                          {!item.isRead && (
                            <span className="w-2 h-2 rounded-full bg-amber-400 shrink-0 shadow-[0_0_6px_#F59E0B]"></span>
                          )}
                        </div>
                        <p className="text-slate-300 text-[11px] mt-0.5 line-clamp-2 leading-tight">
                          {item.message}
                        </p>
                        <div className="flex items-center justify-between mt-1.5">
                          <span className="text-[10px] font-semibold text-[#D4AF37]">
                            {formatRelativeTime(item.time)}
                          </span>
                          <span className="text-[10px] font-bold text-slate-400 group-hover:text-white group-hover:translate-x-0.5 transition-all">
                            તપાસો →
                          </span>
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </div>

              {/* Bottom Quick Action Footer */}
              <div
                style={{
                  marginTop: "12px",
                  paddingTop: "10px",
                  borderTop: "1px solid rgba(212, 175, 55, 0.15)",
                }}
                className="flex items-center justify-between text-xs"
              >
                <Link
                  href="/admin/verifications"
                  onClick={() => setShowNotifications(false)}
                  className="font-bold text-[#D4AF37] hover:underline"
                >
                  ઓળખ ચકાસણી પેન્ડિંગ જુઓ →
                </Link>
                <button
                  onClick={fetchLiveNotifications}
                  className="text-slate-400 hover:text-white text-[11px] font-semibold bg-transparent border-none cursor-pointer"
                  title="રીફ્રેશ કરો"
                >
                  🔄 રીફ્રેશ
                </button>
              </div>
            </div>
          )}
        </div>

        {/* Admin Profile Dropdown */}
        <div ref={profileRef} className="relative">
          <button
            onClick={() => {
              setShowProfileMenu(!showProfileMenu);
              setShowNotifications(false);
            }}
            style={{
              display: "flex",
              alignItems: "center",
              gap: "10px",
              backgroundColor: "#0B1A33",
              border: "1px solid rgba(212, 175, 55, 0.35)",
              borderRadius: "24px",
              padding: "5px 14px 5px 6px",
              cursor: "pointer",
              boxShadow: "0 4px 12px rgba(0,0,0,0.3)",
            }}
            className="hover:border-[#D4AF37] transition-all hover:bg-[#0F2344]"
          >
            <div
              style={{
                color: "#041026",
                boxShadow: "inset 0 1px 3px rgba(255, 255, 255, 0.4)",
                background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
              }}
              className="flex justify-center items-center font-extrabold rounded-full text-xs w-7 h-7 shrink-0"
            >
              A
            </div>
            <div className="hidden sm:block text-left">
              <span
                style={{ display: "block", lineHeight: 1.1 }}
                className="font-bold text-white text-xs truncate max-w-[120px]"
              >
                Admin Officer
              </span>
              <span
                style={{ display: "block", marginTop: "2px", color: "#D4AF37" }}
                className="font-bold text-[10px]"
              >
                Super Admin
              </span>
            </div>
            <span className="text-xs text-slate-400">▾</span>
          </button>

          {showProfileMenu && (
            <div
              style={{
                marginTop: "10px",
                width: "220px",
                backgroundColor: "#071324",
                border: "1px solid rgba(212, 175, 55, 0.35)",
                boxShadow: "0 12px 35px rgba(0, 0, 0, 0.75)",
                zIndex: 50,
              }}
              className="absolute right-0 rounded-2xl p-2.5 animate-in fade-in slide-in-from-top-2 duration-200"
            >
              <div
                style={{
                  padding: "10px 12px",
                  borderBottom: "1px solid rgba(212, 175, 55, 0.15)",
                  marginBottom: "6px",
                }}
              >
                <p className="font-extrabold text-white text-xs">All Gujarat Vankar Samaj</p>
                <p className="text-[11px] text-[#D4AF37] font-semibold">Super Administrator</p>
              </div>

              <div className="flex flex-col gap-1">
                <Link
                  href="/admin/settings"
                  onClick={() => setShowProfileMenu(false)}
                  className="flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold text-slate-300 hover:text-white hover:bg-white/10 transition-colors"
                >
                  <span>⚙️</span>
                  <span>System Settings</span>
                </Link>
                <Link
                  href="/admin/reports"
                  onClick={() => setShowProfileMenu(false)}
                  className="flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold text-slate-300 hover:text-white hover:bg-white/10 transition-colors"
                >
                  <span>📊</span>
                  <span>Audit Reports</span>
                </Link>
                <Link
                  href="/admin/notifications"
                  onClick={() => setShowProfileMenu(false)}
                  className="flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold text-slate-300 hover:text-white hover:bg-white/10 transition-colors"
                >
                  <span>📢</span>
                  <span>Broadcast Notice</span>
                </Link>
              </div>

              <div
                style={{
                  marginTop: "6px",
                  paddingTop: "6px",
                  borderTop: "1px solid rgba(212, 175, 55, 0.15)",
                }}
              >
                <button
                  onClick={async () => {
                    localStorage.removeItem("adminUser");
                    localStorage.removeItem("adminToken");
                    try {
                      await adminApi.logout();
                    } catch (_) {}
                    router.push("/admin/login");
                  }}
                  className="w-full flex items-center gap-2 px-3 py-2 rounded-xl text-xs font-bold text-rose-300 hover:bg-rose-950/50 hover:text-rose-100 transition-colors cursor-pointer bg-transparent border-none text-left"
                >
                  <span>🚪</span>
                  <span>Sign Out</span>
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* ========================================================================= */}
      {/* GLOBAL SEARCH SPOTLIGHT / COMMAND PALETTE MODAL */}
      {/* ========================================================================= */}
      {showSearch && (
        <div
          style={{
            position: "fixed",
            inset: 0,
            zIndex: 100,
            backgroundColor: "rgba(3, 10, 24, 0.85)",
            backdropFilter: "blur(14px)",
            display: "flex",
            alignItems: "flex-start",
            justifyContent: "center",
            paddingTop: "60px",
            paddingBottom: "40px",
            paddingLeft: "16px",
            paddingRight: "16px",
            overflowY: "auto",
          }}
          onClick={(e) => {
            if (e.target === e.currentTarget) setShowSearch(false);
          }}
        >
          <div
            style={{
              width: "100%",
              maxWidth: "680px",
              backgroundColor: "#08152D",
              border: "1px solid rgba(212, 175, 55, 0.4)",
              borderRadius: "20px",
              boxShadow: "0 25px 60px rgba(0, 0, 0, 0.85), 0 0 35px rgba(212, 175, 55, 0.2)",
              overflow: "hidden",
              display: "flex",
              flexDirection: "column",
            }}
            onClick={(e) => e.stopPropagation()}
          >
            {/* Top Search Input Row */}
            <form
              onSubmit={handleSearchSubmit}
              style={{
                display: "flex",
                alignItems: "center",
                gap: "12px",
                padding: "16px 20px",
                borderBottom: "1px solid rgba(212, 175, 55, 0.25)",
                backgroundColor: "#0B1D3D",
              }}
            >
              <span style={{ fontSize: "18px", color: "#D4AF37" }}>🔍</span>
              <input
                ref={searchInputRef}
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search candidate name, mobile, pargana, ID, or admin page..."
                autoComplete="off"
                style={{
                  flex: 1,
                  backgroundColor: "transparent",
                  border: "none",
                  outline: "none",
                  color: "#FFFFFF",
                  fontSize: "15px",
                  fontWeight: 600,
                }}
              />

              {searchQuery && (
                <button
                  type="button"
                  onClick={() => setSearchQuery("")}
                  style={{
                    backgroundColor: "rgba(255, 255, 255, 0.1)",
                    border: "none",
                    borderRadius: "50%",
                    width: "22px",
                    height: "22px",
                    color: "#D4AF37",
                    cursor: "pointer",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontSize: "11px",
                    fontWeight: "bold",
                  }}
                  title="Clear"
                >
                  ✕
                </button>
              )}

              <button
                type="button"
                onClick={() => setShowSearch(false)}
                style={{
                  backgroundColor: "rgba(212, 175, 55, 0.15)",
                  border: "1px solid rgba(212, 175, 55, 0.3)",
                  borderRadius: "8px",
                  padding: "4px 8px",
                  color: "#D4AF37",
                  fontSize: "11px",
                  fontWeight: 700,
                  cursor: "pointer",
                }}
                title="Close (Esc)"
              >
                ESC
              </button>
            </form>

            {/* Filter Category Tabs */}
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: "8px",
                padding: "10px 20px",
                borderBottom: "1px solid rgba(212, 175, 55, 0.15)",
                backgroundColor: "rgba(4, 16, 38, 0.5)",
                overflowX: "auto",
              }}
            >
              {[
                { id: "ALL", label: `All Results (${matchedPages.length + matchedProfiles.length + matchedUsers.length})` },
                { id: "PROFILES", label: `Candidates (${matchedProfiles.length})` },
                { id: "USERS", label: `Users (${matchedUsers.length})` },
                { id: "PAGES", label: `Admin Pages (${matchedPages.length})` },
              ].map((tab) => (
                <button
                  key={tab.id}
                  type="button"
                  onClick={() => setSearchCategory(tab.id as any)}
                  style={{
                    padding: "5px 12px",
                    borderRadius: "14px",
                    fontSize: "11.5px",
                    fontWeight: 700,
                    cursor: "pointer",
                    border: searchCategory === tab.id ? "1px solid #D4AF37" : "1px solid rgba(255, 255, 255, 0.1)",
                    backgroundColor: searchCategory === tab.id ? "#D4AF37" : "#09172E",
                    color: searchCategory === tab.id ? "#041026" : "#A3B3C8",
                    transition: "all 0.2s ease",
                    whiteSpace: "nowrap",
                  }}
                >
                  {tab.label}
                </button>
              ))}
            </div>

            {/* Results Area */}
            <div
              style={{
                maxHeight: "380px",
                overflowY: "auto",
                padding: "12px 16px",
                display: "flex",
                flexDirection: "column",
                gap: "12px",
              }}
            >
              {isLoadingSearchData && cachedProfiles.length === 0 && (
                <div style={{ textAlign: "center", padding: "20px 0", color: "#D4AF37", fontSize: "12px", fontWeight: 600 }}>
                  ⏳ Loading candidate and community directory...
                </div>
              )}

              {/* 1. Admin Pages Section */}
              {(searchCategory === "ALL" || searchCategory === "PAGES") && matchedPages.length > 0 && (
                <div>
                  <div style={{ fontSize: "10.5px", fontWeight: 800, color: "#8E9BAE", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px", paddingLeft: "4px" }}>
                    🧭 Admin Pages & Sections
                  </div>
                  <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
                    {matchedPages.map((page) => (
                      <div
                        key={page.href}
                        onClick={() => handleSelectPage(page.href)}
                        style={{
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "space-between",
                          padding: "10px 14px",
                          borderRadius: "12px",
                          backgroundColor: "#0C1F3F",
                          border: "1px solid rgba(212, 175, 55, 0.15)",
                          cursor: "pointer",
                          transition: "all 0.2s ease",
                        }}
                        className="hover:border-[#D4AF37] hover:bg-[#122A54]"
                      >
                        <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                          <span style={{ fontSize: "18px" }}>{page.icon}</span>
                          <div>
                            <div style={{ fontSize: "13px", fontWeight: 700, color: "#FFFFFF" }}>{page.name}</div>
                            <div style={{ fontSize: "11px", color: "#D4AF37" }}>{page.gujarati}</div>
                          </div>
                        </div>
                        <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                          <span style={{ fontSize: "10.5px", color: "#8E9BAE", backgroundColor: "rgba(255,255,255,0.06)", padding: "2px 8px", borderRadius: "6px" }}>
                            {page.category}
                          </span>
                          <span style={{ color: "#D4AF37", fontSize: "12px" }}>➔</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* 2. Matched Candidates / Profiles Section */}
              {(searchCategory === "ALL" || searchCategory === "PROFILES") && matchedProfiles.length > 0 && (
                <div>
                  <div style={{ fontSize: "10.5px", fontWeight: 800, color: "#8E9BAE", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px", paddingLeft: "4px" }}>
                    👰 Matrimonial Candidates ({matchedProfiles.length})
                  </div>
                  <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
                    {matchedProfiles.map((p) => {
                      const avatarUrl = Array.isArray(p.photos) && p.photos.length > 0 ? p.photos[0] : p.photoUrl;
                      const initials = (p.name || "Candidate").slice(0, 2).toUpperCase();
                      return (
                        <div
                          key={p.id}
                          onClick={() => handleSelectProfile(p)}
                          style={{
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "space-between",
                            padding: "10px 14px",
                            borderRadius: "12px",
                            backgroundColor: "#0C1F3F",
                            border: "1px solid rgba(212, 175, 55, 0.2)",
                            cursor: "pointer",
                            transition: "all 0.2s ease",
                          }}
                          className="hover:border-[#D4AF37] hover:bg-[#122A54]"
                        >
                          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                            {avatarUrl ? (
                              <img
                                src={avatarUrl.startsWith("http") ? avatarUrl : `https://allgujaratvankarsamaj.com${avatarUrl.startsWith("/") ? "" : "/"}${avatarUrl}`}
                                alt={p.name || "Candidate"}
                                style={{ width: "36px", height: "36px", borderRadius: "50%", objectFit: "cover", border: "1px solid #D4AF37" }}
                                onError={(e) => {
                                  (e.target as HTMLElement).style.display = "none";
                                }}
                              />
                            ) : (
                              <div
                                style={{
                                  width: "36px",
                                  height: "36px",
                                  borderRadius: "50%",
                                  backgroundColor: "rgba(212, 175, 55, 0.2)",
                                  border: "1px solid #D4AF37",
                                  color: "#F3E5AB",
                                  display: "flex",
                                  alignItems: "center",
                                  justifyContent: "center",
                                  fontSize: "12px",
                                  fontWeight: 800,
                                }}
                              >
                                {initials}
                              </div>
                            )}

                            <div>
                              <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                                <span style={{ fontSize: "13.5px", fontWeight: 700, color: "#FFFFFF" }}>{p.name || "Candidate Member"}</span>
                                {p.gender && (
                                  <span style={{ fontSize: "10.5px", color: p.gender === "FEMALE" ? "#F472B6" : "#60A5FA", fontWeight: 700 }}>
                                    {p.gender === "FEMALE" ? "Female" : "Male"} {p.age ? `• ${p.age} yrs` : ""}
                                  </span>
                                )}
                              </div>
                              <div style={{ fontSize: "11.5px", color: "#A3B3C8", marginTop: "2px" }}>
                                {p.pargana ? `${p.pargana}` : "Samaj"} {p.city ? `• ${p.city}` : ""} {p.user?.phone ? `• 📞 ${p.user.phone}` : ""}
                              </div>
                            </div>
                          </div>

                          <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                            <span
                              style={{
                                fontSize: "10px",
                                fontWeight: 700,
                                padding: "3px 8px",
                                borderRadius: "8px",
                                backgroundColor: p.status === "APPROVED" ? "rgba(34, 197, 94, 0.15)" : "rgba(234, 179, 8, 0.15)",
                                color: p.status === "APPROVED" ? "#4ADE80" : "#FACC15",
                                border: p.status === "APPROVED" ? "1px solid rgba(34, 197, 94, 0.3)" : "1px solid rgba(234, 179, 8, 0.3)",
                              }}
                            >
                              {p.status || "MEMBER"}
                            </span>
                            <span style={{ color: "#D4AF37", fontSize: "12px" }}>➔</span>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                </div>
              )}

              {/* 3. Matched Users Section */}
              {(searchCategory === "ALL" || searchCategory === "USERS") && matchedUsers.length > 0 && (
                <div>
                  <div style={{ fontSize: "10.5px", fontWeight: 800, color: "#8E9BAE", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px", paddingLeft: "4px" }}>
                    👥 Registered User Accounts ({matchedUsers.length})
                  </div>
                  <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
                    {matchedUsers.map((u) => (
                      <div
                        key={u.id}
                        onClick={() => handleSelectUser(u)}
                        style={{
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "space-between",
                          padding: "10px 14px",
                          borderRadius: "12px",
                          backgroundColor: "#0C1F3F",
                          border: "1px solid rgba(212, 175, 55, 0.15)",
                          cursor: "pointer",
                          transition: "all 0.2s ease",
                        }}
                        className="hover:border-[#D4AF37] hover:bg-[#122A54]"
                      >
                        <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
                          <span style={{ fontSize: "16px" }}>👤</span>
                          <div>
                            <div style={{ fontSize: "13px", fontWeight: 700, color: "#FFFFFF" }}>{u.name || "Member User"}</div>
                            <div style={{ fontSize: "11px", color: "#A3B3C8" }}>
                              {u.email} {u.phone ? `• 📞 ${u.phone}` : ""} {u.pargana ? `• ${u.pargana}` : ""}
                            </div>
                          </div>
                        </div>

                        <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                          <span style={{ fontSize: "10px", color: "#D4AF37", border: "1px solid rgba(212, 175, 55, 0.3)", padding: "2px 8px", borderRadius: "6px" }}>
                            {u.role || "USER"}
                          </span>
                          <span style={{ color: "#D4AF37", fontSize: "12px" }}>➔</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Empty Search State */}
              {cleanQuery && matchedPages.length === 0 && matchedProfiles.length === 0 && matchedUsers.length === 0 && (
                <div style={{ textAlign: "center", padding: "30px 16px", color: "#A3B3C8" }}>
                  <div style={{ fontSize: "28px", marginBottom: "8px" }}>🔍</div>
                  <div style={{ fontSize: "14px", fontWeight: 700, color: "#FFFFFF" }}>
                    No direct matches found for &ldquo;{searchQuery}&rdquo;
                  </div>
                  <p style={{ fontSize: "12px", color: "#8E9BAE", margin: "6px 0 16px" }}>
                    You can still search all community profiles or user accounts:
                  </p>
                  <div style={{ display: "flex", justifyContent: "center", gap: "10px", flexWrap: "wrap" }}>
                    <button
                      type="button"
                      onClick={handleSearchSubmit}
                      style={{
                        padding: "8px 18px",
                        borderRadius: "12px",
                        backgroundColor: "#D4AF37",
                        color: "#041026",
                        fontSize: "12px",
                        fontWeight: 800,
                        border: "none",
                        cursor: "pointer",
                      }}
                    >
                      Search All Profiles for &ldquo;{searchQuery}&rdquo; ➔
                    </button>
                    <button
                      type="button"
                      onClick={handleSearchUsersSubmit}
                      style={{
                        padding: "8px 18px",
                        borderRadius: "12px",
                        backgroundColor: "#0F2448",
                        border: "1px solid rgba(212, 175, 55, 0.4)",
                        color: "#D4AF37",
                        fontSize: "12px",
                        fontWeight: 700,
                        cursor: "pointer",
                      }}
                    >
                      Search in Users ➔
                    </button>
                  </div>
                </div>
              )}
            </div>

            {/* Modal Bottom Action Bar */}
            <div
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                padding: "12px 20px",
                borderTop: "1px solid rgba(212, 175, 55, 0.2)",
                backgroundColor: "#071328",
                flexWrap: "wrap",
                gap: "10px",
              }}
            >
              <div style={{ fontSize: "11px", color: "#8E9BAE" }}>
                💡 Tip: Press <strong style={{ color: "#D4AF37" }}>Enter ↵</strong> to search all profiles • <strong style={{ color: "#D4AF37" }}>ESC</strong> to close
              </div>
              <div style={{ display: "flex", gap: "8px" }}>
                <button
                  type="button"
                  onClick={handleSearchUsersSubmit}
                  style={{
                    padding: "6px 12px",
                    borderRadius: "8px",
                    backgroundColor: "transparent",
                    border: "1px solid rgba(212, 175, 55, 0.3)",
                    color: "#D4AF37",
                    fontSize: "11.5px",
                    fontWeight: 700,
                    cursor: "pointer",
                  }}
                >
                  Search in Users
                </button>
                <button
                  type="button"
                  onClick={handleSearchSubmit}
                  style={{
                    padding: "6px 14px",
                    borderRadius: "8px",
                    backgroundColor: "#D4AF37",
                    border: "none",
                    color: "#041026",
                    fontSize: "11.5px",
                    fontWeight: 800,
                    cursor: "pointer",
                  }}
                >
                  Search in Profiles (Enter ↵)
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </header>
  );
};

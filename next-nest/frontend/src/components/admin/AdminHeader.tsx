"use client";

import React, { useState, useEffect, useCallback, useRef } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { adminApi } from "@/lib/admin-api";

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

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      router.push(`/admin/users?search=${encodeURIComponent(searchQuery.trim())}`);
      setShowSearch(false);
    }
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
        backgroundColor: "rgba(7, 17, 32, 0.92)",
        backdropFilter: "blur(16px)",
        borderBottom: "1px solid rgba(212, 175, 55, 0.22)",
        position: "sticky",
        top: 0,
        zIndex: 30,
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
        {/* Search Portal Box */}
        <div className="relative">
          {showSearch ? (
            <form
              onSubmit={handleSearchSubmit}
              style={{
                backgroundColor: "#0B1A33",
                border: "1px solid #D4AF37",
                borderRadius: "20px",
                boxShadow: "0 4px 14px rgba(0, 0, 0, 0.4)",
              }}
              className="flex items-center gap-2 py-1.5 px-3.5"
            >
              <span className="text-[#D4AF37] text-xs">🔍</span>
              <input
                type="text"
                autoFocus
                placeholder="Search candidates, ID, phone..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{
                  backgroundColor: "transparent",
                  border: "none",
                  outline: "none",
                  fontSize: "12px",
                  color: "#FFFFFF",
                  width: "180px",
                }}
              />
              <button
                type="button"
                onClick={() => setShowSearch(false)}
                style={{
                  border: "none",
                  background: "transparent",
                  color: "#8E9BAE",
                  cursor: "pointer",
                  fontSize: "12px",
                  fontWeight: 700,
                }}
              >
                ✕
              </button>
            </form>
          ) : (
            <button
              onClick={() => setShowSearch(true)}
              style={{
                padding: "8px 14px",
                borderRadius: "20px",
                backgroundColor: "#0B1A33",
                border: "1px solid rgba(212, 175, 55, 0.3)",
                color: "#D4AF37",
                cursor: "pointer",
                fontSize: "12.5px",
                fontWeight: 600,
                display: "flex",
                alignItems: "center",
                gap: "6px",
              }}
              className="hover:border-[#D4AF37] transition-all hover:bg-[#0F2344]"
              title="Search portal"
            >
              <span>🔍</span>
              <span className="hidden xl:inline font-medium text-[#8E9BAE] text-xs">
                Search
              </span>
            </button>
          )}
        </div>

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
    </header>
  );
};

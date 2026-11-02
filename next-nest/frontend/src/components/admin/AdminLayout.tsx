"use client";

import React, { useState, useEffect } from "react";
import { useRouter, usePathname } from "next/navigation";
import { AdminSidebar } from "./AdminSidebar";
import { AdminHeader } from "./AdminHeader";

interface AdminLayoutProps {
  children: React.ReactNode;
  title: string;
  subtitle?: string;
}

const ROUTE_PERMISSION_MAP: { prefix: string; permKey: string }[] = [
  { prefix: "/admin/admins", permKey: "super_admin_only" },
  { prefix: "/admin/dashboard", permKey: "dashboard" },
  { prefix: "/admin/users", permKey: "users" },
  { prefix: "/admin/profiles", permKey: "profiles" },
  { prefix: "/admin/government-employees", permKey: "government_employees" },
  { prefix: "/admin/verifications", permKey: "verifications" },
  { prefix: "/admin/matches", permKey: "matches" },
  { prefix: "/admin/education", permKey: "education" },
  { prefix: "/admin/locations", permKey: "locations" },
  { prefix: "/admin/parganas", permKey: "locations" },
  { prefix: "/admin/services", permKey: "services" },
  { prefix: "/admin/pavan-prernadata", permKey: "pavan_prernadata" },
  { prefix: "/admin/samaj-super-stars", permKey: "samaj_super_stars" },
  { prefix: "/admin/samaj-ratna", permKey: "samaj_ratna" },
  { prefix: "/admin/home-screen", permKey: "home_screen" },
  { prefix: "/admin/advertisements", permKey: "advertisements" },
  { prefix: "/admin/notifications", permKey: "notifications" },
  { prefix: "/admin/reports", permKey: "reports" },
  { prefix: "/admin/otp-analytics", permKey: "otp_analytics" },
  { prefix: "/admin/settings", permKey: "settings" },
];

export const AdminLayout: React.FC<AdminLayoutProps> = ({
  children,
  title,
  subtitle,
}) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [isAuthorized, setIsAuthorized] = useState<boolean | null>(null);
  const [adminUser, setAdminUser] = useState<any>(null);
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    const savedTheme = localStorage.getItem("adminTheme");
    if (savedTheme === "light") {
      document.documentElement.classList.add("light-mode");
    }

    const adminToken = localStorage.getItem("adminToken");
    if (!adminToken) {
      setIsAuthorized(false);
      router.replace("/admin/login");
      if (typeof window !== "undefined") {
        window.location.replace("/admin/login");
      }
      return;
    }

    try {
      const stored = localStorage.getItem("adminUser");
      if (stored) {
        setAdminUser(JSON.parse(stored));
      }
    } catch (_) {}

    setIsAuthorized(true);
  }, [router]);

  if (isAuthorized !== true) {
    return (
      <div className="min-h-screen bg-[#070F1E] flex flex-col items-center justify-center p-4">
        <div className="flex flex-col items-center gap-4">
          <div className="w-12 h-12 border-4 border-[#D4AF37] border-t-transparent rounded-full animate-spin"></div>
          <p className="text-[#D4AF37] text-sm font-semibold tracking-wider font-sans">
            ચકાસણી ચાલુ છે... (Verifying Admin Session)
          </p>
        </div>
      </div>
    );
  }

  const isSuperAdmin = adminUser?.role === "SUPER_ADMIN";
  const userPerms: string[] = Array.isArray(adminUser?.permissions) ? adminUser.permissions : [];

  // Match current route against route permissions
  const matchedRule = ROUTE_PERMISSION_MAP.find((rule) => pathname.startsWith(rule.prefix));

  let isAllowed = true;
  let isSuperAdminOnly = false;

  if (matchedRule) {
    if (matchedRule.permKey === "super_admin_only") {
      isSuperAdminOnly = true;
      isAllowed = isSuperAdmin;
    } else if (!isSuperAdmin) {
      isAllowed = userPerms.includes(matchedRule.permKey);
    }
  }

  // Find first allowed section for fallback button
  const firstAllowedRule = ROUTE_PERMISSION_MAP.find(
    (r) => r.permKey !== "super_admin_only" && userPerms.includes(r.permKey)
  );
  const fallbackRoute = firstAllowedRule ? firstAllowedRule.prefix : "/admin/dashboard";

  return (
    <div className="min-h-screen bg-[#070F1E] text-white flex flex-col">
      {/* Permanently Fixed Left Sidebar */}
      <AdminSidebar
        isOpen={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
      />

      {/* Main Content Area - Guaranteed to never be overlapped by fixed sidebar */}
      <div className="admin-main-desktop flex-1 flex flex-col min-w-0 bg-[#070F1E] min-h-screen">
        {/* Sticky Top Header */}
        <AdminHeader
          onToggleSidebar={() => setSidebarOpen(!sidebarOpen)}
          title={title}
          subtitle={subtitle}
        />

        {/* Page Content Container */}
        <main className="flex-1 px-4 sm:px-6 lg:px-8 pt-6 pb-16 space-y-6 w-full max-w-7xl mx-auto">
          {isAllowed ? (
            children
          ) : (
            <div className="flex flex-col items-center justify-center py-20 px-4 text-center">
              <div className="max-w-lg w-full bg-[#0B1528] border border-red-500/30 rounded-3xl p-8 sm:p-10 shadow-2xl relative overflow-hidden">
                <div className="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-red-500 via-amber-500 to-yellow-500" />
                <div className="w-20 h-20 mx-auto rounded-2xl bg-red-500/10 border border-red-500/20 flex items-center justify-center text-4xl mb-5 shadow-inner">
                  {isSuperAdminOnly ? "👑" : "🛡️"}
                </div>
                <h2 className="text-xl sm:text-2xl font-extrabold text-white mb-2">
                  {isSuperAdminOnly
                    ? "માત્ર સુપર એડમિન માટે (Super Admin Only)"
                    : "વિભાગ પ્રવેશ પ્રતિબંધિત છે (Restricted Access)"}
                </h2>
                <p className="text-sm text-gray-300 mb-3 leading-relaxed">
                  {isSuperAdminOnly
                    ? "આ સબ-એડમિન મેનેજમેન્ટ વિભાગ માત્ર મુખ્ય સુપર એડમિનિસ્ટ્રેટર દ્વારા જ એક્સેસ કરી શકાય છે."
                    : "તમારા સબ-એડમિન એકાઉન્ટ પાસે આ વિભાગ ઍક્સેસ કરવાની અધિકૃત પરવાનગી નથી."}
                </p>
                <p className="text-xs text-gray-400 mb-6">
                  {isSuperAdminOnly
                    ? "This section is restricted to the Super Administrator."
                    : "You do not have access privileges for this section. Please contact your Super Administrator to request permission."}
                </p>
                <div className="flex flex-wrap items-center justify-center gap-3">
                  {userPerms.length > 0 && (
                    <button
                      type="button"
                      onClick={() => router.push(fallbackRoute)}
                      className="px-5 py-2.5 bg-gradient-to-r from-[#D4AF37] to-[#B38F26] text-black font-bold text-sm rounded-xl shadow-lg hover:brightness-110 active:scale-95 transition"
                    >
                      માન્ય વિભાગ પર જાઓ (Go to Permitted Section)
                    </button>
                  )}
                  <button
                    type="button"
                    onClick={() => router.back()}
                    className="px-4 py-2.5 bg-white/10 hover:bg-white/15 text-gray-300 text-sm font-semibold rounded-xl transition"
                  >
                    પાછળ જાઓ (Go Back)
                  </button>
                </div>
              </div>
            </div>
          )}
        </main>
      </div>
    </div>
  );
};

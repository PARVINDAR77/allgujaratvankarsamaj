"use client";

import React from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";

interface AdminSidebarProps {
  isOpen: boolean;
  onClose: () => void;
}

const menuSections = [
  {
    title: "DASHBOARD",
    items: [
      { name: "Dashboard", href: "/admin/dashboard", icon: "📊" },
    ],
  },
  {
    title: "USER MANAGEMENT",
    items: [
      { name: "Users", href: "/admin/users", icon: "👥" },
      { name: "Profiles", href: "/admin/profiles", icon: "👤" },
      { name: "Photos", href: "/admin/photos", icon: "🖼️" },
      { name: "Verifications", href: "/admin/verifications", icon: "🛡️" },
    ],
  },
  {
    title: "MATCHMAKING",
    items: [
      { name: "Matches", href: "/admin/matches", icon: "💖" },
      { name: "Shortlists", href: "/admin/shortlists", icon: "⭐" },
      { name: "Interests", href: "/admin/interests", icon: "💌" },
    ],
  },
  {
    title: "COMMUNICATION",
    items: [
      { name: "Messages", href: "/admin/messages", icon: "💬" },
      { name: "Conversations", href: "/admin/conversations", icon: "🗣️" },
    ],
  },
  {
    title: "COMMUNITY",
    items: [
      { name: "Parganas", href: "/admin/parganas", icon: "🏛️" },
      { name: "Community Members", href: "/admin/community", icon: "🌐" },
    ],
  },
  {
    title: "CONTENT & SETTINGS",
    items: [
      { name: "Pages & Content", href: "/admin/content", icon: "📝" },
      { name: "Notifications", href: "/admin/notifications", icon: "🔔" },
      { name: "Reports", href: "/admin/reports", icon: "📈" },
      { name: "Admin Users", href: "/admin/admins", icon: "👑" },
      { name: "Settings", href: "/admin/settings", icon: "⚙️" },
      { name: "System Health", href: "/admin/health", icon: "🩺" },
    ],
  },
];

export const AdminSidebar: React.FC<AdminSidebarProps> = ({ isOpen, onClose }) => {
  const pathname = usePathname();
  const router = useRouter();

  const handleLogout = () => {
    if (typeof window !== "undefined") {
      localStorage.removeItem("adminToken");
      localStorage.removeItem("adminUser");
    }
    router.push("/admin/login");
  };

  return (
    <>
      {/* Mobile overlay */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/70 z-40 md:hidden"
          onClick={onClose}
        />
      )}

      <aside
        className={`fixed md:sticky top-0 left-0 h-screen z-50 md:z-30 w-64 shrink-0 bg-[#0A1628] border-r border-[#997D20]/30 flex flex-col transition-transform duration-300 ${
          isOpen ? "translate-x-0" : "-translate-x-full md:translate-x-0"
        }`}
      >
        {/* Brand Header */}
        <div className="p-5 border-b border-[#997D20]/30 flex items-center gap-3 shrink-0">
          <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-[#D4AF37] via-[#F3E5AB] to-[#E8C95A] flex items-center justify-center text-black font-black text-xl shadow-[0_0_15px_rgba(212,175,55,0.4)]">
            V
          </div>
          <div>
            <h1 className="font-black tracking-wider text-[#D4AF37] text-base leading-tight">
              VANKAR
            </h1>
            <p className="text-[10px] tracking-widest text-[#E8C95A]/90 uppercase font-bold">
              SAMAJ MATRIMONY ADMIN
            </p>
          </div>
        </div>

        {/* Navigation List */}
        <div className="flex-1 overflow-y-auto px-3 py-4 space-y-6 scrollbar-thin scrollbar-thumb-[#D4AF37]/20">
          {menuSections.map((section, idx) => (
            <div key={idx} className="space-y-1">
              <h2 className="px-3 text-[10px] font-extrabold tracking-widest text-[#AAB7C8]/60 uppercase">
                {section.title}
              </h2>
              <ul className="mt-1 space-y-1">
                {section.items.map((item) => {
                  const isActive = pathname === item.href;
                  return (
                    <li key={item.href}>
                      <Link
                        href={item.href}
                        onClick={() => onClose()}
                        className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition-all duration-200 ${
                          isActive
                            ? "bg-gradient-to-r from-[#D4AF37] via-[#F3E5AB] to-[#E8C95A] text-black shadow-[0_0_15px_rgba(212,175,55,0.3)] font-extrabold"
                            : "text-[#AAB7C8] hover:text-white hover:bg-[#0F2040]"
                        }`}
                      >
                        <span className="text-base">{item.icon}</span>
                        <span>{item.name}</span>
                      </Link>
                    </li>
                  );
                })}
              </ul>
            </div>
          ))}
        </div>

        {/* Footer Logout */}
        <div className="p-4 border-t border-[#997D20]/30 shrink-0">
          <button
            onClick={handleLogout}
            className="w-full flex items-center justify-center gap-2 py-2.5 px-4 rounded-xl bg-[#0F2040] hover:bg-red-950/60 text-red-400 hover:text-red-300 border border-red-500/30 text-xs font-bold transition-all"
          >
            <span>🚪</span>
            <span>Logout</span>
          </button>
        </div>
      </aside>
    </>
  );
};

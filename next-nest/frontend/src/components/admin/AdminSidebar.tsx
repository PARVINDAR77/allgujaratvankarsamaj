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
      { name: "Govt. Employees", href: "/admin/government-employees", icon: "💼" },
      { name: "Verifications", href: "/admin/verifications", icon: "🛡️" },
    ],
  },
  {
    title: "MATCHMAKING",
    items: [
      { name: "Matches", href: "/admin/matches", icon: "💖" },
    ],
  },
  {
    title: "COMMUNITY",
    items: [
      { name: "Locations", href: "/admin/locations", icon: "📍" },
      { name: "Parganas", href: "/admin/parganas", icon: "🏛️" },
      { name: "Samaj Services", href: "/admin/services", icon: "🤝" },
    ],
  },
  {
    title: "CONTENT & SETTINGS",
    items: [
      { name: "Reports", href: "/admin/reports", icon: "📈" },
      { name: "Settings", href: "/admin/settings", icon: "⚙️" },
    ],
  },
];

export const AdminSidebar: React.FC<AdminSidebarProps> = ({ isOpen, onClose }) => {
  const pathname = usePathname();
  const router = useRouter();

  const handleLogout = async () => {
    if (typeof window !== "undefined") {
      localStorage.removeItem("adminUser");
      const { adminApi } = await import("../../lib/admin-api");
      try {
        await adminApi.logout();
      } catch (e) {
        console.error("Logout error", e);
      }
    }
    router.push("/admin/login");
  };

  return (
    <>
      {/* Mobile Overlay */}
      {isOpen && (
        <div
          onClick={onClose}
           style={{ inset: 0, backgroundColor: "rgba(0, 0, 0, 0.75)", zIndex: 40 }} className="fixed"
        />
      )}

      {/* Sidebar Navigation Drawer */}
      <aside
         style={{ position: "sticky", height: "100vh", width: "270px", minWidth: "270px", backgroundColor: "#061224", borderRight: "1.5px solid rgba(153, 125, 32, 0.4)", zIndex: 50, boxSizing: "border-box", boxShadow: "5px 0 25px rgba(0, 0, 0, 0.5)", fontFamily: "'Inter', system-ui, sans-serif" }} className="flex flex-col top-0 left-0"
      >
        {/* Brand Header */}
        <div
           style={{ padding: "22px 20px", borderBottom: "1.5px solid rgba(153, 125, 32, 0.3)" }} className="flex items-center shrink-0 gap-[14px]"
        >
          {/* Logo Image */}
          <div
             style={{ width: "48px", height: "48px", border: "2px solid #D4AF37", boxShadow: "0 0 15px rgba(212, 175, 55, 0.4)" }} className="flex justify-center items-center overflow-hidden shrink-0 rounded-full bg-admin-card"
          >
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src="/logo.png"
              alt="Vankar Samaj Logo"
               style={{ objectFit: "cover" }} className="w-full h-full"
            />
          </div>
          <div>
            <h1
               style={{ fontSize: "15px", fontWeight: 900, letterSpacing: "1.2px", margin: 0, lineHeight: "1.2" }} className="text-admin-gold"
            >
              ALL GUJARAT
            </h1>
            <p
                style={{ color: "rgba(243, 229, 171, 0.9)", margin: 0 }} className="font-bold uppercase text-[11px] tracking-[1px]" 
            >
              Vankar Samaj Admin
            </p>
          </div>
        </div>

        {/* Scrollable Navigation Menu */}
        <div
           style={{ overflowY: "auto", padding: "20px 14px", gap: "22px" }} className="flex flex-col flex-1"
        >
          {menuSections.map((section, idx) => (
            <div key={idx}  style={{ gap: "6px" }} className="flex flex-col">
              <h2
                 style={{ color: "rgba(212, 175, 55, 0.75)", letterSpacing: "1.5px", padding: "0 10px", margin: "0 0 4px 0" }} className="font-extrabold uppercase text-[11px]"
              >
                {section.title}
              </h2>
              <div  style={{ gap: "4px" }} className="flex flex-col">
                {section.items.map((item) => {
                  const isActive = pathname === item.href;
                  return (
                    <Link
                      key={item.href}
                      href={item.href}
                      onClick={() => onClose()}
                      style={{
                        display: "flex",
                        alignItems: "center",
                        gap: "12px",
                        padding: "11px 14px",
                        borderRadius: "14px",
                        fontSize: "13px",
                        fontWeight: isActive ? 800 : 600,
                        textDecoration: "none",
                        transition: "all 0.2s ease-in-out",
                        ...(isActive
                          ? {
                              background: "linear-gradient(90deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                              color: "#000000",
                              boxShadow: "0 0 15px rgba(212, 175, 55, 0.35)",
                            }
                          : {
                              color: "#AAB7C8",
                              backgroundColor: "transparent",
                            }),
                      }}
                    >
                      <span  className="shrink-0 text-base">{item.icon}</span>
                      <span>{item.name}</span>
                    </Link>
                  );
                })}
              </div>
            </div>
          ))}
        </div>

        {/* Footer Logout Section */}
        <div
            style={{ borderTop: "1.5px solid rgba(153, 125, 32, 0.3)" }} className="shrink-0 p-4" 
        >
          <button
            onClick={handleLogout}
             style={{ padding: "12px 16px", borderRadius: "14px", backgroundColor: "rgba(136, 19, 55, 0.3)", border: "1.5px solid rgba(244, 63, 94, 0.4)", color: "#fecdd3", transition: "all 0.2s ease-in-out" }} className="flex justify-center items-center w-full font-extrabold cursor-pointer text-[13px] gap-2"
          >
            <span>🚪</span>
            <span>Logout Session</span>
          </button>
        </div>
      </aside>
    </>
  );
};

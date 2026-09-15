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

  const handleLogout = () => {
    if (typeof window !== "undefined") {
      localStorage.removeItem("adminToken");
      localStorage.removeItem("adminUser");
    }
    router.push("/admin/login");
  };

  return (
    <>
      {/* Mobile Overlay */}
      {isOpen && (
        <div
          onClick={onClose}
          style={{
            position: "fixed",
            inset: 0,
            backgroundColor: "rgba(0, 0, 0, 0.75)",
            zIndex: 40,
          }}
        />
      )}

      {/* Sidebar Navigation Drawer */}
      <aside
        style={{
          position: "sticky",
          top: 0,
          left: 0,
          height: "100vh",
          width: "270px",
          minWidth: "270px",
          backgroundColor: "#061224",
          borderRight: "1.5px solid rgba(153, 125, 32, 0.4)",
          display: "flex",
          flexDirection: "column",
          zIndex: 50,
          boxSizing: "border-box",
          boxShadow: "5px 0 25px rgba(0, 0, 0, 0.5)",
          fontFamily: "'Inter', system-ui, sans-serif",
        }}
      >
        {/* Brand Header */}
        <div
          style={{
            padding: "22px 20px",
            borderBottom: "1.5px solid rgba(153, 125, 32, 0.3)",
            display: "flex",
            alignItems: "center",
            gap: "14px",
            flexShrink: 0,
          }}
        >
          {/* Logo Image */}
          <div
            style={{
              width: "48px",
              height: "48px",
              borderRadius: "50%",
              overflow: "hidden",
              border: "2px solid #D4AF37",
              boxShadow: "0 0 15px rgba(212, 175, 55, 0.4)",
              flexShrink: 0,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              backgroundColor: "#041026",
            }}
          >
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src="/logo.png"
              alt="Vankar Samaj Logo"
              style={{ width: "100%", height: "100%", objectFit: "cover" }}
            />
          </div>
          <div>
            <h1
              style={{
                fontSize: "15px",
                fontWeight: 900,
                color: "#D4AF37",
                letterSpacing: "1.2px",
                margin: 0,
                lineHeight: "1.2",
              }}
            >
              ALL GUJARAT
            </h1>
            <p
              style={{
                fontSize: "11px",
                fontWeight: 700,
                color: "rgba(243, 229, 171, 0.9)",
                letterSpacing: "1px",
                textTransform: "uppercase",
                margin: 0,
              }}
            >
              Vankar Samaj Admin
            </p>
          </div>
        </div>

        {/* Scrollable Navigation Menu */}
        <div
          style={{
            flex: 1,
            overflowY: "auto",
            padding: "20px 14px",
            display: "flex",
            flexDirection: "column",
            gap: "22px",
          }}
        >
          {menuSections.map((section, idx) => (
            <div key={idx} style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
              <h2
                style={{
                  fontSize: "11px",
                  fontWeight: 800,
                  color: "rgba(212, 175, 55, 0.75)",
                  letterSpacing: "1.5px",
                  textTransform: "uppercase",
                  padding: "0 10px",
                  margin: "0 0 4px 0",
                }}
              >
                {section.title}
              </h2>
              <div style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
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
                      <span style={{ fontSize: "16px", flexShrink: 0 }}>{item.icon}</span>
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
          style={{
            padding: "16px",
            borderTop: "1.5px solid rgba(153, 125, 32, 0.3)",
            flexShrink: 0,
          }}
        >
          <button
            onClick={handleLogout}
            style={{
              width: "100%",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: "8px",
              padding: "12px 16px",
              borderRadius: "14px",
              backgroundColor: "rgba(136, 19, 55, 0.3)",
              border: "1.5px solid rgba(244, 63, 94, 0.4)",
              color: "#fecdd3",
              fontSize: "13px",
              fontWeight: 800,
              cursor: "pointer",
              transition: "all 0.2s ease-in-out",
            }}
          >
            <span>🚪</span>
            <span>Logout Session</span>
          </button>
        </div>
      </aside>
    </>
  );
};

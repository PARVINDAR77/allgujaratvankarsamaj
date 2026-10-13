"use client";

import React, { useRef, useEffect, UIEvent } from "react";
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
    title: "COMMUNITY & SERVICES",
    items: [
      { name: "Education (5 Boxes)", href: "/admin/education", icon: "🎓" },
      { name: "Locations", href: "/admin/locations", icon: "📍" },
      { name: "Parganas", href: "/admin/parganas", icon: "🏛️" },
      { name: "Samaj Services", href: "/admin/services", icon: "🤝" },
      { name: "Pavan Prernadata", href: "/admin/pavan-prernadata", icon: "📖" },
      { name: "Samaj Super Stars", href: "/admin/samaj-super-stars", icon: "🌟" },
      { name: "Samaj Ratna", href: "/admin/samaj-ratna", icon: "🏆" },
    ],
  },
  {
    title: "CONTENT & SYSTEM",
    items: [
      { name: "Home Screen", href: "/admin/home-screen", icon: "📱" },
      { name: "Advertisements", href: "/admin/advertisements", icon: "📢" },
      { name: "Notifications", href: "/admin/notifications", icon: "🔔" },
      { name: "Reports", href: "/admin/reports", icon: "📈" },
      { name: "Settings", href: "/admin/settings", icon: "⚙️" },
    ],
  },
];

export const AdminSidebar: React.FC<AdminSidebarProps> = ({ isOpen, onClose }) => {
  const pathname = usePathname();
  const router = useRouter();

  const navContainerRef = useRef<HTMLDivElement>(null);
  const activeLinkRef = useRef<HTMLAnchorElement>(null);

  // Restore scroll position or scroll active item into view on route change
  useEffect(() => {
    const restoreScrollPosition = () => {
      if (!navContainerRef.current) return;

      const savedScroll = sessionStorage.getItem("admin_sidebar_scroll_top");
      if (savedScroll !== null) {
        const parsed = parseInt(savedScroll, 10);
        if (!isNaN(parsed)) {
          navContainerRef.current.scrollTop = parsed;
        }
      }

      // Ensure the active menu button is visible in the viewport
      if (activeLinkRef.current && navContainerRef.current) {
        const container = navContainerRef.current;
        const link = activeLinkRef.current;
        const containerRect = container.getBoundingClientRect();
        const linkRect = link.getBoundingClientRect();

        const isAbove = linkRect.top < containerRect.top + 10;
        const isBelow = linkRect.bottom > containerRect.bottom - 10;

        if (isAbove || isBelow) {
          link.scrollIntoView({ block: "nearest", inline: "nearest" });
          try {
            sessionStorage.setItem("admin_sidebar_scroll_top", String(container.scrollTop));
          } catch {}
        }
      }
    };

    restoreScrollPosition();
    const frameId = requestAnimationFrame(restoreScrollPosition);
    const timer = setTimeout(restoreScrollPosition, 60);

    return () => {
      cancelAnimationFrame(frameId);
      clearTimeout(timer);
    };
  }, [pathname]);

  const handleNavScroll = (e: UIEvent<HTMLDivElement>) => {
    try {
      sessionStorage.setItem("admin_sidebar_scroll_top", String(e.currentTarget.scrollTop));
    } catch {}
  };

  const handleLinkClick = () => {
    if (navContainerRef.current) {
      try {
        sessionStorage.setItem("admin_sidebar_scroll_top", String(navContainerRef.current.scrollTop));
      } catch {}
    }
    onClose();
  };

  const handleLogout = async () => {
    if (typeof window !== "undefined") {
      sessionStorage.removeItem("admin_sidebar_scroll_top");
      localStorage.removeItem("adminUser");
      localStorage.removeItem("adminToken");
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
      {/* Mobile Backdrop Overlay */}
      {isOpen && (
        <div
          onClick={onClose}
          className="fixed inset-0 bg-black/80 backdrop-blur-sm z-40 md:hidden transition-opacity"
        />
      )}

      {/* Permanently Fixed Sidebar Drawer */}
      <aside
        style={{
          position: "fixed",
          top: 0,
          bottom: 0,
          left: 0,
          width: "270px",
          height: "100vh",
          background: "linear-gradient(180deg, #071224 0%, #040915 100%)",
          borderRight: "1px solid rgba(212, 175, 55, 0.22)",
          zIndex: 45,
          boxShadow: "4px 0 30px rgba(0, 0, 0, 0.6)",
          fontFamily: "'Inter', system-ui, sans-serif",
          overflow: "hidden",
        }}
        className={`admin-sidebar-desktop flex flex-col transition-transform duration-300 ease-in-out ${
          isOpen ? "translate-x-0" : "-translate-x-full md:translate-x-0"
        }`}
      >
        {/* Brand Header */}
        <div
          style={{
            padding: "20px 20px 18px 20px",
            borderBottom: "1px solid rgba(212, 175, 55, 0.2)",
            background: "linear-gradient(180deg, rgba(212, 175, 55, 0.08) 0%, transparent 100%)",
          }}
          className="flex items-center justify-between shrink-0"
        >
          <div className="flex items-center gap-3.5">
            {/* Logo Medallion */}
            <div
              style={{
                width: "44px",
                height: "44px",
                border: "2px solid #D4AF37",
                boxShadow: "0 0 16px rgba(212, 175, 55, 0.45)",
              }}
              className="flex justify-center items-center overflow-hidden shrink-0 rounded-full bg-[#041026]"
            >
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                src="/logo.png"
                alt="All Gujarat Vankar Samaj Logo"
                style={{ objectFit: "cover" }}
                className="w-full h-full"
              />
            </div>
            <div>
              <h1
                style={{
                  fontSize: "14px",
                  fontWeight: 900,
                  letterSpacing: "1.2px",
                  margin: 0,
                  lineHeight: "1.2",
                  color: "#D4AF37",
                }}
              >
                ALL GUJARAT
              </h1>
              <p
                style={{ color: "#F3E5AB", margin: "2px 0 0 0" }}
                className="font-bold uppercase text-[10.5px] tracking-wider"
              >
                Vankar Samaj Admin
              </p>
            </div>
          </div>

          {/* Close button for mobile */}
          <button
            onClick={onClose}
            className="md:hidden p-1.5 rounded-lg text-slate-400 hover:text-white hover:bg-white/10"
            aria-label="Close menu"
          >
            ✕
          </button>
        </div>

        {/* Status Pill */}
        <div className="px-5 pt-3.5 pb-1">
          <div className="flex items-center justify-between px-3 py-1.5 rounded-lg bg-emerald-500/10 border border-emerald-500/25">
            <span className="flex items-center gap-1.5 text-[11px] font-bold text-emerald-400">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
              PORTAL LIVE
            </span>
            <span className="text-[10px] font-semibold text-slate-400">
              Gujarat Central
            </span>
          </div>
        </div>

        {/* Scrollable Navigation Menu */}
        <div
          ref={navContainerRef}
          onScroll={handleNavScroll}
          style={{
            overflowY: "auto",
            padding: "16px 14px 40px 14px",
            gap: "20px",
            minHeight: 0,
          }}
          className="flex flex-col flex-1 custom-scrollbar"
        >
          {menuSections.map((section, idx) => (
            <div key={idx} style={{ gap: "5px" }} className="flex flex-col">
              <h2
                style={{
                  color: "rgba(212, 175, 55, 0.75)",
                  letterSpacing: "1.4px",
                  padding: "0 10px",
                  margin: "0 0 3px 0",
                }}
                className="font-extrabold uppercase text-[10.5px]"
              >
                {section.title}
              </h2>
              <div style={{ gap: "3px" }} className="flex flex-col">
                {section.items.map((item) => {
                  const isActive = pathname === item.href;
                  return (
                    <Link
                      key={item.href}
                      ref={isActive ? activeLinkRef : undefined}
                      href={item.href}
                      scroll={false}
                      onClick={handleLinkClick}
                      style={{
                        display: "flex",
                        alignItems: "center",
                        gap: "12px",
                        padding: "10px 14px",
                        borderRadius: "12px",
                        fontSize: "13px",
                        fontWeight: isActive ? 800 : 600,
                        textDecoration: "none",
                        transition: "all 0.2s cubic-bezier(0.4, 0, 0.2, 1)",
                        ...(isActive
                          ? {
                              background:
                                "linear-gradient(90deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                              color: "#041026",
                              boxShadow: "0 3px 15px rgba(212, 175, 55, 0.35)",
                              transform: "translateX(2px)",
                            }
                          : {
                              color: "#94A3B8",
                              backgroundColor: "transparent",
                            }),
                      }}
                      className={isActive ? "" : "hover:bg-white/5 hover:text-[#F3E5AB] hover:translate-x-1"}
                    >
                      <span className="shrink-0 text-base">{item.icon}</span>
                      <span className="truncate">{item.name}</span>
                    </Link>
                  );
                })}
              </div>
            </div>
          ))}
        </div>

        {/* Footer Logout & User Status */}
        <div
          style={{
            borderTop: "1px solid rgba(212, 175, 55, 0.2)",
            background: "linear-gradient(180deg, transparent 0%, rgba(4, 9, 21, 0.95) 100%)",
            padding: "14px 16px",
          }}
          className="shrink-0 flex flex-col gap-2.5"
        >
          <div className="flex items-center justify-between text-xs px-1 text-slate-400">
            <span className="truncate">Administrator Session</span>
            <span className="text-[10px] font-extrabold text-[#D4AF37] bg-[#D4AF37]/10 px-2 py-0.5 rounded border border-[#D4AF37]/30">
              SECURE
            </span>
          </div>
          <button
            onClick={handleLogout}
            style={{
              padding: "10px 16px",
              borderRadius: "12px",
              backgroundColor: "rgba(225, 29, 72, 0.12)",
              border: "1px solid rgba(244, 63, 94, 0.35)",
              color: "#fecdd3",
              transition: "all 0.2s ease-in-out",
            }}
            className="flex justify-center items-center w-full font-bold cursor-pointer text-xs gap-2 hover:bg-rose-950/60 hover:text-white hover:border-rose-500"
          >
            <span>🚪</span>
            <span>Logout Session</span>
          </button>
        </div>
      </aside>
    </>
  );
};

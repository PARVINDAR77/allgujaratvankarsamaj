"use client";

import React, { useState } from "react";
import Link from "next/link";

interface AdminHeaderProps {
  onToggleSidebar: () => void;
  title: string;
  subtitle?: string;
}

export const AdminHeader: React.FC<AdminHeaderProps> = ({
  onToggleSidebar,
  title,
  subtitle = "Welcome to All Gujarat Vankar Samaj Admin Panel",
}) => {
  const [showNotifications, setShowNotifications] = useState(false);
  const [showProfileMenu, setShowProfileMenu] = useState(false);
  const [showSearch, setShowSearch] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");

  return (
    <header
       style={{ backgroundColor: "rgba(6, 16, 30, 0.95)", backdropFilter: "blur(12px)", borderBottom: "1px solid rgba(212, 175, 55, 0.25)", position: "sticky", zIndex: 30, padding: "16px 28px" }} className="flex justify-between items-center top-0 gap-4"
    >
      {/* Left: Mobile Toggle & Page Info */}
      <div  style={{ minWidth: 0 }} className="flex items-center flex-1 gap-4">
        <button
          onClick={onToggleSidebar}
           style={{ padding: "8px 12px", borderRadius: "10px", backgroundColor: "#0F2040" }}
          className="md:hidden hover:bg-admin-gold hover:text-black transition-all cursor-pointer shrink-0 text-admin-gold border border-admin-gold/30 text-sm"
          aria-label="Toggle Navigation"
        >
          ☰
        </button>

        <div  style={{ minWidth: 0, gap: "12px" }} className="flex items-center">
          {/* Header Logo Badge */}
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src="/logo.png"
            alt="Vankar Samaj Medallion"
             style={{ width: "38px", height: "38px", border: "1.5px solid #D4AF37", boxShadow: "0 0 10px rgba(212, 175, 55, 0.4)", objectFit: "cover" }} className="rounded-full"
          />
          <div>
            <h1
             style={{ fontSize: "20px", letterSpacing: "-0.3px", margin: 0, lineHeight: 1.2 }}
            className="truncate font-extrabold text-white"
          >
            {title}
          </h1>
          <p
             style={{ margin: "3px 0 0 0", lineHeight: 1.2 }}
            className="hidden sm:block truncate font-medium text-admin-muted text-xs"
          >
            {subtitle}
          </p>
        </div>
      </div>
    </div>

      {/* Right: Search Toggle, Notifications, Admin Profile */}
      <div  style={{ gap: "12px" }} className="flex items-center shrink-0">
        {/* Search Drawer Toggle */}
        <div  className="relative">
          {showSearch ? (
            <div
                style={{ backgroundColor: "#0F2040", border: "1px solid #D4AF37", borderRadius: "20px", boxShadow: "0 4px 12px rgba(0, 0, 0, 0.3)" }} className="flex items-center gap-2 py-1.5 px-3.5" 
            >
              <span  className="text-admin-gold text-[13px]">🔍</span>
              <input
                type="text"
                autoFocus
                placeholder="Search portal..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{
                  backgroundColor: "transparent",
                  border: "none",
                  outline: "none",
                  fontSize: "12px",
                  color: "#FFFFFF",
                  width: "160px",
                }}
              />
              <button
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
            </div>
          ) : (
            <button
              onClick={() => setShowSearch(true)}
              style={{
                padding: "8px 14px",
                borderRadius: "20px",
                backgroundColor: "#0F2040",
                border: "1px solid rgba(212, 175, 55, 0.3)",
                color: "#D4AF37",
                cursor: "pointer",
                fontSize: "13px",
                fontWeight: 600,
                display: "flex",
                alignItems: "center",
                gap: "6px",
              }}
              className="hover:border-admin-gold transition-all"
              title="Search"
            >
              <span>🔍</span>
              <span  className="hidden xl:inline font-medium text-admin-muted text-xs">
                Search
              </span>
            </button>
          )}
        </div>

        {/* Notifications Bell */}
        <div  className="relative">
          <button
            onClick={() => {
              setShowNotifications(!showNotifications);
              setShowProfileMenu(false);
            }}
            style={{
              width: "38px",
              height: "38px",
              borderRadius: "50%",
              backgroundColor: "#0F2040",
              border: "1px solid rgba(212, 175, 55, 0.3)",
              color: "#FFFFFF",
              cursor: "pointer",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: "14px",
              position: "relative",
            }}
            className="hover:border-admin-gold transition-all"
            aria-label="Notifications"
          >
            🔔
            <span
               style={{ top: "-2px", right: "-2px", width: "16px", height: "16px", background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 100%)", color: "#041026", boxShadow: "0 2px 6px rgba(0, 0, 0, 0.5)" }} className="flex justify-center items-center font-extrabold absolute rounded-full text-[10px]"
            >
              3
            </span>
          </button>

          {showNotifications && (
            <div
                style={{ marginTop: "8px", width: "280px", backgroundColor: "#0F2040", boxShadow: "0 12px 35px rgba(0, 0, 0, 0.6)", zIndex: 50 }} className="absolute right-0 rounded-2xl border border-admin-gold/40 p-4" 
            >
              <div
                 style={{ paddingBottom: "8px", borderBottom: "1px solid rgba(212, 175, 55, 0.2)", marginBottom: "10px" }} className="flex justify-between items-center"
              >
                <span  className="font-bold text-white text-[13px]">Notifications</span>
                <span  className="font-semibold cursor-pointer text-admin-gold text-[11px]">
                  Mark all read
                </span>
              </div>
              <div  className="flex flex-col text-admin-muted text-xs gap-2">
                <div
                   style={{ padding: "10px 12px", borderRadius: "10px" }} className="bg-admin-card border border-admin-gold/20"
                >
                  <p  style={{ margin: 0 }} className="font-bold text-white">New Verification Request</p>
                  <p  style={{ margin: "2px 0 4px 0" }} className="text-admin-muted text-[11px]">
                    Hemantkumar Vankar submitted ID proof
                  </p>
                  <span  className="font-semibold text-admin-gold text-[10px]">10 mins ago</span>
                </div>
                <div
                   style={{ padding: "10px 12px", borderRadius: "10px" }} className="bg-admin-card border border-admin-gold/20"
                >
                  <p  style={{ margin: 0 }} className="font-bold text-white">5 New User Registrations</p>
                  <span  className="font-semibold text-admin-gold text-[10px]">1 hour ago</span>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Admin Profile Dropdown */}
        <div  className="relative">
          <button
            onClick={() => {
              setShowProfileMenu(!showProfileMenu);
              setShowNotifications(false);
            }}
            style={{
              display: "flex",
              alignItems: "center",
              gap: "10px",
              backgroundColor: "#0F2040",
              border: "1px solid rgba(212, 175, 55, 0.35)",
              borderRadius: "24px",
              padding: "5px 14px 5px 6px",
              cursor: "pointer",
              boxShadow: "0 4px 12px rgba(0,0,0,0.3)",
            }}
            className="hover:border-admin-gold transition-all"
          >
            <div
                style={{ color: "#041026", boxShadow: "inset 0 1px 3px rgba(255, 255, 255, 0.4)" }} className="flex justify-center items-center font-extrabold rounded-full text-[13px] bg-gradient-to-br from-admin-gold via-admin-gold-light to-admin-gold-border w-8 h-8" 
            >
              A
            </div>
            <div  className="hidden sm:block text-left">
              <span  style={{ display: "block", lineHeight: 1.1 }} className="font-bold text-white text-xs">
                Admin Officer
              </span>
              <span  style={{ display: "block", marginTop: "2px" }} className="font-bold text-admin-gold text-[10px]">
                Super Admin
              </span>
            </div>
          </button>

          {showProfileMenu && (
            <div
                style={{ marginTop: "8px", width: "180px", backgroundColor: "#0F2040", borderRadius: "14px", boxShadow: "0 12px 35px rgba(0, 0, 0, 0.6)", padding: "6px", zIndex: 50, gap: "4px" }} className="flex flex-col absolute right-0 border border-admin-gold/40" 
            >
              <Link
                href="/admin/settings"
                onClick={() => setShowProfileMenu(false)}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "8px",
                  padding: "8px 12px",
                  fontSize: "12px",
                  fontWeight: 600,
                  color: "#FFFFFF",
                  borderRadius: "8px",
                  textDecoration: "none",
                }}
                className="hover:bg-admin-card transition-all"
              >
                <span>⚙️</span>
                <span>Settings</span>
              </Link>
              <Link
                href="/admin/health"
                onClick={() => setShowProfileMenu(false)}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "8px",
                  padding: "8px 12px",
                  fontSize: "12px",
                  fontWeight: 600,
                  color: "#FFFFFF",
                  borderRadius: "8px",
                  textDecoration: "none",
                }}
                className="hover:bg-admin-card transition-all"
              >
                <span>🩺</span>
                <span>System Health</span>
              </Link>
              <div style={{ borderTop: "1px solid rgba(212, 175, 55, 0.2)", margin: "4px 0" }} />
              <button
                onClick={async () => {
                  setShowProfileMenu(false);
                  if (typeof window !== "undefined") {
                    localStorage.removeItem("adminUser");
                    const { adminApi } = await import("../../lib/admin-api");
                    try {
                      await adminApi.logout();
                    } catch (e) {
                      console.error("Logout error", e);
                    }
                  }
                  window.location.href = "/admin/login";
                }}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "8px",
                  padding: "8px 12px",
                  fontSize: "12px",
                  fontWeight: 700,
                  color: "#FB7185",
                  borderRadius: "8px",
                  background: "transparent",
                  border: "none",
                  cursor: "pointer",
                  width: "100%",
                  textAlign: "left",
                }}
                className="hover:bg-rose-950/40 transition-all"
              >
                <span>🚪</span>
                <span>Logout</span>
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};


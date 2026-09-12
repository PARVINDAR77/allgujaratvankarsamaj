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
      style={{
        backgroundColor: "rgba(6, 16, 30, 0.95)",
        backdropFilter: "blur(12px)",
        borderBottom: "1px solid rgba(212, 175, 55, 0.25)",
        position: "sticky",
        top: 0,
        zIndex: 30,
        padding: "16px 28px",
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        gap: "16px",
      }}
    >
      {/* Left: Mobile Toggle & Page Info */}
      <div style={{ display: "flex", alignItems: "center", gap: "16px", minWidth: 0, flex: 1 }}>
        <button
          onClick={onToggleSidebar}
          style={{
            padding: "8px 12px",
            borderRadius: "10px",
            backgroundColor: "#0F2040",
            color: "#D4AF37",
            border: "1px solid rgba(212, 175, 55, 0.3)",
            cursor: "pointer",
            fontSize: "14px",
            flexShrink: 0,
          }}
          className="md:hidden hover:bg-[#D4AF37] hover:text-black transition-all"
          aria-label="Toggle Navigation"
        >
          ☰
        </button>

        <div style={{ minWidth: 0, display: "flex", alignItems: "center", gap: "12px" }}>
          {/* Header Logo Badge */}
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src="/logo.png"
            alt="Vankar Samaj Medallion"
            style={{
              width: "38px",
              height: "38px",
              borderRadius: "50%",
              border: "1.5px solid #D4AF37",
              boxShadow: "0 0 10px rgba(212, 175, 55, 0.4)",
              objectFit: "cover",
            }}
          />
          <div>
            <h1
            style={{
              fontSize: "20px",
              fontWeight: 800,
              color: "#FFFFFF",
              letterSpacing: "-0.3px",
              margin: 0,
              lineHeight: 1.2,
            }}
            className="truncate"
          >
            {title}
          </h1>
          <p
            style={{
              fontSize: "12px",
              color: "#8E9BAE",
              fontWeight: 500,
              margin: "3px 0 0 0",
              lineHeight: 1.2,
            }}
            className="hidden sm:block truncate"
          >
            {subtitle}
          </p>
        </div>
      </div>
    </div>

      {/* Right: Search Toggle, Notifications, Admin Profile */}
      <div style={{ display: "flex", alignItems: "center", gap: "12px", flexShrink: 0 }}>
        {/* Search Drawer Toggle */}
        <div style={{ position: "relative" }}>
          {showSearch ? (
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: "8px",
                backgroundColor: "#0F2040",
                border: "1px solid #D4AF37",
                borderRadius: "20px",
                padding: "6px 14px",
                boxShadow: "0 4px 12px rgba(0,0,0,0.3)",
              }}
            >
              <span style={{ fontSize: "13px", color: "#D4AF37" }}>🔍</span>
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
              className="hover:border-[#D4AF37] transition-all"
              title="Search"
            >
              <span>🔍</span>
              <span style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 500 }} className="hidden xl:inline">
                Search
              </span>
            </button>
          )}
        </div>

        {/* Notifications Bell */}
        <div style={{ position: "relative" }}>
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
            className="hover:border-[#D4AF37] transition-all"
            aria-label="Notifications"
          >
            🔔
            <span
              style={{
                position: "absolute",
                top: "-2px",
                right: "-2px",
                width: "16px",
                height: "16px",
                borderRadius: "50%",
                background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 100%)",
                color: "#041026",
                fontSize: "10px",
                fontWeight: 800,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                boxShadow: "0 2px 6px rgba(0,0,0,0.5)",
              }}
            >
              3
            </span>
          </button>

          {showNotifications && (
            <div
              style={{
                position: "absolute",
                right: 0,
                marginTop: "8px",
                width: "280px",
                backgroundColor: "#0F2040",
                border: "1px solid rgba(212, 175, 55, 0.4)",
                borderRadius: "16px",
                boxShadow: "0 12px 35px rgba(0, 0, 0, 0.6)",
                padding: "16px",
                zIndex: 50,
              }}
            >
              <div
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  paddingBottom: "8px",
                  borderBottom: "1px solid rgba(212, 175, 55, 0.2)",
                  marginBottom: "10px",
                }}
              >
                <span style={{ fontSize: "13px", fontWeight: 700, color: "#FFFFFF" }}>Notifications</span>
                <span style={{ fontSize: "11px", color: "#D4AF37", fontWeight: 600, cursor: "pointer" }}>
                  Mark all read
                </span>
              </div>
              <div style={{ display: "flex", flexDirection: "column", gap: "8px", fontSize: "12px", color: "#8E9BAE" }}>
                <div
                  style={{
                    padding: "10px 12px",
                    borderRadius: "10px",
                    backgroundColor: "#041026",
                    border: "1px solid rgba(212, 175, 55, 0.2)",
                  }}
                >
                  <p style={{ color: "#FFFFFF", fontWeight: 700, margin: 0 }}>New Verification Request</p>
                  <p style={{ fontSize: "11px", color: "#8E9BAE", margin: "2px 0 4px 0" }}>
                    Hemantkumar Vankar submitted ID proof
                  </p>
                  <span style={{ fontSize: "10px", color: "#D4AF37", fontWeight: 600 }}>10 mins ago</span>
                </div>
                <div
                  style={{
                    padding: "10px 12px",
                    borderRadius: "10px",
                    backgroundColor: "#041026",
                    border: "1px solid rgba(212, 175, 55, 0.2)",
                  }}
                >
                  <p style={{ color: "#FFFFFF", fontWeight: 700, margin: 0 }}>5 New User Registrations</p>
                  <span style={{ fontSize: "10px", color: "#D4AF37", fontWeight: 600 }}>1 hour ago</span>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Admin Profile Dropdown */}
        <div style={{ position: "relative" }}>
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
            className="hover:border-[#D4AF37] transition-all"
          >
            <div
              style={{
                width: "32px",
                height: "32px",
                borderRadius: "50%",
                background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                color: "#041026",
                fontWeight: 800,
                fontSize: "13px",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                boxShadow: "inset 0 1px 3px rgba(255,255,255,0.4)",
              }}
            >
              A
            </div>
            <div style={{ textAlign: "left" }} className="hidden sm:block">
              <span style={{ display: "block", fontSize: "12px", fontWeight: 700, color: "#FFFFFF", lineHeight: 1.1 }}>
                Admin Officer
              </span>
              <span style={{ display: "block", fontSize: "10px", color: "#D4AF37", fontWeight: 700, marginTop: "2px" }}>
                Super Admin
              </span>
            </div>
          </button>

          {showProfileMenu && (
            <div
              style={{
                position: "absolute",
                right: 0,
                marginTop: "8px",
                width: "180px",
                backgroundColor: "#0F2040",
                border: "1px solid rgba(212, 175, 55, 0.4)",
                borderRadius: "14px",
                boxShadow: "0 12px 35px rgba(0, 0, 0, 0.6)",
                padding: "6px",
                zIndex: 50,
                display: "flex",
                flexDirection: "column",
                gap: "4px",
              }}
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
                className="hover:bg-[#041026] transition-all"
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
                className="hover:bg-[#041026] transition-all"
              >
                <span>🩺</span>
                <span>System Health</span>
              </Link>
              <div style={{ borderTop: "1px solid rgba(212, 175, 55, 0.2)", margin: "4px 0" }} />
              <Link
                href="/admin/login"
                onClick={() => setShowProfileMenu(false)}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "8px",
                  padding: "8px 12px",
                  fontSize: "12px",
                  fontWeight: 700,
                  color: "#FB7185",
                  borderRadius: "8px",
                  textDecoration: "none",
                }}
                className="hover:bg-rose-950/40 transition-all"
              >
                <span>🚪</span>
                <span>Logout</span>
              </Link>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};


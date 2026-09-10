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
  subtitle = "Welcome to Vankar Samaj Matrimony Admin Panel",
}) => {
  const [showNotifications, setShowNotifications] = useState(false);
  const [showProfileMenu, setShowProfileMenu] = useState(false);
  const [showSearch, setShowSearch] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");

  return (
    <header className="bg-[#0A1628]/95 backdrop-blur-md border-b border-[#997D20]/30 sticky top-0 z-30 px-4 md:px-6 py-3.5 flex items-center justify-between gap-4">
      {/* Left: Mobile Toggle & Page Info */}
      <div className="flex items-center gap-3 min-w-0 flex-1">
        <button
          onClick={onToggleSidebar}
          className="md:hidden p-2.5 rounded-xl bg-[#0F2040] text-[#D4AF37] border border-[#997D20]/30 shrink-0 hover:bg-[#D4AF37] hover:text-black transition-all"
          aria-label="Toggle Navigation"
        >
          ☰
        </button>

        <div className="min-w-0">
          <h1 className="text-base sm:text-lg font-extrabold text-white tracking-wide truncate">
            {title}
          </h1>
          <p className="text-xs text-[#AAB7C8] hidden sm:block truncate">{subtitle}</p>
        </div>
      </div>

      {/* Right: Search Toggle, Notifications, Admin Profile */}
      <div className="flex items-center gap-3 shrink-0">
        {/* Search Drawer Toggle */}
        <div className="relative">
          {showSearch ? (
            <div className="flex items-center gap-2 bg-[#0F2040] border border-[#D4AF37] rounded-full px-3 py-1 shadow-lg">
              <span className="text-xs text-[#D4AF37]">🔍</span>
              <input
                type="text"
                autoFocus
                placeholder="Search portal..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="bg-transparent text-xs text-white placeholder-[#AAB7C8]/60 focus:outline-none w-36 sm:w-48"
              />
              <button
                onClick={() => setShowSearch(false)}
                className="text-xs text-[#AAB7C8] hover:text-white font-bold ml-1"
              >
                ✕
              </button>
            </div>
          ) : (
            <button
              onClick={() => setShowSearch(true)}
              className="p-2.5 rounded-full bg-[#0F2040] border border-[#997D20]/30 text-[#D4AF37] hover:bg-[#D4AF37] hover:text-black transition-all text-xs font-bold flex items-center gap-1.5"
              title="Search"
            >
              <span>🔍</span>
              <span className="hidden xl:inline text-[11px] font-semibold text-[#AAB7C8]">Search</span>
            </button>
          )}
        </div>

        {/* Notifications Bell */}
        <div className="relative">
          <button
            onClick={() => {
              setShowNotifications(!showNotifications);
              setShowProfileMenu(false);
            }}
            className="p-2.5 rounded-full bg-[#0F2040] border border-[#997D20]/30 text-white hover:text-[#D4AF37] transition-all relative"
            aria-label="Notifications"
          >
            🔔
            <span className="absolute -top-1 -right-1 w-4 h-4 rounded-full bg-gradient-to-r from-[#D4AF37] via-[#F3E5AB] to-[#E8C95A] text-black text-[9px] font-extrabold flex items-center justify-center shadow-md">
              3
            </span>
          </button>

          {showNotifications && (
            <div className="absolute right-0 mt-2 w-72 bg-[#0F2040] border border-[#997D20] rounded-2xl shadow-2xl p-4 z-50">
              <div className="flex justify-between items-center pb-2 border-b border-[#997D20]/20 mb-2">
                <span className="text-xs font-extrabold text-white">Notifications</span>
                <span className="text-[10px] text-[#D4AF37] font-bold cursor-pointer hover:underline">Mark all read</span>
              </div>
              <div className="space-y-2 text-xs text-[#AAB7C8]">
                <div className="p-2.5 rounded-xl bg-[#041026] border border-[#997D20]/20">
                  <p className="text-white font-bold">New Verification Request</p>
                  <p className="text-[11px] text-[#AAB7C8]">Hemantkumar Vankar submitted ID proof</p>
                  <span className="text-[10px] text-[#D4AF37]">10 mins ago</span>
                </div>
                <div className="p-2.5 rounded-xl bg-[#041026] border border-[#997D20]/20">
                  <p className="text-white font-bold">5 New User Registrations</p>
                  <span className="text-[10px] text-[#D4AF37]">1 hour ago</span>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Admin Profile Dropdown */}
        <div className="relative">
          <button
            onClick={() => {
              setShowProfileMenu(!showProfileMenu);
              setShowNotifications(false);
            }}
            className="flex items-center gap-2 bg.5-[#0F2040] bg-[#0F2040] border border-[#997D20]/40 rounded-full px-3 py-1.5 hover:border-[#D4AF37] transition-all shadow-md"
          >
            <div className="w-7 h-7 rounded-full bg-gradient-to-tr from-[#D4AF37] via-[#F3E5AB] to-[#E8C95A] text-black font-extrabold text-xs flex items-center justify-center shadow-inner">
              A
            </div>
            <div className="hidden sm:block text-left pr-1">
              <span className="block text-xs font-bold text-white leading-none">Admin Officer</span>
              <span className="block text-[9px] text-[#D4AF37] font-bold mt-0.5">Super Admin</span>
            </div>
          </button>

          {showProfileMenu && (
            <div className="absolute right-0 mt-2 w-48 bg-[#0F2040] border border-[#997D20] rounded-2xl shadow-2xl p-2 z-50 space-y-1">
              <Link
                href="/admin/settings"
                onClick={() => setShowProfileMenu(false)}
                className="flex items-center gap-2 px-3 py-2 text-xs font-semibold text-white hover:bg-[#041026] rounded-xl transition-all"
              >
                <span>⚙️</span>
                <span>Settings</span>
              </Link>
              <Link
                href="/admin/health"
                onClick={() => setShowProfileMenu(false)}
                className="flex items-center gap-2 px-3 py-2 text-xs font-semibold text-white hover:bg-[#041026] rounded-xl transition-all"
              >
                <span>🩺</span>
                <span>System Health</span>
              </Link>
              <div className="border-t border-[#997D20]/20 my-1" />
              <Link
                href="/admin/login"
                onClick={() => setShowProfileMenu(false)}
                className="flex items-center gap-2 px-3 py-2 text-xs text-red-400 hover:bg-red-950/40 rounded-xl font-bold transition-all"
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

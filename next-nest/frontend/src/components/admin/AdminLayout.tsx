"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { AdminSidebar } from "./AdminSidebar";
import { AdminHeader } from "./AdminHeader";

interface AdminLayoutProps {
  children: React.ReactNode;
  title: string;
  subtitle?: string;
}

export const AdminLayout: React.FC<AdminLayoutProps> = ({
  children,
  title,
  subtitle,
}) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [isAuthorized, setIsAuthorized] = useState<boolean | null>(null);
  const router = useRouter();

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
    } else {
      setIsAuthorized(true);
    }
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
        <main className="flex-1 p-4 md:p-6 lg:p-8 space-y-6 w-full max-w-7xl mx-auto">
          {children}
        </main>
      </div>
    </div>
  );
};

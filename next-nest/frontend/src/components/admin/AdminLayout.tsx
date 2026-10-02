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
    const savedTheme = localStorage.getItem('adminTheme');
    if (savedTheme === 'light') {
      document.documentElement.classList.add('light-mode');
    }

    const token = localStorage.getItem('adminToken') || localStorage.getItem('token');
    if (!token) {
      setIsAuthorized(false);
    } else {
      setIsAuthorized(true);
    }
  }, []);

  return (
    <div className="min-h-screen bg-admin-bg text-white flex flex-col md:flex-row overflow-x-hidden">
      {/* Sidebar */}
      <AdminSidebar
        isOpen={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
      />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0 bg-admin-bg">
        <AdminHeader
          onToggleSidebar={() => setSidebarOpen(!sidebarOpen)}
          title={title}
          subtitle={subtitle}
        />

        <main className="flex-1 p-4 md:p-6 lg:p-8 space-y-6">
          {isAuthorized === false ? (
            <div style={{ display: "flex", justifyContent: "center", alignItems: "center", minHeight: "450px" }}>
              <div style={{
                backgroundColor: "rgba(13, 27, 50, 0.9)",
                backdropFilter: "blur(20px)",
                border: "1px solid rgba(212, 175, 55, 0.4)",
                borderRadius: "24px",
                padding: "48px 40px",
                maxWidth: "500px",
                textAlign: "center",
                boxShadow: "0 20px 50px rgba(0, 0, 0, 0.6)",
              }}>
                <div style={{ fontSize: "56px", marginBottom: "16px" }}>🔐</div>
                <h2 style={{ fontSize: "22px", fontWeight: 800, color: "#D4AF37", marginBottom: "12px" }}>
                  Admin Session Required
                </h2>
                <p style={{ fontSize: "14px", color: "rgba(255, 255, 255, 0.75)", marginBottom: "28px", lineHeight: 1.6 }}>
                  You are attempting to access protected community management records. Please sign in with administrator credentials to continue.
                </p>
                <button
                  onClick={() => router.push("/admin/login")}
                  style={{
                    backgroundColor: "#D4AF37",
                    color: "#041026",
                    fontWeight: 800,
                    fontSize: "14px",
                    padding: "12px 28px",
                    borderRadius: "12px",
                    border: "none",
                    cursor: "pointer",
                    boxShadow: "0 4px 14px rgba(212, 175, 55, 0.4)",
                  }}
                  className="hover:brightness-110 transition-all"
                >
                  Sign In to Admin Portal →
                </button>
              </div>
            </div>
          ) : (
            children
          )}
        </main>
      </div>
    </div>
  );
};


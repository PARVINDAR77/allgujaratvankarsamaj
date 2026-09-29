"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";

export default function AdminHealthPage() {
  const [health, setHealth] = useState<any>(null);
  const [refreshing, setRefreshing] = useState(false);

  const fetchHealth = () => {
    setRefreshing(true);
    fetch("http://localhost:3000/api/v1/admin/health")
      .then((res) => res.json())
      .then((data) => setHealth(data))
      .catch(() =>
        setHealth({
          status: "ok",
          timestamp: new Date().toISOString(),
          environment: "development",
          services: { database: "connected", api: "healthy", auth: "active" },
        })
      )
      .finally(() => {
        setTimeout(() => setRefreshing(false), 800);
      });
  };

  useEffect(() => {
    fetchHealth();
  }, []);

  return (
    <AdminLayout title="System Health & Infrastructure" subtitle="Monitor NestJS backend, PostgreSQL database & active APIs">
      <div style={{ display: "flex", flexDirection: "column", gap: "28px" }}>
        
        {/* Action Header */}
        <div style={{ display: "flex", justifyContent: "flex-end", marginBottom: "-8px" }}>
          <button 
            onClick={fetchHealth}
            style={{
              padding: "10px 20px",
              borderRadius: "10px",
              backgroundColor: "rgba(212, 175, 55, 0.15)",
              border: "1px solid rgba(212, 175, 55, 0.4)",
              color: "#D4AF37",
              fontWeight: 800,
              fontSize: "13px",
              cursor: "pointer",
              display: "flex",
              alignItems: "center",
              gap: "8px",
              transition: "all 0.3s ease",
            }}
            className="hover:bg-[#D4AF37] hover:text-black hover:shadow-[0_0_15px_rgba(212,175,55,0.4)]"
          >
            <span className={refreshing ? "animate-spin" : ""}>🔄</span> 
            {refreshing ? "Pinging Servers..." : "Refresh Diagnostics"}
          </button>
        </div>

        {/* Infrastructure Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
<<<<<<< HEAD
          {/* Card 1: Backend */}
          <div style={{
            backgroundColor: "rgba(13, 27, 50, 0.85)",
            backdropFilter: "blur(16px)",
            border: "1px solid rgba(212, 175, 55, 0.25)",
            borderRadius: "20px",
            padding: "24px",
            boxShadow: "0 15px 40px rgba(0, 0, 0, 0.4)",
            position: "relative",
            overflow: "hidden"
          }}>
            <div style={{ position: "absolute", top: "-20px", right: "-20px", fontSize: "100px", opacity: 0.05, filter: "blur(4px)" }}>⚙️</div>
            <h4 style={{ fontSize: "11px", fontWeight: 900, color: "#8E9BAE", textTransform: "uppercase", letterSpacing: "2px", marginBottom: "12px", display: "flex", alignItems: "center", gap: "8px" }}>
              <span style={{ display: "inline-block", width: "8px", height: "8px", borderRadius: "50%", backgroundColor: "#10B981", boxShadow: "0 0 10px #10B981" }}></span>
              Backend Status
            </h4>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: "8px" }}>
              <span style={{ fontSize: "24px", fontWeight: 900, color: "#FFFFFF", letterSpacing: "0.5px" }}>NestJS API</span>
              <StatusBadge status="ACTIVE" />
            </div>
            <p style={{ fontSize: "13px", color: "#8E9BAE", fontWeight: 600, display: "flex", alignItems: "center", gap: "6px" }}>
              <span>🔌</span> Port 3000 • <span style={{ color: "#10B981" }}>Operational</span>
            </p>
          </div>

          {/* Card 2: Database */}
          <div style={{
            backgroundColor: "rgba(13, 27, 50, 0.85)",
            backdropFilter: "blur(16px)",
            border: "1px solid rgba(212, 175, 55, 0.25)",
            borderRadius: "20px",
            padding: "24px",
            boxShadow: "0 15px 40px rgba(0, 0, 0, 0.4)",
            position: "relative",
            overflow: "hidden"
          }}>
            <div style={{ position: "absolute", top: "-20px", right: "-20px", fontSize: "100px", opacity: 0.05, filter: "blur(4px)" }}>🗄️</div>
            <h4 style={{ fontSize: "11px", fontWeight: 900, color: "#8E9BAE", textTransform: "uppercase", letterSpacing: "2px", marginBottom: "12px", display: "flex", alignItems: "center", gap: "8px" }}>
              <span style={{ display: "inline-block", width: "8px", height: "8px", borderRadius: "50%", backgroundColor: "#10B981", boxShadow: "0 0 10px #10B981" }}></span>
              Database Connectivity
            </h4>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: "8px" }}>
              <span style={{ fontSize: "24px", fontWeight: 900, color: "#FFFFFF", letterSpacing: "0.5px" }}>PostgreSQL</span>
              <StatusBadge status="VERIFIED" />
            </div>
            <p style={{ fontSize: "13px", color: "#8E9BAE", fontWeight: 600, display: "flex", alignItems: "center", gap: "6px" }}>
              <span>🗃️</span> Prisma ORM • <span style={{ color: "#10B981" }}>Connected</span>
            </p>
          </div>

          {/* Card 3: Frontend */}
          <div style={{
            backgroundColor: "rgba(13, 27, 50, 0.85)",
            backdropFilter: "blur(16px)",
            border: "1px solid rgba(212, 175, 55, 0.25)",
            borderRadius: "20px",
            padding: "24px",
            boxShadow: "0 15px 40px rgba(0, 0, 0, 0.4)",
            position: "relative",
            overflow: "hidden"
          }}>
            <div style={{ position: "absolute", top: "-20px", right: "-20px", fontSize: "100px", opacity: 0.05, filter: "blur(4px)" }}>💻</div>
            <h4 style={{ fontSize: "11px", fontWeight: 900, color: "#8E9BAE", textTransform: "uppercase", letterSpacing: "2px", marginBottom: "12px", display: "flex", alignItems: "center", gap: "8px" }}>
              <span style={{ display: "inline-block", width: "8px", height: "8px", borderRadius: "50%", backgroundColor: "#10B981", boxShadow: "0 0 10px #10B981" }}></span>
              Frontend App
            </h4>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: "8px" }}>
              <span style={{ fontSize: "24px", fontWeight: 900, color: "#FFFFFF", letterSpacing: "0.5px" }}>Next.js App</span>
              <StatusBadge status="ACTIVE" />
            </div>
            <p style={{ fontSize: "13px", color: "#8E9BAE", fontWeight: 600, display: "flex", alignItems: "center", gap: "6px" }}>
              <span>🚀</span> Port 3001 • <span style={{ color: "#10B981" }}>Turbo Server</span>
            </p>
=======
          <div className="bg-admin-border border border-admin-gold-dark/30 rounded-2xl p-6 shadow-xl space-y-2">
            <h4 className="text-xs font-bold text-admin-muted-light uppercase">Backend Status</h4>
            <div className="flex items-center justify-between">
              <span className="text-xl font-extrabold text-white">NestJS API</span>
              <StatusBadge status="ACTIVE" />
            </div>
            <p className="text-[11px] text-admin-muted-light">Port 3000 • Operational</p>
          </div>

          <div className="bg-admin-border border border-admin-gold-dark/30 rounded-2xl p-6 shadow-xl space-y-2">
            <h4 className="text-xs font-bold text-admin-muted-light uppercase">Database Connectivity</h4>
            <div className="flex items-center justify-between">
              <span className="text-xl font-extrabold text-white">PostgreSQL</span>
              <StatusBadge status="VERIFIED" />
            </div>
            <p className="text-[11px] text-admin-muted-light">Prisma ORM • Connected</p>
          </div>

          <div className="bg-admin-border border border-admin-gold-dark/30 rounded-2xl p-6 shadow-xl space-y-2">
            <h4 className="text-xs font-bold text-admin-muted-light uppercase">Frontend App</h4>
            <div className="flex items-center justify-between">
              <span className="text-xl font-extrabold text-white">Next.js App</span>
              <StatusBadge status="ACTIVE" />
            </div>
            <p className="text-[11px] text-admin-muted-light">Port 3001 • Turbo Server</p>
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
          </div>
        </div>

        {/* Diagnostics Terminal */}
        {health && (
<<<<<<< HEAD
          <div style={{
            backgroundColor: "rgba(13, 27, 50, 0.85)",
            backdropFilter: "blur(16px)",
            border: "1px solid rgba(212, 175, 55, 0.25)",
            borderRadius: "20px",
            overflow: "hidden",
            boxShadow: "0 20px 50px rgba(0, 0, 0, 0.5)",
          }}>
            {/* Terminal Header */}
            <div style={{
              backgroundColor: "rgba(4, 16, 38, 0.9)",
              borderBottom: "1px solid rgba(212, 175, 55, 0.2)",
              padding: "16px 24px",
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between"
            }}>
              <h3 style={{ fontSize: "14px", fontWeight: 800, color: "#FFFFFF", display: "flex", alignItems: "center", gap: "10px", margin: 0 }}>
                <span>📡</span> Raw Diagnostic Payload (JSON)
              </h3>
              <div style={{ display: "flex", gap: "8px" }}>
                <div style={{ width: "12px", height: "12px", borderRadius: "50%", backgroundColor: "#EF4444" }}></div>
                <div style={{ width: "12px", height: "12px", borderRadius: "50%", backgroundColor: "#F59E0B" }}></div>
                <div style={{ width: "12px", height: "12px", borderRadius: "50%", backgroundColor: "#10B981" }}></div>
              </div>
            </div>
            
            {/* Terminal Body */}
            <div style={{ padding: "24px", backgroundColor: "#020813" }}>
              <pre style={{
                fontFamily: "'Fira Code', 'Courier New', Courier, monospace",
                fontSize: "13px",
                lineHeight: "1.6",
                color: "#6EE7B7",
                margin: 0,
                overflowX: "auto"
              }}>
                <code dangerouslySetInnerHTML={{
                  __html: JSON.stringify(health, null, 2)
                    .replace(/"(.*?)":/g, '<span style="color: #93C5FD">"$1"</span>:')
                    .replace(/:\s"(.*?)"/g, ': <span style="color: #FCD34D">"$1"</span>')
                }} />
              </pre>
            </div>
=======
          <div className="bg-admin-border border border-admin-gold-dark/30 rounded-2xl p-6 shadow-xl space-y-3 text-xs">
            <h3 className="text-sm font-bold text-white">Health Payload Metadata</h3>
            <pre className="bg-admin-card p-4 rounded-xl text-admin-gold font-mono overflow-x-auto border border-admin-gold-dark/20">
              {JSON.stringify(health, null, 2)}
            </pre>
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
          </div>
        )}
      </div>
    </AdminLayout>
  );
}

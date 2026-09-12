"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatCard } from "@/components/admin/StatCard";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { QuickActionCard } from "@/components/admin/QuickActionCard";
import { adminApi, DashboardStats } from "@/lib/admin-api";

export default function AdminDashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    adminApi.getDashboardStats().then((data) => {
      setStats(data);
      setLoading(false);
    });
  }, []);

  if (loading || !stats) {
    return (
      <AdminLayout title="Admin Dashboard" subtitle="Loading All Gujarat Vankar Samaj metrics...">
        <div style={{ display: "flex", justifyContent: "center", alignItems: "center", height: "300px", color: "#D4AF37" }}>
          <div className="animate-spin" style={{ fontSize: "28px" }}>⚙️</div>
          <span style={{ marginLeft: "12px", fontSize: "14px", fontWeight: 700 }}>
            Loading Admin Dashboard...
          </span>
        </div>
      </AdminLayout>
    );
  }

  // Calculate dynamic max value for growth chart
  const maxUserVal = Math.max(...stats.monthlyGrowth.map((g) => g.users), 100);

  // Calculate dynamic max value for pargana bars
  const maxParganaCount = Math.max(...stats.parganaBreakdown.map((p) => p.count), 1);

  // Helper to format user display name
  const formatName = (name: string, email?: string) => {
    if (!name || (name.includes("-") && name.length > 20)) {
      if (email && email.includes("@")) {
        return email.split("@")[0].replace(/[0-9]/g, " ").trim() || "Member Candidate";
      }
      return "Community Member";
    }
    return name;
  };

  return (
    <AdminLayout
      title="Admin Dashboard"
      subtitle="Welcome to All Gujarat Vankar Samaj Admin Panel"
    >
      <div style={{ display: "flex", flexDirection: "column", gap: "28px" }}>
        {/* ─── 1. TOP STAT CARDS ────────────────────────────────────────── */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
          <StatCard
            title="Total Users"
            value={stats.totalUsers}
            change="12%"
            isPositive={true}
            comparisonText="vs last month"
            icon="👥"
          />
          <StatCard
            title="Total Profiles"
            value={stats.totalProfiles}
            change="8%"
            isPositive={true}
            comparisonText="vs last month"
            icon="👤"
          />
          <StatCard
            title="Total Matches"
            value={stats.totalMatches}
            change="15%"
            isPositive={true}
            comparisonText="vs last month"
            icon="💖"
          />
          <StatCard
            title="Total Messages"
            value={stats.totalMessages}
            change="24%"
            isPositive={true}
            comparisonText="vs last month"
            icon="💬"
          />
        </div>

        {/* ─── 2. CHARTS SECTION (GROWTH & PARGANA DISTRIBUTION) ───────── */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* User Growth Chart (2 Cols) */}
          <div
            style={{
              backgroundColor: "rgba(13, 27, 50, 0.85)",
              backdropFilter: "blur(16px)",
              border: "1px solid rgba(212, 175, 55, 0.25)",
              borderRadius: "16px",
              padding: "24px",
              boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4)",
            }}
            className="lg:col-span-2"
          >
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "20px" }}>
              <div>
                <h3 style={{ fontSize: "16px", fontWeight: 800, color: "#FFFFFF", display: "flex", alignItems: "center", gap: "8px", margin: 0 }}>
                  <span>📈</span> User Growth Overview
                </h3>
                <p style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 500, margin: "4px 0 0 0" }}>
                  Monthly candidate registration & profile trend
                </p>
              </div>
              <span
                style={{
                  fontSize: "11px",
                  color: "#D4AF37",
                  fontWeight: 800,
                  backgroundColor: "#041026",
                  padding: "4px 12px",
                  borderRadius: "20px",
                  border: "1px solid rgba(212, 175, 55, 0.35)",
                }}
              >
                Year 2026
              </span>
            </div>

            {/* Scaled Dynamic Growth Chart */}
            <div
              style={{
                height: "240px",
                width: "100%",
                display: "flex",
                alignItems: "flex-end",
                justifyContent: "space-between",
                gap: "10px",
                padding: "20px 16px 12px 16px",
                backgroundColor: "rgba(4, 16, 38, 0.7)",
                borderRadius: "14px",
                border: "1px solid rgba(212, 175, 55, 0.18)",
              }}
            >
              {stats.monthlyGrowth.map((g, i) => {
                // Scale height between 15% and 80% so bar numbers render cleanly above bars
                const heightPercent = Math.min(80, Math.max(15, (g.users / maxUserVal) * 80));
                return (
                  <div
                    key={i}
                    style={{
                      flex: 1,
                      display: "flex",
                      flexDirection: "column",
                      alignItems: "center",
                      gap: "6px",
                      height: "100%",
                      justifyContent: "flex-end",
                    }}
                    className="group"
                  >
                    <div style={{ fontSize: "11px", fontWeight: 700, color: "#F3E5AB" }}>
                      {g.users}
                    </div>
                    <div
                      style={{
                        width: "100%",
                        backgroundColor: "#08152B",
                        borderRadius: "8px 8px 0 0",
                        height: "160px",
                        display: "flex",
                        alignItems: "flex-end",
                        padding: "2px",
                        position: "relative",
                        borderTop: "1px solid rgba(212, 175, 55, 0.25)",
                        borderLeft: "1px solid rgba(212, 175, 55, 0.15)",
                        borderRight: "1px solid rgba(212, 175, 55, 0.15)",
                      }}
                    >
                      <div
                        style={{
                          height: `${heightPercent}%`,
                          width: "100%",
                          background: "linear-gradient(180deg, #F3E5AB 0%, #D4AF37 50%, #8A6D1C 100%)",
                          borderRadius: "6px 6px 0 0",
                          transition: "all 0.5s ease",
                          boxShadow: "0 0 12px rgba(212, 175, 55, 0.35)",
                        }}
                        className="group-hover:brightness-125"
                      />
                    </div>
                    <span style={{ fontSize: "11px", fontWeight: 700, color: "#8E9BAE" }} className="group-hover:text-[#D4AF37] transition-colors">
                      {g.month}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Profiles by Pargana (1 Col) */}
          <div
            style={{
              backgroundColor: "rgba(13, 27, 50, 0.85)",
              backdropFilter: "blur(16px)",
              border: "1px solid rgba(212, 175, 55, 0.25)",
              borderRadius: "16px",
              padding: "24px",
              boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4)",
              display: "flex",
              flexDirection: "column",
              justifyContent: "space-between",
            }}
          >
            <div>
              <h3 style={{ fontSize: "16px", fontWeight: 800, color: "#FFFFFF", display: "flex", alignItems: "center", gap: "8px", margin: 0 }}>
                <span>🏛️</span> Profiles by Pargana
              </h3>
              <p style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 500, margin: "4px 0 18px 0" }}>
                Distribution across Samaj regions
              </p>

              <div style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
                {stats.parganaBreakdown.map((p, idx) => {
                  const colors = [
                    "linear-gradient(90deg, #3B82F6 0%, #60A5FA 100%)",
                    "linear-gradient(90deg, #10B981 0%, #34D399 100%)",
                    "linear-gradient(90deg, #F59E0B 0%, #FBBF24 100%)",
                    "linear-gradient(90deg, #8B5CF6 0%, #A78BFA 100%)",
                    "linear-gradient(90deg, #EC4899 0%, #F472B6 100%)",
                  ];
                  const barGradient = colors[idx % colors.length];
                  const relativeFillPercent = Math.max(12, Math.round((p.count / maxParganaCount) * 95));

                  return (
                    <div key={idx} style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
                      <div style={{ display: "flex", justifyContent: "space-between", fontSize: "12px" }}>
                        <span style={{ color: "#FFFFFF", fontWeight: 700 }}>{p.name}</span>
                        <span style={{ color: "#D4AF37", fontWeight: 800 }}>{p.count} ({p.percentage}%)</span>
                      </div>
                      <div
                        style={{
                          width: "100%",
                          height: "8px",
                          backgroundColor: "#041026",
                          borderRadius: "4px",
                          overflow: "hidden",
                          border: "1px solid rgba(212, 175, 55, 0.2)",
                          padding: "1px",
                        }}
                      >
                        <div
                          style={{
                            width: `${relativeFillPercent}%`,
                            height: "100%",
                            background: barGradient,
                            borderRadius: "4px",
                            transition: "all 0.5s ease",
                          }}
                        />
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            <div style={{ marginTop: "20px", paddingTop: "14px", borderTop: "1px solid rgba(212, 175, 55, 0.15)", textAlign: "center" }}>
              <a
                href="/admin/parganas"
                style={{ fontSize: "12px", color: "#D4AF37", fontWeight: 800, textDecoration: "none", display: "inline-flex", alignItems: "center", gap: "4px" }}
                className="hover:underline"
              >
                <span>View Detailed Pargana Directory</span>
                <span>→</span>
              </a>
            </div>
          </div>
        </div>

        {/* ─── 3. QUICK ACTIONS GRID ───────────────────────────────────── */}
        <div>
          <h3 style={{ fontSize: "11px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1.2px", marginBottom: "14px", display: "flex", alignItems: "center", gap: "6px" }}>
            <span>⚡</span> Quick Management Actions
          </h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <QuickActionCard
              title="Add New Member"
              description="Register new community candidate profile"
              icon="➕"
              href="/admin/users"
            />
            <QuickActionCard
              title="Verify Profile"
              description="Review pending verification documents"
              icon="🛡️"
              href="/admin/verifications"
            />
            <QuickActionCard
              title="Manage Content"
              description="Update announcements, motto & pages"
              icon="📝"
              href="/admin/content"
            />
            <QuickActionCard
              title="View Reports"
              description="System audit & match statistics"
              icon="📊"
              href="/admin/reports"
            />
            <QuickActionCard
              title="System Settings"
              description="Configure portal rules & access"
              icon="⚙️"
              href="/admin/settings"
            />
            <QuickActionCard
              title="System Health"
              description="Monitor NestJS API & Postgres DB"
              icon="🩺"
              href="/admin/health"
            />
          </div>
        </div>

        {/* ─── 4. RECENT USERS & ACTIVITIES SECTION ─────────────────────── */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Recent Users Table (2 Cols) */}
          <div
            style={{
              backgroundColor: "rgba(13, 27, 50, 0.85)",
              backdropFilter: "blur(16px)",
              border: "1px solid rgba(212, 175, 55, 0.25)",
              borderRadius: "16px",
              padding: "24px",
              boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4)",
            }}
            className="lg:col-span-2"
          >
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "18px" }}>
              <div>
                <h3 style={{ fontSize: "16px", fontWeight: 800, color: "#FFFFFF", display: "flex", alignItems: "center", gap: "8px", margin: 0 }}>
                  <span>👥</span> Recent Candidate Registrations
                </h3>
                <p style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 500, margin: "4px 0 0 0" }}>
                  Newly registered matrimonial candidates
                </p>
              </div>
              <a
                href="/admin/users"
                style={{ fontSize: "12px", fontWeight: 800, color: "#D4AF37", textDecoration: "none" }}
                className="hover:underline"
              >
                View All Candidates →
              </a>
            </div>

            <div style={{ borderRadius: "12px", overflow: "hidden", border: "1px solid rgba(212, 175, 55, 0.2)" }}>
              <table style={{ width: "100%", textAlign: "left", fontSize: "12px", color: "#FFFFFF", borderCollapse: "collapse" }}>
                <thead>
                  <tr style={{ backgroundColor: "#041026", borderBottom: "1px solid rgba(212, 175, 55, 0.3)" }}>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>User Candidate</th>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Contact Info</th>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Pargana</th>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Status</th>
                    <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", textAlign: "right" }}>Actions</th>
                  </tr>
                </thead>
                <tbody style={{ backgroundColor: "#0D1B32" }}>
                  {stats.recentUsers.map((u) => {
                    const displayName = formatName(u.name, u.email);
                    return (
                      <tr key={u.id} style={{ borderBottom: "1px solid rgba(212, 175, 55, 0.1)" }} className="hover:bg-[#041026]/80 transition-colors">
                        <td style={{ padding: "14px 18px", fontWeight: 700, color: "#FFFFFF" }}>
                          <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
                            <div
                              style={{
                                width: "32px",
                                height: "32px",
                                borderRadius: "50%",
                                background: "linear-gradient(135deg, rgba(212,175,55,0.3) 0%, rgba(243,229,171,0.1) 100%)",
                                color: "#D4AF37",
                                display: "flex",
                                alignItems: "center",
                                justifyContent: "center",
                                fontWeight: 800,
                                fontSize: "12px",
                                border: "1px solid rgba(212, 175, 55, 0.4)",
                                flexShrink: 0,
                              }}
                            >
                              {displayName.charAt(0).toUpperCase()}
                            </div>
                            <span style={{ overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", maxWidth: "140px" }}>
                              {displayName}
                            </span>
                          </div>
                        </td>
                        <td style={{ padding: "14px 18px", color: "#8E9BAE", fontFamily: "monospace", fontSize: "11px" }}>
                          {u.email || u.phone || "N/A"}
                        </td>
                        <td style={{ padding: "14px 18px", color: "#FFFFFF", fontWeight: 600 }}>{u.pargana}</td>
                        <td style={{ padding: "14px 18px" }}>
                          <StatusBadge status={u.status} />
                        </td>
                        <td style={{ padding: "14px 18px", textAlign: "right" }}>
                          <a
                            href="/admin/users"
                            style={{
                              color: "#D4AF37",
                              fontWeight: 700,
                              fontSize: "11px",
                              padding: "6px 12px",
                              borderRadius: "8px",
                              backgroundColor: "#041026",
                              border: "1px solid rgba(212, 175, 55, 0.35)",
                              textDecoration: "none",
                            }}
                            className="hover:bg-[#D4AF37] hover:text-black transition-all"
                          >
                            Manage
                          </a>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>

          {/* Recent Activities (1 Col) */}
          <div
            style={{
              backgroundColor: "rgba(13, 27, 50, 0.85)",
              backdropFilter: "blur(16px)",
              border: "1px solid rgba(212, 175, 55, 0.25)",
              borderRadius: "16px",
              padding: "24px",
              boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4)",
            }}
          >
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "18px" }}>
              <h3 style={{ fontSize: "16px", fontWeight: 800, color: "#FFFFFF", display: "flex", alignItems: "center", gap: "8px", margin: 0 }}>
                <span>⚡</span> System Activity Log
              </h3>
              <span style={{ fontSize: "12px", color: "#D4AF37", fontWeight: 700, cursor: "pointer" }} className="hover:underline">
                View Log
              </span>
            </div>

            <div style={{ display: "flex", flexDirection: "column", gap: "14px" }}>
              {stats.recentActivities.map((act) => (
                <div
                  key={act.id}
                  style={{
                    display: "flex",
                    gap: "12px",
                    alignItems: "flex-start",
                    paddingBottom: "12px",
                    borderBottom: "1px solid rgba(212, 175, 55, 0.12)",
                  }}
                >
                  <div
                    style={{
                      width: "32px",
                      height: "32px",
                      borderRadius: "8px",
                      backgroundColor: "#041026",
                      border: "1px solid rgba(212, 175, 55, 0.3)",
                      fontSize: "14px",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      flexShrink: 0,
                    }}
                  >
                    ✨
                  </div>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <h4 style={{ fontSize: "12px", fontWeight: 700, color: "#FFFFFF", margin: 0 }} className="truncate">
                      {act.title}
                    </h4>
                    <p style={{ fontSize: "11px", color: "#8E9BAE", margin: "2px 0 2px 0" }} className="truncate">
                      {act.user}
                    </p>
                    <span style={{ fontSize: "10px", color: "#D4AF37", fontWeight: 600 }}>{act.time}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* ─── 5. RECENT VERIFICATIONS QUEUE ──────────────────────────── */}
        <div
          style={{
            backgroundColor: "rgba(13, 27, 50, 0.85)",
            backdropFilter: "blur(16px)",
            border: "1px solid rgba(212, 175, 55, 0.25)",
            borderRadius: "16px",
            padding: "24px",
            boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4)",
          }}
        >
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "18px" }}>
            <div>
              <h3 style={{ fontSize: "16px", fontWeight: 800, color: "#FFFFFF", display: "flex", alignItems: "center", gap: "8px", margin: 0 }}>
                <span>🛡️</span> Verification Review Queue
              </h3>
              <p style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 500, margin: "4px 0 0 0" }}>
                Pending member document & profile verification requests
              </p>
            </div>
            <a
              href="/admin/verifications"
              style={{ fontSize: "12px", fontWeight: 800, color: "#D4AF37", textDecoration: "none" }}
              className="hover:underline"
            >
              All Verifications →
            </a>
          </div>

          <div style={{ borderRadius: "12px", overflow: "hidden", border: "1px solid rgba(212, 175, 55, 0.2)" }}>
            <table style={{ width: "100%", textAlign: "left", fontSize: "12px", color: "#FFFFFF", borderCollapse: "collapse" }}>
              <thead>
                <tr style={{ backgroundColor: "#041026", borderBottom: "1px solid rgba(212, 175, 55, 0.3)" }}>
                  <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Member Name</th>
                  <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Verification Type</th>
                  <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Submission Date</th>
                  <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Status</th>
                  <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", textAlign: "right" }}>Actions</th>
                </tr>
              </thead>
              <tbody style={{ backgroundColor: "#0D1B32" }}>
                {stats.recentVerifications.map((v) => (
                  <tr key={v.id} style={{ borderBottom: "1px solid rgba(212, 175, 55, 0.1)" }} className="hover:bg-[#041026]/80 transition-colors">
                    <td style={{ padding: "14px 18px", fontWeight: 700, color: "#FFFFFF" }}>{v.name}</td>
                    <td style={{ padding: "14px 18px", color: "#8E9BAE", fontWeight: 500 }}>{v.type}</td>
                    <td style={{ padding: "14px 18px", color: "#CBD5E1", fontFamily: "monospace", fontSize: "11px" }}>{v.date}</td>
                    <td style={{ padding: "14px 18px" }}>
                      <StatusBadge status={v.status} />
                    </td>
                    <td style={{ padding: "14px 18px", textAlign: "right" }}>
                      <div style={{ display: "flex", justifyContent: "flex-end", gap: "8px" }}>
                        <button
                          style={{
                            padding: "6px 14px",
                            borderRadius: "8px",
                            backgroundColor: "rgba(6, 78, 59, 0.6)",
                            color: "#6EE7B7",
                            border: "1px solid rgba(16, 185, 129, 0.4)",
                            fontSize: "11px",
                            fontWeight: 800,
                            cursor: "pointer",
                          }}
                          className="hover:bg-emerald-800 transition-colors"
                        >
                          Approve
                        </button>
                        <button
                          style={{
                            padding: "6px 14px",
                            borderRadius: "8px",
                            backgroundColor: "rgba(136, 19, 55, 0.6)",
                            color: "#FDA4AF",
                            border: "1px solid rgba(244, 63, 94, 0.4)",
                            fontSize: "11px",
                            fontWeight: 800,
                            cursor: "pointer",
                          }}
                          className="hover:bg-rose-800 transition-colors"
                        >
                          Reject
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}



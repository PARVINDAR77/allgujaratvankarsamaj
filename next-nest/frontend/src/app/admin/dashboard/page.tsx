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
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    adminApi.getDashboardStats()
      .then((data) => {
        setStats(data);
        setError(null);
      })
      .catch((err) => {
        console.error("Dashboard Stats Error:", err);
        setError(err.message || "Failed to load dashboard statistics.");
      })
      .finally(() => {
        setLoading(false);
      });
  }, []);

  if (loading) {
    return (
      <AdminLayout title="Admin Dashboard" subtitle="Loading All Gujarat Vankar Samaj metrics...">
        <div   className="flex justify-center items-center text-admin-gold h-[300px]" >
          <div className="animate-spin text-[28px]" >⚙️</div>
          <span  style={{ marginLeft: "12px" }} className="font-bold text-sm">
            Loading Admin Dashboard...
          </span>
        </div>
      </AdminLayout>
    );
  }

  if (error || !stats) {
    return (
      <AdminLayout title="Admin Dashboard" subtitle="Overview">
        <div   className="flex flex-col justify-center items-center text-rose-500 h-[300px]" >
          <div style={{ fontSize: "48px", marginBottom: "16px" }}>⚠️</div>
          <span  className="font-bold text-base">{error || "No data available."}</span>
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
      <div   className="flex flex-col gap-7" >
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
            value={stats.activeProfiles}
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
            title="Pending Verifications"
            value={stats.pendingVerifications}
            change="-2"
            isPositive={true}
            comparisonText="vs last month"
            icon="🛡️"
          />
        </div>

        {/* ─── 2. CHARTS SECTION (GROWTH & PARGANA DISTRIBUTION) ───────── */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* User Growth Chart (2 Cols) */}
          <div
              className="lg:col-span-2 border border-admin-gold/25 p-6 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.4)] backdrop-blur-md bg-admin-bg-glass"
            
          >
            <div  style={{ marginBottom: "20px" }} className="flex justify-between items-center">
              <div>
                <h3  style={{ margin: 0 }} className="flex items-center font-extrabold text-white text-base gap-2">
                  <span>📈</span> User Growth Overview
                </h3>
                <p  style={{ margin: "4px 0 0 0" }} className="font-medium text-admin-muted text-xs">
                  Monthly candidate registration & profile trend
                </p>
              </div>
              <span
                  style={{ padding: "4px 12px", borderRadius: "20px" }} className="font-extrabold bg-admin-card text-admin-gold text-[11px] border border-admin-gold/35" 
              >
                Year 2026
              </span>
            </div>

            {/* Scaled Dynamic Growth Chart */}
            <div
               style={{ height: "240px", padding: "20px 16px 12px 16px", backgroundColor: "rgba(4, 16, 38, 0.7)", borderRadius: "14px", border: "1px solid rgba(212, 175, 55, 0.18)" }} className="flex justify-between items-end w-full gap-[10px]"
            >
              {stats.monthlyGrowth.map((g, i) => {
                // Scale height between 15% and 80% so bar numbers render cleanly above bars
                const heightPercent = Math.min(80, Math.max(15, (g.users / maxUserVal) * 80));
                return (
                  <div
                    key={i}
                     style={{ gap: "6px" }}
                    className="group flex flex-col justify-end items-center flex-1 h-full"
                  >
                    <div  style={{ color: "#F3E5AB" }} className="font-bold text-[11px]">
                      {g.users}
                    </div>
                    <div
                       style={{ backgroundColor: "#08152B", borderRadius: "8px 8px 0 0", height: "160px", padding: "2px", borderTop: "1px solid rgba(212, 175, 55, 0.25)", borderLeft: "1px solid rgba(212, 175, 55, 0.15)", borderRight: "1px solid rgba(212, 175, 55, 0.15)" }} className="flex items-end w-full relative"
                    >
                      <div
                         style={{ height: `${heightPercent}%`, background: "linear-gradient(180deg, #F3E5AB 0%, #D4AF37 50%, #8A6D1C 100%)", borderRadius: "6px 6px 0 0", transition: "all 0.5s ease", boxShadow: "0 0 12px rgba(212, 175, 55, 0.35)" }} className="group-hover:brightness-125 w-full"
                        
                      />
                    </div>
                    <span  className="group-hover:text-admin-gold transition-colors font-bold text-admin-muted text-[11px]">
                      {g.month}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Profiles by Pargana (1 Col) */}
          <div
              className="flex flex-col justify-between border border-admin-gold/25 p-6 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.4)] backdrop-blur-md bg-admin-bg-glass" 
          >
            <div>
              <h3  style={{ margin: 0 }} className="flex items-center font-extrabold text-white text-base gap-2">
                <span>🏛️</span> Profiles by Pargana
              </h3>
              <p  style={{ margin: "4px 0 18px 0" }} className="font-medium text-admin-muted text-xs">
                Distribution across Samaj regions
              </p>

              <div  className="flex flex-col gap-4">
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
                    <div key={idx}  style={{ gap: "6px" }} className="flex flex-col">
                      <div  className="flex justify-between text-xs">
                        <span  className="font-bold text-white">{p.name}</span>
                        <span  className="font-extrabold text-admin-gold">{p.count} ({p.percentage}%)</span>
                      </div>
                      <div
                         style={{ height: "8px", borderRadius: "4px", padding: "1px" }} className="w-full overflow-hidden bg-admin-card border border-admin-gold/20"
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

            <div  style={{ marginTop: "20px", paddingTop: "14px", borderTop: "1px solid rgba(212, 175, 55, 0.15)" }} className="text-center">
              <a
                href="/admin/parganas"
                 style={{ textDecoration: "none", display: "inline-flex", gap: "4px" }}
                className="hover:underline items-center font-extrabold text-admin-gold text-xs"
              >
                <span>View Detailed Pargana Directory</span>
                <span>→</span>
              </a>
            </div>
          </div>
        </div>

        {/* ─── 3. QUICK ACTIONS GRID ───────────────────────────────────── */}
        <div>
          <h3  style={{ letterSpacing: "1.2px", marginBottom: "14px", gap: "6px" }} className="flex items-center font-extrabold uppercase text-admin-gold text-[11px]">
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
              className="lg:col-span-2 border border-admin-gold/25 p-6 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.4)] backdrop-blur-md bg-admin-bg-glass"
            
          >
            <div  style={{ marginBottom: "18px" }} className="flex justify-between items-center">
              <div>
                <h3  style={{ margin: 0 }} className="flex items-center font-extrabold text-white text-base gap-2">
                  <span>👥</span> Recent Candidate Registrations
                </h3>
                <p  style={{ margin: "4px 0 0 0" }} className="font-medium text-admin-muted text-xs">
                  Newly registered matrimonial candidates
                </p>
              </div>
              <a
                href="/admin/users"
                 style={{ textDecoration: "none" }}
                className="hover:underline font-extrabold text-admin-gold text-xs"
              >
                View All Candidates →
              </a>
            </div>

            <div  className="overflow-hidden border border-admin-gold/20 rounded-xl">
              <table  className="w-full text-left border-collapse text-white text-xs">
                <thead>
                  <tr  className="bg-admin-card border-b border-admin-gold/30">
                    <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >User Candidate</th>
                    <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Contact Info</th>
                    <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Pargana</th>
                    <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Status</th>
                    <th   className="text-right font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Actions</th>
                  </tr>
                </thead>
                <tbody  className="bg-admin-card">
                  {stats.recentUsers.map((u) => {
                    const displayName = formatName(u.name, u.email);
                    return (
                      <tr key={u.id}  className="hover:bg-admin-card/80 transition-colors border-b border-admin-gold/10">
                        <td  className="font-bold text-white py-[14px] px-[18px]">
                          <div  className="flex items-center gap-[10px]">
                            <div
                                style={{ background: "linear-gradient(135deg, rgba(212, 175, 55, 0.3) 0%, rgba(243, 229, 171, 0.1) 100%)" }} className="flex justify-center items-center font-extrabold shrink-0 rounded-full text-admin-gold text-xs border border-admin-gold/40 w-8 h-8" 
                            >
                              {displayName.charAt(0).toUpperCase()}
                            </div>
                            <span  style={{ maxWidth: "140px" }} className="overflow-hidden whitespace-nowrap text-ellipsis">
                              {displayName}
                            </span>
                          </div>
                        </td>
                        <td   className="text-admin-muted text-[11px] py-[14px] px-[18px] font-mono" >
                          {u.email || u.phone || "N/A"}
                        </td>
                        <td  className="font-semibold text-white py-[14px] px-[18px]">{u.pargana}</td>
                        <td  className="py-[14px] px-[18px]">
                          <StatusBadge status={u.status} />
                        </td>
                        <td  className="text-right py-[14px] px-[18px]">
                          <a
                            href="/admin/users"
                              style={{ padding: "6px 12px", textDecoration: "none" }} className="hover:bg-admin-gold hover:text-black transition-all font-bold bg-admin-card text-admin-gold text-[11px] rounded-lg border border-admin-gold/35"
                            
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
              className="border border-admin-gold/25 p-6 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.4)] backdrop-blur-md bg-admin-bg-glass" 
          >
            <div  style={{ marginBottom: "18px" }} className="flex justify-between items-center">
              <h3  style={{ margin: 0 }} className="flex items-center font-extrabold text-white text-base gap-2">
                <span>⚡</span> System Activity Log
              </h3>
              <span  className="hover:underline font-bold cursor-pointer text-admin-gold text-xs">
                View Log
              </span>
            </div>

            <div  className="flex flex-col gap-[14px]">
              {stats.recentActivities.map((act) => (
                <div
                  key={act.id}
                   style={{ gap: "12px", paddingBottom: "12px", borderBottom: "1px solid rgba(212, 175, 55, 0.12)" }} className="flex items-start"
                >
                  <div
                      className="flex justify-center items-center shrink-0 bg-admin-card border border-admin-gold/30 text-sm rounded-lg w-8 h-8" 
                  >
                    ✨
                  </div>
                  <div  style={{ minWidth: 0 }} className="flex-1">
                    <h4  style={{ margin: 0 }} className="truncate font-bold text-white text-xs">
                      {act.title}
                    </h4>
                    <p  style={{ margin: "2px 0 2px 0" }} className="truncate text-admin-muted text-[11px]">
                      {act.user}
                    </p>
                    <span  className="font-semibold text-admin-gold text-[10px]">{act.time}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* ─── 5. RECENT VERIFICATIONS QUEUE ──────────────────────────── */}
        <div
            className="border border-admin-gold/25 p-6 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.4)] backdrop-blur-md bg-admin-bg-glass" 
        >
          <div  style={{ marginBottom: "18px" }} className="flex justify-between items-center">
            <div>
              <h3  style={{ margin: 0 }} className="flex items-center font-extrabold text-white text-base gap-2">
                <span>🛡️</span> Verification Review Queue
              </h3>
              <p  style={{ margin: "4px 0 0 0" }} className="font-medium text-admin-muted text-xs">
                Pending member document & profile verification requests
              </p>
            </div>
            <a
              href="/admin/verifications"
               style={{ textDecoration: "none" }}
              className="hover:underline font-extrabold text-admin-gold text-xs"
            >
              All Verifications →
            </a>
          </div>

          <div  className="overflow-hidden border border-admin-gold/20 rounded-xl">
            <table  className="w-full text-left border-collapse text-white text-xs">
              <thead>
                <tr  className="bg-admin-card border-b border-admin-gold/30">
                  <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Member Name</th>
                  <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Verification Type</th>
                  <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Submission Date</th>
                  <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Status</th>
                  <th   className="text-right font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Actions</th>
                </tr>
              </thead>
              <tbody  className="bg-admin-card">
                {stats.recentVerifications.map((v) => (
                  <tr key={v.id}  className="hover:bg-admin-card/80 transition-colors border-b border-admin-gold/10">
                    <td  className="font-bold text-white py-[14px] px-[18px]">{v.name}</td>
                    <td  className="font-medium text-admin-muted py-[14px] px-[18px]">{v.type}</td>
                    <td   className="text-admin-muted-lighter text-[11px] py-[14px] px-[18px] font-mono" >{v.date}</td>
                    <td  className="py-[14px] px-[18px]">
                      <StatusBadge status={v.status} />
                    </td>
                    <td  className="text-right py-[14px] px-[18px]">
                      <div  className="flex justify-end gap-2">
                        <button
                            className="hover:bg-emerald-800 transition-colors font-extrabold cursor-pointer text-[11px] rounded-lg bg-emerald-900/60 text-emerald-300 border border-emerald-500/40 py-1.5 px-3.5"
                          
                        >
                          Approve
                        </button>
                        <button
                            className="hover:bg-rose-800 transition-colors font-extrabold cursor-pointer text-[11px] rounded-lg bg-rose-900/60 text-rose-300 border border-rose-500/40 py-1.5 px-3.5"
                          
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



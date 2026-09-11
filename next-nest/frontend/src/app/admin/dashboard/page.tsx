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
      <AdminLayout title="Dashboard" subtitle="Loading Vankar Samaj Matrimony metrics...">
        <div className="flex justify-center items-center h-64 text-[#D4AF37]">
          <div className="animate-spin text-3xl">⚙️</div>
          <span className="ml-3 text-sm font-bold">Loading Admin Dashboard...</span>
        </div>
      </AdminLayout>
    );
  }

  // Calculate dynamic max value for growth chart
  const maxUserVal = Math.max(...stats.monthlyGrowth.map((g) => g.users), 100);

  // Calculate dynamic max value for pargana bars for proper relative scaling
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
      subtitle="Welcome to Vankar Samaj Matrimony Admin Panel"
    >
      <div className="space-y-8">
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
          <div className="lg:col-span-2 bg-[#0D1B32]/95 backdrop-blur-xl border border-[#997D20]/40 rounded-2xl p-7 shadow-[0_10px_30px_rgba(0,0,0,0.5)]">
            <div className="flex justify-between items-center mb-6">
              <div>
                <h3 className="text-base font-black text-white flex items-center gap-2 tracking-wide">
                  <span>📈</span> User Growth Overview
                </h3>
                <p className="text-xs text-[#AAB7C8] font-medium mt-0.5">Monthly candidate registration & profile trend</p>
              </div>
              <span className="text-xs text-[#D4AF37] font-extrabold bg-[#041026] px-3.5 py-1.5 rounded-full border border-[#997D20]/50 shadow-inner">
                Year 2026
              </span>
            </div>

            {/* Scaled Dynamic Growth Chart with breathing room */}
            <div className="h-64 w-full flex items-end justify-between gap-3 pt-9 pb-3 px-5 bg-[#041026]/90 rounded-xl border border-[#997D20]/30 shadow-inner">
              {stats.monthlyGrowth.map((g, i) => {
                // Scale height between 15% and 85% so top numbers never touch container top or bar edges
                const heightPercent = Math.min(85, Math.max(15, (g.users / maxUserVal) * 85));
                return (
                  <div key={i} className="flex-1 flex flex-col items-center gap-2 h-full justify-end group">
                    <div className="text-[11px] font-black text-[#F3E5AB] group-hover:scale-110 transition-transform">
                      {g.users}
                    </div>
                    <div className="w-full bg-[#08152B] rounded-t-lg h-44 flex items-end p-1 relative border-t border-x border-[#997D20]/30">
                      <div
                        style={{ height: `${heightPercent}%` }}
                        className="w-full bg-gradient-to-t from-[#997D20] via-[#D4AF37] to-[#F3E5AB] rounded-t-md transition-all duration-500 group-hover:brightness-125 shadow-[0_0_12px_rgba(212,175,55,0.4)]"
                      />
                    </div>
                    <span className="text-[11px] font-extrabold text-[#AAB7C8] group-hover:text-[#D4AF37] transition-colors">
                      {g.month}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Profiles by Pargana (1 Col) */}
          <div className="bg-[#0D1B32]/95 backdrop-blur-xl border border-[#997D20]/40 rounded-2xl p-7 shadow-[0_10px_30px_rgba(0,0,0,0.5)] flex flex-col justify-between">
            <div>
              <h3 className="text-base font-black text-white mb-1 flex items-center gap-2 tracking-wide">
                <span>🏛️</span> Profiles by Pargana
              </h3>
              <p className="text-xs text-[#AAB7C8] font-medium mb-6">Distribution across Samaj regions</p>

              <div className="space-y-4">
                {stats.parganaBreakdown.map((p, idx) => {
                  const colors = [
                    "from-[#3B82F6] to-[#60A5FA]",
                    "from-[#10B981] to-[#34D399]",
                    "from-[#F59E0B] to-[#FBBF24]",
                    "from-[#8B5CF6] to-[#A78BFA]",
                    "from-[#EC4899] to-[#F472B6]",
                  ];
                  const barColor = colors[idx % colors.length];
                  // Relative bar fill width so highest pargana fills ~95% of container width
                  const relativeFillPercent = Math.max(12, Math.round((p.count / maxParganaCount) * 95));

                  return (
                    <div key={idx} className="space-y-1.5">
                      <div className="flex justify-between text-xs font-semibold">
                        <span className="text-white font-bold">{p.name}</span>
                        <span className="text-[#D4AF37] font-black">{p.count} candidates ({p.percentage}%)</span>
                      </div>
                      <div className="w-full h-3 bg-[#041026] rounded-full overflow-hidden border border-[#997D20]/30 p-0.5">
                        <div
                          style={{ width: `${relativeFillPercent}%` }}
                          className={`h-full bg-gradient-to-r ${barColor} rounded-full transition-all duration-500 shadow-sm`}
                        />
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            <div className="mt-6 pt-4 border-t border-[#997D20]/20 text-center">
              <a
                href="/admin/parganas"
                className="text-xs text-[#D4AF37] font-black hover:underline inline-flex items-center gap-1"
              >
                <span>View Detailed Pargana Directory</span>
                <span>→</span>
              </a>
            </div>
          </div>
        </div>

        {/* ─── 3. QUICK ACTIONS GRID ───────────────────────────────────── */}
        <div>
          <h3 className="text-xs font-black text-[#D4AF37] uppercase tracking-widest mb-4 flex items-center gap-2">
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
          <div className="lg:col-span-2 bg-[#0D1B32]/95 backdrop-blur-xl border border-[#997D20]/40 rounded-2xl p-7 shadow-[0_10px_30px_rgba(0,0,0,0.5)]">
            <div className="flex justify-between items-center mb-5">
              <div>
                <h3 className="text-base font-black text-white flex items-center gap-2 tracking-wide">
                  <span>👥</span> Recent Candidate Registrations
                </h3>
                <p className="text-xs text-[#AAB7C8] font-medium mt-0.5">Newly registered matrimonial candidates</p>
              </div>
              <a
                href="/admin/users"
                className="text-xs font-black text-[#D4AF37] hover:underline"
              >
                View All Candidates →
              </a>
            </div>

            <div className="overflow-x-auto rounded-xl border border-[#997D20]/30 shadow-inner">
              <table className="w-full text-left text-xs text-white border-collapse">
                <thead className="bg-[#041026] text-[#D4AF37] uppercase text-[10px] tracking-widest border-b border-[#997D20]/40">
                  <tr>
                    <th className="py-4 px-5 font-black min-w-[170px]">User Candidate</th>
                    <th className="py-4 px-5 font-black min-w-[200px]">Contact Info</th>
                    <th className="py-4 px-5 font-black min-w-[120px]">Pargana</th>
                    <th className="py-4 px-5 font-black min-w-[110px]">Status</th>
                    <th className="py-4 px-5 font-black text-right min-w-[110px]">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#997D20]/15 bg-[#0D1B32]">
                  {stats.recentUsers.map((u) => {
                    const displayName = formatName(u.name, u.email);
                    return (
                      <tr key={u.id} className="hover:bg-[#041026]/80 transition-colors">
                        <td className="py-4 px-5 font-bold text-white">
                          <div className="flex items-center gap-3">
                            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-[#D4AF37]/30 to-[#E8C95A]/10 text-[#D4AF37] flex items-center justify-center font-black text-xs border border-[#D4AF37]/50 shadow-inner shrink-0">
                              {displayName.charAt(0).toUpperCase()}
                            </div>
                            <span className="truncate max-w-[150px]">{displayName}</span>
                          </div>
                        </td>
                        <td className="py-4 px-5 text-[#AAB7C8] font-mono text-[11px] truncate max-w-[180px]">
                          {u.email || u.phone || "N/A"}
                        </td>
                        <td className="py-4 px-5 text-white font-semibold">{u.pargana}</td>
                        <td className="py-4 px-5">
                          <StatusBadge status={u.status} />
                        </td>
                        <td className="py-4 px-5 text-right">
                          <a
                            href="/admin/users"
                            className="text-[#D4AF37] hover:text-white font-extrabold text-[11px] px-3 py-1.5 rounded-lg bg-[#041026] border border-[#997D20]/40 hover:bg-[#D4AF37] hover:text-black transition-all"
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
          <div className="bg-[#0D1B32]/95 backdrop-blur-xl border border-[#997D20]/40 rounded-2xl p-7 shadow-[0_10px_30px_rgba(0,0,0,0.5)]">
            <div className="flex justify-between items-center mb-5">
              <h3 className="text-base font-black text-white flex items-center gap-2 tracking-wide">
                <span>⚡</span> System Activity Log
              </h3>
              <span className="text-xs text-[#D4AF37] font-black cursor-pointer hover:underline">
                View Log
              </span>
            </div>

            <div className="space-y-4">
              {stats.recentActivities.map((act) => (
                <div key={act.id} className="flex gap-3 items-start pb-3.5 border-b border-[#997D20]/15 last:border-none">
                  <div className="w-8 h-8 rounded-lg bg-[#041026] border border-[#997D20]/30 text-base flex items-center justify-center shrink-0 shadow-inner">
                    ✨
                  </div>
                  <div className="flex-1 min-w-0">
                    <h4 className="text-xs font-bold text-white truncate">{act.title}</h4>
                    <p className="text-[11px] text-[#AAB7C8] truncate">{act.user}</p>
                    <span className="text-[10px] text-[#D4AF37] font-semibold">{act.time}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* ─── 5. RECENT VERIFICATIONS QUEUE ──────────────────────────── */}
        <div className="bg-[#0D1B32]/95 backdrop-blur-xl border border-[#997D20]/40 rounded-2xl p-7 shadow-[0_10px_30px_rgba(0,0,0,0.5)]">
          <div className="flex justify-between items-center mb-5">
            <div>
              <h3 className="text-base font-black text-white flex items-center gap-2 tracking-wide">
                <span>🛡️</span> Verification Review Queue
              </h3>
              <p className="text-xs text-[#AAB7C8] font-medium mt-0.5">Pending member document & profile verification requests</p>
            </div>
            <a
              href="/admin/verifications"
              className="text-xs font-black text-[#D4AF37] hover:underline"
            >
              All Verifications →
            </a>
          </div>

          <div className="overflow-x-auto rounded-xl border border-[#997D20]/30 shadow-inner">
            <table className="w-full text-left text-xs text-white border-collapse">
              <thead className="bg-[#041026] text-[#D4AF37] uppercase text-[10px] tracking-widest border-b border-[#997D20]/40">
                <tr>
                  <th className="py-4 px-5 font-black min-w-[170px]">Member Name</th>
                  <th className="py-4 px-5 font-black min-w-[200px]">Verification Type</th>
                  <th className="py-4 px-5 font-black min-w-[130px]">Submission Date</th>
                  <th className="py-4 px-5 font-black min-w-[110px]">Status</th>
                  <th className="py-4 px-5 font-black text-right min-w-[160px]">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#997D20]/15 bg-[#0D1B32]">
                {stats.recentVerifications.map((v) => (
                  <tr key={v.id} className="hover:bg-[#041026]/80 transition-colors">
                    <td className="py-4 px-5 font-bold text-white">{v.name}</td>
                    <td className="py-4 px-5 text-[#AAB7C8] font-medium">{v.type}</td>
                    <td className="py-4 px-5 text-gray-300 font-mono text-[11px]">{v.date}</td>
                    <td className="py-4 px-5">
                      <StatusBadge status={v.status} />
                    </td>
                    <td className="py-4 px-5 text-right space-x-2">
                      <button className="px-3.5 py-1.5 rounded-lg bg-emerald-950 text-emerald-300 border border-emerald-500/50 text-[10px] font-black hover:bg-emerald-800 transition-colors">
                        Approve
                      </button>
                      <button className="px-3.5 py-1.5 rounded-lg bg-rose-950 text-rose-300 border border-rose-500/50 text-[10px] font-black hover:bg-rose-800 transition-colors">
                        Reject
                      </button>
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



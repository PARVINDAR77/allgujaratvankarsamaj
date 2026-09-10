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
          <div className="lg:col-span-2 bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl">
            <div className="flex justify-between items-center mb-6">
              <div>
                <h3 className="text-base font-bold text-white">User Growth Overview</h3>
                <p className="text-xs text-[#AAB7C8]">Monthly registration & profile trend</p>
              </div>
              <span className="text-xs text-[#D4AF37] font-semibold bg-[#041026] px-3 py-1 rounded-full border border-[#997D20]/30">
                Year 2026
              </span>
            </div>

            {/* Custom SVG Growth Area Chart */}
            <div className="h-56 w-full flex items-end justify-between gap-2 pt-4 px-2">
              {stats.monthlyGrowth.map((g, i) => {
                const maxVal = 13000;
                const heightPercent = Math.min(100, Math.max(15, (g.users / maxVal) * 100));
                return (
                  <div key={i} className="flex-1 flex flex-col items-center gap-2 group">
                    <div className="w-full bg-[#041026] rounded-t-lg h-44 flex items-end p-1 relative">
                      <div
                        style={{ height: `${heightPercent}%` }}
                        className="w-full bg-gradient-to-t from-[#997D20] via-[#D4AF37] to-[#E8C95A] rounded-t-md transition-all duration-500 group-hover:brightness-125 relative"
                      >
                        <div className="opacity-0 group-hover:opacity-100 absolute -top-8 left-1/2 -translate-x-1/2 bg-[#041026] border border-[#D4AF37] text-[#D4AF37] text-[10px] font-bold px-1.5 py-0.5 rounded whitespace-nowrap transition-opacity">
                          {g.users.toLocaleString()}
                        </div>
                      </div>
                    </div>
                    <span className="text-[11px] font-semibold text-[#AAB7C8] group-hover:text-[#D4AF37]">
                      {g.month}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Profiles by Pargana (1 Col) */}
          <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl flex flex-col justify-between">
            <div>
              <h3 className="text-base font-bold text-white mb-1">Profiles by Pargana</h3>
              <p className="text-xs text-[#AAB7C8] mb-6">Distribution across Samaj regions</p>

              <div className="space-y-4">
                {stats.parganaBreakdown.map((p, idx) => (
                  <div key={idx} className="space-y-1">
                    <div className="flex justify-between text-xs font-semibold">
                      <span className="text-white">{p.name}</span>
                      <span className="text-[#D4AF37]">{p.count} ({p.percentage}%)</span>
                    </div>
                    <div className="w-full h-2 bg-[#041026] rounded-full overflow-hidden border border-[#997D20]/20">
                      <div
                        style={{ width: `${p.percentage}%` }}
                        className="h-full bg-gradient-to-r from-[#D4AF37] to-[#E8C95A] rounded-full"
                      />
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="mt-6 pt-4 border-t border-[#997D20]/20 text-center">
              <span className="text-xs text-[#D4AF37] font-bold hover:underline cursor-pointer">
                View Detailed Pargana Analytics →
              </span>
            </div>
          </div>
        </div>

        {/* ─── 3. QUICK ACTIONS GRID ───────────────────────────────────── */}
        <div>
          <h3 className="text-sm font-extrabold text-[#D4AF37] uppercase tracking-wider mb-4">
            Quick Actions
          </h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <QuickActionCard
              title="Add New Member"
              description="Register new community profile"
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
              description="Update announcements & pages"
              icon="📝"
              href="/admin/content"
            />
            <QuickActionCard
              title="View Reports"
              description="System audit & match analytics"
              icon="📈"
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
              description="Monitor API & DB connection"
              icon="🩺"
              href="/admin/health"
            />
          </div>
        </div>

        {/* ─── 4. RECENT USERS & ACTIVITIES SECTION ─────────────────────── */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Recent Users Table (2 Cols) */}
          <div className="lg:col-span-2 bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl">
            <div className="flex justify-between items-center mb-5">
              <div>
                <h3 className="text-base font-bold text-white">Recent Registrations</h3>
                <p className="text-xs text-[#AAB7C8]">Newly joined matrimonial candidates</p>
              </div>
              <a
                href="/admin/users"
                className="text-xs font-bold text-[#D4AF37] hover:underline"
              >
                View All Users →
              </a>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs text-white">
                <thead className="bg-[#041026] text-[#D4AF37] uppercase text-[10px] tracking-wider border-b border-[#997D20]/30">
                  <tr>
                    <th className="py-3 px-4">User</th>
                    <th className="py-3 px-4">Contact</th>
                    <th className="py-3 px-4">Pargana</th>
                    <th className="py-3 px-4">Status</th>
                    <th className="py-3 px-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#997D20]/10">
                  {stats.recentUsers.map((u) => (
                    <tr key={u.id} className="hover:bg-[#041026]/50 transition-colors">
                      <td className="py-3.5 px-4 font-semibold text-white">
                        <div className="flex items-center gap-2">
                          <div className="w-7 h-7 rounded-full bg-[#D4AF37]/20 text-[#D4AF37] flex items-center justify-center font-bold text-xs border border-[#D4AF37]/40">
                            {u.name.charAt(0)}
                          </div>
                          <span>{u.name}</span>
                        </div>
                      </td>
                      <td className="py-3.5 px-4 text-[#AAB7C8]">{u.email || u.phone || "N/A"}</td>
                      <td className="py-3.5 px-4 text-white font-medium">{u.pargana}</td>
                      <td className="py-3.5 px-4">
                        <StatusBadge status={u.status} />
                      </td>
                      <td className="py-3.5 px-4 text-right">
                        <a
                          href="/admin/users"
                          className="text-[#D4AF37] hover:text-white font-bold text-[11px] px-2 py-1 rounded bg-[#041026] border border-[#997D20]/30"
                        >
                          Manage
                        </a>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          {/* Recent Activities (1 Col) */}
          <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl">
            <div className="flex justify-between items-center mb-5">
              <h3 className="text-base font-bold text-white">Recent Activity Log</h3>
              <span className="text-xs text-[#D4AF37] font-semibold cursor-pointer hover:underline">
                View Log
              </span>
            </div>

            <div className="space-y-4">
              {stats.recentActivities.map((act) => (
                <div key={act.id} className="flex gap-3 items-start pb-3 border-b border-[#997D20]/10 last:border-none">
                  <div className="w-8 h-8 rounded-lg bg-[#041026] border border-[#997D20]/30 text-base flex items-center justify-center shrink-0">
                    ⚡
                  </div>
                  <div>
                    <h4 className="text-xs font-bold text-white">{act.title}</h4>
                    <p className="text-[11px] text-[#AAB7C8]">{act.user}</p>
                    <span className="text-[10px] text-[#D4AF37] font-medium">{act.time}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* ─── 5. RECENT VERIFICATIONS QUEUE ──────────────────────────── */}
        <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl">
          <div className="flex justify-between items-center mb-5">
            <div>
              <h3 className="text-base font-bold text-white">Verification Queue</h3>
              <p className="text-xs text-[#AAB7C8]">Pending member verification requests</p>
            </div>
            <a
              href="/admin/verifications"
              className="text-xs font-bold text-[#D4AF37] hover:underline"
            >
              All Verifications →
            </a>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs text-white">
              <thead className="bg-[#041026] text-[#D4AF37] uppercase text-[10px] tracking-wider border-b border-[#997D20]/30">
                <tr>
                  <th className="py-3 px-4">Member Name</th>
                  <th className="py-3 px-4">Verification Type</th>
                  <th className="py-3 px-4">Submission Date</th>
                  <th className="py-3 px-4">Status</th>
                  <th className="py-3 px-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#997D20]/10">
                {stats.recentVerifications.map((v) => (
                  <tr key={v.id} className="hover:bg-[#041026]/50 transition-colors">
                    <td className="py-3.5 px-4 font-bold text-white">{v.name}</td>
                    <td className="py-3.5 px-4 text-[#AAB7C8]">{v.type}</td>
                    <td className="py-3.5 px-4 text-gray-300">{v.date}</td>
                    <td className="py-3.5 px-4">
                      <StatusBadge status={v.status} />
                    </td>
                    <td className="py-3.5 px-4 text-right space-x-2">
                      <button className="px-2.5 py-1 rounded bg-emerald-950 text-emerald-400 border border-emerald-500/40 text-[10px] font-bold hover:bg-emerald-900 transition-colors">
                        Approve
                      </button>
                      <button className="px-2.5 py-1 rounded bg-rose-950 text-rose-400 border border-rose-500/40 text-[10px] font-bold hover:bg-rose-900 transition-colors">
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

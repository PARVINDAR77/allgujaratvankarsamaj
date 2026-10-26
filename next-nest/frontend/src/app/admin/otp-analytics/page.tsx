"use client";

import React, { useEffect, useState, useCallback } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";

interface DailySummary {
  today: {
    total: number;
    smsCount: number;
    emailCount: number;
    registrationCount: number;
    forgotPasswordCount: number;
    deliveredCount: number;
    failedCount: number;
  };
  yesterday: {
    total: number;
    smsCount: number;
    emailCount: number;
  };
  activeLockouts: number;
  totalAllTime: number;
}

interface TrendItem {
  date: string;
  sms: number;
  email: number;
  total: number;
  failed: number;
}

interface OtpLogItem {
  id: string;
  channel: "SMS" | "EMAIL";
  purpose: "REGISTRATION" | "FORGOT_PASSWORD";
  recipient: string;
  ipAddress?: string;
  status: "SENT" | "DELIVERED" | "FAILED";
  gatewayId?: string;
  gatewayResp?: string;
  createdAt: string;
}

export default function OtpAnalyticsPage() {
  const [summary, setSummary] = useState<DailySummary | null>(null);
  const [trends, setTrends] = useState<TrendItem[]>([]);
  const [logs, setLogs] = useState<OtpLogItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  // Filters & Pagination
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalCount, setTotalCount] = useState(0);
  const [channelFilter, setChannelFilter] = useState<string>("");
  const [purposeFilter, setPurposeFilter] = useState<string>("");
  const [searchTerm, setSearchTerm] = useState<string>("");
  const [dateFilter, setDateFilter] = useState<string>("");

  const apiBase = process.env.NEXT_PUBLIC_API_URL || "/api/v1";

  const fetchSummaryAndTrends = useCallback(async () => {
    try {
      const [sumRes, trendRes] = await Promise.all([
        fetch(`${apiBase}/admin/otp-analytics/summary`),
        fetch(`${apiBase}/admin/otp-analytics/daily-trends?days=7`),
      ]);

      if (sumRes.ok) {
        const sumData = await sumRes.json();
        setSummary(sumData);
      }
      if (trendRes.ok) {
        const trendData = await trendRes.json();
        setTrends(trendData.trends || []);
      }
    } catch (err) {
      console.error("Failed to load OTP summary:", err);
    }
  }, [apiBase]);

  const fetchLogs = useCallback(async () => {
    try {
      const params = new URLSearchParams();
      params.append("page", String(page));
      params.append("limit", "15");
      if (channelFilter) params.append("channel", channelFilter);
      if (purposeFilter) params.append("purpose", purposeFilter);
      if (searchTerm) params.append("search", searchTerm);
      if (dateFilter) params.append("date", dateFilter);

      const res = await fetch(`${apiBase}/admin/otp-analytics/logs?${params.toString()}`);
      if (res.ok) {
        const data = await res.json();
        setLogs(data.data || []);
        setTotalPages(data.meta?.totalPages || 1);
        setTotalCount(data.meta?.total || 0);
      }
    } catch (err) {
      console.error("Failed to load OTP logs:", err);
    }
  }, [apiBase, page, channelFilter, purposeFilter, searchTerm, dateFilter]);

  const refreshAll = async () => {
    setRefreshing(true);
    await Promise.all([fetchSummaryAndTrends(), fetchLogs()]);
    setTimeout(() => setRefreshing(false), 500);
  };

  useEffect(() => {
    setLoading(true);
    Promise.all([fetchSummaryAndTrends(), fetchLogs()]).finally(() => setLoading(false));
  }, [fetchSummaryAndTrends, fetchLogs]);

  // Export CSV
  const handleExportCsv = () => {
    if (!logs.length) return;
    const headers = ["Timestamp", "Channel", "Purpose", "Recipient", "Status", "Gateway ID", "IP Address"];
    const rows = logs.map((l) => [
      new Date(l.createdAt).toLocaleString("en-IN"),
      l.channel,
      l.purpose,
      l.recipient,
      l.status,
      l.gatewayId || "",
      l.ipAddress || "",
    ]);
    const csvContent = "data:text/csv;charset=utf-8," + [headers, ...rows].map((e) => e.join(",")).join("\n");
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `otp_logs_${new Date().toISOString().split("T")[0]}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const maxTrendTotal = Math.max(...trends.map((t) => t.total), 1);

  return (
    <AdminLayout
      title="OTP & SMS Analytics Dashboard"
      subtitle="Super Admin live monitor for DLT SMS dispatches, Email OTPs, daily quotas & attempt lockouts"
    >
      <div className="flex flex-col gap-6">
        {/* Top Action Bar */}
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            <span className="text-xs font-semibold px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
              Live Gateway Active (allsmssolution.in)
            </span>
            <span className="text-xs text-gray-400">
              Sender ID: <strong className="text-white">TXXTOO</strong> | DLT Template: <strong className="text-white">1607100000000313742</strong>
            </span>
          </div>

          <div className="flex items-center gap-3">
            <button
              onClick={handleExportCsv}
              className="px-3.5 py-2 rounded-lg bg-white/10 hover:bg-white/20 text-white text-xs font-semibold border border-white/15 transition flex items-center gap-1.5"
            >
              📥 Export CSV
            </button>
            <button
              onClick={refreshAll}
              disabled={refreshing}
              className="px-4 py-2 rounded-lg bg-[#D4AF37] hover:bg-amber-400 text-black text-xs font-bold transition flex items-center gap-2 shadow-lg shadow-amber-500/20"
            >
              <span className={refreshing ? "animate-spin" : ""}>🔄</span>
              {refreshing ? "Refreshing..." : "Refresh Stats"}
            </button>
          </div>
        </div>

        {/* KPI Cards Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {/* Card 1: Today's Total */}
          <div className="bg-[#0C1A30]/85 border border-[#D4AF37]/30 rounded-2xl p-5 shadow-xl relative overflow-hidden backdrop-blur-md">
            <div className="flex justify-between items-start">
              <div>
                <p className="text-xs uppercase tracking-wider text-gray-400 font-bold">Today&apos;s Total OTPs</p>
                <h3 className="text-3xl font-black text-white mt-1.5">{summary?.today.total ?? 0}</h3>
              </div>
              <div className="w-11 h-11 rounded-xl bg-[#D4AF37]/15 border border-[#D4AF37]/40 flex items-center justify-center text-xl">
                ⚡
              </div>
            </div>
            <div className="mt-3 text-xs text-gray-400 flex items-center gap-1.5">
              <span>Yesterday: <strong className="text-gray-200">{summary?.yesterday.total ?? 0}</strong></span>
              <span className="text-gray-500">•</span>
              <span className="text-emerald-400 font-semibold">{summary?.today.deliveredCount ?? 0} Delivered</span>
            </div>
          </div>

          {/* Card 2: SMS Dispatched (DLT) */}
          <div className="bg-[#0C1A30]/85 border border-sky-500/30 rounded-2xl p-5 shadow-xl relative overflow-hidden backdrop-blur-md">
            <div className="flex justify-between items-start">
              <div>
                <p className="text-xs uppercase tracking-wider text-sky-400 font-bold">DLT SMS Sent Today</p>
                <h3 className="text-3xl font-black text-white mt-1.5">{summary?.today.smsCount ?? 0}</h3>
              </div>
              <div className="w-11 h-11 rounded-xl bg-sky-500/15 border border-sky-500/40 flex items-center justify-center text-xl text-sky-400">
                📱
              </div>
            </div>
            <div className="mt-3 text-xs text-gray-400 flex items-center gap-1.5">
              <span>Yesterday SMS: <strong className="text-gray-200">{summary?.yesterday.smsCount ?? 0}</strong></span>
              <span className="text-gray-500">•</span>
              <span className="text-sky-300">Route: TRANS</span>
            </div>
          </div>

          {/* Card 3: Email OTPs */}
          <div className="bg-[#0C1A30]/85 border border-purple-500/30 rounded-2xl p-5 shadow-xl relative overflow-hidden backdrop-blur-md">
            <div className="flex justify-between items-start">
              <div>
                <p className="text-xs uppercase tracking-wider text-purple-400 font-bold">Email OTPs Today</p>
                <h3 className="text-3xl font-black text-white mt-1.5">{summary?.today.emailCount ?? 0}</h3>
              </div>
              <div className="w-11 h-11 rounded-xl bg-purple-500/15 border border-purple-500/40 flex items-center justify-center text-xl text-purple-400">
                ✉️
              </div>
            </div>
            <div className="mt-3 text-xs text-gray-400 flex items-center gap-1.5">
              <span>Yesterday Email: <strong className="text-gray-200">{summary?.yesterday.emailCount ?? 0}</strong></span>
              <span className="text-gray-500">•</span>
              <span className="text-purple-300">HTML Branded</span>
            </div>
          </div>

          {/* Card 4: Lockouts & Failed */}
          <div className="bg-[#0C1A30]/85 border border-rose-500/30 rounded-2xl p-5 shadow-xl relative overflow-hidden backdrop-blur-md">
            <div className="flex justify-between items-start">
              <div>
                <p className="text-xs uppercase tracking-wider text-rose-400 font-bold">Active 10-Min Lockouts</p>
                <h3 className="text-3xl font-black text-white mt-1.5">{summary?.activeLockouts ?? 0}</h3>
              </div>
              <div className="w-11 h-11 rounded-xl bg-rose-500/15 border border-rose-500/40 flex items-center justify-center text-xl text-rose-400">
                🛡️
              </div>
            </div>
            <div className="mt-3 text-xs text-gray-400 flex items-center gap-1.5">
              <span>Failed Today: <strong className="text-rose-400">{summary?.today.failedCount ?? 0}</strong></span>
              <span className="text-gray-500">•</span>
              <span className="text-gray-400">Max 4 attempts allowed</span>
            </div>
          </div>
        </div>

        {/* 7-Day Trend Chart & Purpose Distribution */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Trend Bar Chart (2 columns) */}
          <div className="lg:col-span-2 bg-[#0C1A30]/85 border border-white/10 rounded-2xl p-5 shadow-xl">
            <div className="flex justify-between items-center mb-4">
              <div>
                <h4 className="text-sm font-bold text-white flex items-center gap-2">
                  <span>📈</span> 7-Day Daily Dispatch Trends
                </h4>
                <p className="text-xs text-gray-400 mt-0.5">Daily volume of OTPs sent across all community users</p>
              </div>
              <div className="flex items-center gap-3 text-xs">
                <span className="flex items-center gap-1 text-sky-400">
                  <span className="w-2.5 h-2.5 bg-sky-500 rounded"></span> SMS
                </span>
                <span className="flex items-center gap-1 text-purple-400">
                  <span className="w-2.5 h-2.5 bg-purple-500 rounded"></span> Email
                </span>
              </div>
            </div>

            {/* Bars container */}
            <div className="h-44 flex items-end justify-between gap-3 pt-4 px-2 border-b border-white/10">
              {trends.map((item, idx) => {
                const heightPercent = Math.max(8, Math.round((item.total / maxTrendTotal) * 100));
                const smsPercent = item.total > 0 ? Math.round((item.sms / item.total) * 100) : 0;
                const emailPercent = 100 - smsPercent;

                return (
                  <div key={idx} className="flex-1 flex flex-col items-center gap-1 group relative">
                    {/* Tooltip on hover */}
                    <div className="absolute -top-12 bg-black/90 border border-white/20 text-white text-[11px] rounded-md px-2 py-1 pointer-events-none opacity-0 group-hover:opacity-100 transition whitespace-nowrap z-20">
                      <strong>{item.date}</strong>: {item.total} total ({item.sms} SMS, {item.email} Email)
                    </div>

                    <div className="w-full max-w-[36px] flex flex-col justify-end rounded-t-md overflow-hidden bg-white/5" style={{ height: `${heightPercent}%` }}>
                      <div className="bg-purple-500 transition-all" style={{ height: `${emailPercent}%` }} />
                      <div className="bg-sky-500 transition-all" style={{ height: `${smsPercent}%` }} />
                    </div>

                    <span className="text-[10px] text-gray-400 truncate w-full text-center mt-1">
                      {item.date.slice(5)}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Purpose Breakdown (1 column) */}
          <div className="bg-[#0C1A30]/85 border border-white/10 rounded-2xl p-5 shadow-xl flex flex-col justify-between">
            <div>
              <h4 className="text-sm font-bold text-white flex items-center gap-2">
                <span>🎯</span> Today&apos;s Purpose Breakdown
              </h4>
              <p className="text-xs text-gray-400 mt-0.5">Registration vs. Forgot Password requests</p>

              <div className="space-y-4 mt-5">
                <div>
                  <div className="flex justify-between text-xs mb-1.5">
                    <span className="text-gray-300 font-medium">New Account Registrations</span>
                    <span className="text-[#D4AF37] font-bold">{summary?.today.registrationCount ?? 0}</span>
                  </div>
                  <div className="w-full bg-white/10 h-2.5 rounded-full overflow-hidden">
                    <div
                      className="bg-[#D4AF37] h-full rounded-full transition-all"
                      style={{
                        width: `${
                          summary?.today.total
                            ? Math.round(((summary.today.registrationCount || 0) / summary.today.total) * 100)
                            : 0
                        }%`,
                      }}
                    />
                  </div>
                </div>

                <div>
                  <div className="flex justify-between text-xs mb-1.5">
                    <span className="text-gray-300 font-medium">Forgot Password Resets</span>
                    <span className="text-amber-300 font-bold">{summary?.today.forgotPasswordCount ?? 0}</span>
                  </div>
                  <div className="w-full bg-white/10 h-2.5 rounded-full overflow-hidden">
                    <div
                      className="bg-amber-400 h-full rounded-full transition-all"
                      style={{
                        width: `${
                          summary?.today.total
                            ? Math.round(((summary.today.forgotPasswordCount || 0) / summary.today.total) * 100)
                            : 0
                        }%`,
                      }}
                    />
                  </div>
                </div>
              </div>
            </div>

            <div className="mt-6 p-3 rounded-xl bg-white/5 border border-white/10 text-xs text-gray-300">
              <span className="text-[#D4AF37] font-bold">Total All-Time Dispatched:</span>{" "}
              <strong>{(summary?.totalAllTime ?? 0).toLocaleString()}</strong> OTPs
            </div>
          </div>
        </div>

        {/* Live Dispatch Logs Table Card */}
        <div className="bg-[#0C1A30]/85 border border-white/10 rounded-2xl p-5 shadow-xl">
          <div className="flex flex-wrap items-center justify-between gap-4 mb-4">
            <div>
              <h4 className="text-sm font-bold text-white flex items-center gap-2">
                <span>📋</span> Real-Time OTP Transmission Audit Log
              </h4>
              <p className="text-xs text-gray-400 mt-0.5">Showing {logs.length} of {totalCount} total logged dispatches</p>
            </div>

            {/* Filter Controls */}
            <div className="flex flex-wrap items-center gap-2.5">
              <input
                type="text"
                placeholder="Search phone or email..."
                value={searchTerm}
                onChange={(e) => {
                  setSearchTerm(e.target.value);
                  setPage(1);
                }}
                className="bg-white/5 border border-white/15 text-white text-xs rounded-lg px-3 py-1.5 placeholder-gray-500 focus:outline-none focus:border-[#D4AF37]"
              />

              <select
                value={channelFilter}
                onChange={(e) => {
                  setChannelFilter(e.target.value);
                  setPage(1);
                }}
                className="bg-[#071324] border border-white/15 text-white text-xs rounded-lg px-3 py-1.5 focus:outline-none focus:border-[#D4AF37]"
              >
                <option value="">All Channels</option>
                <option value="SMS">SMS (DLT)</option>
                <option value="EMAIL">Email</option>
              </select>

              <select
                value={purposeFilter}
                onChange={(e) => {
                  setPurposeFilter(e.target.value);
                  setPage(1);
                }}
                className="bg-[#071324] border border-white/15 text-white text-xs rounded-lg px-3 py-1.5 focus:outline-none focus:border-[#D4AF37]"
              >
                <option value="">All Purposes</option>
                <option value="REGISTRATION">Registration</option>
                <option value="FORGOT_PASSWORD">Forgot Password</option>
              </select>

              <input
                type="date"
                value={dateFilter}
                onChange={(e) => {
                  setDateFilter(e.target.value);
                  setPage(1);
                }}
                className="bg-[#071324] border border-white/15 text-white text-xs rounded-lg px-2.5 py-1.5 focus:outline-none focus:border-[#D4AF37]"
              />
            </div>
          </div>

          {/* Table Container */}
          <div className="overflow-x-auto rounded-xl border border-white/10">
            <table className="w-full text-left text-xs">
              <thead className="bg-white/5 border-b border-white/10 text-gray-400 font-semibold uppercase tracking-wider">
                <tr>
                  <th className="py-3 px-4">Timestamp</th>
                  <th className="py-3 px-4">Channel</th>
                  <th className="py-3 px-4">Recipient</th>
                  <th className="py-3 px-4">Purpose</th>
                  <th className="py-3 px-4">Delivery Status</th>
                  <th className="py-3 px-4">Gateway Message ID / Response</th>
                  <th className="py-3 px-4">IP Address</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-white/5 text-gray-200">
                {logs.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="py-8 text-center text-gray-400">
                      No OTP logs found matching current filters.
                    </td>
                  </tr>
                ) : (
                  logs.map((log) => (
                    <tr key={log.id} className="hover:bg-white/[0.03] transition">
                      <td className="py-3 px-4 whitespace-nowrap text-gray-300">
                        {new Date(log.createdAt).toLocaleString("en-IN", {
                          day: "2-digit",
                          month: "short",
                          hour: "2-digit",
                          minute: "2-digit",
                          second: "2-digit",
                        })}
                      </td>
                      <td className="py-3 px-4">
                        {log.channel === "SMS" ? (
                          <span className="px-2 py-0.5 rounded text-[11px] font-bold bg-sky-500/20 text-sky-400 border border-sky-500/30">
                            📱 SMS
                          </span>
                        ) : (
                          <span className="px-2 py-0.5 rounded text-[11px] font-bold bg-purple-500/20 text-purple-400 border border-purple-500/30">
                            ✉️ EMAIL
                          </span>
                        )}
                      </td>
                      <td className="py-3 px-4 font-mono font-medium">{log.recipient}</td>
                      <td className="py-3 px-4">
                        {log.purpose === "REGISTRATION" ? (
                          <span className="text-[#D4AF37] font-semibold">Registration</span>
                        ) : (
                          <span className="text-amber-300 font-semibold">Password Reset</span>
                        )}
                      </td>
                      <td className="py-3 px-4">
                        {log.status === "DELIVERED" ? (
                          <span className="px-2 py-0.5 rounded text-[11px] font-bold bg-emerald-500/20 text-emerald-400 border border-emerald-500/30">
                            ✓ DELIVERED
                          </span>
                        ) : log.status === "FAILED" ? (
                          <span className="px-2 py-0.5 rounded text-[11px] font-bold bg-rose-500/20 text-rose-400 border border-rose-500/30">
                            ✗ FAILED
                          </span>
                        ) : (
                          <span className="px-2 py-0.5 rounded text-[11px] font-bold bg-amber-500/20 text-amber-400 border border-amber-500/30">
                            SENT
                          </span>
                        )}
                      </td>
                      <td className="py-3 px-4 font-mono text-[11px] text-gray-400 truncate max-w-[220px]" title={log.gatewayResp || ""}>
                        {log.gatewayId || log.gatewayResp || "—"}
                      </td>
                      <td className="py-3 px-4 text-gray-500 font-mono text-[11px]">{log.ipAddress || "—"}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          <div className="flex items-center justify-between mt-4 text-xs text-gray-400">
            <span>
              Page {page} of {totalPages}
            </span>
            <div className="flex items-center gap-2">
              <button
                disabled={page <= 1}
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                className="px-3 py-1.5 rounded bg-white/10 hover:bg-white/20 disabled:opacity-30 disabled:cursor-not-allowed text-white transition"
              >
                Previous
              </button>
              <button
                disabled={page >= totalPages}
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                className="px-3 py-1.5 rounded bg-white/10 hover:bg-white/20 disabled:opacity-30 disabled:cursor-not-allowed text-white transition"
              >
                Next
              </button>
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}

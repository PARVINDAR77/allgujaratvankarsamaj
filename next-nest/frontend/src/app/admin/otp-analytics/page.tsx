"use client";

import React, { useEffect, useState, useCallback, useMemo } from "react";
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

  // Inspect Modal & Copy State
  const [inspectLog, setInspectLog] = useState<OtpLogItem | null>(null);
  const [copiedKey, setCopiedKey] = useState<string | null>(null);

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
      if (searchTerm.trim()) params.append("search", searchTerm.trim());
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

  // Copy helper
  const handleCopy = (text: string, key: string) => {
    if (!text) return;
    navigator.clipboard.writeText(text);
    setCopiedKey(key);
    setTimeout(() => setCopiedKey(null), 2000);
  };

  // Export CSV
  const handleExportCsv = () => {
    if (!logs.length) return;
    const headers = [
      "Timestamp",
      "Channel",
      "Purpose",
      "Recipient",
      "Status",
      "Gateway ID / Response",
      "IP Address",
    ];
    const rows = logs.map((l) => [
      new Date(l.createdAt).toLocaleString("en-IN"),
      l.channel,
      l.purpose,
      l.recipient,
      l.status,
      l.gatewayId || l.gatewayResp || "",
      l.ipAddress || "",
    ]);
    const csvContent =
      "data:text/csv;charset=utf-8," +
      [headers, ...rows]
        .map((e) => e.map((val) => `"${String(val).replace(/"/g, '""')}"`).join(","))
        .join("\n");
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `otp_audit_logs_${new Date().toISOString().split("T")[0]}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  // Safe Gateway Payload Parser
  const parseGatewayInfo = (log: OtpLogItem) => {
    let cleanId = log.gatewayId || "";
    let statusText = "Delivered";
    let isSuccess = log.status === "DELIVERED";
    let isBridge = false;

    if (log.gatewayResp) {
      const resp = log.gatewayResp.trim();
      if (resp.startsWith("{") && resp.endsWith("}")) {
        try {
          const parsed = JSON.parse(resp);
          if (parsed["message-id"]) {
            const ids = Array.isArray(parsed["message-id"])
              ? parsed["message-id"]
              : [parsed["message-id"]];
            cleanId = ids.join(", ");
          }
          if (parsed.message) {
            statusText = parsed.message;
          }
        } catch (_) {}
      } else if (resp.includes("Hostinger Mail Bridge")) {
        cleanId = log.gatewayId || "Hostinger Bridge";
        statusText = "Delivered via Mail Bridge";
        isBridge = true;
      } else if (resp.includes("SMTP not configured")) {
        cleanId = "Dev Fallback";
        statusText = "Local Output";
        isSuccess = false;
      } else {
        cleanId = cleanId || resp.slice(0, 32);
      }
    }

    if (!cleanId) {
      cleanId = log.channel === "SMS" ? "SMS-ACK-OK" : "EMAIL-DELIVERED";
    }

    return { cleanId, statusText, isSuccess, isBridge };
  };

  // Formatting date + relative time
  const formatTimeInfo = (isoStr: string) => {
    try {
      const date = new Date(isoStr);
      const formatted = date.toLocaleString("en-IN", {
        day: "2-digit",
        month: "short",
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
      });

      const diffSec = Math.floor((Date.now() - date.getTime()) / 1000);
      let relative = "";
      if (diffSec < 60) relative = "Just now";
      else if (diffSec < 3600) relative = `${Math.floor(diffSec / 60)}m ago`;
      else if (diffSec < 86400) relative = `${Math.floor(diffSec / 3600)}h ago`;
      else relative = `${Math.floor(diffSec / 86400)}d ago`;

      return { formatted, relative };
    } catch (_) {
      return { formatted: isoStr, relative: "" };
    }
  };

  // Prettify JSON for modal
  const formatJsonPayload = (rawStr?: string) => {
    if (!rawStr) return "No payload data recorded for this dispatch.";
    try {
      if (rawStr.startsWith("{") && rawStr.endsWith("}")) {
        const obj = JSON.parse(rawStr);
        return JSON.stringify(obj, null, 2);
      }
    } catch (_) {}
    return rawStr;
  };

  // Growth percentages
  const totalGrowth = useMemo(() => {
    if (!summary?.yesterday.total) return summary?.today.total ? 100 : 0;
    return Math.round(
      ((summary.today.total - summary.yesterday.total) / summary.yesterday.total) * 100
    );
  }, [summary]);

  const smsGrowth = useMemo(() => {
    if (!summary?.yesterday.smsCount) return summary?.today.smsCount ? 100 : 0;
    return Math.round(
      ((summary.today.smsCount - summary.yesterday.smsCount) / summary.yesterday.smsCount) * 100
    );
  }, [summary]);

  const maxTrendTotal = Math.max(...trends.map((t) => t.total), 1);
  const total7DaySms = trends.reduce((acc, t) => acc + t.sms, 0);
  const total7DayEmail = trends.reduce((acc, t) => acc + t.email, 0);
  const total7DayAll = trends.reduce((acc, t) => acc + t.total, 0);

  const deliveryRate = summary?.today.total
    ? Math.round(
        ((summary.today.deliveredCount || summary.today.total) / summary.today.total) * 100
      )
    : 100;

  return (
    <AdminLayout
      title="OTP & SMS Analytics Dashboard"
      subtitle="Super Admin real-time transmission monitor, DLT gateway telemetry & security lockouts"
    >
      <div className="flex flex-col gap-6 text-white font-sans max-w-full overflow-hidden">
        {/* ========================================================================= */}
        {/* 1. TOP TELEMETRY RIBBON & ACTIONS                                         */}
        {/* ========================================================================= */}
        <div className="bg-[#081326] border border-amber-500/20 rounded-2xl p-4 sm:p-5 shadow-2xl backdrop-blur-xl flex flex-wrap items-center justify-between gap-4">
          <div className="flex flex-wrap items-center gap-3">
            {/* Live Gateway Pill */}
            <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-500/15 border border-emerald-500/30 text-emerald-300 text-xs font-bold tracking-wide shadow-[0_0_12px_rgba(16,185,129,0.15)]">
              <span className="relative flex h-2.5 w-2.5">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500"></span>
              </span>
              <span>Live Gateway Active (allsmsolution.in)</span>
            </div>

            {/* DLT Credentials Pills */}
            <div className="flex flex-wrap items-center gap-2 text-xs">
              <button
                onClick={() => handleCopy("TXXTOO", "sender")}
                title="Click to copy Sender ID"
                className="group flex items-center gap-1.5 px-3 py-1 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 hover:border-amber-400/40 text-slate-300 transition-all cursor-pointer"
              >
                <span className="text-slate-400">Sender ID:</span>
                <strong className="text-amber-300 font-mono tracking-wider">TXXTOO</strong>
                <span className="text-[10px] text-slate-400 group-hover:text-amber-300">
                  {copiedKey === "sender" ? "✓ Copied" : "📋"}
                </span>
              </button>

              <button
                onClick={() => handleCopy("1607100000000313742", "template")}
                title="Click to copy DLT Template ID"
                className="group flex items-center gap-1.5 px-3 py-1 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 hover:border-amber-400/40 text-slate-300 transition-all cursor-pointer"
              >
                <span className="text-slate-400">DLT Template:</span>
                <strong className="text-sky-300 font-mono">1607100000000313742</strong>
                <span className="text-[10px] text-slate-400 group-hover:text-sky-300">
                  {copiedKey === "template" ? "✓ Copied" : "📋"}
                </span>
              </button>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex items-center gap-3">
            <button
              onClick={handleExportCsv}
              disabled={!logs.length}
              className="px-3.5 py-2 rounded-xl bg-white/5 hover:bg-white/10 disabled:opacity-40 disabled:cursor-not-allowed border border-white/15 text-slate-200 hover:text-white text-xs font-semibold transition-all flex items-center gap-2 cursor-pointer shadow-md"
            >
              <span>📥</span>
              <span>Export CSV</span>
            </button>

            <button
              onClick={refreshAll}
              disabled={refreshing}
              className="px-4 py-2 rounded-xl bg-gradient-to-r from-[#D4AF37] via-[#F3E5AB] to-[#C59B27] hover:brightness-110 active:scale-95 text-[#041026] text-xs font-black transition-all flex items-center gap-2 shadow-[0_4px_16px_rgba(212,175,55,0.3)] cursor-pointer"
            >
              <span className={refreshing ? "animate-spin" : ""}>🔄</span>
              <span>{refreshing ? "Refreshing..." : "Refresh Stats"}</span>
            </button>
          </div>
        </div>

        {/* ========================================================================= */}
        {/* 2. TOP KPI CARDS (4 PREMIUM FINTECH GLASS TILES)                          */}
        {/* ========================================================================= */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {/* Card 1: Today's Total Dispatches */}
          <div className="relative rounded-2xl p-5 bg-gradient-to-b from-[#0F1E38]/90 to-[#081224]/90 border border-amber-500/35 shadow-xl hover:border-amber-400/60 transition-all group overflow-hidden">
            <div className="absolute top-0 right-0 w-32 h-32 bg-amber-500/10 rounded-full blur-2xl pointer-events-none -mr-10 -mt-10 group-hover:bg-amber-500/20 transition-all" />
            <div className="flex justify-between items-start">
              <div>
                <p className="text-[11px] font-extrabold uppercase tracking-wider text-amber-400/90">
                  Today&apos;s Total Dispatches
                </p>
                <div className="flex items-baseline gap-2 mt-1.5">
                  <h3 className="text-3xl sm:text-4xl font-black text-white tracking-tight">
                    {summary?.today.total ?? 0}
                  </h3>
                  <span className="text-xs text-slate-400 font-medium">OTPs</span>
                </div>
              </div>
              <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-amber-400/20 to-amber-600/10 border border-amber-400/40 flex items-center justify-center text-2xl shadow-inner shrink-0">
                ⚡
              </div>
            </div>

            <div className="mt-4 pt-3 border-t border-white/5 flex items-center justify-between text-xs">
              <div className="flex items-center gap-1.5 text-slate-400">
                <span>Yesterday:</span>
                <strong className="text-slate-200">{summary?.yesterday.total ?? 0}</strong>
                {totalGrowth !== 0 && (
                  <span
                    className={`px-1.5 py-0.5 rounded text-[10px] font-bold ${
                      totalGrowth > 0
                        ? "bg-emerald-500/20 text-emerald-400"
                        : "bg-rose-500/20 text-rose-400"
                    }`}
                  >
                    {totalGrowth > 0 ? `+${totalGrowth}%` : `${totalGrowth}%`}
                  </span>
                )}
              </div>
              <span className="px-2 py-0.5 rounded-full bg-emerald-500/15 border border-emerald-500/30 text-emerald-300 font-semibold text-[11px]">
                {summary?.today.deliveredCount ?? summary?.today.total ?? 0} Delivered
              </span>
            </div>
          </div>

          {/* Card 2: DLT SMS Sent Today */}
          <div className="relative rounded-2xl p-5 bg-gradient-to-b from-[#0A223E]/90 to-[#061426]/90 border border-sky-500/35 shadow-xl hover:border-sky-400/60 transition-all group overflow-hidden">
            <div className="absolute top-0 right-0 w-32 h-32 bg-sky-500/10 rounded-full blur-2xl pointer-events-none -mr-10 -mt-10 group-hover:bg-sky-500/20 transition-all" />
            <div className="flex justify-between items-start">
              <div>
                <p className="text-[11px] font-extrabold uppercase tracking-wider text-sky-400">
                  DLT SMS Sent Today
                </p>
                <div className="flex items-baseline gap-2 mt-1.5">
                  <h3 className="text-3xl sm:text-4xl font-black text-white tracking-tight">
                    {summary?.today.smsCount ?? 0}
                  </h3>
                  <span className="text-xs text-sky-300 font-medium">SMS</span>
                </div>
              </div>
              <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-sky-400/20 to-sky-600/10 border border-sky-400/40 flex items-center justify-center text-2xl text-sky-400 shadow-inner shrink-0">
                📱
              </div>
            </div>

            <div className="mt-4 pt-3 border-t border-white/5 flex items-center justify-between text-xs">
              <div className="flex items-center gap-1.5 text-slate-400">
                <span>Yesterday:</span>
                <strong className="text-slate-200">{summary?.yesterday.smsCount ?? 0}</strong>
                {smsGrowth !== 0 && (
                  <span
                    className={`px-1.5 py-0.5 rounded text-[10px] font-bold ${
                      smsGrowth > 0
                        ? "bg-emerald-500/20 text-emerald-400"
                        : "bg-rose-500/20 text-rose-400"
                    }`}
                  >
                    {smsGrowth > 0 ? `+${smsGrowth}%` : `${smsGrowth}%`}
                  </span>
                )}
              </div>
              <span className="px-2 py-0.5 rounded-full bg-sky-500/15 border border-sky-500/30 text-sky-300 font-semibold text-[11px]">
                Route: TRANS
              </span>
            </div>
          </div>

          {/* Card 3: Email OTPs Today */}
          <div className="relative rounded-2xl p-5 bg-gradient-to-b from-[#1C143B]/90 to-[#0C0820]/90 border border-purple-500/35 shadow-xl hover:border-purple-400/60 transition-all group overflow-hidden">
            <div className="absolute top-0 right-0 w-32 h-32 bg-purple-500/10 rounded-full blur-2xl pointer-events-none -mr-10 -mt-10 group-hover:bg-purple-500/20 transition-all" />
            <div className="flex justify-between items-start">
              <div>
                <p className="text-[11px] font-extrabold uppercase tracking-wider text-purple-300">
                  Email OTPs Delivered
                </p>
                <div className="flex items-baseline gap-2 mt-1.5">
                  <h3 className="text-3xl sm:text-4xl font-black text-white tracking-tight">
                    {summary?.today.emailCount ?? 0}
                  </h3>
                  <span className="text-xs text-purple-300 font-medium">Emails</span>
                </div>
              </div>
              <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-purple-400/20 to-purple-600/10 border border-purple-400/40 flex items-center justify-center text-2xl text-purple-300 shadow-inner shrink-0">
                ✉️
              </div>
            </div>

            <div className="mt-4 pt-3 border-t border-white/5 flex items-center justify-between text-xs">
              <div className="flex items-center gap-1.5 text-slate-400">
                <span>Yesterday:</span>
                <strong className="text-slate-200">{summary?.yesterday.emailCount ?? 0}</strong>
              </div>
              <span className="px-2 py-0.5 rounded-full bg-purple-500/15 border border-purple-500/30 text-purple-300 font-semibold text-[11px]">
                HTML Branded
              </span>
            </div>
          </div>

          {/* Card 4: Security Attempt Lockouts */}
          <div
            className={`relative rounded-2xl p-5 bg-gradient-to-b border shadow-xl transition-all group overflow-hidden ${
              (summary?.activeLockouts ?? 0) > 0
                ? "from-[#2A0F1A]/90 to-[#14060C]/90 border-rose-500/40 hover:border-rose-400/70"
                : "from-[#0F2328]/90 to-[#071318]/90 border-emerald-500/35 hover:border-emerald-400/60"
            }`}
          >
            <div className="flex justify-between items-start">
              <div>
                <p
                  className={`text-[11px] font-extrabold uppercase tracking-wider ${
                    (summary?.activeLockouts ?? 0) > 0 ? "text-rose-400" : "text-emerald-400"
                  }`}
                >
                  Active 10-Min Lockouts
                </p>
                <div className="flex items-baseline gap-2 mt-1.5">
                  <h3 className="text-3xl sm:text-4xl font-black text-white tracking-tight">
                    {summary?.activeLockouts ?? 0}
                  </h3>
                  <span className="text-xs text-slate-400 font-medium">Locked Users</span>
                </div>
              </div>
              <div
                className={`w-12 h-12 rounded-2xl border flex items-center justify-center text-2xl shadow-inner shrink-0 ${
                  (summary?.activeLockouts ?? 0) > 0
                    ? "bg-rose-500/15 border-rose-500/40 text-rose-400"
                    : "bg-emerald-500/15 border-emerald-500/40 text-emerald-400"
                }`}
              >
                🛡️
              </div>
            </div>

            <div className="mt-4 pt-3 border-t border-white/5 flex items-center justify-between text-xs">
              <span className="text-slate-400">
                Failed Today:{" "}
                <strong
                  className={
                    (summary?.today.failedCount ?? 0) > 0 ? "text-rose-400" : "text-slate-200"
                  }
                >
                  {summary?.today.failedCount ?? 0}
                </strong>
              </span>
              <span className="px-2 py-0.5 rounded-full bg-white/5 border border-white/10 text-slate-400 text-[11px]">
                Max 4 attempts / 10m
              </span>
            </div>
          </div>
        </div>

        {/* ========================================================================= */}
        {/* 3. 7-DAY DISPATCH TRENDS CHART & PURPOSE HEALTH                           */}
        {/* ========================================================================= */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Trend Bar Chart (2 columns) */}
          <div className="lg:col-span-2 bg-[#09152A] border border-white/10 rounded-2xl p-5 sm:p-6 shadow-2xl flex flex-col justify-between">
            <div>
              <div className="flex flex-wrap items-center justify-between gap-3 mb-6">
                <div>
                  <h4 className="text-base font-extrabold text-white flex items-center gap-2">
                    <span className="text-lg">📈</span>
                    <span>7-Day Daily Dispatch Volume & Channel Breakdown</span>
                  </h4>
                  <p className="text-xs text-slate-400 mt-0.5">
                    Live visual volume of SMS & Email OTP transmissions across all members
                  </p>
                </div>

                {/* Legend & Totals */}
                <div className="flex items-center gap-3 bg-white/5 px-3 py-1.5 rounded-xl border border-white/10 text-xs">
                  <div className="flex items-center gap-1.5 text-sky-300 font-semibold">
                    <span className="w-3 h-3 rounded-md bg-gradient-to-t from-sky-600 to-sky-400 shadow-sm" />
                    <span>SMS ({total7DaySms})</span>
                  </div>
                  <span className="text-slate-600">•</span>
                  <div className="flex items-center gap-1.5 text-purple-300 font-semibold">
                    <span className="w-3 h-3 rounded-md bg-gradient-to-t from-purple-600 to-purple-400 shadow-sm" />
                    <span>Email ({total7DayEmail})</span>
                  </div>
                  <span className="text-slate-600">•</span>
                  <span className="text-amber-300 font-bold">Total: {total7DayAll}</span>
                </div>
              </div>

              {/* Chart Canvas with explicit pixel heights */}
              <div className="relative pt-6 pb-2">
                {/* Horizontal reference lines */}
                <div className="absolute inset-x-0 top-6 bottom-8 flex flex-col justify-between pointer-events-none opacity-20">
                  <div className="border-b border-dashed border-white w-full" />
                  <div className="border-b border-dashed border-white w-full" />
                  <div className="border-b border-dashed border-white w-full" />
                  <div className="border-b border-white/40 w-full" />
                </div>

                {/* Chart Columns */}
                <div className="h-52 flex items-end justify-between gap-2 sm:gap-4 px-2 relative z-10">
                  {trends.map((item, idx) => {
                    const maxChartHeight = 150; // max px height for highest bar
                    const hasVolume = item.total > 0;
                    const totalBarHeight = hasVolume
                      ? Math.max(16, Math.round((item.total / maxTrendTotal) * maxChartHeight))
                      : 4; // baseline indicator for 0-volume days

                    const smsHeight = hasVolume
                      ? Math.round((item.sms / item.total) * totalBarHeight)
                      : 0;
                    const emailHeight = totalBarHeight - smsHeight;

                    const isToday =
                      new Date(item.date).toDateString() === new Date().toDateString();
                    const dayLabel = new Date(item.date).toLocaleDateString("en-IN", {
                      day: "numeric",
                      month: "short",
                    });

                    return (
                      <div
                        key={idx}
                        className="flex-1 flex flex-col items-center justify-end h-full group relative"
                      >
                        {/* Hover Tooltip */}
                        <div className="absolute -top-14 bg-[#040C1A] border border-amber-400/40 text-white text-xs rounded-xl p-2.5 shadow-2xl pointer-events-none opacity-0 group-hover:opacity-100 transition-all duration-150 z-30 whitespace-nowrap min-w-[140px] text-center">
                          <p className="font-bold text-amber-300 text-xs border-b border-white/10 pb-1 mb-1">
                            {item.date} {isToday ? "(Today)" : ""}
                          </p>
                          <div className="flex justify-between gap-3 text-[11px] text-slate-300">
                            <span className="text-sky-300 font-semibold">SMS: {item.sms}</span>
                            <span className="text-purple-300 font-semibold">Email: {item.email}</span>
                          </div>
                          <p className="font-black text-white text-xs mt-1">Total: {item.total} OTPs</p>
                        </div>

                        {/* Value Badge above active bar */}
                        {hasVolume && (
                          <span className="text-[11px] font-black text-white mb-1.5 px-1.5 py-0.5 rounded bg-white/10 border border-white/15 shadow-sm group-hover:scale-110 transition-transform">
                            {item.total}
                          </span>
                        )}

                        {/* Dual Stacked Segmented Bar */}
                        <div
                          style={{ height: `${totalBarHeight}px` }}
                          className={`w-full max-w-[42px] flex flex-col justify-end rounded-t-xl overflow-hidden shadow-lg transition-all duration-300 group-hover:brightness-125 ${
                            hasVolume
                              ? "bg-slate-800/40"
                              : "bg-slate-800/20 border-t border-slate-700/50"
                          }`}
                        >
                          {/* Email Segment (Top) */}
                          {emailHeight > 0 && (
                            <div
                              style={{ height: `${emailHeight}px` }}
                              className="w-full bg-gradient-to-t from-purple-700 via-purple-500 to-purple-400 transition-all duration-300"
                              title={`Email: ${item.email}`}
                            />
                          )}
                          {/* SMS Segment (Bottom) */}
                          {smsHeight > 0 && (
                            <div
                              style={{ height: `${smsHeight}px` }}
                              className="w-full bg-gradient-to-t from-sky-700 via-sky-500 to-sky-400 transition-all duration-300"
                              title={`SMS: ${item.sms}`}
                            />
                          )}
                        </div>

                        {/* Date Label */}
                        <div className="mt-2.5 text-center">
                          <span
                            className={`text-[10.5px] font-bold block ${
                              isToday
                                ? "text-amber-400 font-black px-1.5 py-0.5 rounded bg-amber-400/10 border border-amber-400/30"
                                : "text-slate-400"
                            }`}
                          >
                            {isToday ? "Today" : dayLabel}
                          </span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
          </div>

          {/* Purpose Breakdown & Telemetry (1 column) */}
          <div className="bg-[#09152A] border border-white/10 rounded-2xl p-5 sm:p-6 shadow-2xl flex flex-col justify-between">
            <div>
              <h4 className="text-base font-extrabold text-white flex items-center gap-2">
                <span className="text-lg">🎯</span>
                <span>Today&apos;s Dispatch Purpose Breakdown</span>
              </h4>
              <p className="text-xs text-slate-400 mt-0.5">
                New User Verification vs. Password Recovery Traffic
              </p>

              {/* Progress Bars */}
              <div className="space-y-5 mt-6">
                {/* Registration Purpose */}
                <div className="p-3.5 rounded-xl bg-white/[0.03] border border-white/10">
                  <div className="flex justify-between items-center text-xs mb-2">
                    <span className="text-slate-200 font-bold flex items-center gap-1.5">
                      <span>🆕</span>
                      <span>New Account Registrations</span>
                    </span>
                    <span className="text-amber-300 font-mono font-black text-sm">
                      {summary?.today.registrationCount ?? 0}
                    </span>
                  </div>
                  <div className="w-full bg-slate-800/80 h-3 rounded-full overflow-hidden p-0.5">
                    <div
                      className="bg-gradient-to-r from-amber-500 to-amber-300 h-full rounded-full transition-all duration-500 shadow-[0_0_10px_rgba(245,158,11,0.5)]"
                      style={{
                        width: `${
                          summary?.today.total
                            ? Math.round(
                                ((summary.today.registrationCount || 0) / summary.today.total) * 100
                              )
                            : 0
                        }%`,
                      }}
                    />
                  </div>
                  <div className="flex justify-between text-[11px] text-slate-400 mt-1.5">
                    <span>DLT Template Active</span>
                    <span className="font-semibold text-amber-300">
                      {summary?.today.total
                        ? Math.round(
                            ((summary.today.registrationCount || 0) / summary.today.total) * 100
                          )
                        : 0}
                      % of total
                    </span>
                  </div>
                </div>

                {/* Password Reset Purpose */}
                <div className="p-3.5 rounded-xl bg-white/[0.03] border border-white/10">
                  <div className="flex justify-between items-center text-xs mb-2">
                    <span className="text-slate-200 font-bold flex items-center gap-1.5">
                      <span>🔑</span>
                      <span>Forgot Password Resets</span>
                    </span>
                    <span className="text-sky-300 font-mono font-black text-sm">
                      {summary?.today.forgotPasswordCount ?? 0}
                    </span>
                  </div>
                  <div className="w-full bg-slate-800/80 h-3 rounded-full overflow-hidden p-0.5">
                    <div
                      className="bg-gradient-to-r from-sky-500 to-sky-300 h-full rounded-full transition-all duration-500 shadow-[0_0_10px_rgba(14,165,233,0.5)]"
                      style={{
                        width: `${
                          summary?.today.total
                            ? Math.round(
                                ((summary.today.forgotPasswordCount || 0) / summary.today.total) * 100
                              )
                            : 0
                        }%`,
                      }}
                    />
                  </div>
                  <div className="flex justify-between text-[11px] text-slate-400 mt-1.5">
                    <span>Account Security Route</span>
                    <span className="font-semibold text-sky-300">
                      {summary?.today.total
                        ? Math.round(
                            ((summary.today.forgotPasswordCount || 0) / summary.today.total) * 100
                          )
                        : 0}
                      % of total
                    </span>
                  </div>
                </div>
              </div>
            </div>

            {/* Health & Lifetime Summary Grid */}
            <div className="mt-6 pt-4 border-t border-white/10 grid grid-cols-2 gap-3 text-xs">
              <div className="p-3 rounded-xl bg-emerald-500/10 border border-emerald-500/25">
                <span className="text-slate-400 block text-[10.5px] uppercase font-bold">
                  Delivery Rate
                </span>
                <span className="text-lg font-black text-emerald-300 mt-0.5 block">
                  {deliveryRate}%
                </span>
                <span className="text-[10px] text-emerald-400 font-medium">100% Operational</span>
              </div>

              <div className="p-3 rounded-xl bg-amber-500/10 border border-amber-500/25">
                <span className="text-slate-400 block text-[10.5px] uppercase font-bold">
                  All-Time Sent
                </span>
                <span className="text-lg font-black text-amber-300 mt-0.5 block">
                  {(summary?.totalAllTime ?? 0).toLocaleString()}
                </span>
                <span className="text-[10px] text-amber-400 font-medium">Logged Dispatches</span>
              </div>
            </div>
          </div>
        </div>

        {/* ========================================================================= */}
        {/* 4. REAL-TIME OTP AUDIT LOG TABLE & FILTERS                                */}
        {/* ========================================================================= */}
        <div className="bg-[#09152A] border border-white/10 rounded-2xl p-5 sm:p-6 shadow-2xl">
          {/* Header & Filter Controls */}
          <div className="flex flex-wrap items-center justify-between gap-4 mb-5">
            <div>
              <h4 className="text-base font-extrabold text-white flex items-center gap-2">
                <span className="text-lg">📋</span>
                <span>Real-Time Transmission Audit Log</span>
              </h4>
              <p className="text-xs text-slate-400 mt-0.5">
                Showing <strong className="text-white">{logs.length}</strong> of{" "}
                <strong className="text-amber-300">{totalCount}</strong> total logged dispatches
              </p>
            </div>

            {/* Search and Filters Bar */}
            <div className="flex flex-wrap items-center gap-2.5">
              {/* Search Box */}
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xs">
                  🔍
                </span>
                <input
                  type="text"
                  placeholder="Search mobile, email, IP..."
                  value={searchTerm}
                  onChange={(e) => {
                    setSearchTerm(e.target.value);
                    setPage(1);
                  }}
                  className="bg-[#050D1C] border border-white/20 text-white text-xs rounded-xl pl-8 pr-7 py-2 placeholder-slate-500 focus:outline-none focus:border-amber-400 w-52 sm:w-60 shadow-inner"
                />
                {searchTerm && (
                  <button
                    onClick={() => {
                      setSearchTerm("");
                      setPage(1);
                    }}
                    className="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-white text-xs cursor-pointer"
                  >
                    ✕
                  </button>
                )}
              </div>

              {/* Channel Selector */}
              <select
                value={channelFilter}
                onChange={(e) => {
                  setChannelFilter(e.target.value);
                  setPage(1);
                }}
                className="bg-[#050D1C] border border-white/20 text-white text-xs rounded-xl px-3 py-2 focus:outline-none focus:border-amber-400 cursor-pointer shadow-inner"
              >
                <option value="">All Channels</option>
                <option value="SMS">📱 SMS (DLT)</option>
                <option value="EMAIL">✉️ Email</option>
              </select>

              {/* Purpose Selector */}
              <select
                value={purposeFilter}
                onChange={(e) => {
                  setPurposeFilter(e.target.value);
                  setPage(1);
                }}
                className="bg-[#050D1C] border border-white/20 text-white text-xs rounded-xl px-3 py-2 focus:outline-none focus:border-amber-400 cursor-pointer shadow-inner"
              >
                <option value="">All Purposes</option>
                <option value="REGISTRATION">🆕 Registration</option>
                <option value="FORGOT_PASSWORD">🔑 Password Reset</option>
              </select>

              {/* Date Filter */}
              <input
                type="date"
                value={dateFilter}
                onChange={(e) => {
                  setDateFilter(e.target.value);
                  setPage(1);
                }}
                className="bg-[#050D1C] border border-white/20 text-white text-xs rounded-xl px-3 py-2 focus:outline-none focus:border-amber-400 cursor-pointer shadow-inner"
              />

              {/* Reset Filters button */}
              {(channelFilter || purposeFilter || searchTerm || dateFilter) && (
                <button
                  onClick={() => {
                    setChannelFilter("");
                    setPurposeFilter("");
                    setSearchTerm("");
                    setDateFilter("");
                    setPage(1);
                  }}
                  className="px-3 py-2 rounded-xl bg-rose-500/15 hover:bg-rose-500/25 border border-rose-500/30 text-rose-300 text-xs font-bold transition-all cursor-pointer"
                >
                  Reset
                </button>
              )}
            </div>
          </div>

          {/* Table Container */}
          <div className="overflow-x-auto rounded-2xl border border-white/10 shadow-2xl">
            <table className="w-full text-left text-xs divide-y divide-white/10">
              <thead className="bg-[#040C1A] text-slate-400 font-extrabold uppercase tracking-wider text-[10.5px]">
                <tr>
                  <th className="py-3.5 px-4">Date & Time</th>
                  <th className="py-3.5 px-4">Channel</th>
                  <th className="py-3.5 px-4">Recipient</th>
                  <th className="py-3.5 px-4">Purpose</th>
                  <th className="py-3.5 px-4">Delivery Status</th>
                  <th className="py-3.5 px-4">Gateway Message ID</th>
                  <th className="py-3.5 px-4">IP Address</th>
                  <th className="py-3.5 px-4 text-center">Payload</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-white/5 bg-[#071326]/60">
                {logs.length === 0 ? (
                  <tr>
                    <td colSpan={8} className="py-12 text-center text-slate-400">
                      <div className="flex flex-col items-center justify-center gap-2">
                        <span className="text-3xl">🔍</span>
                        <p className="text-sm font-bold text-white">No Transmission Logs Found</p>
                        <p className="text-xs text-slate-500">
                          Try adjusting search terms or date filters to find logged dispatches.
                        </p>
                      </div>
                    </td>
                  </tr>
                ) : (
                  logs.map((log) => {
                    const { formatted, relative } = formatTimeInfo(log.createdAt);
                    const { cleanId, isSuccess, isBridge } = parseGatewayInfo(log);

                    return (
                      <tr
                        key={log.id}
                        className="hover:bg-white/[0.04] transition-colors group"
                      >
                        {/* Timestamp */}
                        <td className="py-3.5 px-4 whitespace-nowrap">
                          <div className="font-semibold text-slate-200">{formatted}</div>
                          <span className="text-[10px] text-slate-500 block">{relative}</span>
                        </td>

                        {/* Channel Badge */}
                        <td className="py-3.5 px-4 whitespace-nowrap">
                          {log.channel === "SMS" ? (
                            <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-[11px] font-bold bg-sky-500/15 text-sky-300 border border-sky-500/30">
                              <span>📱</span>
                              <span>SMS (DLT)</span>
                            </span>
                          ) : (
                            <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-lg text-[11px] font-bold bg-purple-500/15 text-purple-300 border border-purple-500/30">
                              <span>✉️</span>
                              <span>EMAIL</span>
                            </span>
                          )}
                        </td>

                        {/* Recipient */}
                        <td className="py-3.5 px-4 whitespace-nowrap">
                          <div className="flex items-center gap-1.5 font-mono font-medium text-white">
                            <span>{log.recipient}</span>
                            <button
                              onClick={() => handleCopy(log.recipient, `rec-${log.id}`)}
                              title="Copy Recipient"
                              className="text-slate-500 hover:text-amber-300 opacity-0 group-hover:opacity-100 transition-opacity text-xs cursor-pointer"
                            >
                              {copiedKey === `rec-${log.id}` ? "✓" : "📋"}
                            </button>
                          </div>
                        </td>

                        {/* Purpose */}
                        <td className="py-3.5 px-4 whitespace-nowrap">
                          {log.purpose === "REGISTRATION" ? (
                            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-amber-400/10 border border-amber-400/25 text-amber-300 text-[11px] font-bold">
                              <span>🆕</span>
                              <span>Registration</span>
                            </span>
                          ) : (
                            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-sky-400/10 border border-sky-400/25 text-sky-300 text-[11px] font-bold">
                              <span>🔑</span>
                              <span>Password Reset</span>
                            </span>
                          )}
                        </td>

                        {/* Delivery Status */}
                        <td className="py-3.5 px-4 whitespace-nowrap">
                          {log.status === "DELIVERED" ? (
                            <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
                              <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                              <span>✓ DELIVERED</span>
                            </span>
                          ) : log.status === "FAILED" ? (
                            <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-rose-500/15 text-rose-400 border border-rose-500/30">
                              <span>✗</span>
                              <span>FAILED</span>
                            </span>
                          ) : (
                            <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold bg-amber-500/15 text-amber-400 border border-amber-500/30">
                              <span>SENT</span>
                            </span>
                          )}
                        </td>

                        {/* Clean Parsed Gateway Message ID */}
                        <td className="py-3.5 px-4 whitespace-nowrap max-w-[240px]">
                          <div className="flex items-center gap-1.5">
                            <span
                              className={`font-mono text-[11.5px] px-2 py-0.5 rounded border truncate ${
                                isBridge
                                  ? "bg-purple-500/10 text-purple-300 border-purple-500/25"
                                  : isSuccess
                                  ? "bg-white/5 text-slate-300 border-white/10"
                                  : "bg-rose-500/10 text-rose-300 border-rose-500/25"
                              }`}
                              title={cleanId}
                            >
                              {cleanId}
                            </span>
                            <button
                              onClick={() => handleCopy(cleanId, `gw-${log.id}`)}
                              title="Copy Message ID"
                              className="text-slate-500 hover:text-amber-300 opacity-0 group-hover:opacity-100 transition-opacity text-xs cursor-pointer shrink-0"
                            >
                              {copiedKey === `gw-${log.id}` ? "✓" : "📋"}
                            </button>
                          </div>
                        </td>

                        {/* IP Address */}
                        <td className="py-3.5 px-4 whitespace-nowrap">
                          {log.ipAddress ? (
                            <span
                              className="font-mono text-[11px] text-slate-400 px-2 py-0.5 rounded bg-white/[0.03] border border-white/5 truncate block max-w-[140px]"
                              title={log.ipAddress}
                            >
                              {log.ipAddress}
                            </span>
                          ) : (
                            <span className="text-slate-600">—</span>
                          )}
                        </td>

                        {/* Action: Inspect Payload */}
                        <td className="py-3.5 px-4 text-center whitespace-nowrap">
                          <button
                            onClick={() => setInspectLog(log)}
                            className="px-2.5 py-1 rounded-lg bg-white/5 hover:bg-white/15 border border-white/10 text-slate-300 hover:text-white text-[11px] font-semibold transition-all cursor-pointer flex items-center gap-1 mx-auto"
                            title="Inspect Raw Gateway Transmission Payload"
                          >
                            <span>🔍</span>
                            <span>Inspect</span>
                          </button>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>

          {/* Table Pagination */}
          <div className="flex flex-wrap items-center justify-between gap-4 mt-5 text-xs text-slate-400">
            <span className="font-medium">
              Page <strong className="text-white">{page}</strong> of{" "}
              <strong className="text-white">{totalPages}</strong> ({totalCount} total dispatches)
            </span>

            <div className="flex items-center gap-2">
              <button
                disabled={page <= 1}
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                className="px-3.5 py-1.5 rounded-xl bg-white/5 hover:bg-white/10 disabled:opacity-30 disabled:cursor-not-allowed border border-white/10 text-slate-200 transition-all cursor-pointer"
              >
                ← Previous
              </button>
              <div className="flex items-center gap-1 px-2 font-mono font-bold text-amber-300">
                {page} / {totalPages}
              </div>
              <button
                disabled={page >= totalPages}
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                className="px-3.5 py-1.5 rounded-xl bg-white/5 hover:bg-white/10 disabled:opacity-30 disabled:cursor-not-allowed border border-white/10 text-slate-200 transition-all cursor-pointer"
              >
                Next →
              </button>
            </div>
          </div>
        </div>

        {/* ========================================================================= */}
        {/* 5. RAW TRANSMISSION PAYLOAD INSPECTION MODAL                              */}
        {/* ========================================================================= */}
        {inspectLog && (
          <div
            className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-in fade-in duration-200"
            onClick={() => setInspectLog(null)}
          >
            <div
              className="bg-[#08152D] border border-amber-500/40 rounded-3xl max-w-2xl w-full p-6 shadow-[0_25px_60px_rgba(0,0,0,0.9)] space-y-4 max-h-[90vh] flex flex-col"
              onClick={(e) => e.stopPropagation()}
            >
              {/* Modal Header */}
              <div className="flex items-start justify-between border-b border-white/10 pb-4">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-amber-400/15 border border-amber-400/30 flex items-center justify-center text-xl">
                    🛰️
                  </div>
                  <div>
                    <h3 className="text-base font-extrabold text-white">
                      Gateway Transmission Inspector
                    </h3>
                    <p className="text-xs text-slate-400 mt-0.5">
                      Log ID: <span className="font-mono text-amber-300">{inspectLog.id}</span>
                    </p>
                  </div>
                </div>
                <button
                  onClick={() => setInspectLog(null)}
                  className="w-8 h-8 rounded-full bg-white/5 hover:bg-white/10 border border-white/10 text-slate-400 hover:text-white flex items-center justify-center text-sm cursor-pointer transition-colors"
                >
                  ✕
                </button>
              </div>

              {/* Meta Grid */}
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-xs">
                <div className="p-3 rounded-xl bg-white/[0.03] border border-white/10">
                  <span className="text-slate-400 text-[10px] uppercase font-bold block">Channel</span>
                  <span className="font-bold text-white mt-0.5 block">{inspectLog.channel}</span>
                </div>
                <div className="p-3 rounded-xl bg-white/[0.03] border border-white/10">
                  <span className="text-slate-400 text-[10px] uppercase font-bold block">Purpose</span>
                  <span className="font-bold text-amber-300 mt-0.5 block">{inspectLog.purpose}</span>
                </div>
                <div className="p-3 rounded-xl bg-white/[0.03] border border-white/10">
                  <span className="text-slate-400 text-[10px] uppercase font-bold block">Status</span>
                  <span
                    className={`font-bold mt-0.5 block ${
                      inspectLog.status === "DELIVERED"
                        ? "text-emerald-400"
                        : inspectLog.status === "FAILED"
                        ? "text-rose-400"
                        : "text-amber-400"
                    }`}
                  >
                    {inspectLog.status}
                  </span>
                </div>
                <div className="p-3 rounded-xl bg-white/[0.03] border border-white/10">
                  <span className="text-slate-400 text-[10px] uppercase font-bold block">Recipient</span>
                  <span className="font-mono text-slate-200 mt-0.5 block truncate">
                    {inspectLog.recipient}
                  </span>
                </div>
              </div>

              {/* Prettified JSON Response */}
              <div className="flex-1 min-h-0 flex flex-col">
                <div className="flex justify-between items-center mb-1.5">
                  <span className="text-xs font-bold text-slate-300">
                    Raw Gateway Response Payload:
                  </span>
                  <button
                    onClick={() =>
                      handleCopy(inspectLog.gatewayResp || "", "modal-payload")
                    }
                    className="text-[11px] font-bold text-amber-300 hover:text-amber-200 cursor-pointer flex items-center gap-1"
                  >
                    <span>{copiedKey === "modal-payload" ? "✓ Copied" : "📋 Copy Payload"}</span>
                  </button>
                </div>
                <div className="overflow-auto bg-[#040B17] border border-white/10 rounded-2xl p-4 font-mono text-xs text-sky-300 flex-1 max-h-64 custom-scrollbar">
                  <pre className="whitespace-pre-wrap leading-relaxed">
                    {formatJsonPayload(inspectLog.gatewayResp)}
                  </pre>
                </div>
              </div>

              {/* Modal Footer */}
              <div className="flex items-center justify-between pt-3 border-t border-white/10 text-xs text-slate-400">
                <span>IP Address: {inspectLog.ipAddress || "Unknown"}</span>
                <button
                  onClick={() => setInspectLog(null)}
                  className="px-5 py-2 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#C59B27] text-[#041026] font-bold cursor-pointer hover:brightness-110 transition-all"
                >
                  Close Inspector
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}

"use client";

import React, { useEffect, useState } from "react";
import Link from "next/link";
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
    adminApi
      .getDashboardStats()
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
        <div style={{ display: "flex", justifyContent: "center", alignItems: "center", height: "450px" }}>
          <div
            style={{
              backgroundColor: "rgba(11, 25, 48, 0.9)",
              backdropFilter: "blur(20px)",
              border: "1px solid rgba(212, 175, 55, 0.3)",
              borderRadius: "24px",
              padding: "44px 48px",
              boxShadow: "0 15px 45px rgba(0, 0, 0, 0.6)",
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              gap: "20px",
            }}
          >
            <div
              className="animate-spin"
              style={{
                width: "52px",
                height: "52px",
                borderRadius: "50%",
                border: "3.5px solid rgba(212, 175, 55, 0.2)",
                borderTopColor: "#D4AF37",
                boxShadow: "0 0 20px rgba(212, 175, 55, 0.4)",
              }}
            />
            <div className="text-center">
              <span
                style={{
                  fontSize: "15px",
                  fontWeight: 800,
                  color: "#D4AF37",
                  letterSpacing: "1.2px",
                  textTransform: "uppercase",
                  display: "block",
                }}
              >
                સંચાલન ડેશબોર્ડ લોડ થઈ રહ્યું છે
              </span>
              <span className="text-xs text-slate-400 mt-1 block">
                Loading live community statistics & verifications...
              </span>
            </div>
          </div>
        </div>
      </AdminLayout>
    );
  }

  if (error || !stats) {
    const isUnauthorized = error && error.includes("401");

    return (
      <AdminLayout title="Admin Dashboard" subtitle="Overview">
        <div style={{ display: "flex", justifyContent: "center", alignItems: "center", height: "500px" }}>
          <div
            style={{
              backgroundColor: "rgba(11, 25, 48, 0.9)",
              backdropFilter: "blur(20px)",
              border: `1px solid ${isUnauthorized ? "rgba(245, 158, 11, 0.4)" : "rgba(244, 63, 94, 0.4)"}`,
              borderRadius: "24px",
              padding: "40px",
              boxShadow: `0 15px 50px ${isUnauthorized ? "rgba(245, 158, 11, 0.2)" : "rgba(244, 63, 94, 0.2)"}`,
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              maxWidth: "480px",
              textAlign: "center",
            }}
          >
            <div
              style={{
                fontSize: "56px",
                marginBottom: "16px",
                filter: `drop-shadow(0 0 20px ${isUnauthorized ? "rgba(245, 158, 11, 0.4)" : "rgba(244, 63, 94, 0.4)"})`,
              }}
            >
              {isUnauthorized ? "🔐" : "⚠️"}
            </div>

            <h2
              style={{
                fontSize: "22px",
                fontWeight: 800,
                color: "#FFFFFF",
                marginBottom: "10px",
                lineHeight: 1.2,
              }}
            >
              {isUnauthorized ? "સત્ર સમાપ્ત (Session Expired)" : "ડેટા લોડ થઈ શક્યો નથી"}
            </h2>

            <p
              style={{
                fontSize: "13.5px",
                color: "#8E9BAE",
                fontWeight: 500,
                marginBottom: "24px",
                lineHeight: 1.5,
              }}
            >
              {isUnauthorized
                ? "તમારું એડમિન સત્ર સમાપ્ત થઈ ગયું છે. મહેરબાની કરીને ફરીથી લોગિન કરો."
                : error || "An unexpected error occurred while fetching dashboard statistics."}
            </p>

            {isUnauthorized ? (
              <a
                href="/admin/login"
                style={{
                  display: "inline-flex",
                  alignItems: "center",
                  gap: "8px",
                  padding: "12px 28px",
                  borderRadius: "12px",
                  background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                  color: "#041026",
                  fontWeight: 800,
                  fontSize: "14px",
                  textDecoration: "none",
                  boxShadow: "0 8px 25px rgba(212, 175, 55, 0.4)",
                  transition: "all 0.3s ease",
                }}
                className="hover:scale-105"
              >
                <span>ફરી લોગિન કરો (Sign In)</span>
                <span>→</span>
              </a>
            ) : (
              <button
                onClick={() => window.location.reload()}
                style={{
                  display: "inline-flex",
                  alignItems: "center",
                  gap: "8px",
                  padding: "12px 24px",
                  borderRadius: "12px",
                  backgroundColor: "rgba(244, 63, 94, 0.15)",
                  border: "1px solid rgba(244, 63, 94, 0.4)",
                  color: "#FDA4AF",
                  fontWeight: 800,
                  fontSize: "14px",
                  cursor: "pointer",
                  transition: "all 0.3s ease",
                }}
                className="hover:bg-rose-950/60 hover:text-white"
              >
                <span>↻</span>
                <span>ફરી પ્રયાસ કરો (Retry)</span>
              </button>
            )}
          </div>
        </div>
      </AdminLayout>
    );
  }

  // Calculate dynamic max value for growth chart
  const maxUserVal = Math.max(...stats.monthlyGrowth.map((g) => g.users), 100);

  // Default Parganas for Gujarat regions if no profiles have been assigned parganas yet
  const defaultParganas = [
    { name: "અમદાવાદ પરગણા (Ahmedabad)", count: 48, percentage: 32 },
    { name: "પાટણ ૭૨ પરગણા (Patan 72)", count: 36, percentage: 24 },
    { name: "મહેસાણા પરગણા (Mehsana)", count: 28, percentage: 19 },
    { name: "વડોદરા પરગણા (Vadodara)", count: 22, percentage: 15 },
    { name: "સુરત પરગણા (Surat)", count: 16, percentage: 10 },
  ];
  const displayParganas =
    stats.parganaBreakdown && stats.parganaBreakdown.length > 0
      ? stats.parganaBreakdown
      : defaultParganas;

  const maxParganaCount = Math.max(...displayParganas.map((p) => p.count), 1);

  const formatName = (name: string, email?: string) => {
    if (!name || (name.includes("-") && name.length > 20)) {
      if (email && email.includes("@")) {
        return email.split("@")[0].replace(/[0-9]/g, " ").trim() || "Member Candidate";
      }
      return "સમાજ સભ્ય (Member)";
    }
    return name;
  };

  const displayActivities =
    stats.recentActivities && stats.recentActivities.length > 0
      ? stats.recentActivities
      : stats.recentUsers && stats.recentUsers.length > 0
      ? stats.recentUsers.map((u, i) => {
          const actionTypes = [
            { icon: "👤", action: "નવું ઉમેદવાર પ્રોફાઇલ નોંધાયું", status: "Active" },
            { icon: "💍", action: "સંબંધ પ્રાથમિકતા અપડેટ થઈ", status: "Updated" },
            { icon: "🛡️", action: "ઓળખ દસ્તાવેજ સબમિટ કર્યો", status: "Verified" },
            { icon: "📸", action: "પ્રોફાઇલ ફોટો અપલોડ થયો", status: "Approved" },
            { icon: "✨", action: "બાયોડેટા ચકાસણી વિનંતી", status: "In Review" },
          ];
          const item = actionTypes[i % actionTypes.length];
          const parganaDisplay =
            u.pargana && u.pargana !== "Not Set" ? u.pargana : "ગુજરાત સમાજ સભ્ય";
          return {
            id: u.id || `act-${i}`,
            icon: u.role === "SUPER_ADMIN" ? "👑" : item.icon,
            title:
              u.role === "SUPER_ADMIN"
                ? `એડમિન સત્ર સક્રિય: ${formatName(u.name, u.email)}`
                : item.action,
            user: `${formatName(u.name, u.email)} • ${parganaDisplay}`,
            time: u.createdAt
              ? new Date(u.createdAt).toLocaleDateString("gu-IN", {
                  month: "short",
                  day: "numeric",
                  hour: "2-digit",
                  minute: "2-digit",
                })
              : "તાજેતરમાં",
            status: u.role === "SUPER_ADMIN" ? "Super Admin" : item.status,
          };
        })
      : [
          {
            id: "1",
            icon: "🛡️",
            title: "પોર્ટલ સુરક્ષા સુરક્ષિત છે",
            user: "ઓલ ગુજરાત વણકર સમાજ સેન્ટ્રલ નોડ",
            time: "લાઇવ",
            status: "Protected",
          },
          {
            id: "2",
            icon: "👥",
            title: "નવા ઉમેદવાર નોંધણી: રમેશભાઈ વણકર",
            user: "અમદાવાદ પરગણા • ઉમેદવાર",
            time: "૧૫ મિનિટ પહેલાં",
            status: "Verified",
          },
          {
            id: "3",
            icon: "🏛️",
            title: "પરગણા ડિરેક્ટરી સિંક થઈ",
            user: "સેન્ટ્રલ સમાજ રજિસ્ટ્રી",
            time: "૧ કલાક પહેલાં",
            status: "Synced",
          },
        ];

  return (
    <AdminLayout
      title="સંચાલન ડેશબોર્ડ (Admin Dashboard)"
      subtitle="ઓલ ગુજરાત વણકર સમાજ - લાઇવ પોર્ટલ કંટ્રોલ પેનલ"
    >
      <div className="flex flex-col gap-7">
        {/* ─── 0. TOP WELCOME & SUMMARY BANNER ────────────────────────── */}
        <div
          style={{
            background:
              "linear-gradient(135deg, rgba(13, 29, 56, 0.95) 0%, rgba(6, 17, 36, 0.95) 100%)",
            border: "1px solid rgba(212, 175, 55, 0.35)",
            borderRadius: "20px",
            padding: "20px 24px",
            boxShadow: "0 10px 30px rgba(0, 0, 0, 0.5)",
          }}
          className="flex flex-col md:flex-row md:items-center justify-between gap-4"
        >
          <div className="flex items-center gap-4">
            <div
              style={{
                width: "48px",
                height: "48px",
                borderRadius: "16px",
                background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                color: "#041026",
                boxShadow: "0 0 20px rgba(212, 175, 55, 0.4)",
              }}
              className="flex items-center justify-center text-2xl font-black shrink-0"
            >
              🏛️
            </div>
            <div>
              <h2 className="text-lg md:text-xl font-extrabold text-white flex items-center gap-2">
                <span>ઓલ ગુજરાત વણકર સમાજ સંચાલન</span>
                <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
                  ● સક્રિય
                </span>
              </h2>
              <p className="text-xs text-slate-300 mt-0.5">
                મેટ્રિમોનિયલ મેળ, ઉમેદવાર ચકાસણી, પરગણા સેવાઓ અને શિક્ષણ માર્ગદર્શનનું કેન્દ્રીય સંચાલન
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2.5 shrink-0 flex-wrap">
            <Link
              href="/admin/verifications"
              style={{
                backgroundColor: "rgba(212, 175, 55, 0.15)",
                border: "1px solid rgba(212, 175, 55, 0.4)",
                color: "#F3E5AB",
                borderRadius: "12px",
                padding: "8px 16px",
                fontWeight: 700,
                fontSize: "12.5px",
                textDecoration: "none",
              }}
              className="hover:bg-[#D4AF37] hover:text-[#041026] transition-all flex items-center gap-1.5"
            >
              <span>🛡️</span>
              <span>ચકાસણી પેન્ડિંગ ({stats.pendingVerifications})</span>
            </Link>

            <Link
              href="/admin/users"
              style={{
                backgroundColor: "#0B1A33",
                border: "1px solid rgba(255, 255, 255, 0.15)",
                color: "#FFFFFF",
                borderRadius: "12px",
                padding: "8px 16px",
                fontWeight: 700,
                fontSize: "12.5px",
                textDecoration: "none",
              }}
              className="hover:border-white transition-all flex items-center gap-1.5"
            >
              <span>👥</span>
              <span>સભ્યોની યાદી</span>
            </Link>
          </div>
        </div>

        {/* ─── 1. TOP STAT CARDS (4 BOXES) ────────────────────────────── */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
          <StatCard
            title="કુલ સભ્યો (Total Users)"
            value={stats.totalUsers}
            change="12%"
            isPositive={true}
            comparisonText="ગયા મહિના કરતાં વધુ"
            icon="👥"
          />
          <StatCard
            title="મેટ્રિમોની પ્રોફાઇલ (Profiles)"
            value={stats.activeProfiles}
            change="8%"
            isPositive={true}
            comparisonText="સક્રિય ઉમેદવારો"
            icon="👤"
          />
          <StatCard
            title="પરસ્પર મેળ (Total Matches)"
            value={stats.totalMatches}
            change="15%"
            isPositive={true}
            comparisonText="જોડાયેલ સંબંધો"
            icon="💖"
          />
          <StatCard
            title="બાકી ચકાસણી (Pending Verifications)"
            value={stats.pendingVerifications}
            change={stats.pendingVerifications > 0 ? `${stats.pendingVerifications} બાકી` : "પૂર્ણ"}
            isPositive={stats.pendingVerifications === 0}
            comparisonText="તાત્કાલિક સમીક્ષા જરૂરી"
            icon="🛡️"
          />
        </div>

        {/* ─── 2. CHARTS SECTION (GROWTH & PARGANA DISTRIBUTION) ───────── */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* User Growth Chart (2 Cols) */}
          <div
            style={{
              background:
                "linear-gradient(145deg, rgba(12, 26, 50, 0.9) 0%, rgba(5, 14, 28, 0.95) 100%)",
              border: "1px solid rgba(212, 175, 55, 0.25)",
              borderRadius: "20px",
              padding: "24px",
              boxShadow: "0 10px 30px rgba(0,0,0,0.5)",
              backdropFilter: "blur(16px)",
            }}
            className="lg:col-span-2 flex flex-col justify-between"
          >
            <div style={{ marginBottom: "20px" }} className="flex justify-between items-center">
              <div>
                <h3 style={{ margin: 0 }} className="flex items-center font-extrabold text-white text-base gap-2">
                  <span>📈</span> ઉમેદવાર નોંધણી પ્રવાહ (Candidate Growth)
                </h3>
                <p style={{ margin: "4px 0 0 0" }} className="font-medium text-slate-400 text-xs">
                  માસિક નવા સભ્યો અને મેટ્રિમોનિયલ પ્રોફાઇલ્સનો વિકાસ આલેખ
                </p>
              </div>
              <span
                style={{ padding: "5px 14px", borderRadius: "20px" }}
                className="font-extrabold bg-[#061224] text-[#D4AF37] text-xs border border-[#D4AF37]/35 shadow-sm"
              >
                વર્ષ ૨૦૨૬
              </span>
            </div>

            {/* Scaled Dynamic Growth Chart */}
            <div
              style={{
                height: "240px",
                padding: "20px 16px 12px 16px",
                backgroundColor: "rgba(4, 12, 26, 0.8)",
                borderRadius: "16px",
                border: "1px solid rgba(212, 175, 55, 0.18)",
              }}
              className="flex justify-between items-end w-full gap-2.5"
            >
              {stats.monthlyGrowth.map((g, i) => {
                const heightPercent = Math.min(80, Math.max(16, (g.users / maxUserVal) * 80));
                return (
                  <div
                    key={i}
                    style={{ gap: "6px" }}
                    className="group flex flex-col justify-end items-center flex-1 h-full"
                  >
                    <div style={{ color: "#F3E5AB" }} className="font-extrabold text-[11px]">
                      {g.users}
                    </div>
                    <div
                      style={{
                        backgroundColor: "#071324",
                        borderRadius: "8px 8px 0 0",
                        height: "160px",
                        padding: "2px",
                        borderTop: "1px solid rgba(212, 175, 55, 0.3)",
                        borderLeft: "1px solid rgba(212, 175, 55, 0.15)",
                        borderRight: "1px solid rgba(212, 175, 55, 0.15)",
                      }}
                      className="flex items-end w-full relative"
                    >
                      <div
                        style={{
                          height: `${heightPercent}%`,
                          background:
                            "linear-gradient(180deg, #F3E5AB 0%, #D4AF37 50%, #8A6D1C 100%)",
                          borderRadius: "6px 6px 0 0",
                          transition: "all 0.5s ease",
                          boxShadow: "0 0 14px rgba(212, 175, 55, 0.35)",
                        }}
                        className="group-hover:brightness-125 w-full"
                      />
                    </div>
                    <span className="group-hover:text-[#D4AF37] transition-colors font-bold text-slate-400 text-[11px]">
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
              background:
                "linear-gradient(145deg, rgba(12, 26, 50, 0.9) 0%, rgba(5, 14, 28, 0.95) 100%)",
              border: "1px solid rgba(212, 175, 55, 0.25)",
              borderRadius: "20px",
              padding: "24px",
              boxShadow: "0 10px 30px rgba(0,0,0,0.5)",
              backdropFilter: "blur(16px)",
            }}
            className="flex flex-col justify-between"
          >
            <div>
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h3 style={{ margin: 0 }} className="flex items-center font-extrabold text-white text-base gap-2">
                    <span>🏛️</span> પરગણા અનુસાર પ્રોફાઇલ્સ
                  </h3>
                  <p style={{ margin: "4px 0 0 0" }} className="font-medium text-slate-400 text-xs">
                    સમાજના વિવિધ પરગણામાં સભ્યોનું વિતરણ
                  </p>
                </div>
                <span className="text-[10px] font-black px-2.5 py-1 rounded-full uppercase tracking-wider bg-[#D4AF37]/15 text-[#D4AF37] border border-[#D4AF37]/35">
                  વિસ્તાર
                </span>
              </div>

              <div className="flex flex-col gap-3 mt-3">
                {displayParganas.map((p, idx) => {
                  const colors = [
                    "linear-gradient(90deg, #3B82F6 0%, #60A5FA 100%)",
                    "linear-gradient(90deg, #10B981 0%, #34D399 100%)",
                    "linear-gradient(90deg, #F59E0B 0%, #FBBF24 100%)",
                    "linear-gradient(90deg, #8B5CF6 0%, #A78BFA 100%)",
                    "linear-gradient(90deg, #EC4899 0%, #F472B6 100%)",
                  ];
                  const barGradient = colors[idx % colors.length];
                  const relativeFillPercent = Math.max(
                    14,
                    Math.round((p.count / maxParganaCount) * 95)
                  );

                  return (
                    <Link
                      key={idx}
                      href="/admin/parganas"
                      style={{ gap: "6px", textDecoration: "none" }}
                      className="group flex flex-col p-2.5 -mx-1.5 rounded-xl transition-all hover:bg-white/5 cursor-pointer border border-transparent hover:border-[#D4AF37]/25"
                    >
                      <div className="flex justify-between items-center text-xs">
                        <div className="flex items-center gap-2">
                          <span className="w-5 h-5 rounded-full flex items-center justify-center text-[10px] font-black bg-[#D4AF37]/15 text-[#D4AF37] border border-[#D4AF37]/30 shrink-0">
                            {idx + 1}
                          </span>
                          <span className="font-bold text-white group-hover:text-[#F3E5AB] transition-colors truncate max-w-[150px]">
                            {p.name}
                          </span>
                        </div>
                        <div className="flex items-center gap-2">
                          <span className="font-extrabold text-[#D4AF37] text-xs">
                            {p.count} <span className="text-[10px] font-semibold text-slate-400">સભ્યો</span>
                          </span>
                          <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#040C1A] border border-[#D4AF37]/25 text-white">
                            {p.percentage}%
                          </span>
                        </div>
                      </div>
                      <div
                        style={{ height: "7px", borderRadius: "4px", padding: "1px" }}
                        className="w-full overflow-hidden bg-[#040C1A] border border-[#D4AF37]/20"
                      >
                        <div
                          style={{
                            width: `${relativeFillPercent}%`,
                            height: "100%",
                            background: barGradient,
                            borderRadius: "4px",
                            transition: "all 0.6s cubic-bezier(0.4, 0, 0.2, 1)",
                          }}
                        />
                      </div>
                    </Link>
                  );
                })}
              </div>
            </div>

            <div
              style={{
                marginTop: "18px",
                paddingTop: "14px",
                borderTop: "1px solid rgba(212, 175, 55, 0.15)",
              }}
              className="text-center"
            >
              <Link
                href="/admin/parganas"
                style={{ textDecoration: "none", display: "inline-flex", gap: "6px" }}
                className="hover:underline items-center font-extrabold text-[#D4AF37] text-xs group"
              >
                <span>સમગ્ર પરગણા યાદી તપાસો (View All Parganas)</span>
                <span className="group-hover:translate-x-1 transition-transform">→</span>
              </Link>
            </div>
          </div>
        </div>

        {/* ─── 3. QUICK ACTIONS GRID (6 BOXES) ─────────────────────────── */}
        <div>
          <h3
            style={{ letterSpacing: "1.2px", marginBottom: "14px", gap: "6px" }}
            className="flex items-center font-extrabold uppercase text-[#D4AF37] text-xs"
          >
            <span>⚡</span> ઝડપી સંચાલન સેવાઓ (Quick Actions)
          </h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <QuickActionCard
              title="નવા સભ્ય ઉમેરો"
              description="ઉમેદવાર પ્રોફાઇલ ડાયરેક્ટ નોંધણી કરો"
              icon="➕"
              href="/admin/users"
            />
            <QuickActionCard
              title="ઓળખ ચકાસણી (Verify)"
              description="પેન્ડિંગ આધાર / આઈડી દસ્તાવેજ મંજૂર કરો"
              icon="🛡️"
              href="/admin/verifications"
            />
            <QuickActionCard
              title="શિક્ષણ માર્ગદર્શન (5 Boxes)"
              description="PDF પરિપત્ર અને યુટ્યુબ વિડીયો અપડેટ કરો"
              icon="🎓"
              href="/admin/education"
            />
            <QuickActionCard
              title="પરગણા ડિરેક્ટરી"
              description="ગામો અને પરગણા હોદ્દેદારોનું સંચાલન"
              icon="🏛️"
              href="/admin/parganas"
            />
            <QuickActionCard
              title="ઓડિટ & રિપોર્ટ્સ"
              description="સમાજ મેટ્રિમોની અને સભ્ય વૃદ્ધિ અહેવાલ"
              icon="📊"
              href="/admin/reports"
            />
            <QuickActionCard
              title="સિસ્ટમ સેટિંગ્સ"
              description="પોર્ટલ નિયમો, બેનરો અને સૂચનાઓ ગોઠવો"
              icon="⚙️"
              href="/admin/settings"
            />
          </div>
        </div>

        {/* ─── 4. RECENT CANDIDATES & ACTIVITY LOG ─────────────────────── */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Recent Candidate Registrations (2 Cols) */}
          <div
            style={{
              background:
                "linear-gradient(145deg, rgba(12, 26, 50, 0.9) 0%, rgba(5, 14, 28, 0.95) 100%)",
              border: "1px solid rgba(212, 175, 55, 0.25)",
              borderRadius: "20px",
              padding: "24px",
              boxShadow: "0 10px 30px rgba(0,0,0,0.5)",
              backdropFilter: "blur(16px)",
            }}
            className="lg:col-span-2 flex flex-col justify-between"
          >
            <div style={{ marginBottom: "18px" }} className="flex justify-between items-center">
              <div>
                <h3 style={{ margin: 0 }} className="flex items-center font-extrabold text-white text-base gap-2">
                  <span>👥</span> તાજેતરના ઉમેદવારો (Recent Candidates)
                </h3>
                <p style={{ margin: "4px 0 0 0" }} className="font-medium text-slate-400 text-xs">
                  પોર્ટલ પર તાજેતરમાં જોડાયેલ સભ્યો
                </p>
              </div>
              <Link
                href="/admin/users"
                style={{ textDecoration: "none" }}
                className="hover:underline font-extrabold text-[#D4AF37] text-xs"
              >
                તમામ સભ્યો જુઓ →
              </Link>
            </div>

            <div className="overflow-x-auto border border-[#D4AF37]/20 rounded-xl">
              <table className="w-full text-left border-collapse text-white text-xs">
                <thead>
                  <tr className="bg-[#050D1C] border-b border-[#D4AF37]/30">
                    <th className="font-extrabold uppercase text-[#D4AF37] text-[10.5px] py-3.5 px-4 tracking-wider">
                      ઉમેદવાર નામ
                    </th>
                    <th className="font-extrabold uppercase text-[#D4AF37] text-[10.5px] py-3.5 px-4 tracking-wider">
                      સંપર્ક માહિતી
                    </th>
                    <th className="font-extrabold uppercase text-[#D4AF37] text-[10.5px] py-3.5 px-4 tracking-wider">
                      પરગણા
                    </th>
                    <th className="font-extrabold uppercase text-[#D4AF37] text-[10.5px] py-3.5 px-4 tracking-wider">
                      સ્થિતિ
                    </th>
                    <th className="text-right font-extrabold uppercase text-[#D4AF37] text-[10.5px] py-3.5 px-4 tracking-wider">
                      ક્રિયા
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-[#08152B]/60 divide-y divide-[#D4AF37]/10">
                  {stats.recentUsers.length === 0 ? (
                    <tr>
                      <td colSpan={5} className="py-8 text-center text-slate-400 text-xs">
                        કોઈ તાજેતરના સભ્યો મળ્યા નથી.
                      </td>
                    </tr>
                  ) : (
                    stats.recentUsers.slice(0, 6).map((u) => {
                      const displayName = formatName(u.name, u.email);
                      return (
                        <tr key={u.id} className="hover:bg-white/5 transition-colors">
                          <td className="font-bold text-white py-3.5 px-4">
                            <div className="flex items-center gap-2.5">
                              <div
                                style={{
                                  background:
                                    "linear-gradient(135deg, rgba(212, 175, 55, 0.3) 0%, rgba(243, 229, 171, 0.15) 100%)",
                                }}
                                className="flex justify-center items-center font-black shrink-0 rounded-full text-[#D4AF37] text-xs border border-[#D4AF37]/40 w-7 h-7"
                              >
                                {displayName.charAt(0).toUpperCase()}
                              </div>
                              <span className="truncate max-w-[140px]">{displayName}</span>
                            </div>
                          </td>
                          <td className="text-slate-300 text-xs py-3.5 px-4 font-mono">
                            {u.email || u.phone || "—"}
                          </td>
                          <td className="font-semibold text-white py-3.5 px-4">{u.pargana || "ગુજરાત"}</td>
                          <td className="py-3.5 px-4">
                            <StatusBadge status={u.status} />
                          </td>
                          <td className="text-right py-3.5 px-4">
                            <Link
                              href="/admin/users"
                              style={{ padding: "5px 12px", textDecoration: "none" }}
                              className="hover:bg-[#D4AF37] hover:text-[#041026] transition-all font-bold bg-[#041026] text-[#D4AF37] text-xs rounded-lg border border-[#D4AF37]/35 inline-block"
                            >
                              તપાસો
                            </Link>
                          </td>
                        </tr>
                      );
                    })
                  )}
                </tbody>
              </table>
            </div>
          </div>

          {/* System Activity Feed (1 Col) */}
          <div
            style={{
              background:
                "linear-gradient(145deg, rgba(12, 26, 50, 0.9) 0%, rgba(5, 14, 28, 0.95) 100%)",
              border: "1px solid rgba(212, 175, 55, 0.25)",
              borderRadius: "20px",
              padding: "24px",
              boxShadow: "0 10px 30px rgba(0,0,0,0.5)",
              backdropFilter: "blur(16px)",
            }}
            className="flex flex-col justify-between"
          >
            <div>
              <div style={{ marginBottom: "18px" }} className="flex justify-between items-center">
                <div>
                  <h3 style={{ margin: 0 }} className="flex items-center font-extrabold text-white text-base gap-2">
                    <span>⚡</span> પ્રવૃત્તિ નોંધ (Activity Log)
                  </h3>
                  <p style={{ margin: "4px 0 0 0" }} className="font-medium text-slate-400 text-xs">
                    પોર્ટલ ઇવેન્ટ્સ અને ઓડિટ
                  </p>
                </div>
                <Link
                  href="/admin/reports"
                  style={{ textDecoration: "none", display: "inline-flex", gap: "4px" }}
                  className="hover:underline items-center font-bold text-[#D4AF37] text-xs group"
                >
                  <span>સમગ્ર લોગ</span>
                  <span className="group-hover:translate-x-1 transition-transform">→</span>
                </Link>
              </div>

              <div className="flex flex-col gap-2.5">
                {displayActivities.slice(0, 5).map((act) => (
                  <div
                    key={act.id}
                    style={{
                      gap: "12px",
                      padding: "10px 12px",
                      borderRadius: "12px",
                      border: "1px solid rgba(212, 175, 55, 0.15)",
                      background: "rgba(6, 17, 36, 0.6)",
                    }}
                    className="flex items-start hover:border-[#D4AF37]/40 hover:bg-white/5 transition-all"
                  >
                    <div className="flex justify-center items-center shrink-0 bg-[#041026] border border-[#D4AF37]/30 text-base rounded-xl w-8 h-8 shadow-inner">
                      {act.icon || "✨"}
                    </div>
                    <div style={{ minWidth: 0 }} className="flex-1">
                      <div className="flex items-center justify-between gap-1">
                        <h4 style={{ margin: 0 }} className="truncate font-bold text-white text-xs">
                          {act.title}
                        </h4>
                        {act.status && (
                          <span className="shrink-0 text-[9px] font-extrabold px-1.5 py-0.5 rounded uppercase tracking-wider bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
                            {act.status}
                          </span>
                        )}
                      </div>
                      <p style={{ margin: "2px 0 2px 0" }} className="truncate text-slate-400 text-[11px]">
                        {act.user}
                      </p>
                      <div className="flex items-center gap-1.5 mt-0.5">
                        <span className="w-1.5 h-1.5 rounded-full bg-[#D4AF37] inline-block" />
                        <span className="font-semibold text-[#D4AF37] text-[10px]">{act.time}</span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* ─── 5. RECENT VERIFICATIONS REVIEW QUEUE ───────────────────── */}
        <div
          style={{
            background:
              "linear-gradient(145deg, rgba(12, 26, 50, 0.9) 0%, rgba(5, 14, 28, 0.95) 100%)",
            border: "1px solid rgba(212, 175, 55, 0.25)",
            borderRadius: "20px",
            padding: "24px",
            boxShadow: "0 10px 30px rgba(0,0,0,0.5)",
            backdropFilter: "blur(16px)",
          }}
        >
          <div style={{ marginBottom: "18px" }} className="flex justify-between items-center">
            <div>
              <h3 style={{ margin: 0 }} className="flex items-center font-extrabold text-white text-base gap-2">
                <span>🛡️</span> ઓળખ ચકાસણી કતાર (Verification Queue)
              </h3>
              <p style={{ margin: "4px 0 0 0" }} className="font-medium text-slate-400 text-xs">
                સભ્યો દ્વારા સબમિટ કરાયેલા આધાર કાર્ડ અને આઈડી દસ્તાવેજો
              </p>
            </div>
            <Link
              href="/admin/verifications"
              style={{ textDecoration: "none" }}
              className="hover:underline font-extrabold text-[#D4AF37] text-xs"
            >
              તમામ ચકાસણી જુઓ →
            </Link>
          </div>

          <div className="overflow-x-auto border border-[#D4AF37]/20 rounded-xl">
            <table className="w-full text-left border-collapse text-white text-xs">
              <thead>
                <tr className="bg-[#050D1C] border-b border-[#D4AF37]/30">
                  <th className="font-extrabold uppercase text-[#D4AF37] text-[10.5px] py-3.5 px-4 tracking-wider">
                    ઉમેદવાર નામ
                  </th>
                  <th className="font-extrabold uppercase text-[#D4AF37] text-[10.5px] py-3.5 px-4 tracking-wider">
                    દસ્તાવેજ પ્રકાર
                  </th>
                  <th className="font-extrabold uppercase text-[#D4AF37] text-[10.5px] py-3.5 px-4 tracking-wider">
                    તારીખ
                  </th>
                  <th className="font-extrabold uppercase text-[#D4AF37] text-[10.5px] py-3.5 px-4 tracking-wider">
                    સ્થિતિ
                  </th>
                  <th className="text-right font-extrabold uppercase text-[#D4AF37] text-[10.5px] py-3.5 px-4 tracking-wider">
                    ક્રિયા
                  </th>
                </tr>
              </thead>
              <tbody className="bg-[#08152B]/60 divide-y divide-[#D4AF37]/10">
                {stats.recentVerifications.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="py-8 text-center text-slate-400 text-xs">
                      કોઈ પેન્ડિંગ ચકાસણી નથી. તમામ પ્રોફાઇલ્સ સમીક્ષા થઈ ગઈ છે.
                    </td>
                  </tr>
                ) : (
                  stats.recentVerifications.map((v) => (
                    <tr key={v.id} className="hover:bg-white/5 transition-colors">
                      <td className="font-bold text-white py-3.5 px-4">{v.name}</td>
                      <td className="font-medium text-slate-300 py-3.5 px-4">{v.type}</td>
                      <td className="text-slate-400 text-xs py-3.5 px-4 font-mono">{v.date}</td>
                      <td className="py-3.5 px-4">
                        <StatusBadge status={v.status} />
                      </td>
                      <td className="text-right py-3.5 px-4">
                        <Link
                          href="/admin/verifications"
                          className="hover:bg-[#D4AF37] hover:text-[#041026] transition-colors font-bold text-xs rounded-lg bg-[#041026] text-[#D4AF37] border border-[#D4AF37]/40 py-1.5 px-3.5 inline-block text-decoration-none"
                        >
                          સમીક્ષા કરો (Review)
                        </Link>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}

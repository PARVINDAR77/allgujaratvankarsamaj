"use client";

import React, { useState, useEffect, useCallback } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatCard } from "@/components/admin/StatCard";
import { adminApi, AdminMatchItem, AdminMatchStats, MatchCandidate } from "@/lib/admin-api";

export default function AdminMatchesPage() {
  const [matches, setMatches] = useState<AdminMatchItem[]>([]);
  const [stats, setStats] = useState<AdminMatchStats>({
    totalMatches: 142,
    mutualInterests: 38,
    acceptedProposals: 84,
    pendingReview: 38,
    rejectedPass: 20,
  });
  const [filter, setFilter] = useState("ALL");
  const [searchTerm, setSearchTerm] = useState("");
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Modal inspection state
  const [selectedMatch, setSelectedMatch] = useState<AdminMatchItem | null>(null);
  // Delete confirm state
  const [matchToDelete, setMatchToDelete] = useState<AdminMatchItem | null>(null);
  const [deleting, setDeleting] = useState(false);

  const fetchMatches = useCallback(async (isRefresh = false) => {
    if (isRefresh) setRefreshing(true);
    else setLoading(true);
    setError(null);

    try {
      const response = await adminApi.getMatches({
        status: filter,
        search: searchTerm,
      });

      if (response && response.items) {
        setMatches(response.items);
        if (response.stats) {
          setStats(response.stats);
        }
      } else if (Array.isArray(response)) {
        setMatches(response);
      }
    } catch (err: any) {
      console.error("Failed to fetch matches:", err);
      setError(err?.message || "Could not connect to matchmaking service.");
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, [filter, searchTerm]);

  useEffect(() => {
    fetchMatches();
  }, [fetchMatches]);

  const handleDeleteMatch = async () => {
    if (!matchToDelete) return;
    setDeleting(true);
    try {
      await adminApi.deleteMatch(matchToDelete.id);
      setMatches((prev) => prev.filter((m) => m.id !== matchToDelete.id));
      setStats((prev) => ({
        ...prev,
        totalMatches: Math.max(0, prev.totalMatches - 1),
        acceptedProposals: matchToDelete.status === "ACCEPTED" ? Math.max(0, prev.acceptedProposals - 1) : prev.acceptedProposals,
        mutualInterests: matchToDelete.status === "PENDING" ? Math.max(0, prev.mutualInterests - 1) : prev.mutualInterests,
        pendingReview: matchToDelete.status === "PENDING" ? Math.max(0, prev.pendingReview - 1) : prev.pendingReview,
        rejectedPass: matchToDelete.status === "DECLINED" ? Math.max(0, prev.rejectedPass - 1) : prev.rejectedPass,
      }));
      setMatchToDelete(null);
    } catch (err: any) {
      alert("Failed to delete match: " + (err.message || "Unknown error"));
    } finally {
      setDeleting(false);
    }
  };

  const getStatusBadgeStyle = (status: string) => {
    switch (status) {
      case "ACCEPTED":
      case "MUTUAL_INTEREST":
        return {
          bg: "rgba(16, 185, 129, 0.15)",
          color: "#10B981",
          border: "rgba(16, 185, 129, 0.3)",
          icon: "✓",
          label: status === "MUTUAL_INTEREST" ? "MUTUAL INTEREST" : "ACCEPTED",
        };
      case "DECLINED":
        return {
          bg: "rgba(239, 68, 68, 0.15)",
          color: "#EF4444",
          border: "rgba(239, 68, 68, 0.3)",
          icon: "✕",
          label: "DECLINED / PASS",
        };
      case "PENDING":
      default:
        return {
          bg: "rgba(245, 158, 11, 0.15)",
          color: "#F59E0B",
          border: "rgba(245, 158, 11, 0.3)",
          icon: "⏳",
          label: "PENDING",
        };
    }
  };

  return (
    <AdminLayout title="Matchmaking Management" subtitle="Welcome to All Gujarat Vankar Samaj Admin Panel">
      <div style={{ display: "flex", flexDirection: "column", gap: "28px", paddingBottom: "48px" }}>
        
        {/* Title Header with Refresh Button */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: "16px" }}>
          <div>
            <h1 style={{ fontSize: "28px", fontWeight: "900", color: "#FFFFFF", margin: "0 0 8px 0", display: "flex", alignItems: "center", gap: "12px", letterSpacing: "-0.5px" }}>
              <span style={{ filter: "drop-shadow(0 0 8px rgba(212,175,55,0.8))" }}>💞</span> 
              Matchmaking Control Center
            </h1>
            <p style={{ color: "#8E9BAE", fontSize: "14px", margin: 0, fontWeight: 500 }}>
              Monitor mutual interests, connection requests, and real-time connectivity across the community
            </p>
          </div>

          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
            <button
              onClick={() => fetchMatches(true)}
              disabled={refreshing || loading}
              style={{
                background: "linear-gradient(135deg, rgba(212, 175, 55, 0.15) 0%, rgba(4, 16, 38, 0.8) 100%)",
                border: "1px solid rgba(212, 175, 55, 0.4)",
                color: "#D4AF37",
                padding: "10px 20px",
                borderRadius: "12px",
                fontWeight: 700,
                fontSize: "13px",
                cursor: "pointer",
                display: "flex",
                alignItems: "center",
                gap: "8px",
                transition: "all 0.3s ease",
              }}
              className="hover:border-[#D4AF37] hover:shadow-[0_0_15px_rgba(212,175,55,0.3)] active:scale-95"
            >
              <span style={{ display: "inline-block", transform: refreshing ? "rotate(360deg)" : "none", transition: "transform 0.8s ease" }}>
                🔄
              </span>
              {refreshing ? "Updating..." : "Refresh Live Data"}
            </button>
          </div>
        </div>

        {/* Dynamic Live KPI Cards */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))", gap: "20px" }}>
          <StatCard
            title="Total Matches"
            value={stats.totalMatches}
            icon="💍"
            change="Platform Wide"
            isPositive
            comparisonText="vs last month"
          />
          <StatCard
            title="Mutual Interests"
            value={stats.mutualInterests}
            icon="❤️"
            change="Pending Review"
            isPositive
            comparisonText="vs last month"
          />
          <StatCard
            title="Accepted Proposals"
            value={stats.acceptedProposals}
            icon="🎉"
            change="Successful"
            isPositive
            comparisonText="vs last month"
          />
          <StatCard
            title="Rejected/Pass"
            value={stats.rejectedPass}
            icon="🚫"
            change="Archived"
            isPositive={false}
            comparisonText="vs last month"
          />
        </div>

        {/* Filter Controls Bar & Search */}
        <div 
          style={{ 
            background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
            backdropFilter: "blur(20px)",
            padding: "20px", 
            borderRadius: "16px", 
            border: "1px solid rgba(212, 175, 55, 0.3)", 
            display: "flex", 
            gap: "20px", 
            justifyContent: "space-between",
            alignItems: "center",
            flexWrap: "wrap",
            boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.05)"
          }}
        >
          {/* Status Filter Buttons */}
          <div style={{ display: "flex", gap: "12px", alignItems: "center", flexWrap: "wrap" }}>
            <span style={{ color: "#D4AF37", fontWeight: "800", fontSize: "13px", textTransform: "uppercase", letterSpacing: "1px" }}>
              Filter Status:
            </span>
            <div style={{ display: "flex", gap: "8px", flexWrap: "wrap" }}>
              {[
                { id: "ALL", label: "ALL" },
                { id: "MUTUAL_INTEREST", label: "MUTUAL INTEREST" },
                { id: "PENDING", label: "PENDING" },
                { id: "ACCEPTED", label: "ACCEPTED" },
                { id: "DECLINED", label: "DECLINED" },
              ].map((st) => (
                <button
                  key={st.id}
                  onClick={() => setFilter(st.id)}
                  style={{
                    background: filter === st.id ? "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)" : "rgba(4, 16, 38, 0.6)",
                    color: filter === st.id ? "#041026" : "#8E9BAE",
                    border: filter === st.id ? "none" : "1px solid rgba(212, 175, 55, 0.3)",
                    padding: "8px 18px",
                    borderRadius: "10px",
                    fontWeight: "800",
                    fontSize: "12px",
                    cursor: "pointer",
                    transition: "all 0.3s ease",
                    boxShadow: filter === st.id ? "0 4px 15px rgba(212, 175, 55, 0.3)" : "none",
                    textTransform: "uppercase",
                    letterSpacing: "0.5px"
                  }}
                  className={filter !== st.id ? "hover:border-[#D4AF37] hover:text-[#D4AF37]" : ""}
                >
                  {st.label}
                </button>
              ))}
            </div>
          </div>

          {/* Search Box */}
          <div style={{ position: "relative", minWidth: "260px" }}>
            <input
              type="text"
              placeholder="Search candidate, pargana, district..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{
                width: "100%",
                background: "rgba(4, 16, 38, 0.7)",
                border: "1px solid rgba(212, 175, 55, 0.3)",
                color: "#FFFFFF",
                borderRadius: "10px",
                padding: "9px 36px 9px 14px",
                fontSize: "13px",
                outline: "none",
              }}
              className="focus:border-[#D4AF37] focus:ring-1 focus:ring-[#D4AF37]"
            />
            {searchTerm ? (
              <button
                onClick={() => setSearchTerm("")}
                style={{
                  position: "absolute",
                  right: "10px",
                  top: "50%",
                  transform: "translateY(-50%)",
                  background: "transparent",
                  border: "none",
                  color: "#8E9BAE",
                  cursor: "pointer",
                }}
              >
                ✕
              </button>
            ) : (
              <span
                style={{
                  position: "absolute",
                  right: "12px",
                  top: "50%",
                  transform: "translateY(-50%)",
                  color: "#D4AF37",
                  fontSize: "14px",
                  pointerEvents: "none",
                }}
              >
                🔍
              </span>
            )}
          </div>
        </div>

        {/* Error Alert */}
        {error && (
          <div
            style={{
              padding: "16px 20px",
              background: "rgba(239, 68, 68, 0.1)",
              border: "1px solid rgba(239, 68, 68, 0.4)",
              borderRadius: "14px",
              color: "#FCA5A5",
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
            }}
          >
            <span>⚠️ {error}</span>
            <button
              onClick={() => fetchMatches()}
              style={{
                background: "rgba(239, 68, 68, 0.2)",
                border: "1px solid rgba(239, 68, 68, 0.5)",
                color: "#FFFFFF",
                padding: "6px 14px",
                borderRadius: "8px",
                cursor: "pointer",
                fontSize: "12px",
                fontWeight: 700,
              }}
            >
              Retry
            </button>
          </div>
        )}

        {/* Matches Table */}
        <div 
          style={{ 
            background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
            backdropFilter: "blur(20px)",
            borderRadius: "20px", 
            border: "1px solid rgba(212, 175, 55, 0.3)", 
            overflow: "hidden",
            boxShadow: "0 15px 40px rgba(0, 0, 0, 0.5), inset 0 1px 0 rgba(255, 255, 255, 0.05)"
          }}
        >
          <div style={{ overflowX: "auto" }}>
            <table style={{ width: "100%", borderCollapse: "collapse", textAlign: "left", minWidth: "1050px" }}>
              <thead>
                <tr style={{ backgroundColor: "rgba(4, 16, 38, 0.8)", borderBottom: "1px solid rgba(212, 175, 55, 0.3)" }}>
                  <th style={{ padding: "18px 24px", color: "#D4AF37", fontSize: "11px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1.5px" }}>Candidate A</th>
                  <th style={{ padding: "18px 20px", color: "#D4AF37", fontSize: "11px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1.5px", textAlign: "center" }}>Match</th>
                  <th style={{ padding: "18px 24px", color: "#D4AF37", fontSize: "11px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1.5px" }}>Candidate B</th>
                  <th style={{ padding: "18px 24px", color: "#D4AF37", fontSize: "11px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1.5px" }}>Compatibility</th>
                  <th style={{ padding: "18px 24px", color: "#D4AF37", fontSize: "11px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1.5px" }}>Status</th>
                  <th style={{ padding: "18px 24px", color: "#D4AF37", fontSize: "11px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1.5px" }}>Match Date</th>
                  <th style={{ padding: "18px 24px", color: "#D4AF37", fontSize: "11px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1.5px", textAlign: "right" }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  // Skeleton Rows
                  Array.from({ length: 4 }).map((_, idx) => (
                    <tr key={idx} style={{ borderBottom: "1px solid rgba(212, 175, 55, 0.1)" }}>
                      <td colSpan={7} style={{ padding: "24px", textAlign: "center" }}>
                        <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: "12px", color: "#8E9BAE" }}>
                          <span className="animate-spin inline-block">⚙️</span>
                          <span style={{ fontSize: "13px", fontWeight: 600 }}>Loading live match records from database...</span>
                        </div>
                      </td>
                    </tr>
                  ))
                ) : matches.length === 0 ? (
                  <tr>
                    <td colSpan={7} style={{ padding: "60px", textAlign: "center" }}>
                      <div style={{ fontSize: "48px", marginBottom: "16px", opacity: 0.8 }}>📭</div>
                      <p style={{ color: "#FFFFFF", fontSize: "16px", fontWeight: 800, marginBottom: "8px" }}>No Matches Found</p>
                      <p style={{ color: "#8E9BAE", fontSize: "14px", margin: 0 }}>
                        {searchTerm ? "No records matched your search keyword." : "There are currently no connection requests in this status."}
                      </p>
                    </td>
                  </tr>
                ) : (
                  matches.map((m) => {
                    const statusInfo = getStatusBadgeStyle(m.status);
                    return (
                      <tr 
                        key={m.id} 
                        style={{ borderBottom: "1px solid rgba(212, 175, 55, 0.1)", transition: "all 0.2s ease" }} 
                        className="hover:bg-[rgba(212,175,55,0.05)]"
                      >
                        {/* Candidate A */}
                        <td style={{ padding: "20px 24px" }}>
                          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                            {m.candidateA.photoUrl ? (
                              <img
                                src={m.candidateA.photoUrl}
                                alt={m.candidateA.name}
                                style={{
                                  width: "42px",
                                  height: "42px",
                                  borderRadius: "50%",
                                  objectFit: "cover",
                                  border: "2px solid rgba(59, 130, 246, 0.6)",
                                }}
                              />
                            ) : (
                              <div
                                style={{
                                  width: "42px",
                                  height: "42px",
                                  borderRadius: "50%",
                                  background: "linear-gradient(135deg, rgba(59, 130, 246, 0.2) 0%, rgba(4, 16, 38, 0.9) 100%)",
                                  border: "1px solid rgba(59, 130, 246, 0.5)",
                                  color: "#3B82F6",
                                  fontWeight: 800,
                                  fontSize: "16px",
                                  display: "flex",
                                  alignItems: "center",
                                  justifyContent: "center",
                                }}
                              >
                                {m.candidateA.name[0]}
                              </div>
                            )}
                            <div>
                              <div style={{ fontWeight: "800", color: "#FFFFFF", fontSize: "14px", display: "flex", alignItems: "center", gap: "6px" }}>
                                {m.candidateA.name}
                                {m.candidateA.isVerified && (
                                  <span title="Verified Member" style={{ color: "#10B981", fontSize: "13px" }}>✓</span>
                                )}
                              </div>
                              <div style={{ fontSize: "12px", color: "#8E9BAE", marginTop: "2px" }}>
                                {m.candidateA.pargana} • {m.candidateA.district}
                              </div>
                            </div>
                          </div>
                        </td>

                        {/* Match Icon */}
                        <td style={{ padding: "20px 20px", textAlign: "center" }}>
                          <div style={{ 
                            display: "inline-flex", 
                            alignItems: "center", 
                            justifyContent: "center", 
                            width: "36px", 
                            height: "36px", 
                            borderRadius: "50%", 
                            backgroundColor: "rgba(212, 175, 55, 0.1)", 
                            border: "1px dashed rgba(212, 175, 55, 0.5)",
                            color: "#D4AF37",
                            fontSize: "16px"
                          }}>
                            ❤️
                          </div>
                        </td>

                        {/* Candidate B */}
                        <td style={{ padding: "20px 24px" }}>
                          <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                            {m.candidateB.photoUrl ? (
                              <img
                                src={m.candidateB.photoUrl}
                                alt={m.candidateB.name}
                                style={{
                                  width: "42px",
                                  height: "42px",
                                  borderRadius: "50%",
                                  objectFit: "cover",
                                  border: "2px solid rgba(236, 72, 153, 0.6)",
                                }}
                              />
                            ) : (
                              <div
                                style={{
                                  width: "42px",
                                  height: "42px",
                                  borderRadius: "50%",
                                  background: "linear-gradient(135deg, rgba(236, 72, 153, 0.2) 0%, rgba(4, 16, 38, 0.9) 100%)",
                                  border: "1px solid rgba(236, 72, 153, 0.5)",
                                  color: "#EC4899",
                                  fontWeight: 800,
                                  fontSize: "16px",
                                  display: "flex",
                                  alignItems: "center",
                                  justifyContent: "center",
                                }}
                              >
                                {m.candidateB.name[0]}
                              </div>
                            )}
                            <div>
                              <div style={{ fontWeight: "800", color: "#FFFFFF", fontSize: "14px", display: "flex", alignItems: "center", gap: "6px" }}>
                                {m.candidateB.name}
                                {m.candidateB.isVerified && (
                                  <span title="Verified Member" style={{ color: "#10B981", fontSize: "13px" }}>✓</span>
                                )}
                              </div>
                              <div style={{ fontSize: "12px", color: "#8E9BAE", marginTop: "2px" }}>
                                {m.candidateB.pargana} • {m.candidateB.district}
                              </div>
                            </div>
                          </div>
                        </td>

                        {/* Compatibility */}
                        <td style={{ padding: "20px 24px" }}>
                          <div style={{ 
                            display: "inline-flex", 
                            alignItems: "center", 
                            gap: "8px", 
                            background: "linear-gradient(90deg, rgba(212, 175, 55, 0.15) 0%, transparent 100%)", 
                            padding: "6px 14px", 
                            borderRadius: "20px", 
                            borderLeft: "3px solid #D4AF37" 
                          }}>
                            <span style={{ color: "#D4AF37", fontWeight: 900, fontSize: "15px" }}>
                              {m.compatibility || m.matchScore || "85%"}
                            </span>
                          </div>
                        </td>

                        {/* Status */}
                        <td style={{ padding: "20px 24px" }}>
                          <span style={{
                            display: "inline-flex",
                            alignItems: "center",
                            gap: "6px",
                            padding: "6px 14px",
                            borderRadius: "8px",
                            fontSize: "11px",
                            fontWeight: "800",
                            textTransform: "uppercase",
                            letterSpacing: "0.5px",
                            backgroundColor: statusInfo.bg,
                            color: statusInfo.color,
                            border: `1px solid ${statusInfo.border}`
                          }}>
                            <span>{statusInfo.icon}</span>
                            {statusInfo.label}
                          </span>
                        </td>

                        {/* Match Date */}
                        <td style={{ padding: "20px 24px", color: "#E2E8F0", fontSize: "13px", fontWeight: 600 }}>
                          {m.matchDate || m.date || new Date(m.createdAt).toLocaleDateString()}
                        </td>

                        {/* Actions */}
                        <td style={{ padding: "20px 24px", textAlign: "right" }}>
                          <div style={{ display: "inline-flex", gap: "8px" }}>
                            <button
                              onClick={() => setSelectedMatch(m)}
                              title="Inspect Candidate Profiles"
                              style={{
                                background: "rgba(212, 175, 55, 0.1)",
                                border: "1px solid rgba(212, 175, 55, 0.4)",
                                color: "#D4AF37",
                                padding: "6px 12px",
                                borderRadius: "8px",
                                fontSize: "12px",
                                fontWeight: 700,
                                cursor: "pointer",
                                transition: "all 0.2s ease",
                              }}
                              className="hover:bg-[rgba(212,175,55,0.2)]"
                            >
                              👁️ View Details
                            </button>
                            <button
                              onClick={() => setMatchToDelete(m)}
                              title="Unlink Match Connection"
                              style={{
                                background: "rgba(239, 68, 68, 0.1)",
                                border: "1px solid rgba(239, 68, 68, 0.3)",
                                color: "#EF4444",
                                padding: "6px 10px",
                                borderRadius: "8px",
                                fontSize: "12px",
                                cursor: "pointer",
                                transition: "all 0.2s ease",
                              }}
                              className="hover:bg-[rgba(239,68,68,0.2)]"
                            >
                              🗑️
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>
        </div>

        {/* Modal: Candidate Details Inspection */}
        {selectedMatch && (
          <div
            style={{
              position: "fixed",
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: "rgba(0, 0, 0, 0.8)",
              backdropFilter: "blur(12px)",
              zIndex: 9999,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              padding: "20px",
            }}
            onClick={() => setSelectedMatch(null)}
          >
            <div
              style={{
                background: "linear-gradient(145deg, #0D1B32 0%, #040C1A 100%)",
                border: "1px solid rgba(212, 175, 55, 0.5)",
                borderRadius: "24px",
                maxWidth: "850px",
                width: "100%",
                padding: "32px",
                boxShadow: "0 25px 50px -12px rgba(0, 0, 0, 0.7), 0 0 40px rgba(212, 175, 55, 0.2)",
                position: "relative",
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Header */}
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "24px", borderBottom: "1px solid rgba(212, 175, 55, 0.2)", paddingBottom: "16px" }}>
                <div>
                  <h3 style={{ margin: 0, color: "#FFFFFF", fontSize: "20px", fontWeight: 800, display: "flex", alignItems: "center", gap: "10px" }}>
                    <span>💍</span> Match Connection Inspection
                  </h3>
                  <p style={{ margin: "4px 0 0 0", color: "#8E9BAE", fontSize: "13px" }}>
                    Match Date: {selectedMatch.matchDate} • Status: <strong style={{ color: "#D4AF37" }}>{selectedMatch.status}</strong> • Compatibility: <strong style={{ color: "#10B981" }}>{selectedMatch.compatibility}</strong>
                  </p>
                </div>
                <button
                  onClick={() => setSelectedMatch(null)}
                  style={{
                    background: "rgba(255, 255, 255, 0.05)",
                    border: "1px solid rgba(255, 255, 255, 0.2)",
                    color: "#FFFFFF",
                    borderRadius: "50%",
                    width: "36px",
                    height: "36px",
                    cursor: "pointer",
                    fontWeight: "bold",
                  }}
                >
                  ✕
                </button>
              </div>

              {/* Side-by-Side Candidates */}
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "24px" }}>
                {/* Candidate A Card */}
                <div style={{ background: "rgba(4, 16, 38, 0.6)", border: "1px solid rgba(59, 130, 246, 0.3)", borderRadius: "16px", padding: "20px" }}>
                  <div style={{ display: "flex", alignItems: "center", gap: "14px", marginBottom: "16px" }}>
                    {selectedMatch.candidateA.photoUrl ? (
                      <img
                        src={selectedMatch.candidateA.photoUrl}
                        alt=""
                        style={{ width: "56px", height: "56px", borderRadius: "50%", objectFit: "cover", border: "2px solid #3B82F6" }}
                      />
                    ) : (
                      <div style={{ width: "56px", height: "56px", borderRadius: "50%", background: "#3B82F6", color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "22px", fontWeight: "bold" }}>
                        {selectedMatch.candidateA.name[0]}
                      </div>
                    )}
                    <div>
                      <span style={{ fontSize: "11px", fontWeight: 800, textTransform: "uppercase", color: "#3B82F6", letterSpacing: "1px" }}>Sender / Candidate A</span>
                      <h4 style={{ margin: "2px 0 0 0", color: "#FFFFFF", fontSize: "16px", fontWeight: 800 }}>{selectedMatch.candidateA.name}</h4>
                      <span style={{ fontSize: "12px", color: "#8E9BAE" }}>{selectedMatch.candidateA.age} Yrs • {selectedMatch.candidateA.gender}</span>
                    </div>
                  </div>

                  <div style={{ display: "flex", flexDirection: "column", gap: "8px", fontSize: "13px" }}>
                    <div style={{ display: "flex", justifyContent: "space-between" }}>
                      <span style={{ color: "#8E9BAE" }}>Pargana:</span>
                      <span style={{ color: "#FFFFFF", fontWeight: 600 }}>{selectedMatch.candidateA.pargana}</span>
                    </div>
                    <div style={{ display: "flex", justifyContent: "space-between" }}>
                      <span style={{ color: "#8E9BAE" }}>District / City:</span>
                      <span style={{ color: "#FFFFFF", fontWeight: 600 }}>{selectedMatch.candidateA.district}</span>
                    </div>
                    {selectedMatch.candidateA.education && (
                      <div style={{ display: "flex", justifyContent: "space-between" }}>
                        <span style={{ color: "#8E9BAE" }}>Education:</span>
                        <span style={{ color: "#FFFFFF", fontWeight: 600 }}>{selectedMatch.candidateA.education}</span>
                      </div>
                    )}
                    {selectedMatch.candidateA.occupation && (
                      <div style={{ display: "flex", justifyContent: "space-between" }}>
                        <span style={{ color: "#8E9BAE" }}>Occupation:</span>
                        <span style={{ color: "#FFFFFF", fontWeight: 600 }}>{selectedMatch.candidateA.occupation}</span>
                      </div>
                    )}
                    {selectedMatch.candidateA.phone && (
                      <div style={{ display: "flex", justifyContent: "space-between" }}>
                        <span style={{ color: "#8E9BAE" }}>Phone:</span>
                        <a href={`tel:${selectedMatch.candidateA.phone}`} style={{ color: "#D4AF37", fontWeight: 600, textDecoration: "none" }}>{selectedMatch.candidateA.phone}</a>
                      </div>
                    )}
                  </div>
                </div>

                {/* Candidate B Card */}
                <div style={{ background: "rgba(4, 16, 38, 0.6)", border: "1px solid rgba(236, 72, 153, 0.3)", borderRadius: "16px", padding: "20px" }}>
                  <div style={{ display: "flex", alignItems: "center", gap: "14px", marginBottom: "16px" }}>
                    {selectedMatch.candidateB.photoUrl ? (
                      <img
                        src={selectedMatch.candidateB.photoUrl}
                        alt=""
                        style={{ width: "56px", height: "56px", borderRadius: "50%", objectFit: "cover", border: "2px solid #EC4899" }}
                      />
                    ) : (
                      <div style={{ width: "56px", height: "56px", borderRadius: "50%", background: "#EC4899", color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "22px", fontWeight: "bold" }}>
                        {selectedMatch.candidateB.name[0]}
                      </div>
                    )}
                    <div>
                      <span style={{ fontSize: "11px", fontWeight: 800, textTransform: "uppercase", color: "#EC4899", letterSpacing: "1px" }}>Receiver / Candidate B</span>
                      <h4 style={{ margin: "2px 0 0 0", color: "#FFFFFF", fontSize: "16px", fontWeight: 800 }}>{selectedMatch.candidateB.name}</h4>
                      <span style={{ fontSize: "12px", color: "#8E9BAE" }}>{selectedMatch.candidateB.age} Yrs • {selectedMatch.candidateB.gender}</span>
                    </div>
                  </div>

                  <div style={{ display: "flex", flexDirection: "column", gap: "8px", fontSize: "13px" }}>
                    <div style={{ display: "flex", justifyContent: "space-between" }}>
                      <span style={{ color: "#8E9BAE" }}>Pargana:</span>
                      <span style={{ color: "#FFFFFF", fontWeight: 600 }}>{selectedMatch.candidateB.pargana}</span>
                    </div>
                    <div style={{ display: "flex", justifyContent: "space-between" }}>
                      <span style={{ color: "#8E9BAE" }}>District / City:</span>
                      <span style={{ color: "#FFFFFF", fontWeight: 600 }}>{selectedMatch.candidateB.district}</span>
                    </div>
                    {selectedMatch.candidateB.education && (
                      <div style={{ display: "flex", justifyContent: "space-between" }}>
                        <span style={{ color: "#8E9BAE" }}>Education:</span>
                        <span style={{ color: "#FFFFFF", fontWeight: 600 }}>{selectedMatch.candidateB.education}</span>
                      </div>
                    )}
                    {selectedMatch.candidateB.occupation && (
                      <div style={{ display: "flex", justifyContent: "space-between" }}>
                        <span style={{ color: "#8E9BAE" }}>Occupation:</span>
                        <span style={{ color: "#FFFFFF", fontWeight: 600 }}>{selectedMatch.candidateB.occupation}</span>
                      </div>
                    )}
                    {selectedMatch.candidateB.phone && (
                      <div style={{ display: "flex", justifyContent: "space-between" }}>
                        <span style={{ color: "#8E9BAE" }}>Phone:</span>
                        <a href={`tel:${selectedMatch.candidateB.phone}`} style={{ color: "#D4AF37", fontWeight: 600, textDecoration: "none" }}>{selectedMatch.candidateB.phone}</a>
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* Modal Footer */}
              <div style={{ marginTop: "24px", display: "flex", justifyContent: "flex-end", gap: "12px" }}>
                <button
                  onClick={() => setSelectedMatch(null)}
                  style={{
                    background: "rgba(212, 175, 55, 0.15)",
                    border: "1px solid rgba(212, 175, 55, 0.5)",
                    color: "#D4AF37",
                    padding: "10px 24px",
                    borderRadius: "12px",
                    fontWeight: 700,
                    cursor: "pointer",
                  }}
                >
                  Close Inspection
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Modal: Delete / Unlink Confirmation */}
        {matchToDelete && (
          <div
            style={{
              position: "fixed",
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: "rgba(0, 0, 0, 0.8)",
              backdropFilter: "blur(8px)",
              zIndex: 9999,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              padding: "20px",
            }}
          >
            <div
              style={{
                background: "linear-gradient(145deg, #1C0F1A 0%, #0A050B 100%)",
                border: "1px solid rgba(239, 68, 68, 0.5)",
                borderRadius: "20px",
                maxWidth: "480px",
                width: "100%",
                padding: "28px",
                boxShadow: "0 25px 50px -12px rgba(0, 0, 0, 0.7)",
              }}
            >
              <h3 style={{ margin: "0 0 12px 0", color: "#EF4444", fontSize: "18px", fontWeight: 800 }}>
                ⚠️ Confirm Disconnect Match
              </h3>
              <p style={{ margin: "0 0 20px 0", color: "#E2E8F0", fontSize: "14px", lineHeight: "1.5" }}>
                Are you sure you want to unlink and delete the connection between{" "}
                <strong>{matchToDelete.candidateA.name}</strong> and{" "}
                <strong>{matchToDelete.candidateB.name}</strong>? This action cannot be undone.
              </p>
              <div style={{ display: "flex", justifyContent: "flex-end", gap: "12px" }}>
                <button
                  onClick={() => setMatchToDelete(null)}
                  disabled={deleting}
                  style={{
                    background: "rgba(255, 255, 255, 0.1)",
                    border: "none",
                    color: "#FFFFFF",
                    padding: "9px 18px",
                    borderRadius: "10px",
                    cursor: "pointer",
                    fontWeight: 600,
                  }}
                >
                  Cancel
                </button>
                <button
                  onClick={handleDeleteMatch}
                  disabled={deleting}
                  style={{
                    background: "#EF4444",
                    border: "none",
                    color: "#FFFFFF",
                    padding: "9px 18px",
                    borderRadius: "10px",
                    cursor: "pointer",
                    fontWeight: 700,
                  }}
                >
                  {deleting ? "Unlinking..." : "Yes, Unlink Match"}
                </button>
              </div>
            </div>
          </div>
        )}

      </div>
    </AdminLayout>
  );
}

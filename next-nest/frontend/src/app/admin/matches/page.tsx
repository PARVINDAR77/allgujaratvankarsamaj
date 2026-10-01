"use client";

import React, { useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatCard } from "@/components/admin/StatCard";

const mockMatches = [
  { id: "m-1", candidateA: "Ramesh Vankar (35 Pargana)", candidateB: "Priyankaben Solanki (14 Pargana)", matchScore: "94%", status: "MUTUAL_INTEREST", date: "2026-09-08" },
  { id: "m-2", candidateA: "Hemantkumar Vankar (16 Pargana)", candidateB: "Hiralben Parmar (27 Pargana)", matchScore: "89%", status: "ACCEPTED", date: "2026-09-09" },
  { id: "m-3", candidateA: "Vikram Vankar (35 Pargana)", candidateB: "Aarti Vankar (27 Pargana)", matchScore: "82%", status: "PENDING", date: "2026-09-10" },
];

export default function AdminMatchesPage() {
  const [filter, setFilter] = useState("ALL");

  return (
    <AdminLayout title="Matchmaking Management">
      <div style={{ display: "flex", flexDirection: "column", gap: "28px", paddingBottom: "48px" }}>
        
        {/* Title Header */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div>
            <h1 style={{ fontSize: "28px", fontWeight: "900", color: "#FFFFFF", margin: "0 0 8px 0", display: "flex", alignItems: "center", gap: "12px", letterSpacing: "-0.5px" }}>
              <span style={{ filter: "drop-shadow(0 0 8px rgba(212,175,55,0.8))" }}>💞</span> 
              Matchmaking Control Center
            </h1>
            <p style={{ color: "#8E9BAE", fontSize: "14px", margin: 0, fontWeight: 500 }}>
              Monitor mutual interests, shortlists, and connectivity across the community
            </p>
          </div>
        </div>

        {/* Dynamic KPI Cards */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))", gap: "20px" }}>
          <StatCard title="Total Matches" value={142} icon="💍" change="Platform Wide" isPositive />
          <StatCard title="Mutual Interests" value={38} icon="❤️" change="Pending Review" isPositive />
          <StatCard title="Accepted Proposals" value={84} icon="🎉" change="Successful" isPositive />
          <StatCard title="Rejected/Pass" value={20} icon="🚫" change="Archived" isPositive={false} />
        </div>

        {/* Filter Controls Bar */}
        <div 
          style={{ 
            background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
            backdropFilter: "blur(20px)",
            padding: "20px", 
            borderRadius: "16px", 
            border: "1px solid rgba(212, 175, 55, 0.3)", 
            display: "flex", 
            gap: "16px", 
            alignItems: "center",
            boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.05)"
          }}
        >
          <span style={{ color: "#D4AF37", fontWeight: "800", fontSize: "14px", textTransform: "uppercase", letterSpacing: "1px" }}>Filter Status:</span>
          <div style={{ display: "flex", gap: "10px", flexWrap: "wrap" }}>
            {["ALL", "MUTUAL_INTEREST", "PENDING", "ACCEPTED"].map((st) => (
              <button
                key={st}
                onClick={() => setFilter(st)}
                style={{
                  background: filter === st ? "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)" : "rgba(4, 16, 38, 0.6)",
                  color: filter === st ? "#041026" : "#8E9BAE",
                  border: filter === st ? "none" : "1px solid rgba(212, 175, 55, 0.3)",
                  padding: "8px 20px",
                  borderRadius: "10px",
                  fontWeight: "800",
                  fontSize: "12px",
                  cursor: "pointer",
                  transition: "all 0.3s ease",
                  boxShadow: filter === st ? "0 4px 15px rgba(212, 175, 55, 0.3)" : "none",
                  textTransform: "uppercase",
                  letterSpacing: "0.5px"
                }}
                className={filter !== st ? "hover:border-[#D4AF37] hover:text-[#D4AF37]" : ""}
              >
                {st.replace("_", " ")}
              </button>
            ))}
          </div>
        </div>

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
            <table style={{ width: "100%", borderCollapse: "collapse", textAlign: "left", minWidth: "1000px" }}>
              <thead>
                <tr style={{ backgroundColor: "rgba(4, 16, 38, 0.8)", borderBottom: "1px solid rgba(212, 175, 55, 0.3)" }}>
                  <th style={{ padding: "18px 24px", color: "#D4AF37", fontSize: "11px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1.5px" }}>Candidate A</th>
                  <th style={{ padding: "18px 24px", color: "#D4AF37", fontSize: "11px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1.5px", textAlign: "center" }}>Match</th>
                  <th style={{ padding: "18px 24px", color: "#D4AF37", fontSize: "11px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1.5px" }}>Candidate B</th>
                  <th style={{ padding: "18px 24px", color: "#D4AF37", fontSize: "11px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1.5px" }}>Compatibility</th>
                  <th style={{ padding: "18px 24px", color: "#D4AF37", fontSize: "11px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1.5px" }}>Status</th>
                  <th style={{ padding: "18px 24px", color: "#D4AF37", fontSize: "11px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "1.5px", textAlign: "right" }}>Match Date</th>
                </tr>
              </thead>
              <tbody>
                {mockMatches
                  .filter((m) => filter === "ALL" || m.status === filter)
                  .map((m) => (
                  <tr key={m.id} style={{ borderBottom: "1px solid rgba(212, 175, 55, 0.1)", transition: "all 0.2s ease" }} className="hover:bg-[rgba(212,175,55,0.05)]">
                    <td style={{ padding: "20px 24px" }}>
                      <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                        <div
                          style={{
                            width: "40px",
                            height: "40px",
                            borderRadius: "50%",
                            background: "linear-gradient(135deg, rgba(59, 130, 246, 0.2) 0%, rgba(4, 16, 38, 0.9) 100%)",
                            border: "1px solid rgba(59, 130, 246, 0.4)",
                            color: "#3B82F6",
                            fontWeight: 800,
                            fontSize: "16px",
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                          }}
                        >
                          {m.candidateA[0]}
                        </div>
                        <div>
                          <div style={{ fontWeight: "800", color: "#FFFFFF", fontSize: "14px" }}>
                            {m.candidateA.split("(")[0].trim()}
                          </div>
                          <div style={{ fontSize: "12px", color: "#8E9BAE", marginTop: "2px" }}>
                            {m.candidateA.match(/\((.*?)\)/)?.[1]}
                          </div>
                        </div>
                      </div>
                    </td>

                    <td style={{ padding: "20px 24px", textAlign: "center" }}>
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

                    <td style={{ padding: "20px 24px" }}>
                      <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                        <div
                          style={{
                            width: "40px",
                            height: "40px",
                            borderRadius: "50%",
                            background: "linear-gradient(135deg, rgba(236, 72, 153, 0.2) 0%, rgba(4, 16, 38, 0.9) 100%)",
                            border: "1px solid rgba(236, 72, 153, 0.4)",
                            color: "#EC4899",
                            fontWeight: 800,
                            fontSize: "16px",
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                          }}
                        >
                          {m.candidateB[0]}
                        </div>
                        <div>
                          <div style={{ fontWeight: "800", color: "#FFFFFF", fontSize: "14px" }}>
                            {m.candidateB.split("(")[0].trim()}
                          </div>
                          <div style={{ fontSize: "12px", color: "#8E9BAE", marginTop: "2px" }}>
                            {m.candidateB.match(/\((.*?)\)/)?.[1]}
                          </div>
                        </div>
                      </div>
                    </td>

                    <td style={{ padding: "20px 24px" }}>
                      <div style={{ display: "inline-flex", alignItems: "center", gap: "8px", background: "linear-gradient(90deg, rgba(212, 175, 55, 0.1) 0%, transparent 100%)", padding: "4px 12px", borderRadius: "20px", borderLeft: "2px solid #D4AF37" }}>
                        <span style={{ color: "#D4AF37", fontWeight: 900, fontSize: "16px" }}>{m.matchScore}</span>
                      </div>
                    </td>

                    <td style={{ padding: "20px 24px" }}>
                      <span style={{
                        display: "inline-flex",
                        alignItems: "center",
                        gap: "6px",
                        padding: "6px 12px",
                        borderRadius: "8px",
                        fontSize: "11px",
                        fontWeight: "800",
                        textTransform: "uppercase",
                        letterSpacing: "0.5px",
                        backgroundColor: 
                          m.status === "ACCEPTED" ? "rgba(16, 185, 129, 0.15)" : 
                          m.status === "MUTUAL_INTEREST" ? "rgba(236, 72, 153, 0.15)" : 
                          "rgba(245, 158, 11, 0.15)",
                        color: 
                          m.status === "ACCEPTED" ? "#10B981" : 
                          m.status === "MUTUAL_INTEREST" ? "#EC4899" : 
                          "#F59E0B",
                        border: `1px solid ${
                          m.status === "ACCEPTED" ? "rgba(16, 185, 129, 0.3)" : 
                          m.status === "MUTUAL_INTEREST" ? "rgba(236, 72, 153, 0.3)" : 
                          "rgba(245, 158, 11, 0.3)"}`
                      }}>
                        {m.status === "ACCEPTED" ? "✓" : m.status === "MUTUAL_INTEREST" ? "💞" : "⏳"} 
                        {m.status.replace("_", " ")}
                      </span>
                    </td>

                    <td style={{ padding: "20px 24px", textAlign: "right", color: "#E2E8F0", fontSize: "13px", fontWeight: 600 }}>
                      {m.date}
                    </td>
                  </tr>
                ))}
                
                {mockMatches.filter((m) => filter === "ALL" || m.status === filter).length === 0 && (
                  <tr>
                    <td colSpan={6} style={{ padding: "60px", textAlign: "center" }}>
                      <div style={{ fontSize: "48px", marginBottom: "16px", opacity: 0.8 }}>📭</div>
                      <p style={{ color: "#FFFFFF", fontSize: "16px", fontWeight: 800, marginBottom: "8px" }}>No Matches Found</p>
                      <p style={{ color: "#8E9BAE", fontSize: "14px", margin: 0 }}>There are no matches currently matching this filter.</p>
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}

"use client";

import React, { useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";

const mockVerifications = [
  { id: "v-1", name: "Hemantkumar Vankar", type: "Govt ID & Passport Photo", pargana: "16 Pargana", date: "2026-09-09", status: "VERIFIED" },
  { id: "v-2", name: "Hiralben Parmar", type: "Family Address & Mosal Proof", pargana: "27 Pargana", date: "2026-09-09", status: "VERIFIED" },
  { id: "v-3", name: "Mehul Vankar", type: "Higher Education Degree", pargana: "35 Pargana", date: "2026-09-10", status: "PENDING" },
  { id: "v-4", name: "Aarti Vankar", type: "Profile Photo Verification", pargana: "14 Pargana", date: "2026-09-10", status: "PENDING" },
  { id: "v-5", name: "Sanjay Solanki", type: "Income & Salary Slip", pargana: "35 Pargana", date: "2026-09-08", status: "REJECTED" },
];

export default function AdminVerificationsPage() {
  const [items, setItems] = useState(mockVerifications);
  const [filter, setFilter] = useState("ALL");
  const [search, setSearch] = useState("");

  const updateStatus = (id: string, status: string) => {
    setItems((prev) => prev.map((item) => (item.id === id ? { ...item, status } : item)));
  };

  const filteredItems = items.filter((item) => {
    const matchesSearch = item.name.toLowerCase().includes(search.toLowerCase()) || item.type.toLowerCase().includes(search.toLowerCase());
    const matchesFilter = filter === "ALL" || item.status === filter;
    return matchesSearch && matchesFilter;
  });

  return (
    <AdminLayout title="Verification Management" subtitle="Approve or reject submitted community profile proofs">
      <div style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
        {/* Search & Status Filter Bar */}
        <div
          style={{
            backgroundColor: "rgba(13, 27, 50, 0.85)",
            backdropFilter: "blur(16px)",
            border: "1px solid rgba(212, 175, 55, 0.25)",
            borderRadius: "16px",
            padding: "18px 24px",
            display: "flex",
            flexWrap: "wrap",
            justifyContent: "space-between",
            alignItems: "center",
            gap: "16px",
            boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4)",
          }}
        >
          <div style={{ position: "relative", minWidth: "300px" }}>
            <input
              type="text"
              placeholder="Search member or document type..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              style={{
                width: "100%",
                backgroundColor: "#041026",
                border: "1px solid rgba(212, 175, 55, 0.35)",
                borderRadius: "12px",
                padding: "10px 14px 10px 38px",
                fontSize: "12px",
                color: "#FFFFFF",
                outline: "none",
              }}
            />
            <span style={{ position: "absolute", left: "12px", top: "11px", fontSize: "13px", color: "#8E9BAE" }}>🔍</span>
          </div>

          <div style={{ display: "flex", gap: "8px" }}>
            {["ALL", "PENDING", "VERIFIED", "REJECTED"].map((tab) => (
              <button
                key={tab}
                onClick={() => setFilter(tab)}
                style={{
                  padding: "8px 16px",
                  borderRadius: "12px",
                  fontSize: "12px",
                  fontWeight: 800,
                  border: "none",
                  cursor: "pointer",
                  backgroundColor: filter === tab ? "#D4AF37" : "#041026",
                  color: filter === tab ? "#041026" : "#8E9BAE",
                  boxShadow: filter === tab ? "0 4px 12px rgba(212, 175, 55, 0.3)" : "none",
                }}
                className="transition-all"
              >
                {tab}
              </button>
            ))}
          </div>
        </div>

        {/* Verification Submissions Table */}
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
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "20px" }}>
            <h3 style={{ fontSize: "16px", fontWeight: 800, color: "#FFFFFF", display: "flex", alignItems: "center", gap: "8px", margin: 0 }}>
              <span>🛡️</span> Verification Review Requests
            </h3>
            <span
              style={{
                fontSize: "11px",
                color: "#D4AF37",
                fontWeight: 800,
                backgroundColor: "#041026",
                padding: "6px 14px",
                borderRadius: "20px",
                border: "1px solid rgba(212, 175, 55, 0.3)",
              }}
            >
              Pending Queue: {items.filter(i => i.status === "PENDING").length}
            </span>
          </div>

          <div style={{ borderRadius: "12px", overflow: "hidden", border: "1px solid rgba(212, 175, 55, 0.2)" }}>
            <table style={{ width: "100%", textAlign: "left", fontSize: "12px", color: "#FFFFFF", borderCollapse: "collapse" }}>
              <thead>
                <tr style={{ backgroundColor: "#041026", borderBottom: "1px solid rgba(212, 175, 55, 0.3)" }}>
                  <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Member Name</th>
                  <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Verification Type</th>
                  <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Pargana</th>
                  <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Submitted Date</th>
                  <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Status</th>
                  <th style={{ padding: "14px 18px", fontSize: "10px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", textAlign: "right" }}>Actions</th>
                </tr>
              </thead>
              <tbody style={{ backgroundColor: "#0D1B32" }}>
                {filteredItems.map((item) => (
                  <tr key={item.id} style={{ borderBottom: "1px solid rgba(212, 175, 55, 0.1)" }} className="hover:bg-[#041026]/70 transition-colors">
                    <td style={{ padding: "14px 18px", fontWeight: 700, color: "#FFFFFF" }}>{item.name}</td>
                    <td style={{ padding: "14px 18px", color: "#8E9BAE", fontWeight: 500 }}>{item.type}</td>
                    <td style={{ padding: "14px 18px", color: "#FFFFFF", fontWeight: 600 }}>{item.pargana}</td>
                    <td style={{ padding: "14px 18px", color: "#CBD5E1", fontFamily: "monospace", fontSize: "11px" }}>{item.date}</td>
                    <td style={{ padding: "14px 18px" }}>
                      <StatusBadge status={item.status} />
                    </td>
                    <td style={{ padding: "14px 18px", textAlign: "right" }}>
                      <div style={{ display: "flex", justifyContent: "flex-end", gap: "8px" }}>
                        <button
                          onClick={() => updateStatus(item.id, "VERIFIED")}
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
                          onClick={() => updateStatus(item.id, "REJECTED")}
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


